//
//  TYBarChartView.m
//  CandlerstickCharts
//
//  k线图
//  Created by xdliu on 16/8/11.
//  Copyright © 2016年 liuxd. All rights reserved.
//

#import "TYKLineChartView.h"
#import "KLineListTransformer.h"
#import "UIBezierPath+curved.h"
#import "TipBoardView.h"

#define RGB(r, g, b)    [UIColor colorWithRed:(r/255.0f) green:(g/255.0f) blue:(b/255.0f) alpha:1.0]

@interface TYKLineChartView ()

@property (nonatomic, assign) CGFloat yAxisHeight;

@property (nonatomic, assign) CGFloat xAxisWidth;

@property (nonatomic, strong) NSArray *contexts;

@property (nonatomic, strong) NSArray *dates;

@property (nonatomic, assign) NSInteger startDrawIndex;

@property (nonatomic, assign) NSInteger kLineDrawNum;

@property (nonatomic, assign) CGFloat maxHighValue;

@property (nonatomic, assign) CGFloat minLowValue;

@property (nonatomic, assign) CGFloat maxVolValue;

@property (nonatomic, assign) CGFloat minVolValue;

//手势
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;

@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;

@property (nonatomic, strong) UIPinchGestureRecognizer *pinchGesture;

@property (nonatomic, strong) UILongPressGestureRecognizer *longGesture;

@property (nonatomic, assign) CGFloat lastPanScale;

//坐标轴
@property (nonatomic, strong) NSMutableDictionary *xAxisContext;

//十字线
@property (nonatomic, strong) UIView *verticalLine;     //垂直
@property (nonatomic, strong) UIView *horizontalLine;   //水平

@property (nonatomic, strong) UIView *barVerticalLine;

@property (nonatomic, strong) TipBoardView *tipBoard;

@property (nonatomic, strong) NSTimer *timer;

@end

@implementation TYKLineChartView

#pragma mark - life cycle

- (id)init {
    if (self = [super init]) {
        [self _setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self _setup];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self _setup];
    }
    return self;
}

- (void)_setup {
    self.kLineWidth = 5.0;
    self.kLinePadding = 2.0;
    
    self.barRiseColor = [UIColor colorWithRed:(252/255.0f) green:(80.0f/255.0f) blue:(92.0f/255.0f) alpha:1.0];
    self.barFallColor = [UIColor colorWithRed:(56.0f/255.0f) green:(185.0f/255.0f) blue:(30/255.0f) alpha:1.0];
    
    self.upperShadowColor = self.barFallColor;
    self.lowerShadowColor = self.barFallColor;
    
    self.avgLineWidth = 0.8;
    
    self.avgLineMA5Color = [UIColor colorWithRed:(135/255.0f) green:(186/255.0f) blue:(215/255.0f) alpha:1.0];
    self.avgLineMA10Color = [UIColor colorWithRed:(224/255.0f) green:(132/255.0f) blue:(161/255.0f) alpha:1.0];
    self.avgLineMA20Color = [UIColor colorWithRed:(137/255.0f) green:(204/255.0f) blue:(87/255.0f) alpha:1.0];
    
    self.axisShadowColor = [UIColor colorWithRed:223/255.0f green:223/255.0f blue:223/255.0f alpha:1.0];
    self.axisShadowWidth = 0.8;
    
    self.separatorColor = [UIColor colorWithRed:230/255.0f green:230/255.0f blue:230/255.0f alpha:1.0];
    self.separatorWidth = 0.5;
    
    self.yAxisTitleFont = [UIFont systemFontOfSize:8.0];
    self.yAxisTitleColor = [UIColor colorWithRed:(130/255.0f) green:(130/255.0f) blue:(130/255.0f) alpha:1.0];
    
    self.scrollEnable = YES;
    
    self.zoomEnable = YES;
    
    self.showAvgLine = YES;
    
    self.showBarChart = YES;
    
    self.minKLineWidth = 2.0;
    
    self.lastPanScale = 1.0;
    
    self.xAxisContext = [NSMutableDictionary new];
    
    //添加手势
    [self addGestures];
}

/**
 *  添加手势
 */
- (void)addGestures {
    [self addGestureRecognizer:self.tapGesture];
    
    [self addGestureRecognizer:self.panGesture];
    
    [self addGestureRecognizer:self.pinchGesture];
    
    [self addGestureRecognizer:self.longGesture];
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    if (!self.contexts || self.contexts.count == 0) {
        return;
    }
    //x坐标轴长度
    self.xAxisWidth = rect.size.width - self.leftMargin - self.rightMargin;
    
    //y坐标轴高度
    self.yAxisHeight = rect.size.height - self.bottomMargin - self.topMargin;
    
    //坐标轴
    [self drawAxisInRect:rect];
    
    //k线
    [self drawKLine];
    
    //均线
    [self drawAvgLine];
    
    //交易量
    [self drawVol];
}

#pragma mark - render UI

- (void)drawChartWithData:(NSDictionary *)data {
    self.contexts = data[kCandlerstickChartsContext];
    self.dates = data[kCandlerstickChartsDate];
    
    self.kLineDrawNum = (int)((self.frame.size.width - self.leftMargin - self.rightMargin) / (self.kLineWidth + self.kLinePadding));
    
    self.startDrawIndex = self.contexts.count - self.kLineDrawNum + 1 == 0 ? 0 : self.contexts.count - self.kLineDrawNum + 1;
    
    /**
     *  最高价,最低价
     */
    self.maxHighValue = [data[kCandlerstickChartsMaxHigh] floatValue];
    self.minLowValue = [data[kCandlerstickChartsMinLow] floatValue];
    float avgValue = (self.maxHighValue - self.minLowValue) / 6.0;
    self.maxHighValue += avgValue;
    self.minLowValue -= avgValue;
    
    /**
     *  成交量最大之，最小值
     */
    self.maxVolValue = [data[kCandlerstickChartsMaxVol] floatValue];
    self.minVolValue = [data[kCandlerstickChartsMinVol] floatValue];
    
    [self setNeedsDisplay];
}

#pragma mark - event reponse

- (void)tapEvent:(UITapGestureRecognizer *)tapGesture {
    //[self longPressEvent:nil];
}

- (void)panEvent:(UIPanGestureRecognizer *)panGesture {
    if (!self.scrollEnable) {
        return;
    }
    
    CGPoint touchPoint = [panGesture translationInView:self];
    NSInteger offsetIndex = fabs(touchPoint.x/8.0);
    
    if (touchPoint.x > 0) {
        self.startDrawIndex -= offsetIndex;
        
        self.startDrawIndex = self.startDrawIndex < 0 ? 0 : self.startDrawIndex;
    } else {
        self.startDrawIndex += offsetIndex;
        
        if (self.startDrawIndex + self.kLineDrawNum - 1 > self.contexts.count) {
            self.startDrawIndex = self.contexts.count - self.kLineDrawNum + 1;
        }
    }
    
    [self setNeedsDisplay];
    [panGesture setTranslation:CGPointMake(0, 0) inView:self];
}

- (void)pinchEvent:(UIPinchGestureRecognizer *)pinchEvent {
    if (!self.zoomEnable) {
        return;
    }
    
    CGFloat scale = pinchEvent.scale - self.lastPanScale + 1;
    
    self.kLineWidth = self.kLineWidth*scale < 1.5 ? 1.5 : self.kLineWidth*scale;
    
    if (self.kLineWidth > 25) {
        self.kLineWidth = 25.0f;
    }
    
    self.kLineDrawNum = (int)((self.frame.size.width - self.leftMargin - self.rightMargin) / (self.kLineWidth + self.kLinePadding)) + 1;
    
    if (self.startDrawIndex + self.kLineDrawNum - 1 > self.contexts.count) {
        self.startDrawIndex = self.contexts.count - self.kLineDrawNum + 1;
    }
    
    self.lastPanScale = pinchEvent.scale;
    
    [self setNeedsDisplay];
}

- (void)longPressEvent:(UILongPressGestureRecognizer *)longGesture {
    if (longGesture.state == UIGestureRecognizerStateEnded) {
        self.horizontalLine.hidden = YES;
        self.verticalLine.hidden = YES;
        self.barVerticalLine.hidden = YES;
        CATransition *animation = [CATransition animation];
        animation.type = kCATransitionFade;
        animation.duration = 3.5;
        [self.tipBoard.layer addAnimation:animation forKey:nil];
        self.tipBoard.hidden = YES;
    } else {
        CGPoint touchPoint = [longGesture locationInView:self];
        [self.xAxisContext enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, NSNumber *obj, BOOL *stop) {
            if (_kLinePadding+_kLineWidth >= ([obj floatValue] - touchPoint.x) && ([obj floatValue] - touchPoint.x) > 0) {
                NSInteger index = [key integerValue];
                
                // 获取对应的k线数据
                NSArray *line = _contexts[index];
                CGFloat open = [line[0] floatValue];
                CGFloat close = [line[3] floatValue];
                CGFloat scale = (self.maxHighValue - self.minLowValue) / self.yAxisHeight;
                CGFloat xAxis = [obj floatValue] - _kLineWidth / 2.0 + self.leftMargin;
                CGFloat yAxis = self.yAxisHeight - (open - self.minLowValue)/scale + self.topMargin;
                
                if ([line[1] floatValue] > [line[2] floatValue]) {
                    yAxis = self.yAxisHeight - (close - self.minLowValue)/scale + self.topMargin;
                }
                
                [self configUIWithPoint:CGPointMake(xAxis, yAxis)];
                
                *stop = YES;
            }
        }];
    }
}

- (void)configUIWithPoint:(CGPoint)point {
    self.verticalLine.hidden = NO;
    CGRect frame = self.verticalLine.frame;
    frame.origin.x = point.x;
    self.verticalLine.frame = frame;
    
    self.horizontalLine.hidden = NO;
    frame = self.horizontalLine.frame;
    frame.origin.y = point.y;
    self.horizontalLine.frame = frame;
    
    [self bringSubviewToFront:self.horizontalLine];
    [self bringSubviewToFront:self.verticalLine];
    
    self.barVerticalLine.hidden = NO;
    frame = self.barVerticalLine.frame;
    frame.origin.x = point.x;
    self.barVerticalLine.frame = frame;
    
    [self bringSubviewToFront:self.barVerticalLine];
    
    self.tipBoard.hidden = NO;
    [self.tipBoard.layer removeAllAnimations];
    [self.tipBoard showForTipPoint:CGPointMake(point.x, point.y)];
    [self bringSubviewToFront:self.tipBoard];
}

#pragma mark - private methods

/**
 *  网格（坐标图）
 */
- (void)drawAxisInRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //k线边框
    CGRect strokeRect = CGRectMake(self.leftMargin, self.topMargin, self.xAxisWidth, self.yAxisHeight);
    CGContextSetLineWidth(context, self.axisShadowWidth);
    CGContextSetStrokeColorWithColor(context, self.axisShadowColor.CGColor);
    CGContextStrokeRect(context, strokeRect);
    
    //k线分割线
    CGFloat avgHeight = strokeRect.size.height/5.0;
    for (int i = 1; i <= 4; i ++) {
        CGContextSetLineWidth(context, self.separatorWidth);
        double lengths[] = {5,5};
        CGContextSetStrokeColorWithColor(context, self.separatorColor.CGColor);
        CGContextSetLineDash(context, 0, lengths, 2);  //画虚线
        
        CGContextBeginPath(context);
        CGContextMoveToPoint(context, self.leftMargin + 1.25, self.topMargin + avgHeight*i);    //开始画线
        CGContextAddLineToPoint(context, rect.size.width  - self.rightMargin - 0.8, self.topMargin + avgHeight*i);
        
        CGContextStrokePath(context);
    }
    
    //这必须把dash给初始化一次，不然会影响其他线条的绘制
    CGContextSetLineDash(context, 0, 0, 0);
    
    //k线y坐标
    CGFloat avgValue = (self.maxHighValue - self.minLowValue) / 5.0;
    for (int i = 0; i < 6; i ++) {
        float yAxisValue = self.maxHighValue - avgValue*i;
        NSAttributedString *attString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%.2f", yAxisValue] attributes:@{NSFontAttributeName:self.yAxisTitleFont, NSForegroundColorAttributeName:self.yAxisTitleColor}];
        CGSize size = [attString boundingRectWithSize:CGSizeMake(self.leftMargin, self.yAxisTitleFont.lineHeight) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
        
        [attString drawInRect:CGRectMake(self.leftMargin - size.width - 2.0f, self.topMargin + avgHeight*i - size.height/2.0, size.width, size.height)];
    }
    
    if (self.showBarChart) {
        //交易量边框
        CGContextSetLineWidth(context, self.axisShadowWidth);
        CGContextSetStrokeColorWithColor(context, self.axisShadowColor.CGColor);
        strokeRect = CGRectMake(self.leftMargin, self.yAxisHeight + self.topMargin + 20.0f, self.xAxisWidth, rect.size.height - self.yAxisHeight - self.topMargin - 20.0f);
        CGContextStrokeRect(context, strokeRect);
        
        NSAttributedString *attString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%.2f", self.maxVolValue/10000.0f] attributes:@{NSFontAttributeName:self.yAxisTitleFont, NSForegroundColorAttributeName:self.yAxisTitleColor}];
        CGSize size = [attString boundingRectWithSize:CGSizeMake(self.leftMargin, self.yAxisTitleFont.lineHeight) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
        
        [attString drawInRect:CGRectMake(self.leftMargin - size.width - 2.0f, self.yAxisHeight + self.topMargin + 20.0f - 2, size.width, size.height)];
        
        attString = [[NSAttributedString alloc] initWithString:@"万" attributes:@{NSFontAttributeName:self.yAxisTitleFont, NSForegroundColorAttributeName:self.yAxisTitleColor}];
        size = [attString boundingRectWithSize:CGSizeMake(self.leftMargin, self.yAxisTitleFont.lineHeight) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
        
        [attString drawInRect:CGRectMake(self.leftMargin - size.width - 2.0f, rect.size.height - size.height, size.width, size.height)];
    }
}

/**
 *  K线
 */
- (void)drawKLine {
    CGFloat scale = (self.maxHighValue - self.minLowValue) / self.yAxisHeight;
    if (scale == 0) {
        return;
    }
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 0.5);
    
    CGFloat xAxis = _kLinePadding;
    [self.xAxisContext removeAllObjects];
    
    for (NSArray *line in [_contexts subarrayWithRange:NSMakeRange(self.startDrawIndex, self.kLineDrawNum - 1)]) {
        [self.xAxisContext setObject:@(xAxis + _kLineWidth) forKey:@([_contexts indexOfObject:line])];
        
        //通过开盘价、收盘价判断颜色
        CGFloat open = [line[0] floatValue];
        CGFloat close = [line[3] floatValue];
        UIColor *fillColor = open > close ? RGB(31, 185, 63.0f) : RGB(232, 50.0f, 52.0f);
        CGContextSetFillColorWithColor(context, fillColor.CGColor);
        
        CGFloat diffValue = fabs(open - close);
        CGFloat maxValue = MAX(open, close);
        CGFloat height = diffValue/scale;
        CGFloat width = _kLineWidth;
        CGFloat yAxis = self.yAxisHeight - (maxValue - self.minLowValue)/scale + self.topMargin;
        
        CGRect rect = CGRectMake(xAxis + self.leftMargin, yAxis, width, height);
        CGContextAddRect(context, rect);
        CGContextFillPath(context);
        
        //上、下影线
        CGFloat highYAxis = self.yAxisHeight - ([line[1] floatValue] - self.minLowValue)/scale;
        CGFloat lowYAxis = self.yAxisHeight - ([line[2] floatValue] - self.minLowValue)/scale;
        CGPoint highPoint = CGPointMake(xAxis + width/2.0 + self.leftMargin, highYAxis + self.topMargin);
        CGPoint lowPoint = CGPointMake(xAxis + width/2.0 + self.leftMargin, lowYAxis + self.topMargin);
        CGContextSetStrokeColorWithColor(context, fillColor.CGColor);
        CGContextBeginPath(context);
        CGContextMoveToPoint(context, highPoint.x, highPoint.y);  //起点坐标
        CGContextAddLineToPoint(context, lowPoint.x, lowPoint.y);   //终点坐标
        CGContextStrokePath(context);
        
        xAxis += width + _kLinePadding;
    }
}

/**
 *  均线图
 */
- (void)drawAvgLine {
    if (!self.showAvgLine) {
        return;
    }
    
    NSArray<UIColor *> *colors = @[self.avgLineMA5Color, self.avgLineMA10Color, self.avgLineMA20Color];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, self.avgLineWidth);
    
    for (int i = 0; i < 3; i ++) {
        CGContextSetStrokeColorWithColor(context, colors[i].CGColor);
        CGPathRef path = [self maGraphPathForContextAtIndex:(i + 5)];
        CGContextAddPath(context, path);
        CGContextStrokePath(context);
    }
}

/**
 *  均线path
 */
- (CGPathRef)maGraphPathForContextAtIndex:(NSInteger)index {
    UIBezierPath *path;
    
    CGFloat xAxis = self.leftMargin + 1/2.0*_kLineWidth + _kLinePadding;
    CGFloat scale = (self.maxHighValue - self.minLowValue) / self.yAxisHeight;
    
    if (scale != 0) {
        path = [UIBezierPath bezierPath];
        for (NSArray *line in [_contexts subarrayWithRange:NSMakeRange(self.startDrawIndex, self.kLineDrawNum - 1)]) {
            CGFloat maValue = [line[index] floatValue];
            CGFloat yAxis = self.yAxisHeight - (maValue - self.minLowValue)/scale + self.topMargin;
            CGPoint maPoint = CGPointMake(xAxis, yAxis);
            
            if (xAxis == (self.leftMargin + 1/2.0*_kLineWidth + _kLinePadding)) {
                [path moveToPoint:maPoint];
            } else {
                [path addLineToPoint:maPoint];
            }
            
            xAxis += self.kLineWidth + self.kLinePadding;
        }
    }
    
    //圆滑
    path = [path smoothedPathWithGranularity:15];
    
    return path.CGPath;
}

/**
 *  交易量
 */
- (void)drawVol {
    if (!self.showBarChart) {
        return;
    }
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, self.kLineWidth);
    
    CGRect rect = self.bounds;
    
    CGFloat xAxis = _kLinePadding + _leftMargin;
    
    CGFloat boxYOrigin = self.topMargin + self.yAxisHeight + 20.0;
    CGFloat boxHeight = rect.size.height - boxYOrigin;
    CGFloat scale = self.maxVolValue/boxHeight;
    
    for (NSArray *line in [_contexts subarrayWithRange:NSMakeRange(self.startDrawIndex, self.kLineDrawNum - 1)]) {
        CGFloat open = [line[0] floatValue];
        CGFloat close = [line[3] floatValue];
        UIColor *fillColor = open > close ? RGB(31, 185, 63.0f) : RGB(232, 50.0f, 52.0f);
        CGContextSetFillColorWithColor(context, fillColor.CGColor);
        
        CGFloat height = [line[4] floatValue]/scale;
        CGRect pathRect = CGRectMake(xAxis, boxYOrigin + boxHeight - height, self.kLineWidth, height);
        CGContextAddRect(context, pathRect);
        CGContextFillPath(context);
        
        xAxis += _kLineWidth + _kLinePadding;
    }
}

#pragma mark -  public methods

- (void)clear {
    self.contexts = nil;
    self.dates = nil;
    [self setNeedsDisplay];
}

#pragma mark - getters

- (UIView *)verticalLine {
    if (!_verticalLine) {
        _verticalLine = [[UIView alloc] initWithFrame:CGRectMake(self.leftMargin, self.topMargin, 0.5, self.yAxisHeight)];
        _verticalLine.backgroundColor = [UIColor redColor];
        [self addSubview:_verticalLine];
    }
    return _verticalLine;
}

- (UIView *)horizontalLine {
    if (!_horizontalLine) {
        _horizontalLine = [[UIView alloc] initWithFrame:CGRectMake(self.leftMargin, self.topMargin, self.xAxisWidth, 0.5)];
        _horizontalLine.backgroundColor = [UIColor blueColor];
        [self addSubview:_horizontalLine];
    }
    return _horizontalLine;
}

- (UIView *)barVerticalLine {
    if (!_barVerticalLine) {
        _barVerticalLine = [[UIView alloc] initWithFrame:CGRectMake(self.leftMargin, self.topMargin + self.yAxisHeight + 20.0f, 0.5, self.frame.size.height - (self.topMargin + self.yAxisHeight + 20.0f))];
        _barVerticalLine.backgroundColor = [UIColor redColor];
        [self addSubview:_barVerticalLine];
    }
    return _barVerticalLine;
}

- (TipBoardView *)tipBoard {
    if (!_tipBoard) {
        _tipBoard = [[TipBoardView alloc] initWithFrame:CGRectMake(self.leftMargin, self.topMargin, 80.0f, 50.0f)];
        _tipBoard.backgroundColor = [UIColor clearColor];
        [self addSubview:_tipBoard];
    }
    return _tipBoard;
}

- (UITapGestureRecognizer *)tapGesture {
    if (!_tapGesture) {
        _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapEvent:)];
    }
    return _tapGesture;
}

- (UIPanGestureRecognizer *)panGesture {
    if (!_panGesture) {
        _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panEvent:)];
    }
    return _panGesture;
}

- (UIPinchGestureRecognizer *)pinchGesture {
    if (!_pinchGesture) {
        _pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchEvent:)];
    }
    return _pinchGesture;
}

- (UILongPressGestureRecognizer *)longGesture {
    if (!_longGesture) {
        _longGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressEvent:)];
    }
    return _longGesture;
}

#pragma mark - setters 

- (void)setKLineDrawNum:(NSInteger)kLineDrawNum {
    if (kLineDrawNum  < 0) {
        _kLineDrawNum = 0;
    }
    
    _kLineDrawNum = self.contexts.count > 0 && kLineDrawNum < self.contexts.count ? kLineDrawNum : self.contexts.count;
}

@end
