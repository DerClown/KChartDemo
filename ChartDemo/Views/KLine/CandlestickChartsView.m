//
//  TYBarChartView.m
//  CandlerstickCharts
//
//  k线图
//  Created by xdliu on 16/8/11.
//  Copyright © 2016年 liuxd. All rights reserved.
//

#import "CandlestickChartsView.h"
#import "UIBezierPath+curved.h"
#import "ACMacros.h"
#import "Global+Helper.h"
#import "VOLView.h"
#import "KLineItem.h"
#import "CandlestickView.h"
#import <Masonry.h>
#import "KLineDataTransport.h"
#import "CandlestickTipView.h"

@interface CandlestickChartsView ()<KLineDataTransportDelegate, CandlestickViewDelegate>

// 成交量图
@property (nonatomic, strong) VOLView *volView;

@property (nonatomic, assign) CGFloat yAxisHeight;

@property (nonatomic, assign) CGFloat xAxisWidth;

@property (nonatomic, strong) NSArray<KLineItem *> *chartDataSources;

@property (nonatomic, assign) NSInteger startDrawIndex;

@property (nonatomic, assign) NSInteger needDrawingCandlestickNumber;

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
@property (nonatomic, strong) CandlestickView *candleView;

@property (nonatomic, strong) NSArray<UILabel *> *yAsixLableContainers;
@property (nonatomic, strong) NSArray<UILabel *> *xAsixLableContainers;

//十字线
@property (nonatomic, strong) UIView *verticalCrossLine;     //垂直十字线
@property (nonatomic, strong) UIView *horizontalCrossLine;   //水平十字线

//时间
@property (nonatomic, strong) UILabel *dateLabel;
//价格
@property (nonatomic, strong) UILabel *priceLabel;

@property (nonatomic, strong) CandlestickTipView *tipView;

@end

@implementation CandlestickChartsView

- (void)clean {
    _lock = NO;
    self.chartDataSources = nil;
    [_candleView clean];
}

#pragma mark - life cycle

- (void)dealloc {
    [self clean];
}

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
    
    self.dateTipAndPriceTipBackgroundColor = HexRGB(0xD70002);
    self.dateTipAndPriceTipTextColor = [UIColor colorWithWhite:1.0 alpha:0.95];
    
    self.supportGesture = YES;
    
    self.maxCandleWidth = 24;
    self.minCandleWidth = 1.5;
    
    self.kCandleWidth = 5.0;
    self.kCandleFixedSpacing = 1.8;
    
    self.lastPinchScale = 1.0;
    self.lastTouchIndex = -1;
    
    // 添加试图
    [self addPageSubViews];
    
    //添加手势
    [self addGestureRecognizers];
}

- (void)addPageSubViews {
    _candleView = [[CandlestickView alloc] initWithFrame:self.bounds];
    _candleView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
    _candleView.kCandleWidth = _kCandleWidth;
    _candleView.kCandleFixedSpacing = _kCandleFixedSpacing;
    _candleView.negativeCandleColor = _negativeLineColor;
    _candleView.positiveCandleColor = _positiveLineColor;
    _candleView.MAColors = self.MAColors;
    _candleView.delegate = self;
    [self addSubview:_candleView];
    
    if (self.showVolChart) {
        _volView = [VOLView new];
        _volView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
        _volView.barWidth = _kCandleWidth;
        _volView.barFixedSpacing = _kCandleFixedSpacing;
        _volView.negativeVOLColor = _negativeLineColor;
        _volView.positiveVOLColor = _positiveLineColor;
        [self addSubview:_volView];
    }
    
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
    
    [self randerUI];
}

- (void)drawSetting {
    self.leftMargin += 10.0f;
    
    self.xAxisWidth = self.frame.size.width - self.rightMargin - (self.fullScreen ? 0 : self.leftMargin);
    
    //y坐标轴高度
    self.yAxisHeight = self.frame.size.height - self.bottomMargin - self.topMargin;
    
    _candleView.frame = CGRectMake(self.frame.size.width - self.xAxisWidth, self.topMargin, self.xAxisWidth, self.yAxisHeight);
    
    float volYOrigin = _candleView.frame.origin.y + self.yAxisHeight + 25.0f;
    _volView.frame = CGRectMake(self.frame.size.width - self.xAxisWidth, volYOrigin, self.xAxisWidth, self.frame.size.height - volYOrigin);
    
    //更具宽度和间距确定要画多少个k线柱形图
    self.needDrawingCandlestickNumber = floor(((self.frame.size.width - (self.fullScreen ? 0 : self.leftMargin) - self.rightMargin - _kCandleFixedSpacing) / (self.kCandleWidth + self.kCandleFixedSpacing)));
    
    //确定从第几个开始画
    self.startDrawIndex = self.chartDataSources.count > 0 ? self.chartDataSources.count - self.needDrawingCandlestickNumber : 0;
    
    float avgHeight = _candleView.frame.size.height/5.0, fontHeight = self.yAxisTitleFont.lineHeight;
    for (int i = 0; i < self.yAsixLableContainers.count; i ++) {
        float diffHeight = i == 0 ? 1 : (i == self.yAsixLableContainers.count - 1 ? fontHeight : fontHeight*0.5);
        CGRect frame = CGRectMake(1.0f, avgHeight*i - diffHeight + self.topMargin, self.leftMargin, self.yAxisTitleFont.lineHeight);
        
        self.yAsixLableContainers[i].frame = frame;
    }
}

- (void)randerUI {
    _lock = YES;
    
    while ([self askLock:&_lock]) {
        [self drawCandlestick];
        [self drawVOL];
        [self updateAxisTitles];
        _lock = NO;
    }
}

- (void)drawCandlestick {
    _candleView.maxmumPrice = self.dataTransport.maxmumPrice;
    _candleView.minmumPrice = self.dataTransport.minmumPrice;
    
    [_candleView updateCandleForData:self.dataTransport.getNeedDrawingCandleData];
    [_candleView updateMAWithData:self.dataTransport.getMovingAverageData];
}

- (void)drawVOL {
    _volView.maxmumVol = self.dataTransport.maxmumVol;
    _volView.minmunVol = self.dataTransport.minmumVol;
    
    [_volView updateVolWithData:self.dataTransport.getNeedDrawingCandleData];
}

- (void)updateAxisTitles {
    float avg = (_candleView.maxmumPrice - _candleView.minmumPrice)/5.0;
    for (int i = 0; i < self.yAsixLableContainers.count; i ++) {
        self.yAsixLableContainers[i].text = [self.dataTransport getPriceString:@(_candleView.maxmumPrice - (i == self.yAsixLableContainers.count - 1 ? _candleView.minmumPrice : avg*i))];
    }
}

- (void)updateChartWithKLineItem:(KLineItem *)item {
    // 等待解锁
    while ([self askLock:&_lock]);
    
    BOOL isNew = (self.chartDataSources.count == 0 || ![self.chartDataSources.lastObject.date isEqualToString:item.date]);
    if (isNew) {
        self.chartDataSources = [self.chartDataSources arrayByAddingObject:item];
    } else {
        float high = MAX(item.high.floatValue, self.chartDataSources.lastObject.high.floatValue);
        float low = MIN(item.low.floatValue, self.chartDataSources.lastObject.low.floatValue);
        
        self.chartDataSources.lastObject.high = @(high);
        self.chartDataSources.lastObject.low = @(low);
        self.chartDataSources.lastObject.close = item.close;
    }
    
    [self randerUI];
}

#pragma mark - gesture events

- (void)tapTouchHandler:(UIGestureRecognizer *)gestureRecognizer {
    if (self.chartDataSources.count == 0) {
        return;
    }
    
    [self cancelAllActions];
    CGPoint touchPoint = [gestureRecognizer locationInView:self];
    [self showTipWithTouchPoint:touchPoint];
    [self performSelector:@selector(hideTips) withObject:nil afterDelay:2.5];
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
        if (self.startDrawIndex == self.chartDataSources.count - self.needDrawingCandlestickNumber) {
            return;
        }
        
        self.startDrawIndex = self.startDrawIndex + offsetIndex + self.needDrawingCandlestickNumber > self.chartDataSources.count ? self.chartDataSources.count - self.needDrawingCandlestickNumber : self.startDrawIndex + offsetIndex;
    }
    
    [self randerUI];
    
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
    
    CGFloat forwardDrawCount = _needDrawingCandlestickNumber;
    
    self.needDrawingCandlestickNumber = floor((self.frame.size.width - (self.fullScreen ? 0 : self.leftMargin) - self.rightMargin) / (self.kCandleWidth + self.kCandleFixedSpacing));
    
    //容差处理
    CGFloat diffWidth = (self.frame.size.width - (self.fullScreen ? 0 : self.leftMargin) - self.rightMargin) - (self.kCandleWidth + self.kCandleFixedSpacing)*_needDrawingCandlestickNumber;
    if (diffWidth > 4*(self.kCandleWidth + self.kCandleFixedSpacing)/5.0) {
        self.needDrawingCandlestickNumber = _needDrawingCandlestickNumber + 1;
    }
    
    self.needDrawingCandlestickNumber = self.chartDataSources.count > 0 && _needDrawingCandlestickNumber < self.chartDataSources.count ? _needDrawingCandlestickNumber : self.chartDataSources.count;
    if (forwardDrawCount == self.needDrawingCandlestickNumber && self.maxCandleWidth != self.kCandleWidth) {
        return;
    }
    
    NSInteger diffCount = fabs(self.needDrawingCandlestickNumber - forwardDrawCount);
    
    if (forwardDrawCount > self.startDrawIndex) {
        // 放大
        self.startDrawIndex += ceil(diffCount/2.0);
    } else {
        // 缩小
        self.startDrawIndex -= floor(diffCount/2.0);
        self.startDrawIndex = self.startDrawIndex < 0 ? 0 : self.startDrawIndex;
    }
    
    self.startDrawIndex = self.startDrawIndex + self.needDrawingCandlestickNumber > self.chartDataSources.count ? self.chartDataSources.count - self.needDrawingCandlestickNumber : self.startDrawIndex;
    
    [self randerUI];
    
    pinchGesture.scale = scale;
    self.lastPinchScale = scale;
}

- (void)longTouchHander:(UILongPressGestureRecognizer *)longGesture {
    if (self.chartDataSources.count == 0) {
        return;
    }
    
    if (longGesture.state == UIGestureRecognizerStateEnded) {
        [self performSelector:@selector(hideTips) withObject:nil afterDelay:2.5];
    } else {
        [self cancelAllActions];
        
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
    float scale = (_candleView.maxmumPrice - _candleView.minmumPrice)/_candleView.frame.size.height;
    float height = MIN(MAX((touchItem.close.floatValue - _candleView.minmumPrice)/scale, 0.5), _candleView.frame.size.height - 0.5);
    
    float verticalXOrigin = (self.fullScreen ? 0 : self.leftMargin) + touchIndex*(_candleView.kCandleWidth + _candleView.kCandleFixedSpacing) - _candleView.kCandleWidth*0.5, horizontalYOrigin = self.topMargin + _candleView.frame.size.height - height + (touchItem.close.floatValue < touchItem.open.floatValue ? 0.5 : - 0.5);
    
    self.horizontalCrossLine.frame = CGRectMake((self.fullScreen ? 0 : self.leftMargin) + 1.0, horizontalYOrigin, self.frame.size.width - (self.fullScreen ? 0 : self.leftMargin), 0.5);
    self.verticalCrossLine.frame = CGRectMake(verticalXOrigin + 0.75, self.topMargin + 0.5, 0.5, self.yAxisHeight);
    
    self.priceLabel.text = touchItem.close.stringValue;
    self.dateLabel.text = touchItem.date;
    
    CGSize size = [self.priceLabel sizeThatFits:CGSizeMake(100, 100)];
    self.priceLabel.frame = CGRectMake(1.0, MIN(MAX(1.0, self.horizontalCrossLine.frame.origin.y - size.height/2.0), self.topMargin + _candleView.frame.size.height - size.height), size.width, size.height);
    size = [self.dateLabel sizeThatFits:CGSizeMake(100, 100)];
    self.dateLabel.frame = CGRectMake(MIN(MAX(self.verticalCrossLine.frame.origin.x - size.width/2.0, 1.0), self.frame.size.width - size.width), self.topMargin + _candleView.frame.size.height, size.width, size.height + 1.0);
    
    _tipView.close = [self.dataTransport getPriceString:touchItem.close];
    _tipView.open = [self.dataTransport getPriceString:touchItem.open];
    _tipView.high = [self.dataTransport getPriceString:touchItem.high];
    _tipView.low = [self.dataTransport getPriceString:touchItem.low];
    
    size = _tipView.fitSize;
    
    float xOrigin = 0.0, yOrigin = 0.0;
    if (self.verticalCrossLine.frame.origin.x - size.width - MIN(2*_kCandleWidth, _maxCandleWidth/2.0f +2) - (self.fullScreen? _leftMargin : 0) < 0) {
        // 展示在右边
        xOrigin = self.verticalCrossLine.frame.origin.x + 2*_kCandleWidth;
    } else {
        xOrigin = self.verticalCrossLine.frame.origin.x - 2*_kCandleWidth - size.width;
    }
    
    if (self.horizontalCrossLine.frame.origin.y - size.height - MIN(2*_kCandleWidth, _maxCandleWidth/2.0f +2) - self.topMargin < 0) {
        // 显示在下面
        yOrigin = self.horizontalCrossLine.frame.origin.y + 2*_kCandleWidth;
    } else {
        yOrigin = self.horizontalCrossLine.frame.origin.y - size.height - 2*_kCandleWidth;
    }
    
    _tipView.frame = CGRectMake(xOrigin, yOrigin, size.width, size.height);
}

- (void)hideTips {
    [_verticalCrossLine removeFromSuperview];
    [_horizontalCrossLine removeFromSuperview];
    [_priceLabel removeFromSuperview];
    [_dateLabel removeFromSuperview];
    [_tipView removeFromSuperview];
    _verticalCrossLine = nil;
    _horizontalCrossLine = nil;
    _priceLabel = nil;
    _dateLabel = nil;
    _tipView = nil;
}

- (void)cancelAllActions {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideTips) object:nil];
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

- (CandlestickTipView *)tipView {
    if (!_tipView) {
        _tipView = [CandlestickTipView new];
        [self addSubview:_tipView];
    }
    return _tipView;
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

- (NSArray<KLineItem *> *)chartDataSources {
    if (!_chartDataSources) {
        _chartDataSources = @[];
    }
    return _chartDataSources;
}

#pragma mark - setters

- (void)setSeparatorNumber:(NSInteger)separatorNumber {
    _candleView.separatorNumber = separatorNumber;
}

- (void)setNeedDrawingCandlestickNumber:(NSInteger)kLineDrawNum {
    _needDrawingCandlestickNumber = MAX(MIN(self.chartDataSources.count, kLineDrawNum), 0);
    
    if (_needDrawingCandlestickNumber != 0) {
        self.kCandleWidth = (self.frame.size.width - (self.fullScreen ? 0 : self.leftMargin) - self.rightMargin - _kCandleFixedSpacing)/_needDrawingCandlestickNumber - _kCandleFixedSpacing;
    }
    
    self.dataTransport.needDrawingCandleNumber = _needDrawingCandlestickNumber;
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

- (void)setMaxnumIntegerDigits:(NSUInteger)maxnumIntegerDigits {
    self.dataTransport.maxnumIntegerDigits = MAX(0, MIN(maxnumIntegerDigits, 3));
}

@end
