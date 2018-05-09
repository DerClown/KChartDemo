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
#import "ACMacros.h"
#import "Global+Helper.h"
#import "VolumnView.h"
#import "KLineItem.h"
#import "KCandleView.h"
#import <Masonry.h>
#import "KLineDataTransport.h"

@interface KLineChartView ()<KLineDataTransportDelegate, KCandleViewDelegate>

// 成交量图
@property (nonatomic, strong) VolumnView *volView;

@property (nonatomic, assign) CGFloat yAxisHeight;

@property (nonatomic, assign) CGFloat xAxisWidth;

@property (nonatomic, strong) NSArray<KLineItem *> *chartDataSources;

@property (nonatomic, assign) NSInteger startDrawIndex;

@property (nonatomic, assign) NSInteger needDrawCandleNumber;

//手势
@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;
@property (nonatomic, strong) UIPanGestureRecognizer *panGestureRecognizer;

@property (nonatomic, strong) UIPinchGestureRecognizer *pinchGestureRecognizer;
@property (nonatomic, assign) CGFloat lastPinchScale;

@property (nonatomic, strong) UILongPressGestureRecognizer *longPressGestureRecognizer;
@property (nonatomic) NSInteger lastTouchIndex;

// 申请锁
@property (nonatomic, assign) BOOL lock;

@property (nonatomic, strong) KLineDataTransport *dataTransport;
@property (nonatomic, strong) KCandleView *candleView;

@property (nonatomic, strong) NSArray<UILabel *> *yAsixLableContainers;
@property (nonatomic, strong) NSArray<UILabel *> *xAsixLableContainers;

//十字线
@property (nonatomic, strong) UIView *verticalCrossLine;     //垂直十字线
@property (nonatomic, strong) UIView *horizontalCrossLine;   //水平十字线

//时间
@property (nonatomic, strong) UILabel *dateLabel;
//价格
@property (nonatomic, strong) UILabel *priceLabel;

@end

@implementation KLineChartView

#pragma mark - life cycle

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self _setup];
    }
    return self;
}

- (void)_setup {
    self.fullScreen = YES;
    
    self.positiveLineColor = [UIColor colorWithRed:(31/255.0f) green:(185/255.0f) blue:(63.0f/255.0f) alpha:1.0];
    self.negativeLineColor = [UIColor colorWithRed:(232/255.0f) green:(50.0f/255.0f) blue:(52.0f/255.0f) alpha:1.0];
    
    self.movingAvgLineWidth = 0.8;
    
    self.MAColors = @[HexRGB(0x019FFD), HexRGB(0xFF9900), HexRGB(0xFF00FF)];
    
    self.separatorColor = [UIColor colorWithRed:230/255.0f green:230/255.0f blue:230/255.0f alpha:1.0];
    self.separatorWidth = 0.5;
    
    self.yAxisTitleFont = [UIFont systemFontOfSize:8.0];
    self.yAxisTitleColor = [UIColor colorWithRed:(130/255.0f) green:(130/255.0f) blue:(130/255.0f) alpha:1.0];
    
    self.xAxisTitleFont = [UIFont systemFontOfSize:8.0];
    self.xAxisTitleColor = [UIColor colorWithRed:(130/255.0f) green:(130/255.0f) blue:(130/255.0f) alpha:1.0];
    
    self.crossLineColor = HexRGB(0xC9C9C9);
    
    self.scrollEnable = YES;
    
    self.zoomEnable = YES;
    
    self.showMA = YES;
    
    self.showVolChart = YES;
    
    self.isVisiableViewerExtremeValue = YES;
    
    self.saveDecimalPlaces = 2;
    
    self.dateTipAndPriceTipBackgroundColor = HexRGB(0xD70002);
    self.dateTipAndPriceTipTextColor = [UIColor colorWithWhite:1.0 alpha:0.95];
    
    self.supportGesture = YES;
    
    self.maxCandleWidth = 24;
    self.minCandleWidth = 1.5;
    
    self.kCandleWidth = 8.0;
    self.kCandleFixedSpacing = 2.0;
    
    self.lastPinchScale = 1.0;
    self.lastTouchIndex = -1;
    
    // 添加试图
    [self addPageSubViews];
    
    //添加手势
    [self addGestureRecognizers];
}

- (void)addPageSubViews {
    _candleView = [[KCandleView alloc] initWithFrame:self.bounds];
    _candleView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
    _candleView.kCandleWidth = _kCandleWidth;
    _candleView.kCandleFixedSpacing = _kCandleFixedSpacing;
    _candleView.negativeCandleColor = _negativeLineColor;
    _candleView.positiveCandleColor = _positiveLineColor;
    _candleView.MAColors = self.MAColors;
    _candleView.delegate = self;
    [self addSubview:_candleView];
    
    NSMutableArray *yAsixLables = [NSMutableArray new];
    for (int i = 0; i < 6; i ++) {
        UILabel *yAsixLbl = [UILabel new];
        yAsixLbl.font = self.yAxisTitleFont;
        yAsixLbl.textColor = self.yAxisTitleColor;
        yAsixLbl.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
        [self addSubview:yAsixLbl];
        [yAsixLables addObject:yAsixLbl];
    }
    self.yAsixLableContainers = yAsixLables;
    
    NSMutableArray *xAsixLables = [NSMutableArray new];
    for (int i = 0; i < _candleView.separatorNumber; i ++) {
        UILabel *xAsixLbl = [UILabel new];
        xAsixLbl.font = self.xAxisTitleFont;
        xAsixLbl.textColor = self.xAxisTitleColor;
        xAsixLbl.numberOfLines = 0;
        xAsixLbl.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
        [self addSubview:xAsixLbl];
        [xAsixLables addObject:xAsixLbl];
    }
    self.xAsixLableContainers = xAsixLables;
}

/**
 *  添加手势
 */
- (void)addGestureRecognizers {
    [self addGestureRecognizer:self.tapGestureRecognizer];
    [self addGestureRecognizer:self.panGestureRecognizer];
    [self addGestureRecognizer:self.pinchGestureRecognizer];
    [self addGestureRecognizer:self.longPressGestureRecognizer];
}

- (void)removeGestureRecognizers {
    [self addGestureRecognizer:_tapGestureRecognizer];
    [self addGestureRecognizer:_panGestureRecognizer];
    [self addGestureRecognizer:_pinchGestureRecognizer];
    [self addGestureRecognizer:_longPressGestureRecognizer];
    
    _tapGestureRecognizer = nil;
    _panGestureRecognizer = nil;
    _pinchGestureRecognizer = nil;
    _longPressGestureRecognizer = nil;
}

- (BOOL)askLock:(BOOL *)lock {
    BOOL spinLock = *lock;
    return spinLock;
}

#pragma mark - render UI

- (void)drawChartWithData:(NSArray *)data {
    if ([self askLock:&_lock]) {
        return;
    }
    
    self.chartDataSources = data;
    
    // 绘制前的一些设置项
    [self drawSetting];
    
    [self drawStockViewer];
    
    // 更新坐标标题
    [self updateAxisTitles];
}

- (void)drawSetting {
    self.leftMargin += 10.0f;
    
    self.xAxisWidth = self.frame.size.width - self.rightMargin - (self.fullScreen ? 0 : self.leftMargin);
    
    //y坐标轴高度
    self.yAxisHeight = self.frame.size.height - self.bottomMargin - self.topMargin;
    
    _candleView.frame = CGRectMake(self.frame.size.width - self.xAxisWidth, self.topMargin, self.xAxisWidth, self.yAxisHeight);
    
    //更具宽度和间距确定要画多少个k线柱形图
    self.needDrawCandleNumber = floor(((self.frame.size.width - (self.fullScreen ? 0 : self.leftMargin) - self.rightMargin - _kCandleFixedSpacing) / (self.kCandleWidth + self.kCandleFixedSpacing)));
    
    //确定从第几个开始画
    self.startDrawIndex = self.chartDataSources.count > 0 ? self.chartDataSources.count - self.needDrawCandleNumber : 0;
    
    float avgHeight = _candleView.frame.size.height/5.0, fontHeight = self.yAxisTitleFont.lineHeight;
    for (int i = 0; i < self.yAsixLableContainers.count; i ++) {
        float diffHeight = i == 0 ? 1 : (i == self.yAsixLableContainers.count - 1 ? fontHeight : fontHeight*0.5);
        CGRect frame = CGRectMake(1.0f, avgHeight*i - diffHeight + self.topMargin, self.leftMargin, self.yAxisTitleFont.lineHeight);
        
        self.yAsixLableContainers[i].frame = frame;
    }
}

- (void)drawStockViewer {
    _lock = YES;
    
    while ([self askLock:&_lock]) {
        _candleView.maxValue = self.dataTransport.maxValue;
        _candleView.minValue = self.dataTransport.minValue;
        
        [_candleView updateCandleForData:self.dataTransport.getNeedDrawingCandleData];
        [_candleView updateMAWithData:self.dataTransport.getMovingAverageData];
        _lock = NO;
    }
}

- (void)updateAxisTitles {
    float avg = (_candleView.maxValue - _candleView.minValue)/5.0;
    for (int i = 0; i < self.yAsixLableContainers.count; i ++) {
        self.yAsixLableContainers[i].text = [self saveDecimalPlaceWithNum:@(_candleView.maxValue - (i == self.yAsixLableContainers.count - 1 ? _candleView.minValue : avg*i))];
    }
}

#pragma mark - gesture events

- (void)tapTouchHandler:(UITapGestureRecognizer *)tapGesture {
    if (self.chartDataSources.count == 0 || !self.chartDataSources) {
        return;
    }
    
    CGPoint touchPoint = [tapGesture locationInView:_candleView];
    [self showTipWithTouchPoint:touchPoint];
}

- (void)panTouchHandler:(UIPanGestureRecognizer *)panGesture {
    if ([self askLock:&_lock] || !self.scrollEnable || self.chartDataSources.count == 0) {
        return;
    }
    
    CGPoint touchPoint = [panGesture translationInView:self];
    NSInteger offsetIndex = fabs(touchPoint.x/(self.kCandleWidth > self.maxCandleWidth/2.0 ? 12 : 8));
    if (offsetIndex == 0) {
        return;
    }
    
    
    if (touchPoint.x > 0) {
        if (self.startDrawIndex == 0) {
            return;
        }
        self.startDrawIndex = self.startDrawIndex - offsetIndex < 0 ? 0 : self.startDrawIndex - offsetIndex;
    } else {
        if (self.startDrawIndex == self.chartDataSources.count - self.needDrawCandleNumber) {
            return;
        }
        
        self.startDrawIndex = self.startDrawIndex + offsetIndex + self.needDrawCandleNumber > self.chartDataSources.count ? self.chartDataSources.count - self.needDrawCandleNumber : self.startDrawIndex + offsetIndex;
    }
    
    [self drawStockViewer];
    [self updateAxisTitles];
    
    [panGesture setTranslation:CGPointZero inView:self];
}

- (void)pinchTouchHandler:(UIPinchGestureRecognizer *)pinchGesture {
    if (!self.zoomEnable || self.chartDataSources.count == 0 || [self askLock:&_lock]) {
        return;
    }
    
    CGFloat scale = pinchGesture.scale - self.lastPinchScale + 1;
    if (self.lastPinchScale > scale) {
        if (_minCandleWidth > _kCandleWidth*scale && _minCandleWidth >= _kCandleWidth) return;
    } else {
        if (_kCandleWidth >= _kCandleWidth*scale && _maxCandleWidth <= _kCandleWidth) return;
    }
    
    self.kCandleWidth = _kCandleWidth*scale;
    
    CGFloat forwardDrawCount = _needDrawCandleNumber;
    
    self.needDrawCandleNumber = floor((self.frame.size.width - (self.fullScreen ? 0 : self.leftMargin) - self.rightMargin) / (self.kCandleWidth + self.kCandleFixedSpacing));
    
    //容差处理
    CGFloat diffWidth = (self.frame.size.width - (self.fullScreen ? 0 : self.leftMargin) - self.rightMargin) - (self.kCandleWidth + self.kCandleFixedSpacing)*_needDrawCandleNumber;
    if (diffWidth > 4*(self.kCandleWidth + self.kCandleFixedSpacing)/5.0) {
        self.needDrawCandleNumber = _needDrawCandleNumber + 1;
    }
    
    self.needDrawCandleNumber = self.chartDataSources.count > 0 && _needDrawCandleNumber < self.chartDataSources.count ? _needDrawCandleNumber : self.chartDataSources.count;
    if (forwardDrawCount == self.needDrawCandleNumber && self.maxCandleWidth != self.kCandleWidth) {
        return;
    }
    
    NSInteger diffCount = fabs(self.needDrawCandleNumber - forwardDrawCount);
    
    if (forwardDrawCount > self.startDrawIndex) {
        // 放大
        self.startDrawIndex += ceil(diffCount/2.0);
    } else {
        // 缩小
        self.startDrawIndex -= floor(diffCount/2.0);
        self.startDrawIndex = self.startDrawIndex < 0 ? 0 : self.startDrawIndex;
    }
    
    self.startDrawIndex = self.startDrawIndex + self.needDrawCandleNumber > self.chartDataSources.count ? self.chartDataSources.count - self.needDrawCandleNumber : self.startDrawIndex;
    
    [self drawStockViewer];
    [self updateAxisTitles];
    
    pinchGesture.scale = scale;
    self.lastPinchScale = scale;
}

- (void)longTouchHander:(UILongPressGestureRecognizer *)longGesture {
    if (self.chartDataSources.count == 0 || !self.chartDataSources) {
        return;
    }
    
    if (longGesture.state == UIGestureRecognizerStateEnded) {
        [self hideTips];
    } else {
        CGPoint touchPoint = [longGesture locationInView:self];
        [self showTipWithTouchPoint:touchPoint];
    }
}

- (void)showTipWithTouchPoint:(CGPoint)touchPoint {
    NSInteger touchIndex = touchPoint.x/(_candleView.kCandleWidth + _candleView.kCandleFixedSpacing)/1;
    // 不符合要求，不继续操作
    if (touchIndex <= 0 || touchIndex > self.dataTransport.needDrawingCandleNumber || self.lastTouchIndex == touchIndex) return;
    
    self.lastTouchIndex = touchIndex;
    KLineItem *touchItem = self.chartDataSources[touchIndex + self.startDrawIndex - 1];
    
    // 计算高度
    float scale = (_candleView.maxValue - _candleView.minValue)/_candleView.frame.size.height;
    float height = MIN(MAX((touchItem.close.floatValue - _candleView.minValue)/scale, 0.5), _candleView.frame.size.height - 0.5);
    
    float verticalXOrigin = (self.fullScreen ? 0 : self.leftMargin) + touchIndex*(_candleView.kCandleWidth + _candleView.kCandleFixedSpacing) - _candleView.kCandleWidth*0.5, horizontalYOrigin = self.topMargin + _candleView.frame.size.height - height + (touchItem.close.floatValue < touchItem.open.floatValue ? 0.5 : - 0.5);
    
    self.verticalCrossLine.hidden = NO;
    self.horizontalCrossLine.hidden = NO;
    self.verticalCrossLine.frame = CGRectMake(verticalXOrigin, self.topMargin + 0.5, 0.5, self.yAxisHeight);
    self.horizontalCrossLine.frame = CGRectMake((self.fullScreen ? 0 : self.leftMargin) + 1.0, horizontalYOrigin, self.frame.size.width - (self.fullScreen ? 0 : self.leftMargin), 0.5);
    
    
    self.priceLabel.hidden = NO;
    self.dateLabel.hidden = NO;
    self.priceLabel.text = touchItem.close.stringValue;
    self.dateLabel.text = touchItem.date;
    
    CGSize size = [self.priceLabel sizeThatFits:CGSizeMake(100, 100)];
    self.priceLabel.frame = CGRectMake(1.0, MIN(MAX(1.0, self.horizontalCrossLine.frame.origin.y - size.height/2.0), self.topMargin + _candleView.frame.size.height - size.height), size.width, size.height);
    size = [self.dateLabel sizeThatFits:CGSizeMake(100, 100)];
    self.dateLabel.frame = CGRectMake(MIN(MAX(self.verticalCrossLine.frame.origin.x - size.width/2.0, 1.0), self.frame.size.width - size.width), self.topMargin + _candleView.frame.size.height, size.width, size.height + 1.0);
}

- (void)hideTips {
    self.verticalCrossLine.hidden = YES;
    self.horizontalCrossLine.hidden = YES;
    self.priceLabel.hidden = YES;
    self.dateLabel.hidden = YES;
}

#pragma mark - private methods

- (NSString *)saveDecimalPlaceWithNum:(NSNumber *)num {
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
    _lock = NO;
    self.chartDataSources = nil;
    [_candleView clean];
}

#pragma mark - KCandleViewDelegate

- (void)xAxis_coordinate:(float)x_coordinate date:(NSString *)date atIndex:(NSInteger)index {
    UILabel *xAxisLbl = self.xAsixLableContainers[index];
    xAxisLbl.text = date;
    CGSize size = [xAxisLbl sizeThatFits:CGSizeMake(100, 100)];
    xAxisLbl.frame = CGRectMake((self.fullScreen ? x_coordinate : self.leftMargin + x_coordinate) - size.width/2.0, self.topMargin + _candleView.frame.size.height + 0.5, size.width, size.height);
}

#pragma mark - KLineDataTransportDelegate

- (NSArray *)MAs {
    return self.Mas;
}

- (NSArray *)kLineDataSources {
    return self.chartDataSources;
}

#pragma mark - getters

- (UIView *)verticalCrossLine {
    if (!_verticalCrossLine) {
        _verticalCrossLine = [UIView new];
        _verticalCrossLine.backgroundColor = self.crossLineColor;
        [self addSubview:_verticalCrossLine];
    }
    return _verticalCrossLine;
}

- (UIView *)horizontalCrossLine {
    if (!_horizontalCrossLine) {
        _horizontalCrossLine = [UIView new];
        _horizontalCrossLine.backgroundColor = self.crossLineColor;
        [self addSubview:_horizontalCrossLine];
    }
    return _horizontalCrossLine;
}

- (UILabel *)dateLabel {
    if (!_dateLabel) {
        _dateLabel = [UILabel new];
        _dateLabel.backgroundColor = self.dateTipAndPriceTipBackgroundColor;
        _dateLabel.textAlignment = NSTextAlignmentCenter;
        _dateLabel.font = self.yAxisTitleFont;
        _dateLabel.textColor = self.dateTipAndPriceTipTextColor;
        _dateLabel.numberOfLines = 0;
        [self addSubview:_dateLabel];
    }
    return _dateLabel;
}

- (UILabel *)priceLabel {
    if (!_priceLabel) {
        _priceLabel = [UILabel new];
        _priceLabel.backgroundColor = self.dateTipAndPriceTipBackgroundColor;
        _priceLabel.textAlignment = NSTextAlignmentCenter;
        _priceLabel.font = [UIFont systemFontOfSize:self.xAxisTitleFont.pointSize + 2.0];
        _priceLabel.textColor = self.dateTipAndPriceTipTextColor;
        [self addSubview:_priceLabel];
    }
    return _priceLabel;
}

- (UITapGestureRecognizer *)tapGestureRecognizer {
    if (!_tapGestureRecognizer) {
        _tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapTouchHandler:)];
    }
    return _tapGestureRecognizer;
}

- (UIPanGestureRecognizer *)panGestureRecognizer {
    if (!_panGestureRecognizer) {
        _panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panTouchHandler:)];
    }
    return _panGestureRecognizer;
}

- (UIPinchGestureRecognizer *)pinchGestureRecognizer {
    if (!_pinchGestureRecognizer) {
        _pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchTouchHandler:)];
    }
    return _pinchGestureRecognizer;
}

- (UILongPressGestureRecognizer *)longPressGestureRecognizer {
    if (!_longPressGestureRecognizer) {
        _longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longTouchHander:)];
    }
    return _longPressGestureRecognizer;
}

- (KLineDataTransport *)dataTransport {
    if (!_dataTransport) {
        _dataTransport = [KLineDataTransport new];
        _dataTransport.delegate = self;
    }
    return _dataTransport;
}

#pragma mark - setters

- (void)setSeparatorNumber:(NSInteger)separatorNumber {
    _candleView.separatorNumber = separatorNumber;
}

- (void)setNeedDrawCandleNumber:(NSInteger)kLineDrawNum {
    _needDrawCandleNumber = MAX(MIN(self.chartDataSources.count, kLineDrawNum), 0);
    
    if (_needDrawCandleNumber != 0) {
        self.kCandleWidth = (self.frame.size.width - (self.fullScreen ? 0 : self.leftMargin) - self.rightMargin - _kCandleFixedSpacing)/_needDrawCandleNumber - _kCandleFixedSpacing;
    }
    
    self.dataTransport.needDrawingCandleNumber = _needDrawCandleNumber;
}

- (void)setStartDrawIndex:(NSInteger)startDrawIndex {
    _startDrawIndex = startDrawIndex;
    self.dataTransport.startIndex = startDrawIndex;
}

- (void)setKCandleWidth:(CGFloat)kLineWidth {
    _kCandleWidth = MIN(MAX(kLineWidth, self.minCandleWidth), self.maxCandleWidth);
    _candleView.kCandleWidth = _kCandleWidth;
}

- (void)setMaxCandleWidth:(CGFloat)maxKLineWidth {
    if (maxKLineWidth < _minCandleWidth) {
        maxKLineWidth = _minCandleWidth;
    }
    
    CGFloat realAxisWidth = (self.frame.size.width - (self.fullScreen ? 0 : self.leftMargin) - self.rightMargin - _kCandleFixedSpacing);
    NSInteger maxKLineCount = floor(realAxisWidth)/(maxKLineWidth + _kCandleFixedSpacing);
    maxKLineWidth = realAxisWidth/maxKLineCount - _kCandleFixedSpacing;
    
    _maxCandleWidth = maxKLineWidth;
}

- (void)setLeftMargin:(CGFloat)leftMargin {
    _leftMargin = leftMargin;
    
    self.maxCandleWidth = _maxCandleWidth;
}

- (void)setIsVisiableViewerExtremeValue:(BOOL)isVisiableViewerExtremeValue  {
    self.dataTransport.isVisableExtremeValue = isVisiableViewerExtremeValue;
}

- (void)setSupportGesture:(BOOL)supportGesture {
    if (!supportGesture) {
        [self removeGestureRecognizers];
    } else {
        [self addGestureRecognizers];
    }
}

- (void)setAxisColor:(UIColor *)axisColor {
    _candleView.layer.borderColor = axisColor.CGColor;
}

- (void)setAxisWidth:(CGFloat)axisWidth {
    _candleView.layer.borderWidth = axisWidth;
}

@end
