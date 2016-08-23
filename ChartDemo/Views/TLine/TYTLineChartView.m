//
//  KLineView.m
//  CandlerstickCharts
//
//  折线图
//  Created by xdliu on 16/8/11.
//  Copyright © 2016年 liuxd. All rights reserved.
//

#import "TYTLineChartView.h"
#import "KLineListTransformer.h"
#import "UIBezierPath+curved.h"
#import "UIColor+Ext.h"
#import "TLineTipBoardView.h"

@interface TYTLineChartView ()

@property (nonatomic, strong) NSArray *contexts;

@property (nonatomic, assign) CGFloat xAxisWidth;

@property (nonatomic, assign) CGFloat yAxisHeight;

@property (nonatomic, assign) NSInteger kGraphDrawCount;

@property (nonatomic, assign) NSInteger startDrawIndex;

@property (nonatomic, assign) CGFloat maxValue;

@property (nonatomic, assign) CGFloat minValue;

@property (nonatomic, strong) NSArray *points;

@property (nonatomic, strong) TLineTipBoardView *tipBox;

@property (nonatomic, strong) UIView *vtlCrossLine; //垂直线

@property (nonatomic, strong) UILongPressGestureRecognizer *longGesture;

@end

@implementation TYTLineChartView

#pragma mark - life cycle

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
    self.pointPadding = 1.5;
    
    self.lineWidth = 0.8;
    self.lineColor = [UIColor colorWithRed:(128.0/255.0) green:(195.0f/255.0) blue:(220.0/255.0f) alpha:1.0];
    
    self.gradientStartColor = [UIColor colorWithRed:(96/255.0) green:(225/255.0) blue:(240/255.0f) alpha:0.5];
    self.gradientEndColor = [UIColor whiteColor];
    
    self.separatorColor = [UIColor colorWithRed:(230/255.0f) green:(230/255.0f) blue:(230/255.0f) alpha:1.0];
    self.separatorWidth = 0.5;
    
    self.yAxisTitleFont = [UIFont systemFontOfSize:8.0];
    self.yAxisTitleColor = [UIColor colorWithRed:(130/255.0f) green:(130/255.0f) blue:(130/255.0f) alpha:1.0];
    
    self.axisShadowColor = [UIColor colorWithRed:223/255.0f green:223/255.0f blue:223/255.0f alpha:1.0];
    self.axisShadowWidth = 0.5;
    
    self.separatorNum = 4;
    
    self.smoothPath = YES;
    
    self.crossLineColor = [UIColor colorWithHexString:@"#C9C9C9"];
    
    [self addGestureRecognizer:self.longGesture];
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    if (self.contexts.count == 0) {
        return;
    }
    
    //x坐标轴长度
    self.xAxisWidth = rect.size.width - self.leftMargin - self.rightMargin;
    
    //y坐标轴高度
    self.yAxisHeight = rect.size.height - self.bottomMargin - self.topMargin;
    
    //画坐标轴
    [self drawAxisInRect:rect];
    
    //折线图
    [self drawLineChart];
}

#pragma mark - reponse events

- (void)longPressedEvent:(UILongPressGestureRecognizer *)longGesture {
    if (longGesture.state == UIGestureRecognizerStateEnded) {
        self.vtlCrossLine.hidden = YES;
        [self.tipBox hide];
    } else {
        CGPoint touchPoint = [longGesture locationInView:self];
        [self.points enumerateObjectsUsingBlock:^(NSString *pointString, NSUInteger idx, BOOL * _Nonnull stop) {
            CGPoint point = CGPointFromString(pointString);
            if (touchPoint.x > self.pointPadding && touchPoint.x < (self.frame.size.width - self.leftMargin - self.rightMargin)) {
                if (touchPoint.x > (point.x - self.pointPadding/2.0) && touchPoint.x < (point.x + self.pointPadding/2.0)) {
                    self.vtlCrossLine.hidden = NO;
                    CGRect frame = self.vtlCrossLine.frame;
                    frame.origin.x = point.x;
                    
                    self.vtlCrossLine.frame = frame;
                    
                    self.tipBox.hidden = NO;
                    
                    point.y = point.y > 4*(self.frame.size.height - self.topMargin)/5.0 ? 4*(self.frame.size.height - self.topMargin)/5.0 : point.y;
                    point.y -= self.tipBox.frame.size.height/2.0;
                    if (point.y < self.topMargin + self.tipBox.frame.size.height/2.0) {
                        point.y = self.topMargin;
                    }
                    
                    NSInteger index = (point.x - self.leftMargin)/self.pointPadding - 1;
                    NSArray<NSArray *> *line = [self.contexts subarrayWithRange:NSMakeRange(self.startDrawIndex, self.kGraphDrawCount)];
                    
                    self.tipBox.content = [NSString stringWithFormat:@"%.2f", [[line[index] objectAtIndex:4] floatValue]];
                    [self.tipBox showWithTipPoint:point];
                    [self bringSubviewToFront:self.tipBox];
                    
                    *stop = YES;
                }
            }
        }];
    }
}

#pragma mark - public methods

- (void)drawChartWithData:(NSDictionary *)data {
    self.contexts = data[kCandlerstickChartsContext];
    //最大、最小 交易量
    self.maxValue = [data[kCandlerstickChartsMaxVol] floatValue];
    self.minValue = [data[kCandlerstickChartsMinVol] floatValue];

    CGFloat offsetValue = (self.maxValue - self.minValue)/12.0f;
    self.maxValue += offsetValue;
    self.minValue = self.minValue - offsetValue < 0 ? 0 : self.minValue - offsetValue;
    
    //绘制点数
    self.kGraphDrawCount = floor(((self.frame.size.width - self.leftMargin - self.rightMargin - self.pointPadding) / (1 + self.pointPadding)));
    
    [self setNeedsDisplay];
}

#pragma mark - private methods

//坐标轴
- (void)drawAxisInRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //k线边框
    CGRect strokeRect = CGRectMake(self.leftMargin, self.topMargin, self.xAxisWidth, self.yAxisHeight);
    CGContextSetLineWidth(context, self.axisShadowWidth);
    
    double lengths[] = {5,5};
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
        CGContextMoveToPoint(context, self.leftMargin + 1.25, self.topMargin + avgHeight*i);    //开始画线
        CGContextAddLineToPoint(context, rect.size.width  - self.rightMargin - 0.8, self.topMargin + avgHeight*i);
        
        CGContextStrokePath(context);
    }
    
    //这必须把dash给初始化一次，不然会影响其他线条的绘制
    CGContextSetLineDash(context, 0, 0, 0);
    
    //k线y坐标
    CGFloat avgValue = (self.maxValue - self.minValue) / (self.separatorNum + 1);
    for (int i = 0; i < (self.separatorNum + 2); i ++) {
        float yAxisValue = i == (self.separatorNum  + 2 - 1) ? self.minValue : self.maxValue - avgValue*i;
        NSAttributedString *attString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%.2f", yAxisValue] attributes:@{NSFontAttributeName:self.yAxisTitleFont, NSForegroundColorAttributeName:self.yAxisTitleColor}];
        CGSize size = [attString boundingRectWithSize:CGSizeMake(self.leftMargin, self.yAxisTitleFont.lineHeight) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
        
        [attString drawInRect:CGRectMake(self.leftMargin - size.width - 2.0f, self.topMargin + avgHeight*i - (i == 5 ? size.height - 1 : size.height/2.0), size.width, size.height)];
    }
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
    CGPoint point = CGPointFromString([self.points lastObject]);
    [bPath addLineToPoint:CGPointMake(point.x, self.frame.size.height - self.bottomMargin)];
    [bPath addLineToPoint:CGPointMake(self.leftMargin + self.pointPadding, self.frame.size.height - self.bottomMargin)];
    CGPathRef path = bPath.CGPath;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGFloat locations[] = {0.9, 1.0};
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
    CGFloat xAxis = self.leftMargin + self.pointPadding;
    CGFloat scale = (self.maxValue - self.minValue) / self.yAxisHeight;
    
    if (scale != 0) {
        NSArray *contentValue = [_contexts subarrayWithRange:NSMakeRange(self.startDrawIndex, self.kGraphDrawCount)];
        NSMutableArray *contentPoints = [NSMutableArray new];
        for (NSArray *line in contentValue) {
            CGFloat volValue = [line[4] floatValue];
            CGFloat yAxis = self.yAxisHeight - (volValue - self.minValue)/scale + self.topMargin;
            CGPoint maPoint = CGPointMake(xAxis, yAxis);
            if (yAxis < self.topMargin) {
                xAxis += self.pointPadding;
                [contentPoints addObject:NSStringFromCGPoint(CGPointMake(xAxis, self.frame.size.height - self.bottomMargin))];
                continue;
            }
            
            if (!path) {
                path = [UIBezierPath bezierPath];
                [path moveToPoint:maPoint];
            } else {
                [path addLineToPoint:maPoint];
            }
            
            [contentPoints addObject:NSStringFromCGPoint(CGPointMake(xAxis, yAxis))];
            xAxis += self.pointPadding;
        }
        self.points = contentPoints;
    }
    
    if (self.smoothPath) {
        path = [path smoothedPathWithGranularity:15];
    }

    return path;
}

#pragma mark - getters

- (TLineTipBoardView *)tipBox {
    if (!_tipBox) {
        _tipBox = [[TLineTipBoardView alloc] initWithFrame:CGRectMake(self.leftMargin, self.topMargin, 60.0f, 25.0f)];
        _tipBox.backgroundColor = [UIColor clearColor];
        _tipBox.radius = 2.0;
        [self addSubview:_tipBox];
    }
    return _tipBox;
}

- (UIView *)vtlCrossLine {
    if (!_vtlCrossLine) {
        _vtlCrossLine = [[UIView alloc] initWithFrame:CGRectMake(self.leftMargin + self.pointPadding, self.axisShadowWidth + self.topMargin, 0.5, self.yAxisHeight - self.axisShadowWidth)];
        _vtlCrossLine.backgroundColor = self.crossLineColor;
        _vtlCrossLine.hidden = YES;
        [self addSubview:_vtlCrossLine];
    }
    return _vtlCrossLine;
}

- (UILongPressGestureRecognizer *)longGesture {
    if (!_longGesture) {
        _longGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressedEvent:)];
    }
    return _longGesture;
}

#pragma mark - setters

- (void)setSeparatorNum:(NSInteger)separatorNum {
    _separatorNum = separatorNum < 0 ? 0 : separatorNum;
}

- (void)setKGraphDrawCount:(NSInteger)kGraphDrawCount {
    if (kGraphDrawCount > self.contexts.count || self.contexts.count < kGraphDrawCount) {
        kGraphDrawCount = self.contexts.count;
    }
    
    self.startDrawIndex = self.contexts.count > kGraphDrawCount ? self.contexts.count - kGraphDrawCount : 0;
    
    _kGraphDrawCount = kGraphDrawCount;
}

@end
