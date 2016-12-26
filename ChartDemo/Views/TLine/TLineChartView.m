//
//  KLineView.m
//  CandlerstickCharts
//
//  折线图
//  Created by xdliu on 16/8/11.
//  Copyright © 2016年 liuxd. All rights reserved.
//

#import "TLineChartView.h"
#import "UIBezierPath+curved.h"
#import "TLineTipBoardView.h"
#import "KLineItem.h"
#import "ACMacros.h"

NSString *const TLineKeyStartUserInterfaceNotification = @"TLineKeyStartUserInterfaceNotification";
NSString *const TLineKeyEndOfUserInterfaceNotification = @"TLineKeyEndOfUserInterfaceNotification";

@interface TLineChartView ()

@property (nonatomic, strong) NSArray<KLineItem *> *chartData;

@property (nonatomic, assign) CGFloat xAxisWidth;

@property (nonatomic, assign) CGFloat yAxisHeight;

@property (nonatomic, assign) NSInteger kGraphDrawCount;

@property (nonatomic, assign) NSInteger startDrawIndex;

@property (nonatomic, assign) CGFloat maxValue;

@property (nonatomic, assign) CGFloat minValue;

@property (nonatomic, strong) NSDictionary *points;

@property (nonatomic, strong) TLineTipBoardView *tipBox;

@property (nonatomic, strong) UIView *vtlCrossLine; //垂直线

@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;

@property (nonatomic, strong) UILongPressGestureRecognizer *longGesture;

@property (nonatomic, strong) CALayer *flashLayer;

//价格
@property (nonatomic, strong) UILabel *timeLbl;

//交互中， 默认NO
@property (nonatomic, assign) BOOL interactive;

//数据更新
@property (nonatomic, strong) NSMutableArray *updateTempContexts;
@property (nonatomic, strong) NSMutableArray *updateTempDates;

@property (nonatomic, strong) KLineItem *highItem;

@end

@implementation TLineChartView

#pragma mark - life cycle

- (void)dealloc {
    [self stopFlashAnimation];
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
    
    self.pointPadding = 1.5;
    
    self.lineWidth = 0.8;
    self.lineColor = [UIColor colorWithRed:(128.0/255.0) green:(195.0f/255.0) blue:(220.0/255.0f) alpha:1.0];
    
    self.gradientStartColor = [UIColor colorWithRed:(96/255.0) green:(225/255.0) blue:(240/255.0f) alpha:0.5];
    self.gradientEndColor = [UIColor whiteColor];
    
    self.separatorColor = [UIColor colorWithRed:(230/255.0f) green:(230/255.0f) blue:(230/255.0f) alpha:1.0];
    self.separatorWidth = 0.5;
    
    self.yAxisTitleFont = [UIFont systemFontOfSize:8.0];
    self.yAxisTitleColor = [UIColor colorWithRed:(130/255.0f) green:(130/255.0f) blue:(130/255.0f) alpha:1.0];
    
    self.xAxisTitleFont = [UIFont systemFontOfSize:8.0];
    self.xAxisTitleColor = [UIColor colorWithRed:(130/255.0f) green:(130/255.0f) blue:(130/255.0f) alpha:1.0];
    
    self.timeAxisHeigth = 20.0;
    
    self.axisShadowColor = [UIColor colorWithRed:223/255.0f green:223/255.0f blue:223/255.0f alpha:1.0];
    self.axisShadowWidth = 0.5;
    
    self.separatorNum = 4;
    
    self.smoothPath = YES;
    
    self.crossLineColor = HexRGB(0xC9C9C9);
    
    self.flashPointColor = [UIColor redColor];
    
    self.yAxisTitleIsChange = YES;
    
    self.saveDecimalPlaces = 2;
    
    self.timeTipBackgroundColor = HexRGB(0xD70002);
    self.timeTipTextColor = [UIColor colorWithWhite:1.0 alpha:0.95];
    
    self.updateTempContexts = [NSMutableArray new];
    self.updateTempDates = [NSMutableArray new];
    
    [self addGestureRecognizer:self.tapGesture];
    [self addGestureRecognizer:self.longGesture];
}

/**
 *  通知
 */
- (void)registerObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startTouchNotification:) name:TLineKeyStartUserInterfaceNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(endOfTouchNotification:) name:TLineKeyEndOfUserInterfaceNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChangeNotification:) name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    [_vtlCrossLine removeFromSuperview];
    _vtlCrossLine = nil;
    self.timeLbl.hidden = YES;
    self.tipBox.hidden = YES;
    [self stopFlashAnimation];
    if (self.chartData.count == 0 || !self.chartData) {
        return;
    }
    
    //x坐标轴长度
    self.xAxisWidth = rect.size.width - self.rightMargin - (self.fullScreen ? 0 : self.leftMargin);
    
    //y坐标轴高度
    self.yAxisHeight = rect.size.height - self.bottomMargin - self.topMargin;
    
    //画坐标轴
    [self drawAxisInRect:rect];
    
    //时间轴
    [self drawTimeAxis];
    
    //折线图
    [self drawLineChart];
    
    //y坐标
    [self drawYAxisTitle];
}

#pragma mark - reponse events

- (void)tapPressedEvent:(UITapGestureRecognizer *)tapGesture {
    if (self.chartData.count == 0 || !self.chartData) {
        return;
    }
    
    CGPoint touchPoint = [tapGesture locationInView:self];
    [self showTipBoardWithTouchPoint:touchPoint];
}

- (void)longPressedEvent:(UILongPressGestureRecognizer *)longGesture {
    [self postNotificationWithGestureRecognizerStatee:longGesture.state];
    
    if (self.chartData.count == 0 || !self.chartData) {
        return;
    }
    if (longGesture.state == UIGestureRecognizerStateEnded) {
        self.vtlCrossLine.hidden = YES;
        self.timeLbl.hidden = YES;
        [self.tipBox hide];
    } else {
        CGPoint touchPoint = [longGesture locationInView:self];
        [self showTipBoardWithTouchPoint:touchPoint];
    }
}

- (void)showTipBoardWithTouchPoint:(CGPoint)touchPoint {
    [self.points enumerateKeysAndObjectsUsingBlock:^(NSNumber *indexNum, NSString *pointKey, BOOL * _Nonnull stop) {
        NSInteger touchIndex = MIN(MAX(0, floor((touchPoint.x - (self.fullScreen ? 0 : self.leftMargin))/self.pointPadding)), self.points.count - 1);
        if (touchIndex*self.pointPadding - touchPoint.x > 1/2*self.pointPadding) {
            touchIndex += 1;
        }
        
        touchIndex += self.startDrawIndex;
        
        CGPoint point = CGPointFromString([_points objectForKey:@(touchIndex)]);
        CGRect frame = self.vtlCrossLine.frame;
        frame.origin.x = point.x;
        self.vtlCrossLine.frame = frame;
        self.vtlCrossLine.hidden = NO;
        [self bringSubviewToFront:self.vtlCrossLine];
        
        self.tipBox.hidden = NO;
        
        point.y = point.y > (self.frame.size.height - self.topMargin - self.tipBox.frame.size.height/2.0)/2.0 ? (self.frame.size.height - self.topMargin - self.tipBox.frame.size.height/2.0)/2.0 : point.y;
        point.y -= self.tipBox.frame.size.height/2.0;
        if (point.y < self.topMargin + self.tipBox.frame.size.height/2.0) {
            point.y = self.topMargin;
        }
        
        self.tipBox.content = [NSString stringWithFormat:@"%@", [self dealDecimalWithNum:@([self.chartData[touchIndex].close floatValue])]];
        [self.tipBox showWithTipPoint:point];
        [self bringSubviewToFront:self.tipBox];
        
        NSString *date = self.chartData[touchIndex].date;
        self.timeLbl.text = date;
        self.timeLbl.hidden = date.length > 0 ? NO : YES;
        if (date.length > 0) {
            CGSize size = [date boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.xAxisTitleFont} context:nil].size;
            CGFloat originX = MIN(MAX((self.fullScreen ? 0 : self.leftMargin), point.x - size.width/2.0 - 2), self.frame.size.width - self.rightMargin - size.width - 4);
            self.timeLbl.frame = CGRectMake(originX, self.topMargin + self.yAxisHeight + self.separatorWidth, size.width + 4, self.timeAxisHeigth - self.separatorWidth*2);
        }
        
        
        *stop = YES;
    }];
}

- (void)postNotificationWithGestureRecognizerStatee:(UIGestureRecognizerState)state {
    switch (state) {
        case UIGestureRecognizerStateBegan: {
            [[NSNotificationCenter defaultCenter] postNotificationName:TLineKeyStartUserInterfaceNotification object:nil];
            break;
        }
        case UIGestureRecognizerStateEnded: {
            [[NSNotificationCenter defaultCenter] postNotificationName:TLineKeyEndOfUserInterfaceNotification object:nil];
            break;
        }
        default:
            break;
    }
}

#pragma mark - public method

- (void)drawChartWithData:(NSArray *)data {
    self.chartData = data;

    [self drawSetting];
    
    [self setNeedsDisplay];
}

- (void)drawSetting {
    NSAttributedString *attString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%.2f", self.highItem.high.floatValue] attributes:@{NSFontAttributeName:self.yAxisTitleFont, NSForegroundColorAttributeName:self.yAxisTitleColor}];
    CGSize size = [attString boundingRectWithSize:CGSizeMake(MAXFLOAT, self.yAxisTitleFont.lineHeight) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
    self.leftMargin = size.width + 4.0f;
    
    //绘制点数
    self.kGraphDrawCount = ceil(((self.frame.size.width - self.rightMargin - 0.5) / self.pointPadding));
    self.pointPadding += fabs((self.frame.size.width - (self.fullScreen ? 0 : self.leftMargin) - self.rightMargin - 0.5) - MAX(0, (self.kGraphDrawCount - 1))*self.pointPadding)/self.kGraphDrawCount;
    DLog(@"%ld, %.2f %.2f", (long)self.kGraphDrawCount, self.pointPadding, self.leftMargin);
    [self resetMinAndMax];
}

#pragma mark - private methods

//坐标轴
- (void)drawAxisInRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //k线边框
    CGRect strokeRect = CGRectMake((self.fullScreen ? 0 : self.leftMargin), self.topMargin, self.xAxisWidth, self.yAxisHeight);
    CGContextSetLineWidth(context, self.axisShadowWidth);
    
    CGFloat lengths[] = {5,5};
    if (self.dashLineBorder) {
        CGContextSetLineDash(context, 0, lengths, 2);
    }
    CGContextSetStrokeColorWithColor(context, self.axisShadowColor.CGColor);
    CGContextStrokeRect(context, strokeRect);
    
    //k线分割线
    CGFloat avgHeight = strokeRect.size.height/(self.separatorNum + 1);
    for (int i = 1; i <= 4; i ++) {
        CGContextSetLineWidth(context, self.separatorWidth);
        CGContextSetStrokeColorWithColor(context, self.separatorColor.CGColor);
        CGContextSetLineDash(context, 0, lengths, 2);  //画虚线
        
        CGContextBeginPath(context);
        CGContextMoveToPoint(context, (self.fullScreen ? 0 : self.leftMargin) + 1.25, self.topMargin + avgHeight*i);    //开始画线
        CGContextAddLineToPoint(context, rect.size.width  - self.rightMargin - 0.8, self.topMargin + avgHeight*i);
        
        CGContextStrokePath(context);
    }
    
    //这必须把dash给初始化一次，不然会影响其他线条的绘制
    CGContextSetLineDash(context, 0, 0, 0);
}

- (void)drawTimeAxis {
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //四分之一宽需要画多少个点
    CGFloat quarteredWidth = self.xAxisWidth/4.0;
    NSInteger avgDrawCount = ceil(quarteredWidth/_pointPadding);
    
    CGFloat xAxis = (self.fullScreen ? 0 : self.leftMargin) + 2.0 + self.pointPadding;
    //画4条虚线
    for (int i = 0; i < 4; i ++) {
        if (xAxis > (self.fullScreen ? 0 : self.leftMargin) + self.xAxisWidth) {
            break;
        }
        CGContextSetLineWidth(context, self.separatorWidth);
        CGFloat lengths[] = {5,5};
        CGContextSetStrokeColorWithColor(context, self.separatorColor.CGColor);
        CGContextSetLineDash(context, 0, lengths, 2);  //画虚线
        CGContextBeginPath(context);
        CGContextMoveToPoint(context, xAxis, self.topMargin + 1.25);    //开始画线
        CGContextAddLineToPoint(context, xAxis, self.topMargin + self.yAxisHeight - 1.25);
        CGContextStrokePath(context);
        
        //x轴坐标
        NSInteger timeIndex = i*avgDrawCount + self.startDrawIndex + 1;
        if (timeIndex > self.chartData.count - 1) {
            xAxis += avgDrawCount*_pointPadding;
            continue;
        }
        NSAttributedString *attString = [[NSAttributedString alloc] initWithString:SAFE_STRING(self.chartData[timeIndex].date) attributes:@{NSFontAttributeName:self.xAxisTitleFont, NSForegroundColorAttributeName:self.xAxisTitleColor}];
        CGSize size = [attString boundingRectWithSize:CGSizeMake(MAXFLOAT, self.xAxisTitleFont.lineHeight) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
        CGFloat originX = MIN(xAxis - size.width/2.0, self.frame.size.width - self.rightMargin - size.width);
        [attString drawInRect:CGRectMake(originX, self.topMargin + self.yAxisHeight + 2.0, size.width, size.height)];
        
        xAxis += avgDrawCount*_pointPadding;
    }
    CGContextSetLineDash(context, 0, 0, 0);
}

//折线图
- (void)drawLineChart {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, self.lineWidth);
    CGContextSetStrokeColorWithColor(context, self.lineColor.CGColor);
    UIBezierPath *bPath = [self getLineChartPath];
    CGContextAddPath(context, bPath.CGPath);
    CGContextStrokePath(context);
    
    //gradient
    CGPoint point = CGPointFromString([self.points objectForKey:[self.points.allKeys valueForKeyPath:@"@max.intValue"]]);
    [bPath addLineToPoint:CGPointMake(point.x, self.frame.size.height - self.bottomMargin - 0.5)];
    [bPath addLineToPoint:CGPointMake((self.fullScreen ? 0 :self.leftMargin) + 0.5, self.frame.size.height - self.bottomMargin - 0.5)];
    CGPathRef path = bPath.CGPath;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGFloat locations[] = {0.5, 1.0};
    NSArray *colors = @[(__bridge id) self.gradientStartColor.CGColor, (__bridge id) self.gradientEndColor.CGColor];
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef) colors, locations);
    CGRect pathRect = CGPathGetBoundingBox(path);
    CGPoint startPoint = CGPointMake(CGRectGetMidX(pathRect), CGRectGetMinY(pathRect));
    CGPoint endPoint = CGPointMake(CGRectGetMidX(pathRect), CGRectGetMaxY(pathRect));
    CGContextSaveGState(context);
    CGContextAddPath(context, path);
    CGContextClip(context);
    CGContextSetAlpha(context, 1.0);
    CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
    CGContextRestoreGState(context);
    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorSpace);
}

- (UIBezierPath *)getLineChartPath {
    UIBezierPath *path;
    CGFloat xAxis = (self.fullScreen ? 0 :self.leftMargin) + 0.6;
    CGFloat scale = (self.maxValue - self.minValue) / self.yAxisHeight;
    scale = scale == 0 ? 1.0 : scale;
    
    if (scale != 0) {
        NSArray *drawContexts = [self.chartData subarrayWithRange:NSMakeRange(self.startDrawIndex, self.kGraphDrawCount)];
        NSMutableDictionary *contentPoints = [NSMutableDictionary new];
        for (KLineItem *item in drawContexts) {
            CGFloat volValue = [item.close floatValue];
            CGFloat yAxis = self.yAxisHeight - (volValue - self.minValue)/scale + self.topMargin;
            if (scale == 1) {
                yAxis = self.yAxisHeight/2.0 + self.topMargin;
            }
            CGPoint maPoint = CGPointMake(xAxis, yAxis);
            
            if (!path) {
                path = [UIBezierPath bezierPath];
                [path moveToPoint:maPoint];
            } else {
                [path addLineToPoint:maPoint];
            }
            
            [contentPoints setObject:NSStringFromCGPoint(CGPointMake(xAxis, yAxis)) forKey:@([self.chartData indexOfObject:item])];
            xAxis += self.pointPadding;
        }
        self.points = contentPoints;
        
        [self startFlashAnimation];
    }
    
    if (self.smoothPath) {
        path = [path smoothedPathWithGranularity:15];
    }

    return path;
}

- (void)startFlashAnimation {
    if (!self.flashPoint) {
        return;
    }
    [self stopFlashAnimation];
    
    CGRect frame = self.flashLayer.frame;
    CGPoint lastPoint = CGPointFromString([self.points objectForKey:[self.points.allKeys valueForKeyPath:@"@max.intValue"]]);
    frame.origin.x = lastPoint.x - frame.size.width/2.0;
    frame.origin.y = lastPoint.y - frame.size.height/2.0;
    self.flashLayer.frame = frame;
    
    //animation
    CAAnimationGroup *animaTionGroup = [CAAnimationGroup animation];
    animaTionGroup.duration = 0.8;
    animaTionGroup.removedOnCompletion = NO;
    animaTionGroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault];
    animaTionGroup.autoreverses = YES;
    animaTionGroup.repeatCount = MAXFLOAT;
    
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnimation.fromValue = @1.0;
    scaleAnimation.toValue = @0;
    
    CAKeyframeAnimation *opencityAnimation = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
    opencityAnimation.values = @[@1.0, @0.1];
    opencityAnimation.keyTimes = @[@0, @(animaTionGroup.duration)];
    
    animaTionGroup.animations = @[scaleAnimation,opencityAnimation];
    [self.flashLayer addAnimation:animaTionGroup forKey:nil];
}

- (void)stopFlashAnimation {
    if (!self.flashPoint) {
        return;
    }
    [self.flashLayer removeFromSuperlayer];
    _flashLayer = nil;
}

//k线y坐标
- (void)drawYAxisTitle {
    CGFloat avgHeight = self.yAxisHeight/(self.separatorNum + 1);
    CGFloat avgValue = (self.maxValue - self.minValue) / (self.separatorNum + 1);
    for (int i = 0; i < (self.separatorNum + 2); i ++) {
        float yAxisValue = i == (self.separatorNum  + 2 - 1) ? self.minValue : self.maxValue - avgValue*i;
        NSAttributedString *attString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@", [self dealDecimalWithNum:@(yAxisValue)]] attributes:@{NSFontAttributeName:self.yAxisTitleFont, NSForegroundColorAttributeName:self.yAxisTitleColor}];
        CGSize size = [attString boundingRectWithSize:CGSizeMake(self.leftMargin, self.yAxisTitleFont.lineHeight) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
        
        [attString drawInRect:CGRectMake((self.fullScreen ? 1.25 : self.leftMargin - size.width - 2.0f), self.topMargin + avgHeight*i - (i == (self.separatorNum  + 2 - 1) ? size.height - 1 : (i == 0 ? 0 : size.height/2.0)), size.width, size.height)];
    }
}

- (void)resetMinAndMax {
    self.maxValue = -MAXFLOAT;
    self.minValue = MAXFLOAT;
    NSArray *drawContext = self.yAxisTitleIsChange ? [self.chartData subarrayWithRange:NSMakeRange(self.startDrawIndex, MIN(self.kGraphDrawCount, self.chartData.count))] : self.chartData;
    
    for (int i = 0; i < drawContext.count; i++) {
        KLineItem *item = drawContext[i];
        
        self.maxValue = MAX([item.close floatValue], self.maxValue);
        self.minValue = MIN([item.close floatValue], self.minValue);
    }
    
    int offsetValue = self.maxValue - self.minValue;
    self.maxValue += offsetValue;
    self.minValue = self.minValue - offsetValue < 0 ? 0 : self.minValue - offsetValue;
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

- (TLineTipBoardView *)tipBox {
    if (!_tipBox) {
        _tipBox = [[TLineTipBoardView alloc] initWithFrame:CGRectMake(self.leftMargin, self.topMargin, 60.0f, 25.0f)];
        _tipBox.backgroundColor = [UIColor clearColor];
        _tipBox.radius = 2.0;
        _tipBox.font = [UIFont systemFontOfSize:14.0f];
        [self addSubview:_tipBox];
    }
    return _tipBox;
}

- (UIView *)vtlCrossLine {
    if (!_vtlCrossLine) {
        _vtlCrossLine = [[UIView alloc] initWithFrame:CGRectMake(self.leftMargin + self.pointPadding, self.axisShadowWidth + self.topMargin, 0.5, self.yAxisHeight - self.axisShadowWidth)];
        _vtlCrossLine.backgroundColor = self.crossLineColor;
        [self addSubview:_vtlCrossLine];
    }
    return _vtlCrossLine;
}

- (UILabel *)timeLbl {
    if (!_timeLbl) {
        _timeLbl = [UILabel new];
        _timeLbl.backgroundColor = self.timeTipBackgroundColor;
        _timeLbl.textAlignment = NSTextAlignmentCenter;
        _timeLbl.font = self.yAxisTitleFont;
        _timeLbl.textColor = self.timeTipTextColor;
        [self addSubview:_timeLbl];
    }
    return _timeLbl;
}

- (UITapGestureRecognizer *)tapGesture {
    if (!_tapGesture) {
        _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapPressedEvent:)];
    }
    return _tapGesture;
}

- (UILongPressGestureRecognizer *)longGesture {
    if (!_longGesture) {
        _longGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressedEvent:)];
    }
    return _longGesture;
}

- (CALayer *)flashLayer {
    if (!_flashLayer) {
        _flashLayer = [[CALayer alloc] init];
        _flashLayer.frame = CGRectMake(0, 0, MAX(MIN(4.0f, self.pointPadding), 2.0), MAX(MIN(4.0f, self.pointPadding), 2.0));
        _flashLayer.cornerRadius = _flashLayer.frame.size.height/2.0;
        _flashLayer.backgroundColor = self.flashPointColor.CGColor;
        [self.layer addSublayer:_flashLayer];
    }
    return _flashLayer;
}

#pragma mark - setters

- (void)setChartData:(NSArray<KLineItem *> *)chartData {
    _chartData = chartData;
    
    CGFloat maxHigh = -MAXFLOAT;
    for (KLineItem *item in self.chartData) {
        if (item.high.floatValue > maxHigh) {
            maxHigh = item.high.floatValue;
            self.highItem = item;
        }
    }
}

- (void)setSeparatorNum:(NSInteger)separatorNum {
    _separatorNum = separatorNum < 0 ? 0 : separatorNum;
}

- (void)setKGraphDrawCount:(NSInteger)kGraphDrawCount {
    kGraphDrawCount = MAX(MIN(self.chartData.count, kGraphDrawCount), 0);
    
    self.startDrawIndex = self.chartData.count - kGraphDrawCount;
    
    _kGraphDrawCount = kGraphDrawCount;
}

- (void)setBottomMargin:(CGFloat)bottomMargin {
    _bottomMargin = bottomMargin < _timeAxisHeigth ? _timeAxisHeigth : bottomMargin;
}

@end
