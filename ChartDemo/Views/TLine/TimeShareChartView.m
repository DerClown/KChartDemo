//
//  KLineView.m
//  CandlerstickCharts
//
//  折线图
//  Created by xdliu on 16/8/11.
//  Copyright © 2016年 liuxd. All rights reserved.
//

#import "TimeShareChartView.h"
#import "KLineDataTransport.h"
#import "TimeSharingChartContentView.h"
#import "KLineItem.h"

@interface TimeShareChartView ()<KLineDataTransportDelegate, TimeSharingChartContentViewDelegate>

@property (nonatomic, strong) KLineDataTransport *dataTransport;
@property (nonatomic, strong) TimeSharingChartContentView *chartContentView;

@property (nonatomic, strong) NSArray *chartDataSources;

@property (nonatomic, strong) NSArray<UILabel *> *yAsixLableContainers;
@property (nonatomic, strong) NSArray<UILabel *> *xAsixLableContainers;

@property (nonatomic, strong) UIView *verticalCrossLine;     //垂直十字线
@property (nonatomic, strong) UIView *horizontalCrossLine;   //水平十字线

@property (nonatomic, assign) NSInteger lastTouchIndex;

//时间
@property (nonatomic, strong) UILabel *dateLabel;
//价格
@property (nonatomic, strong) UILabel *priceLabel;

@end

@implementation TimeShareChartView

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setup];
        [self initPageSubviews];
        [self addGestures];
    }
    return self;
}

- (void)setup {
    self.yAxisTitleFont = [UIFont systemFontOfSize:8.0];
    self.yAxisTitleColor = [UIColor whiteColor];
    
    self.xAxisTitleFont = [UIFont systemFontOfSize:8.0];
    self.xAxisTitleColor = [UIColor colorWithRed:(130/255.0f) green:(130/255.0f) blue:(130/255.0f) alpha:1.0];
    
    self.crossLineColor = [UIColor colorWithRed:(201/255.0f) green:(201/255.0f) blue:(201/255.0f) alpha:1.0];
    
    self.self.dateTipAndPriceTipBackgroundColor = [UIColor colorWithRed:(215/255.0f) green:(0/255.0f) blue:(2/255.0f) alpha:1.0];
    self.dateTipAndPriceTipTextColor = [UIColor colorWithWhite:1.0 alpha:0.95];
    
    self.lastTouchIndex = -1;
}

- (void)initPageSubviews {
    _chartContentView = [[TimeSharingChartContentView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height - 20.0f)];
    _chartContentView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
    _chartContentView.delegate = self;
    [self addSubview:_chartContentView];
    
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
    for (int i = 0; i < 5; i ++) {
        UILabel *xAsixLbl = [UILabel new];
        xAsixLbl.font = self.xAxisTitleFont;
        xAsixLbl.textColor = self.xAxisTitleColor;
        xAsixLbl.numberOfLines = 0;
        xAsixLbl.textAlignment = NSTextAlignmentCenter;
        xAsixLbl.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
        [self addSubview:xAsixLbl];
        [xAsixLables addObject:xAsixLbl];
    }
    self.xAsixLableContainers = xAsixLables;
}

- (void)addGestures {
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapTouchHandler:)];
    UILongPressGestureRecognizer *longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longTouchHander:)];
    
    [self addGestureRecognizer:tapGesture];
    [self addGestureRecognizer:longPressGestureRecognizer];
}

#pragma mark - rander UI

- (void)drawChartWithData:(NSArray *)data {
    if (!data) return;
    
    self.chartDataSources = data;
    [self renderUI];
}

- (void)renderUI {
    [self drawTimeSharingChart];
    [self updateYAxisTitles];
}

- (void)drawTimeSharingChart {
    _chartContentView.maxmumPrice = self.dataTransport.maxmumPrice;
    _chartContentView.minmumPrice = self.dataTransport.minmumPrice;
    _chartContentView.needDrawingPointNumber = self.dataTransport.needDrawingCandleNumber;
    [_chartContentView updateChartWithData:self.dataTransport.getNeedDrawingTimeSharingChartData];
}

- (void)updateYAxisTitles {
    float avgPrice = (_chartContentView.maxmumPrice - _chartContentView.minmumPrice)/5.0f;
    
    float avgHeight = _chartContentView.frame.size.height/5.0f;
    for (int i = 0; i < 5.0f; i ++) {
        float yOrigin = avgHeight*(i + 1);
        
        UILabel *titleLbl = self.yAsixLableContainers[i];
        titleLbl.text = [self.dataTransport getPriceString:@(_chartContentView.maxmumPrice - (i + 1)*avgPrice)];
        
        CGSize size = [titleLbl sizeThatFits:CGSizeMake(100, 100)];
        
        titleLbl.frame = CGRectMake(0.5f, yOrigin - size.height, size.width, size.height);
    }
}

#pragma mark - response events

- (void)tapTouchHandler:(UIGestureRecognizer *)gestureRecognizer {
    if (self.chartDataSources.count == 0) {
        return;
    }
    
    // 取消所有方法
    [self cancelAllActions];
    CGPoint touchPoint = [gestureRecognizer locationInView:self.chartContentView];
    [self showTipsWithTouchPoint:touchPoint];
    [self performSelector:@selector(hideTips) withObject:nil afterDelay:2.5];
}

- (void)longTouchHander:(UIGestureRecognizer *)gestureRecognizer {
    if (self.chartDataSources.count == 0) {
        return;
    }
    
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        [self performSelector:@selector(hideTips) withObject:nil afterDelay:2.5];
    } else {
        // 取消所有方法
        [self cancelAllActions];
        CGPoint touchPoint = [gestureRecognizer locationInView:self.chartContentView];
        [self showTipsWithTouchPoint:touchPoint];
    }
}

- (void)hideTips {
    self.verticalCrossLine.hidden = YES;
    self.horizontalCrossLine.hidden = YES;
    self.priceLabel.hidden = YES;
    self.dateLabel.hidden = YES;
}

- (void)showTipsWithTouchPoint:(CGPoint)touchPoint {
    NSInteger touchIndex = touchPoint.x/self.chartContentView.linePadding/1;
    // 不符合要求，不继续操作
    if (touchIndex < 0 || touchIndex >= self.dataTransport.needDrawingCandleNumber || self.lastTouchIndex == touchIndex) return;
    
    self.lastTouchIndex = touchIndex;
    KLineItem *touchItem = self.dataTransport.getNeedDrawingTimeSharingChartData[touchIndex];
    
    float verticalXOrigin = 0.5 + self.chartContentView.linePadding*touchIndex;
    
    float scale = (self.chartContentView.maxmumPrice - self.chartContentView.minmumPrice)/(self.chartContentView.frame.size.height*1.0);
    float yOrigin = _chartContentView.frame.size.height  - (touchItem.close.floatValue - self.chartContentView.minmumPrice)/scale;
    
    self.verticalCrossLine.hidden = NO;
    self.horizontalCrossLine.hidden = NO;
    self.verticalCrossLine.frame = CGRectMake(MIN(verticalXOrigin, self.chartContentView.frame.size.width - 1.0), 0, 0.5, self.chartContentView.frame.size.height);
    self.horizontalCrossLine.frame = CGRectMake(0.5, yOrigin, self.frame.size.width - 1.0, 0.5);
    
    self.priceLabel.hidden = NO;
    self.dateLabel.hidden = NO;
    self.priceLabel.text = touchItem.close.stringValue;
    self.dateLabel.text = touchItem.date;
    
    CGSize size = [self.priceLabel sizeThatFits:CGSizeMake(100, 100)];
    self.priceLabel.frame = CGRectMake(1.0, MIN(MAX(1.0, self.horizontalCrossLine.frame.origin.y - size.height/2.0), _chartContentView.frame.size.height - size.height), size.width, size.height);
    size = [self.dateLabel sizeThatFits:CGSizeMake(100, 100)];
    self.dateLabel.frame = CGRectMake(MIN(MAX(self.verticalCrossLine.frame.origin.x - size.width/2.0, 1.0), self.frame.size.width - size.width), _chartContentView.frame.size.height, size.width, size.height + 1.0);
}

- (void)cancelAllActions {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideTips) object:nil];
}

#pragma mark - TimeSharingChartContentViewDelegate

- (void)xAxis_coordinate:(float)x_coordinate date:(NSString *)date atIndex:(NSInteger)index {
    float yOrigin = _chartContentView.frame.size.height + 1.5f;
    
    UILabel *titleLbl = self.xAsixLableContainers[index];
    titleLbl.text = date;
    CGSize size = [titleLbl sizeThatFits:CGSizeMake(100, 100)];
    
    titleLbl.frame = CGRectMake(MAX(0.5, x_coordinate - size.width/2.0f), yOrigin, size.width, size.height);
}

#pragma mark - KLineDataTransportDelegate

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

- (KLineDataTransport *)dataTransport {
    if (!_dataTransport) {
        _dataTransport = [KLineDataTransport new];
        _dataTransport.delegate = self;
        _dataTransport.needDrawingCandleNumber = 50;
        _dataTransport.isVisableExtremeValue = YES;
    }
    return _dataTransport;
}

#pragma mark - setters

- (void)setLineColor:(UIColor *)lineColor {
    _chartContentView.strokeColor = lineColor;
}

- (void)setGradientFillColor:(UIColor *)gradientFillColor {
    _chartContentView.fillColor = gradientFillColor;
}

- (void)setMaxnumIntegerDigits:(NSUInteger)maxnumIntegerDigits {
    self.dataTransport.maxnumIntegerDigits = MAX(0, MIN(maxnumIntegerDigits, 3));
}

@end
