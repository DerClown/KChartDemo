//
//  TYBarChartView.m
//  CandlerstickCharts
//
//  k线图
//  Created by xdliu on 16/8/11.
//  Copyright © 2016年 liuxd. All rights reserved.
//

#import "KLineChartView.h"
#import "UIBezierPath+curved.h"
#import "KLineTipBoardView.h"
#import "MATipView.h"
#import "ACMacros.h"
#import "Global+Helper.h"
#import "VolumnView.h"
#import "KLineItem.h"

NSString *const KLineKeyStartUserInterfaceNotification = @"KLineKeyStartUserInterfaceNotification";
NSString *const KLineKeyEndOfUserInterfaceNotification = @"KLineKeyEndOfUserInterfaceNotification";

@interface KLineChartView ()

@property (nonatomic, assign) CGFloat yAxisHeight;

@property (nonatomic, assign) CGFloat xAxisWidth;

@property (nonatomic, strong) NSArray<KLineItem *> *chartValues;

@property (nonatomic, assign) NSInteger startDrawIndex;

@property (nonatomic, assign) NSInteger kLineDrawNum;

@property (nonatomic, strong) KLineItem *highItem;

@property (nonatomic, assign) CGFloat maxHighValue;

@property (nonatomic, assign) CGFloat minLowValue;

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

@property (nonatomic, strong) MATipView * maTipView;

// 成交量图
@property (nonatomic, strong) VolumnView *volView;

//时间
@property (nonatomic, strong) UILabel *timeLbl;
//价格
@property (nonatomic, strong) UILabel *priceLbl;

//实时数据提示按钮
@property (nonatomic, strong) UIButton *realDataTipBtn;

//交互中， 默认NO
@property (nonatomic, assign) BOOL interactive;

@end

@implementation KLineChartView

#pragma mark - life cycle

- (void)dealloc {
    [self removeObserver];
}

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
    self.fullScreen = YES;
    
    self.timeAxisHeight = 20.0;
    
    self.positiveLineColor = [UIColor colorWithRed:(31/255.0f) green:(185/255.0f) blue:(63.0f/255.0f) alpha:1.0];
    self.negativeLineColor = [UIColor colorWithRed:(232/255.0f) green:(50.0f/255.0f) blue:(52.0f/255.0f) alpha:1.0];
    
    self.upperShadowColor = self.positiveLineColor;
    self.lowerShadowColor = self.negativeLineColor;
    
    self.movingAvgLineWidth = 0.8;
    
    self.minMALineColor = HexRGB(0x019FFD);
    self.midMALineColor = HexRGB(0xFF9900);
    self.maxMALineColor = HexRGB(0xFF00FF);
    
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
    
    self.crossLineColor = HexRGB(0xC9C9C9);
    
    self.scrollEnable = YES;
    
    self.zoomEnable = YES;
    
    self.showAvgLine = YES;
    
    self.showBarChart = YES;
    
    self.yAxisTitleIsChange = YES;
    
    self.saveDecimalPlaces = 2;
    
    self.timeAndPriceTipsBackgroundColor = HexRGB(0xD70002);
    self.timeAndPriceTextColor = [UIColor colorWithWhite:1.0 alpha:0.95];
    
    self.supportGesture = YES;
    
    self.maxKLineWidth = 24;
    self.minKLineWidth = 1.5;
    
    self.kLineWidth = 8.0;
    self.kLinePadding = 2.0;
    
    self.lastPanScale = 1.0;
    
    self.xAxisContext = [NSMutableDictionary new];
    
    self.numberOfMACount = 3;
    
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

- (void)removeObserver {
    [self removeObserver:self forKeyPath:KLineKeyStartUserInterfaceNotification];
    [self removeObserver:self forKeyPath:KLineKeyEndOfUserInterfaceNotification];
    [self removeObserver:self forKeyPath:UIDeviceOrientationDidChangeNotification];
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    [self hideTipsWithAnimated:NO];
    [_verticalCrossLine removeFromSuperview];
    _verticalCrossLine = nil;
    [_horizontalCrossLine removeFromSuperview];
    _horizontalCrossLine = nil;
    
    if (!self.chartValues || self.chartValues.count == 0) {
        return;
    }
    //x坐标轴长度
    self.xAxisWidth = rect.size.width - self.rightMargin - (self.fullScreen ? 0 : self.leftMargin);
    
    //y坐标轴高度
    self.yAxisHeight = rect.size.height - self.bottomMargin - self.topMargin;
    
    //坐标轴
    [self drawAxisInRect:rect];
    
    //时间轴
    [self drawTimeAxis];
    
    //k线
    [self drawKLine];
    
    //均线
    [self drawMALine];
    
    //y坐标标题
    [self drawYAxisTitle];
    
    //交易量
    [self drawVol];
}

#pragma mark - render UI

- (void)drawChartWithData:(NSArray *)data {
    self.chartValues = data;
    
    if (self.showBarChart) {
        self.volView.data = data;
    }
    
    NSAttributedString *attString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%.2f", self.highItem.high.floatValue] attributes:@{NSFontAttributeName:self.yAxisTitleFont, NSForegroundColorAttributeName:self.yAxisTitleColor}];
    CGSize size = [attString boundingRectWithSize:CGSizeMake(MAXFLOAT, self.yAxisTitleFont.lineHeight) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
    self.leftMargin = size.width + 4.0f;
    
    //更具宽度和间距确定要画多少个k线柱形图
    self.kLineDrawNum = floor(((self.frame.size.width - (self.fullScreen ? 0 : self.leftMargin) - self.rightMargin - _kLinePadding) / (self.kLineWidth + self.kLinePadding)));
    
    //确定从第几个开始画
    self.startDrawIndex = self.chartValues.count > 0 ? self.chartValues.count - self.kLineDrawNum : 0;
    
    [self resetMaxAndMin];
    
    [self setNeedsDisplay];
}

#pragma mark - event reponse

- (void)updateChartPressed:(UIButton *)button {
    self.startDrawIndex = self.chartValues.count - self.kLineDrawNum;
}

- (void)tapEvent:(UITapGestureRecognizer *)tapGesture {
    if (self.chartValues.count == 0 || !self.chartValues) {
        return;
    }
    
    CGPoint touchPoint = [tapGesture locationInView:self];
    [self showTipBoardWithTouchPoint:touchPoint];
}

- (void)panEvent:(UIPanGestureRecognizer *)panGesture {
    [self hideTipsWithAnimated:NO];
    CGPoint touchPoint = [panGesture translationInView:self];
    NSInteger offsetIndex = fabs(touchPoint.x/(self.kLineWidth > self.maxKLineWidth/2.0 ? 16.0f : 8.0));
    
    [self postNotificationWithGestureRecognizerStatus:panGesture.state];
    if (!self.scrollEnable || self.chartValues.count == 0 || offsetIndex == 0) {
        return;
    }
    
    if (touchPoint.x > 0) {
        self.startDrawIndex = self.startDrawIndex - offsetIndex < 0 ? 0 : self.startDrawIndex - offsetIndex;
    } else {
        self.startDrawIndex = self.startDrawIndex + offsetIndex + self.kLineDrawNum > self.chartValues.count ? self.chartValues.count - self.kLineDrawNum : self.startDrawIndex + offsetIndex;
    }
    
    [self resetMaxAndMin];
    
    [panGesture setTranslation:CGPointZero inView:self];
    [self setNeedsDisplay];
}

- (void)pinchEvent:(UIPinchGestureRecognizer *)pinchEvent {
    [self hideTipsWithAnimated:NO];
    CGFloat scale = pinchEvent.scale - self.lastPanScale + 1;
    
    [self postNotificationWithGestureRecognizerStatus:pinchEvent.state];
    
    if (!self.zoomEnable || self.chartValues.count == 0) {
        return;
    }
    
    self.kLineWidth = _kLineWidth*scale;
    
    CGFloat forwardDrawCount = self.kLineDrawNum;
    
    _kLineDrawNum = floor((self.frame.size.width - (self.fullScreen ? 0 : self.leftMargin) - self.rightMargin) / (self.kLineWidth + self.kLinePadding));
    
    //容差处理
    CGFloat diffWidth = (self.frame.size.width - (self.fullScreen ? 0 : self.leftMargin) - self.rightMargin) - (self.kLineWidth + self.kLinePadding)*_kLineDrawNum;
    if (diffWidth > 4*(self.kLineWidth + self.kLinePadding)/5.0) {
        _kLineDrawNum = _kLineDrawNum + 1;
    }
    
    _kLineDrawNum = self.chartValues.count > 0 && _kLineDrawNum < self.chartValues.count ? _kLineDrawNum : self.chartValues.count;
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
    
    self.startDrawIndex = self.startDrawIndex + self.kLineDrawNum > self.chartValues.count ? self.chartValues.count - self.kLineDrawNum : self.startDrawIndex;
    
    [self resetMaxAndMin];
    
    pinchEvent.scale = scale;
    self.lastPanScale = pinchEvent.scale;
    
    [self setNeedsDisplay];
}

- (void)longPressEvent:(UILongPressGestureRecognizer *)longGesture {
    [self postNotificationWithGestureRecognizerStatus:longGesture.state];
    
    if (self.chartValues.count == 0 || !self.chartValues) {
        return;
    }
    
    if (longGesture.state == UIGestureRecognizerStateEnded) {
        [self hideTipsWithAnimated:NO];
    } else {
        CGPoint touchPoint = [longGesture locationInView:self];
        [self showTipBoardWithTouchPoint:touchPoint];
    }
}

- (void)showTipBoardWithTouchPoint:(CGPoint)touchPoint {
    [self.xAxisContext enumerateKeysAndObjectsUsingBlock:^(NSNumber *xAxisKey, NSNumber *indexObject, BOOL *stop) {
        if (_kLinePadding+_kLineWidth >= ([xAxisKey floatValue] - touchPoint.x) && ([xAxisKey floatValue] - touchPoint.x) > 0) {
            NSInteger index = [indexObject integerValue];
            // 获取对应的k线数据
            KLineItem *item = self.chartValues[index];
            CGFloat open = [item.open floatValue];
            CGFloat close = [item.close floatValue];
            CGFloat scale = (self.maxHighValue - self.minLowValue) / self.yAxisHeight;
            scale = scale == 0 ? 1.0 : scale;
            
            CGFloat xAxis = [xAxisKey floatValue] - _kLineWidth / 2.0 + (self.fullScreen ? 0 : self.leftMargin);
            CGFloat yAxis = self.yAxisHeight - (open - self.minLowValue)/scale + self.topMargin;
            
            if ([item.high floatValue] > [item.low floatValue]) {
                yAxis = self.yAxisHeight - (close - self.minLowValue)/scale + self.topMargin;
            }
            
            [self configUIWithLineItem:item atPoint:CGPointMake(xAxis, yAxis)];
            
            *stop = YES;
        }
    }];
}

- (void)configUIWithLineItem:(KLineItem *)item atPoint:(CGPoint)point {
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
    self.maTipView.hidden = !self.showAvgLine;
    if (self.showAvgLine) {
        NSArray *mas = item.MAs;
        self.maTipView.minAvgPrice = [NSString stringWithFormat:@"MA5：%.2f", [mas[0] doubleValue]];
        self.maTipView.midAvgPrice = [NSString stringWithFormat:@"MA10：%.2f", [mas[1] doubleValue]];
        self.maTipView.maxAvgPrice = [NSString stringWithFormat:@"MA20：%.2f", [mas[2] doubleValue]];
    }
    //提示版
    self.tipBoard.open = [self dealDecimalWithNum:item.open];
    self.tipBoard.close = [self dealDecimalWithNum:item.close];
    self.tipBoard.high = [self dealDecimalWithNum:item.high];
    self.tipBoard.low = [self dealDecimalWithNum:item.low];
    
    if (point.y - self.topMargin - self.tipBoard.frame.size.height/2.0 < 0) {
        point.y = self.topMargin;
    } else if ((point.y - self.tipBoard.frame.size.height/2.0) > self.topMargin + self.yAxisHeight - self.tipBoard.frame.size.height*3/2.0f) {
        point.y = self.topMargin + self.yAxisHeight - self.tipBoard.frame.size.height*3/2.0f;
    } else {
        point.y -= self.tipBoard.frame.size.height / 2.0;
    }
    
    NSAttributedString *maxText = [Global_Helper attributeText:[NSString stringWithFormat:@"最高价：%@", [self dealDecimalWithNum:@(self.maxHighValue)]] textColor:HexRGB(0xffffff) font:self.tipBoard.font];
    CGSize size = [Global_Helper attributeString:maxText boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT)];
    
    frame = self.tipBoard.frame;
    frame.size.width = size.width + Adaptor_Value(20.0f);

    self.tipBoard.frame = frame;
    
    [self.tipBoard showWithTipPoint:CGPointMake(point.x, point.y)];
    
    //时间，价额
    self.priceLbl.hidden = NO;
    self.priceLbl.text = [item.open floatValue] > [item.close floatValue] ? [self dealDecimalWithNum:item.open] :[self dealDecimalWithNum:item.close] ;
    self.priceLbl.frame = CGRectMake(0.5, MIN(self.horizontalCrossLine.frame.origin.y - (self.timeAxisHeight*2/3.0 - self.separatorWidth*2)/2.0, self.topMargin + self.yAxisHeight - self.timeAxisHeight), (self.fullScreen ? self.leftMargin + Adaptor_Value(6.0f) : self.leftMargin - self.separatorWidth), self.timeAxisHeight*2/3.0 - self.separatorWidth*2);
    [self bringSubviewToFront:self.priceLbl];
    
    NSString *date = item.date;
    self.timeLbl.text = date;
    self.timeLbl.hidden = date.length > 0 ? NO : YES;
    if (date.length > 0) {
        CGSize size = [date boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.xAxisTitleFont} context:nil].size;
        CGFloat originX = MIN(MAX(self.leftMargin, point.x - size.width/2.0 - 2), self.frame.size.width - self.rightMargin - size.width - 4);
        self.timeLbl.frame = CGRectMake(originX, self.topMargin + self.yAxisHeight + self.separatorWidth, size.width + 4, self.timeAxisHeight - self.separatorWidth*2);
    }
}

- (void)hideTipsWithAnimated:(BOOL)animated {
    self.horizontalCrossLine.hidden = YES;
    self.verticalCrossLine.hidden = YES;
    self.barVerticalLine.hidden = YES;
    self.maTipView.hidden = YES;
    self.priceLbl.hidden = YES;
    self.timeLbl.hidden = YES;
    if (animated) {
        [self.tipBoard hide];
    } else {
        self.tipBoard.hidden = YES;
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
    CGRect strokeRect = CGRectMake((self.fullScreen ? 0 : self.leftMargin), self.topMargin, self.xAxisWidth, self.yAxisHeight);
    CGContextSetLineWidth(context, self.axisShadowWidth);
    CGContextSetStrokeColorWithColor(context, self.axisShadowColor.CGColor);
    CGContextStrokeRect(context, strokeRect);
    
    //k线分割线
    CGFloat avgHeight = strokeRect.size.height/5.0;
    for (int i = 1; i <= 4; i ++) {
        [self drawDashLineInContext:context
                          movePoint:CGPointMake((self.fullScreen ? 0 : self.leftMargin) + 1.25, self.topMargin + avgHeight*i)
                            toPoint:CGPointMake(rect.size.width  - self.rightMargin - 0.8, self.topMargin + avgHeight*i)];
    }
    
    //这必须把dash给初始化一次，不然会影响其他线条的绘制
    CGContextSetLineDash(context, 0, 0, 0);
}

- (void)drawYAxisTitle {
    //k线y坐标
    CGFloat avgValue = (self.maxHighValue - self.minLowValue) / 5.0;
    for (int i = 0; i < 6; i ++) {
        float yAxisValue = i == 5 ? self.minLowValue : self.maxHighValue - avgValue*i;
        
        NSAttributedString *attString = [Global_Helper attributeText:[self dealDecimalWithNum:@(yAxisValue)] textColor:self.yAxisTitleColor font:self.yAxisTitleFont];
        CGSize size = [attString boundingRectWithSize:CGSizeMake((self.fullScreen ? 0 : self.leftMargin), self.yAxisTitleFont.lineHeight) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
        
        CGFloat diffHeight = 0;
        if (i == 5) {
            diffHeight = size.height;
        } else if (i > 0 && i < 5) {
            diffHeight = size.height/2.0;
        }
        [attString drawInRect:CGRectMake((self.fullScreen ? 2.0 : self.leftMargin - size.width - 2.0f), self.topMargin + self.yAxisHeight/5.0*i - diffHeight, size.width, size.height)];
    }
}

- (void)drawDashLineInContext:(CGContextRef)context
                    movePoint:(CGPoint)mPoint toPoint:(CGPoint)toPoint {
    CGContextSetLineWidth(context, self.separatorWidth);
    CGFloat lengths[] = {5,5};
    CGContextSetStrokeColorWithColor(context, self.separatorColor.CGColor);
    CGContextSetLineDash(context, 0, lengths, 2);  //画虚线
    
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, mPoint.x, mPoint.y);    //开始画线
    CGContextAddLineToPoint(context, toPoint.x, toPoint.y);
    
    CGContextStrokePath(context);
}

- (void)drawTimeAxis {
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGFloat quarteredWidth = self.xAxisWidth/4.0;
    NSInteger avgDrawCount = ceil(quarteredWidth/(_kLinePadding + _kLineWidth));
    
    CGFloat xAxis = (self.fullScreen ? 0 : self.leftMargin) + _kLineWidth/2.0 + _kLinePadding;
    //画4条虚线
    for (int i = 0; i < 4; i ++) {
        if (xAxis > (self.fullScreen ? 0 : self.leftMargin) + self.xAxisWidth) {
            break;
        }
        [self drawDashLineInContext:context movePoint:CGPointMake(xAxis, self.topMargin + 1.25) toPoint:CGPointMake(xAxis, self.topMargin + self.yAxisHeight - 1.25)];
        //x轴坐标
        NSInteger timeIndex = i*avgDrawCount + self.startDrawIndex;
        if (timeIndex > self.chartValues.count - 1) {
            xAxis += avgDrawCount*(_kLinePadding + _kLineWidth);
            continue;
        }
        NSAttributedString *attString = [Global_Helper attributeText:self.chartValues[timeIndex].date textColor:self.xAxisTitleColor font:self.xAxisTitleFont lineSpacing:2];
        CGSize size = [Global_Helper attributeString:attString boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT)];
        CGFloat originX = MIN(xAxis - size.width/2.0, self.frame.size.width - self.rightMargin - size.width);
        [attString drawInRect:CGRectMake(originX, self.topMargin + self.yAxisHeight + 2.0, size.width, size.height)];
        
        xAxis += avgDrawCount*(_kLinePadding + _kLineWidth);
    }
    CGContextSetLineDash(context, 0, 0, 0);
}

/**
 *  K线
 */
- (void)drawKLine {
    CGFloat scale = (self.maxHighValue - self.minLowValue) / self.yAxisHeight;
    if (scale == 0) {
        scale = 1.0;
    }
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 0.5);
    
    CGFloat xAxis = _kLinePadding;
    [self.xAxisContext removeAllObjects];
    
    CGPoint maxPoint, minPoint;
    
    for (KLineItem *item in [self.chartValues subarrayWithRange:NSMakeRange(self.startDrawIndex, self.kLineDrawNum)]) {
        [self.xAxisContext setObject:@([self.chartValues indexOfObject:item]) forKey:@(xAxis + _kLineWidth)];
        //通过开盘价、收盘价判断颜色
        CGFloat open = [item.open floatValue];
        CGFloat close = [item.close floatValue];
        UIColor *fillColor = open > close ? self.positiveLineColor : self.negativeLineColor;
        CGContextSetFillColorWithColor(context, fillColor.CGColor);
        
        CGFloat diffValue = fabs(open - close);
        CGFloat maxValue = MAX(open, close);
        CGFloat height = diffValue/scale == 0 ? 1 : diffValue/scale;
        CGFloat width = _kLineWidth;
        CGFloat yAxis = self.yAxisHeight - ((maxValue - self.minLowValue)/scale == 0 ? 1 : (maxValue - self.minLowValue)/scale) + self.topMargin;
        
        CGRect rect = CGRectMake(xAxis + (self.fullScreen ? 0 : self.leftMargin), yAxis, width, height);
        CGContextAddRect(context, rect);
        CGContextFillPath(context);
        
        //上、下影线
        CGFloat highYAxis = self.yAxisHeight - ([item.high floatValue] - self.minLowValue)/scale;
        CGFloat lowYAxis = self.yAxisHeight - ([item.low floatValue] - self.minLowValue)/scale;
        CGPoint highPoint = CGPointMake(xAxis + width/2.0 + (self.fullScreen ? 0 : self.leftMargin), highYAxis + self.topMargin);
        CGPoint lowPoint = CGPointMake(xAxis + width/2.0 + (self.fullScreen ? 0 : self.leftMargin), lowYAxis + self.topMargin);
        CGContextSetStrokeColorWithColor(context, fillColor.CGColor);
        CGContextBeginPath(context);
        CGContextMoveToPoint(context, highPoint.x, highPoint.y);  //起点坐标
        CGContextAddLineToPoint(context, lowPoint.x, lowPoint.y);   //终点坐标
        CGContextStrokePath(context);
        
        if ([item.high floatValue] == self.maxHighValue) {
            maxPoint = highPoint;
        }
        
        if ([item.low floatValue] == self.minLowValue) {
            minPoint = lowPoint;
        }
        
        xAxis += width + _kLinePadding;
    }
    
    NSAttributedString *attString = [Global_Helper attributeText:[self dealDecimalWithNum:@(self.maxHighValue)] textColor:HexRGB(0xFFB54C) font:[UIFont systemFontOfSize:12.0f]];
    CGSize size = [Global_Helper attributeString:attString boundingRectWithSize:CGSizeMake(100, 100)];
    float originX = maxPoint.x - size.width - self.kLineWidth - 2 < (self.fullScreen ? 0 : self.leftMargin) + self.kLineWidth + 2.0 ?  maxPoint.x + self.kLineWidth : maxPoint.x - size.width - self.kLineWidth;
    [attString drawInRect:CGRectMake(originX, maxPoint.y, size.width, size.height)];
    
    attString = [Global_Helper attributeText:[self dealDecimalWithNum:@(self.minLowValue)] textColor:HexRGB(0xFFB54C) font:[UIFont systemFontOfSize:12.0f]];
    size = [Global_Helper attributeString:attString boundingRectWithSize:CGSizeMake(100, 100)];
    originX = minPoint.x - size.width - self.kLineWidth - 2 < (self.fullScreen ? 0 : self.leftMargin) + self.kLineWidth + 2.0 ?  minPoint.x + self.kLineWidth : minPoint.x - size.width - self.kLineWidth;
    [attString drawInRect:CGRectMake(originX, self.yAxisHeight - size.height + self.topMargin, size.width, size.height)];
}

/**
 *  均线图
 */
- (void)drawMALine {
    if (!self.showAvgLine) {
        return;
    }
    
    NSArray<UIColor *> *colors = @[self.minMALineColor, self.midMALineColor, self.maxMALineColor];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, self.movingAvgLineWidth);
    
    for (int i = 0; i < self.numberOfMACount; i ++) {
        CGContextSetStrokeColorWithColor(context, colors[i].CGColor);
        CGPathRef path = [self movingAvgGraphPathForContextAtIndex:i];
        CGContextAddPath(context, path);
        CGContextStrokePath(context);
    }
}

/**
 *  均线path
 */
- (CGPathRef)movingAvgGraphPathForContextAtIndex:(NSInteger)index {
    UIBezierPath *path;
    
    CGFloat xAxis = (self.fullScreen ? 0 : self.leftMargin) + 1/2.0*_kLineWidth + _kLinePadding;
    CGFloat scale = (self.maxHighValue - self.minLowValue) / self.yAxisHeight;
    
    if (scale != 0) {
        for (KLineItem *item in [self.chartValues subarrayWithRange:NSMakeRange(self.startDrawIndex, self.kLineDrawNum)]) {
            NSAssert(item.MAs.count == self.numberOfMACount, @"均线显示个数，和设置不一致！");
            CGFloat maValue = [item.MAs[index] floatValue];
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
    
    CGFloat boxOriginY = self.topMargin + self.yAxisHeight + self.timeAxisHeight;
    CGFloat boxHeight = rect.size.height - boxOriginY;
    self.volView.frame = CGRectMake(0, boxOriginY, rect.size.width, boxHeight);
    self.volView.kLineWidth = self.kLineWidth;
    self.volView.linePadding = self.kLinePadding;
    self.volView.boxOriginX = (self.fullScreen ? 0 : self.leftMargin);
    
    self.volView.startDrawIndex = self.startDrawIndex;
    self.volView.numberOfDrawCount = self.kLineDrawNum;
    [self.volView update];
}

- (void)resetMaxAndMin {
    self.maxHighValue = -MAXFLOAT;
    self.minLowValue = MAXFLOAT;
    NSArray *drawContext = self.yAxisTitleIsChange ? [self.chartValues subarrayWithRange:NSMakeRange(self.startDrawIndex, MIN(self.kLineDrawNum, self.chartValues.count))] : self.chartValues;
    
    for (int i = 0; i < drawContext.count; i++) {
        KLineItem *item = drawContext[i];
        
        self.maxHighValue = MAX([item.high floatValue], self.maxHighValue);
        self.minLowValue = MIN([item.low floatValue], self.minLowValue);
    }
}

- (NSString *)dealDecimalWithNum:(NSNumber *)num {
    NSString *dealString;
    
    switch (self.saveDecimalPlaces) {
        case 0: {
            dealString = [NSString stringWithFormat:@"%ld", lroundf(num.doubleValue)];
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

- (void)clear {
    self.chartValues = nil;
    [self setNeedsDisplay];
}

#pragma mark - notificaiton events

- (void)startTouchNotification:(NSNotification *)notification {
    self.interactive = YES;
}

- (void)endOfTouchNotification:(NSNotification *)notification {
    self.interactive = NO;
}

- (void)deviceOrientationDidChangeNotification:(NSNotification *)notificaiton {
    
}

#pragma mark - getters

- (VolumnView *)volView {
    if (!_volView) {
        _volView = [VolumnView new];
        _volView.backgroundColor  = self.backgroundColor;
        _volView.boxRightMargin = self.rightMargin;
        _volView.axisShadowColor = self.axisShadowColor;
        _volView.axisShadowWidth = self.axisShadowWidth;
        _volView.negativeVolColor = self.negativeVolColor;
        _volView.positiveVolColor = self.positiveVolColor;
        _volView.yAxisTitleFont = self.yAxisTitleFont;
        _volView.yAxisTitleColor = self.yAxisTitleColor;
        _volView.separatorWidth = self.separatorWidth;
        _volView.separatorColor = self.separatorColor;
        [self addSubview:_volView];
    }
    return _volView;
}

- (UIView *)verticalCrossLine {
    if (!_verticalCrossLine) {
        _verticalCrossLine = [[UIView alloc] initWithFrame:CGRectMake((self.fullScreen ? 0 : self.leftMargin), self.topMargin, 0.5, self.yAxisHeight)];
        _verticalCrossLine.backgroundColor = self.crossLineColor;
        [self addSubview:_verticalCrossLine];
    }
    return _verticalCrossLine;
}

- (UIView *)horizontalCrossLine {
    if (!_horizontalCrossLine) {
        _horizontalCrossLine = [[UIView alloc] initWithFrame:CGRectMake((self.fullScreen ? 0 : self.leftMargin), self.topMargin, self.xAxisWidth, 0.5)];
        _horizontalCrossLine.backgroundColor = self.crossLineColor;
        [self addSubview:_horizontalCrossLine];
    }
    return _horizontalCrossLine;
}

- (UIView *)barVerticalLine {
    if (!_barVerticalLine) {
        _barVerticalLine = [[UIView alloc] initWithFrame:CGRectMake((self.fullScreen ? 0 : self.leftMargin), self.topMargin + self.yAxisHeight + self.timeAxisHeight, 0.5, self.frame.size.height - (self.topMargin + self.yAxisHeight + self.timeAxisHeight))];
        _barVerticalLine.backgroundColor = self.crossLineColor;
        [self addSubview:_barVerticalLine];
    }
    return _barVerticalLine;
}

- (KLineTipBoardView *)tipBoard {
    if (!_tipBoard) {
        _tipBoard = [[KLineTipBoardView alloc] initWithFrame:CGRectMake((self.fullScreen ? 0 : self.leftMargin), self.topMargin, 115.0f, 24.0f + [UIFont systemFontOfSize:14.0f].lineHeight*4.0f)];
        _tipBoard.backgroundColor = [UIColor clearColor];
        _tipBoard.font = [UIFont systemFontOfSize:14.0f];
        [self addSubview:_tipBoard];
    }
    return _tipBoard;
}

- (MATipView *)maTipView {
    if (!_maTipView) {
        _maTipView = [[MATipView alloc] initWithFrame:CGRectMake((self.fullScreen ? 0 : self.leftMargin) + 20, self.topMargin - 18.0f, self.frame.size.width - (self.fullScreen ? 0 : self.leftMargin) - self.rightMargin - 20, 13.0f)];
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
        _timeLbl.numberOfLines = 0;
        [self addSubview:_timeLbl];
    }
    return _timeLbl;
}

- (UILabel *)priceLbl {
    if (!_priceLbl) {
        _priceLbl = [UILabel new];
        _priceLbl.backgroundColor = self.timeAndPriceTipsBackgroundColor;
        _priceLbl.textAlignment = NSTextAlignmentCenter;
        _priceLbl.font = [UIFont systemFontOfSize:self.xAxisTitleFont.pointSize + 2.0];
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

- (void)setChartValues:(NSArray<KLineItem *> *)chartValues {
    _chartValues = chartValues;
    
    CGFloat maxHigh = -MAXFLOAT;
    for (KLineItem *item in self.chartValues) {
        if (item.high.floatValue > maxHigh) {
            maxHigh = item.high.floatValue;
            self.highItem = item;
        }
    }
}

- (void)setKLineDrawNum:(NSInteger)kLineDrawNum {
    _kLineDrawNum = MAX(MIN(self.chartValues.count, kLineDrawNum), 0);
    
    if (_kLineDrawNum != 0) {
        self.kLineWidth = (self.frame.size.width - (self.fullScreen ? 0 : self.leftMargin) - self.rightMargin - _kLinePadding)/_kLineDrawNum - _kLinePadding;
    }
}

- (void)setKLineWidth:(CGFloat)kLineWidth {
    _kLineWidth = MIN(MAX(kLineWidth, self.minKLineWidth), self.maxKLineWidth);
}

- (void)setMaxKLineWidth:(CGFloat)maxKLineWidth {
    if (maxKLineWidth < _minKLineWidth) {
        maxKLineWidth = _minKLineWidth;
    }
    
    CGFloat realAxisWidth = (self.frame.size.width - (self.fullScreen ? 0 : self.leftMargin) - self.rightMargin - _kLinePadding);
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
    
    for (UIGestureRecognizer *gesture in self.gestureRecognizers) {
        gesture.enabled = supportGesture;
    }
}

- (void)setNumberOfMACount:(NSInteger)numberOfMACount {
    _numberOfMACount = numberOfMACount;
}

- (void)setBottomMargin:(CGFloat)bottomMargin {
    _bottomMargin = bottomMargin < _timeAxisHeight ? _timeAxisHeight : bottomMargin;
}

@end
