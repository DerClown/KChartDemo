//
//  TYBarChartView.m
//  CandlerstickCharts
//
//  k线图
//  Created by xdliu on 16/8/11.
//  Copyright © 2016年 liuxd. All rights reserved.
//

#import "KLineChartView.h"
#import "KLineListTransformer.h"
#import "UIBezierPath+curved.h"
#import "KLineTipBoardView.h"
#import "UIColor+Ext.h"
#import "MATipView.h"

NSString *const KLineKeyStartUserInterfaceNotification = @"KLineKeyStartUserInterfaceNotification";
NSString *const KLineKeyEndOfUserInterfaceNotification = @"KLineKeyEndOfUserInterfaceNotification";

@interface KLineChartView ()

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
@property (nonatomic, strong) UIView *verticalCrossLine;     //垂直十字线
@property (nonatomic, strong) UIView *horizontalCrossLine;   //水平十字线

@property (nonatomic, strong) UIView *barVerticalLine;

@property (nonatomic, strong) KLineTipBoardView *tipBoard;

@property (nonatomic, strong) MATipView *maTipView;

//时间
@property (nonatomic, strong) UILabel *timeLbl;
//价格
@property (nonatomic, strong) UILabel *priceLbl;

//实时数据提示按钮
@property (nonatomic, strong) UIButton *realDataTipBtn;

//交互中， 默认NO
@property (nonatomic, assign) BOOL interactive;
//更新临时存储
@property (nonatomic, strong) NSMutableArray *updateTempContexts;
@property (nonatomic, strong) NSMutableArray *updateTempDates;
@property (nonatomic, assign) CGFloat updateTempMaxHigh;
@property (nonatomic, assign) CGFloat updateTempMaxVol;

@end

@implementation KLineChartView

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
    self.positiveLineColor = [UIColor colorWithRed:(31/255.0f) green:(185/255.0f) blue:(63.0f/255.0f) alpha:1.0];
    self.negativeLineColor = [UIColor colorWithRed:(232/255.0f) green:(50.0f/255.0f) blue:(52.0f/255.0f) alpha:1.0];
    
    self.upperShadowColor = self.positiveLineColor;
    self.lowerShadowColor = self.negativeLineColor;
    
    self.movingAvgLineWidth = 0.8;
    
    self.minMALineColor = [UIColor colorWithHexString:@"#019FFD"];
    self.midMALineColor = [UIColor colorWithHexString:@"#FF99OO"];
    self.maxMALineColor = [UIColor colorWithHexString:@"#FF00FF"];
    
    self.positiveVolColor = self.positiveLineColor;
    self.negativeVolColor =  self.negativeLineColor;
    
    self.axisShadowColor = [UIColor colorWithRed:223/255.0f green:223/255.0f blue:223/255.0f alpha:1.0];
    self.axisShadowWidth = 0.8;
    
    self.separatorColor = [UIColor colorWithRed:230/255.0f green:230/255.0f blue:230/255.0f alpha:1.0];
    self.separatorWidth = 0.5;
    
    self.yAxisTitleFont = [UIFont systemFontOfSize:8.0];
    self.yAxisTitleColor = [UIColor colorWithRed:(130/255.0f) green:(130/255.0f) blue:(130/255.0f) alpha:1.0];
    
    self.xAxisTitleFont = [UIFont systemFontOfSize:8.0];
    self.xAxisTitleColor = [UIColor colorWithRed:(130/255.0f) green:(130/255.0f) blue:(130/255.0f) alpha:1.0];
    
    self.crossLineColor = [UIColor colorWithHexString:@"#C9C9C9"];
    
    self.scrollEnable = YES;
    
    self.zoomEnable = YES;
    
    self.showAvgLine = YES;
    
    self.showBarChart = YES;
    
    self.yAxisTitleIsChange = YES;
    
    self.saveDecimalPlaces = 2;
    
    self.timeAndPriceTipsBackgroundColor = [UIColor colorWithHexString:@"D70002"];
    self.timeAndPriceTextColor = [UIColor colorWithWhite:1.0 alpha:0.95];
    
    self.supportGesture = YES;
    
    self.maxKLineWidth = 24;
    self.minKLineWidth = 1.5;
    
    self.kLineWidth = 8.0;
    self.kLinePadding = 2.0;
    
    self.lastPanScale = 1.0;
    
    self.xAxisContext = [NSMutableDictionary new];
    self.updateTempDates = [NSMutableArray new];
    self.updateTempContexts = [NSMutableArray new];
    
    //添加手势
    [self addGestures];
    
    [self registerObserver];
}

/**
 *  添加手势
 */
- (void)addGestures {
    if (!self.supportGesture) {
        return;
    }
    
    [self addGestureRecognizer:self.tapGesture];
    
    [self addGestureRecognizer:self.panGesture];
    
    [self addGestureRecognizer:self.pinchGesture];
    
    [self addGestureRecognizer:self.longGesture];
}

/**
 *  通知
 */
- (void)registerObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startTouchNotification:) name:KLineKeyStartUserInterfaceNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(endOfTouchNotification:) name:KLineKeyEndOfUserInterfaceNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChangeNotification:) name:UIDeviceOrientationDidChangeNotification object:nil];
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
    
    /**
     *  最高价,最低价
     */
    self.maxHighValue = [data[kCandlerstickChartsMaxHigh] floatValue];
    self.minLowValue = [data[kCandlerstickChartsMinLow] floatValue];
    
    /**
     *  成交量最大之，最小值
     */
    self.maxVolValue = [data[kCandlerstickChartsMaxVol] floatValue];
    self.minVolValue = [data[kCandlerstickChartsMinVol] floatValue];
    
    CGFloat maxValue = self.showBarChart ? (self.maxVolValue > self.maxHighValue ? self.maxVolValue : self.maxHighValue) : self.maxHighValue;
    
    NSAttributedString *attString = [[NSAttributedString alloc] initWithString:[self dealDecimalWithNum:@(maxValue)] attributes:@{NSFontAttributeName:self.yAxisTitleFont, NSForegroundColorAttributeName:self.yAxisTitleColor}];
    CGSize size = [attString boundingRectWithSize:CGSizeMake(MAXFLOAT, self.yAxisTitleFont.lineHeight) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
    self.leftMargin = size.width + 4.0f;
    
    //更具宽度和间距确定要画多少个k线柱形图
    self.kLineDrawNum = floor(((self.frame.size.width - self.leftMargin - self.rightMargin - _kLinePadding) / (self.kLineWidth + self.kLinePadding)));
    
    //确定从第几个开始画
    self.startDrawIndex = self.contexts.count > 0 ? self.contexts.count - self.kLineDrawNum : 0;
    
    [self resetMaxAndMin];
    
    [self setNeedsDisplay];
}

#pragma mark - event reponse

- (void)updateChartPressed:(UIButton *)button {
    self.startDrawIndex = self.contexts.count - self.kLineDrawNum;
    [self dynamicUpdateChart];
}

- (void)tapEvent:(UITapGestureRecognizer *)tapGesture {
    //[self longPressEvent:nil];
}

- (void)panEvent:(UIPanGestureRecognizer *)panGesture {
    CGPoint touchPoint = [panGesture translationInView:self];
    NSInteger offsetIndex = fabs(touchPoint.x/(self.kLineWidth > self.maxKLineWidth/2.0 ? 16.0f : 8.0));
    
    [self postNotificationWithGestureRecognizerStatus:panGesture.state];
    if (!self.scrollEnable || self.contexts.count == 0 || offsetIndex == 0) {
        return;
    }
    
    if (touchPoint.x > 0) {
        self.startDrawIndex = self.startDrawIndex - offsetIndex < 0 ? 0 : self.startDrawIndex - offsetIndex;
    } else {
        self.startDrawIndex = self.startDrawIndex + offsetIndex + self.kLineDrawNum > self.contexts.count ? self.contexts.count - self.kLineDrawNum : self.startDrawIndex + offsetIndex;
    }
    
    [self resetMaxAndMin];
    
    [panGesture setTranslation:CGPointZero inView:self];
    [self setNeedsDisplay];
}

- (void)pinchEvent:(UIPinchGestureRecognizer *)pinchEvent {
    CGFloat scale = pinchEvent.scale - self.lastPanScale + 1;
    
    [self postNotificationWithGestureRecognizerStatus:pinchEvent.state];
    
    if (!self.zoomEnable || self.contexts.count == 0) {
        return;
    }
    
    self.kLineWidth = _kLineWidth*scale;
    
    CGFloat forwardDrawCount = self.kLineDrawNum;
    
    _kLineDrawNum = floor((self.frame.size.width - self.leftMargin - self.rightMargin) / (self.kLineWidth + self.kLinePadding));
    
    //容差处理
    CGFloat diffWidth = (self.frame.size.width - self.leftMargin - self.rightMargin) - (self.kLineWidth + self.kLinePadding)*_kLineDrawNum;
    if (diffWidth > 4*(self.kLineWidth + self.kLinePadding)/5.0) {
        _kLineDrawNum = _kLineDrawNum + 1;
    }
    
    _kLineDrawNum = self.contexts.count > 0 && _kLineDrawNum < self.contexts.count ? _kLineDrawNum : self.contexts.count;
    if (forwardDrawCount == self.kLineDrawNum && self.maxKLineWidth != self.kLineWidth) {
        return;
    }
    
    NSInteger diffCount = fabs(self.kLineDrawNum - forwardDrawCount);
    
    if (forwardDrawCount > self.startDrawIndex) {
        // 放大
        self.startDrawIndex += ceil(diffCount/2.0);
    } else {
        // 缩小
        self.startDrawIndex -= floor(diffCount/2.0);
        self.startDrawIndex = self.startDrawIndex < 0 ? 0 : self.startDrawIndex;
    }
    
    self.startDrawIndex = self.startDrawIndex + self.kLineDrawNum > self.contexts.count ? self.contexts.count - self.kLineDrawNum : self.startDrawIndex;
    
    [self resetMaxAndMin];
    
    pinchEvent.scale = scale;
    self.lastPanScale = pinchEvent.scale;
    
    [self setNeedsDisplay];
}

- (void)longPressEvent:(UILongPressGestureRecognizer *)longGesture {
    [self postNotificationWithGestureRecognizerStatus:longGesture.state];
    
    if (self.contexts.count == 0 || !self.contexts) {
        return;
    }
    
    if (longGesture.state == UIGestureRecognizerStateEnded) {
        self.horizontalCrossLine.hidden = YES;
        self.verticalCrossLine.hidden = YES;
        self.barVerticalLine.hidden = YES;
        self.maTipView.hidden = YES;
        self.priceLbl.hidden = YES;
        self.timeLbl.hidden = YES;
        [self.tipBoard hide];
    } else {
        CGPoint touchPoint = [longGesture locationInView:self];
        [self.xAxisContext enumerateKeysAndObjectsUsingBlock:^(NSNumber *xAxisKey, NSNumber *indexObject, BOOL *stop) {
            if (_kLinePadding+_kLineWidth >= ([xAxisKey floatValue] - touchPoint.x) && ([xAxisKey floatValue] - touchPoint.x) > 0) {
                NSInteger index = [indexObject integerValue];
                // 获取对应的k线数据
                NSArray *line = _contexts[index];
                CGFloat open = [line[0] floatValue];
                CGFloat close = [line[3] floatValue];
                CGFloat scale = (self.maxHighValue - self.minLowValue) / self.yAxisHeight;
                CGFloat xAxis = [xAxisKey floatValue] - _kLineWidth / 2.0 + self.leftMargin;
                CGFloat yAxis = self.yAxisHeight - (open - self.minLowValue)/scale + self.topMargin;
                
                if ([line[1] floatValue] > [line[2] floatValue]) {
                    yAxis = self.yAxisHeight - (close - self.minLowValue)/scale + self.topMargin;
                }
                
                [self configUIWithLine:line atPoint:CGPointMake(xAxis, yAxis)];
                
                *stop = YES;
            }
        }];
    }
}

- (void)configUIWithLine:(NSArray *)line atPoint:(CGPoint)point {
    //十字线
    self.verticalCrossLine.hidden = NO;
    CGRect frame = self.verticalCrossLine.frame;
    frame.origin.x = point.x;
    self.verticalCrossLine.frame = frame;
    
    self.horizontalCrossLine.hidden = NO;
    frame = self.horizontalCrossLine.frame;
    frame.origin.y = point.y;
    self.horizontalCrossLine.frame = frame;
    
    self.barVerticalLine.hidden = NO;
    frame = self.barVerticalLine.frame;
    frame.origin.x = point.x;
    self.barVerticalLine.frame = frame;
    //均值
    self.maTipView.hidden = NO;
    self.maTipView.minAvgPrice = [NSString stringWithFormat:@"MA5：%.2f", [line[5] doubleValue]];
    self.maTipView.midAvgPrice = [NSString stringWithFormat:@"MA10：%.2f", [line[6] doubleValue]];
    self.maTipView.maxAvgPrice = [NSString stringWithFormat:@"MA20：%.2f", [line[7] doubleValue]];
    //提示版
    self.tipBoard.open = line[0];
    self.tipBoard.close = line[3];
    self.tipBoard.high = line[1];
    self.tipBoard.low = line[2];
    
    if (point.y - self.topMargin - self.tipBoard.frame.size.height/2.0 < 0) {
        point.y = self.topMargin;
    } else if ((point.y - self.tipBoard.frame.size.height/2.0) > self.topMargin + self.yAxisHeight - self.tipBoard.frame.size.height*3/2.0f) {
        point.y = self.topMargin + self.yAxisHeight - self.tipBoard.frame.size.height*3/2.0f;
    } else {
        point.y -= self.tipBoard.frame.size.height / 2.0;
    }
    
    [self.tipBoard showWithTipPoint:CGPointMake(point.x, point.y)];
    
    //时间，价额
    self.priceLbl.hidden = NO;
    self.priceLbl.text = [line[0] floatValue] > [line[3] floatValue] ? [self dealDecimalWithNum:@([line[0] floatValue])] :[self dealDecimalWithNum:@([line[3] floatValue])] ;
    self.priceLbl.frame = CGRectMake(0, self.horizontalCrossLine.frame.origin.y - (20 - self.separatorWidth*2)/2.0, self.leftMargin - self.separatorWidth, 20 - self.separatorWidth*2);
    
    NSString *date = self.dates[[self.contexts indexOfObject:line]];
    self.timeLbl.text = date;
    self.timeLbl.hidden = date.length > 0 ? NO : YES;
    if (date.length > 0) {
        CGSize size = [date boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.xAxisTitleFont} context:nil].size;
        CGFloat originX = MIN(MAX(self.leftMargin, point.x - size.width/2.0 - 2), self.frame.size.width - self.rightMargin - size.width - 4);
        self.timeLbl.frame = CGRectMake(originX, self.topMargin + self.yAxisHeight + self.separatorWidth, size.width + 4, 20 - self.separatorWidth*2);
    }
}

- (void)postNotificationWithGestureRecognizerStatus:(UIGestureRecognizerState)state {
    switch (state) {
        case UIGestureRecognizerStateBegan: {
            [[NSNotificationCenter defaultCenter] postNotificationName:KLineKeyStartUserInterfaceNotification object:nil];
            break;
        }
        case UIGestureRecognizerStateEnded: {
            [[NSNotificationCenter defaultCenter] postNotificationName:KLineKeyEndOfUserInterfaceNotification object:nil];
            break;
        }
        default:
            break;
    }
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
        CGFloat lengths[] = {5,5};
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
        float yAxisValue = i == 5 ? self.minLowValue : self.maxHighValue - avgValue*i;
        NSAttributedString *attString = [[NSAttributedString alloc] initWithString:[self dealDecimalWithNum:@(yAxisValue)] attributes:@{NSFontAttributeName:self.yAxisTitleFont, NSForegroundColorAttributeName:self.yAxisTitleColor}];
        CGSize size = [attString boundingRectWithSize:CGSizeMake(self.leftMargin, self.yAxisTitleFont.lineHeight) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
        
        [attString drawInRect:CGRectMake(self.leftMargin - size.width - 2.0f, self.topMargin + avgHeight*i - (i == 5 ? size.height - 1 : size.height/2.0), size.width, size.height)];
    }
    
    if (self.showBarChart) {
        //交易量边框
        CGContextSetLineWidth(context, self.axisShadowWidth);
        CGContextSetStrokeColorWithColor(context, self.axisShadowColor.CGColor);
        strokeRect = CGRectMake(self.leftMargin, self.yAxisHeight + self.topMargin + 20.0f, self.xAxisWidth, rect.size.height - self.yAxisHeight - self.topMargin - 20.0f);
        CGContextStrokeRect(context, strokeRect);
        
        NSAttributedString *attString = [[NSAttributedString alloc] initWithString:[self dealDecimalWithNum:@(self.maxVolValue)] attributes:@{NSFontAttributeName:self.yAxisTitleFont, NSForegroundColorAttributeName:self.yAxisTitleColor}];
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
    
    for (NSArray *line in [_contexts subarrayWithRange:NSMakeRange(self.startDrawIndex, self.kLineDrawNum)]) {
        [self.xAxisContext setObject:@([_contexts indexOfObject:line]) forKey:@(xAxis + _kLineWidth)];
        //通过开盘价、收盘价判断颜色
        CGFloat open = [line[0] floatValue];
        CGFloat close = [line[3] floatValue];
        UIColor *fillColor = open > close ? self.positiveLineColor : self.negativeLineColor;
        CGContextSetFillColorWithColor(context, fillColor.CGColor);
        
        CGFloat diffValue = fabs(open - close);
        CGFloat maxValue = MAX(open, close);
        CGFloat height = diffValue/scale == 0 ? 1 : diffValue/scale;
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
    
    NSArray<UIColor *> *colors = @[self.minMALineColor, self.midMALineColor, self.maxMALineColor];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, self.movingAvgLineWidth);
    
    for (int i = 0; i < 3; i ++) {
        CGContextSetStrokeColorWithColor(context, colors[i].CGColor);
        CGPathRef path = [self movingAvgGraphPathForContextAtIndex:(i + 5)];
        CGContextAddPath(context, path);
        CGContextStrokePath(context);
    }
}

/**
 *  均线path
 */
- (CGPathRef)movingAvgGraphPathForContextAtIndex:(NSInteger)index {
    UIBezierPath *path;
    
    CGFloat xAxis = self.leftMargin + 1/2.0*_kLineWidth + _kLinePadding;
    CGFloat scale = (self.maxHighValue - self.minLowValue) / self.yAxisHeight;
    
    if (scale != 0) {
        for (NSArray *line in [_contexts subarrayWithRange:NSMakeRange(self.startDrawIndex, self.kLineDrawNum)]) {
            CGFloat maValue = [line[index] floatValue];
            CGFloat yAxis = self.yAxisHeight - (maValue - self.minLowValue)/scale + self.topMargin;
            CGPoint maPoint = CGPointMake(xAxis, yAxis);
            if (yAxis < self.topMargin || yAxis > (self.frame.size.height - self.bottomMargin)) {
                xAxis += self.kLineWidth + self.kLinePadding;
                continue;
            }
            
            if (!path) {
                path = [UIBezierPath bezierPath];
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
    
    for (NSArray *line in [_contexts subarrayWithRange:NSMakeRange(self.startDrawIndex, self.kLineDrawNum)]) {
        CGFloat open = [line[0] floatValue];
        CGFloat close = [line[3] floatValue];
        UIColor *fillColor = open > close ? self.positiveVolColor : self.negativeVolColor;
        CGContextSetFillColorWithColor(context, fillColor.CGColor);
        
        CGFloat height = [line[4] floatValue]/scale == 0 ? 1.0 : [line[4] floatValue]/scale;
        CGRect pathRect = CGRectMake(xAxis, boxYOrigin + boxHeight - height, self.kLineWidth, height);
        CGContextAddRect(context, pathRect);
        CGContextFillPath(context);
        
        xAxis += _kLineWidth + _kLinePadding;
    }
}

- (void)dynamicUpdateChart {
    if (self.updateTempContexts.count == 0) {
        return;
    }
    
    if ((!self.interactive && (self.startDrawIndex + self.kLineDrawNum) == self.contexts.count) || self.dynamicUpdateIsNew) {
        self.contexts = [self.contexts arrayByAddingObjectsFromArray:self.updateTempContexts];
        self.dates = [self.dates arrayByAddingObjectsFromArray:self.updateTempDates];
        self.maxVolValue = self.maxVolValue > self.updateTempMaxVol ? self.maxVolValue : self.updateTempMaxVol;
        self.maxHighValue = self.maxHighValue > self.updateTempMaxHigh ? self.maxHighValue : self.updateTempMaxHigh;
        
        [self resetLeftMargin];
        
        //更具宽度和间距确定要画多少个k线柱形图
        self.kLineDrawNum = floor(((self.frame.size.width - self.leftMargin - self.rightMargin - _kLinePadding) / (self.kLineWidth + self.kLinePadding)));
        
        //确定从第几个开始画
        self.startDrawIndex = self.contexts.count > 0 ? self.contexts.count - self.kLineDrawNum : 0;
        
        [self resetMaxAndMin];
        
        [self setNeedsDisplay];
        self.realDataTipBtn.hidden = YES;
        [self.realDataTipBtn.layer removeAllAnimations];
        [self.updateTempDates removeAllObjects];
        [self.updateTempContexts removeAllObjects];
        self.updateTempMaxHigh = 0.0;
        self.updateTempMaxVol = 0.0;
    } else {
        //提示有新数据
        NSLog(@"has new data!");
        if (self.realDataTipBtn.hidden) {
            self.realDataTipBtn.hidden = NO;
            CAKeyframeAnimation* animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
            animation.duration = 2.5;
            animation.repeatCount = 99999;
            
            NSMutableArray *values = [NSMutableArray array];
            [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.65, 0.65, 1.0)]];
            [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.05, 1.05, 1.0)]];
            [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.65, 0.65, 1.0)]];
            animation.values = values;
            [self.realDataTipBtn.layer addAnimation:animation forKey:nil];
        }
    }
}

- (void)resetLeftMargin {
    CGFloat maxValue = self.showBarChart ? (self.maxVolValue > self.maxHighValue ? self.maxVolValue : self.maxHighValue) : self.maxHighValue;
    
    NSAttributedString *attString = [[NSAttributedString alloc] initWithString:[self dealDecimalWithNum:@(maxValue)] attributes:@{NSFontAttributeName:self.yAxisTitleFont, NSForegroundColorAttributeName:self.yAxisTitleColor}];
    CGSize size = [attString boundingRectWithSize:CGSizeMake(MAXFLOAT, self.yAxisTitleFont.lineHeight) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
    self.leftMargin = size.width + 4.0f;
}

- (void)resetMaxAndMin {
    NSArray *drawContext = self.contexts;
    if (self.yAxisTitleIsChange) {
        drawContext = [self.contexts subarrayWithRange:NSMakeRange(self.startDrawIndex, self.kLineDrawNum)];
    }
    
    for (int i = 0; i < drawContext.count; i++) {
        NSArray<NSString *> *item = drawContext[i];
        if (i == 0) {
            self.minVolValue = [item[4] floatValue];
            self.maxVolValue = [item[4] floatValue];
            self.minLowValue = [item[2] floatValue];
            self.maxHighValue = [item[1] floatValue];
        } else {
            if (self.maxHighValue < [item[1] floatValue]) {
                self.maxHighValue = [item[1] floatValue];
            }
            
            if (self.minLowValue > [item[2] floatValue]) {
                self.minLowValue = [item[2] floatValue];
            }
            
            if (self.maxVolValue < [item[4] floatValue]) {
                self.maxVolValue = [item[4] floatValue];
            }
            
            if (self.minVolValue > [item[4] floatValue]) {
                self.minVolValue = [item[4] floatValue];
            }
        }
    }
}

- (NSString *)dealDecimalWithNum:(NSNumber *)num {
    NSString *dealString;
    
    switch (self.saveDecimalPlaces) {
        case 0: {
            dealString = [NSString stringWithFormat:@"%ld", (long)floor(num.doubleValue)];
        }
            break;
        case 1: {
            dealString = [NSString stringWithFormat:@"%.1f", num.doubleValue];
        }
            break;
        case 2: {
            dealString = [NSString stringWithFormat:@"%.2f", num.doubleValue];
        }
            break;
        default:
            break;
    }
    
    return dealString;
}

#pragma mark -  public methods

- (void)updateChartWithData:(NSDictionary *)data {
    if (data.count == 0 || !data) {
        return;
    }
    
    [self.updateTempDates addObjectsFromArray:data[kCandlerstickChartsDate]];
    [self.updateTempContexts addObjectsFromArray:data[kCandlerstickChartsContext]];
    
    if ([data[kCandlerstickChartsMaxVol] floatValue] > self.updateTempMaxVol) {
        self.updateTempMaxVol = [data[kCandlerstickChartsMaxVol] floatValue];
    }
    
    if ([data[kCandlerstickChartsMaxHigh] floatValue] > self.updateTempMaxHigh) {
        self.updateTempMaxHigh = [data[kCandlerstickChartsMaxHigh] floatValue];
    }
    
    [self dynamicUpdateChart];
}

- (void)clear {
    self.contexts = nil;
    self.dates = nil;
    [self setNeedsDisplay];
}

#pragma mark - notificaiton events

- (void)startTouchNotification:(NSNotification *)notification {
    self.interactive = YES;
}

- (void)endOfTouchNotification:(NSNotification *)notification {
    self.interactive = NO;
    [self dynamicUpdateChart];
}

- (void)deviceOrientationDidChangeNotification:(NSNotification *)notificaiton {
    
}

#pragma mark - getters

- (UIView *)verticalCrossLine {
    if (!_verticalCrossLine) {
        _verticalCrossLine = [[UIView alloc] initWithFrame:CGRectMake(self.leftMargin, self.topMargin, 0.5, self.yAxisHeight)];
        _verticalCrossLine.backgroundColor = self.crossLineColor;
        [self addSubview:_verticalCrossLine];
    }
    return _verticalCrossLine;
}

- (UIView *)horizontalCrossLine {
    if (!_horizontalCrossLine) {
        _horizontalCrossLine = [[UIView alloc] initWithFrame:CGRectMake(self.leftMargin, self.topMargin, self.xAxisWidth, 0.5)];
        _horizontalCrossLine.backgroundColor = self.crossLineColor;
        [self addSubview:_horizontalCrossLine];
    }
    return _horizontalCrossLine;
}

- (UIView *)barVerticalLine {
    if (!_barVerticalLine) {
        _barVerticalLine = [[UIView alloc] initWithFrame:CGRectMake(self.leftMargin, self.topMargin + self.yAxisHeight + 20.0f, 0.5, self.frame.size.height - (self.topMargin + self.yAxisHeight + 20.0f))];
        _barVerticalLine.backgroundColor = self.crossLineColor;
        [self addSubview:_barVerticalLine];
    }
    return _barVerticalLine;
}

- (KLineTipBoardView *)tipBoard {
    if (!_tipBoard) {
        _tipBoard = [[KLineTipBoardView alloc] initWithFrame:CGRectMake(self.leftMargin, self.topMargin, 130.0f, 60.0f)];
        _tipBoard.backgroundColor = [UIColor clearColor];
        [self addSubview:_tipBoard];
    }
    return _tipBoard;
}

- (MATipView *)maTipView {
    if (!_maTipView) {
        _maTipView = [[MATipView alloc] initWithFrame:CGRectMake(self.leftMargin + 20, self.topMargin - 18.0f, self.frame.size.width - self.leftMargin - self.rightMargin - 20, 13.0f)];
        _maTipView.layer.masksToBounds = YES;
        _maTipView.layer.cornerRadius = 7.0f;
        _maTipView.backgroundColor = [UIColor colorWithWhite:0.35 alpha:1.0];
        [self addSubview:_maTipView];
    }
    return _maTipView;
}

- (UIButton *)realDataTipBtn {
    if (!_realDataTipBtn) {
        _realDataTipBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        [_realDataTipBtn setTitle:@"New Data" forState:UIControlStateNormal];
        [_realDataTipBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        _realDataTipBtn.titleLabel.font = [UIFont systemFontOfSize:12.0f];
        _realDataTipBtn.frame = CGRectMake(self.frame.size.width - self.rightMargin - 60.0f, self.topMargin + 10.0f, 60.0f, 25.0f);
        [_realDataTipBtn addTarget:self action:@selector(updateChartPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_realDataTipBtn];
        _realDataTipBtn.layer.borderWidth = 1.0;
        _realDataTipBtn.layer.borderColor = [UIColor redColor].CGColor;
        _realDataTipBtn.hidden = YES;
    }
    return _realDataTipBtn;
}

- (UILabel *)timeLbl {
    if (!_timeLbl) {
        _timeLbl = [UILabel new];
        _timeLbl.backgroundColor = self.timeAndPriceTipsBackgroundColor;
        _timeLbl.textAlignment = NSTextAlignmentCenter;
        _timeLbl.font = self.yAxisTitleFont;
        _timeLbl.textColor = self.timeAndPriceTextColor;
        [self addSubview:_timeLbl];
    }
    return _timeLbl;
}

- (UILabel *)priceLbl {
    if (!_priceLbl) {
        _priceLbl = [UILabel new];
        _priceLbl.backgroundColor = self.timeAndPriceTipsBackgroundColor;
        _priceLbl.textAlignment = NSTextAlignmentCenter;
        _priceLbl.font = self.xAxisTitleFont;
        _priceLbl.textColor = self.timeAndPriceTextColor;
        [self addSubview:_priceLbl];
    }
    return _priceLbl;
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
    
    if (_kLineDrawNum != 0) {
        self.kLineWidth = (self.frame.size.width - self.leftMargin - self.rightMargin - _kLinePadding)/_kLineDrawNum - _kLinePadding;
    }
}

- (void)setKLineWidth:(CGFloat)kLineWidth {
    if (kLineWidth < self.minKLineWidth) {
        kLineWidth = self.minKLineWidth;
    }
    
    if (kLineWidth > self.maxKLineWidth) {
        kLineWidth = self.maxKLineWidth;
    }
    
    _kLineWidth = kLineWidth;
}

- (void)setMaxKLineWidth:(CGFloat)maxKLineWidth {
    if (maxKLineWidth < _minKLineWidth) {
        maxKLineWidth = _minKLineWidth;
    }
    
    CGFloat realAxisWidth = (self.frame.size.width - self.leftMargin - self.rightMargin - _kLinePadding);
    NSInteger maxKLineCount = floor(realAxisWidth)/(maxKLineWidth + _kLinePadding);
    maxKLineWidth = realAxisWidth/maxKLineCount - _kLinePadding;
    
    _maxKLineWidth = maxKLineWidth;
}

- (void)setLeftMargin:(CGFloat)leftMargin {
    _leftMargin = leftMargin;
    
    self.maxKLineWidth = _maxKLineWidth;
}

- (void)setSupportGesture:(BOOL)supportGesture {
    _supportGesture = supportGesture;
    
    if (!supportGesture) {
        self.gestureRecognizers = nil;
    }
}

@end
