//
//  CandlestickView.m
//  ChartDemo
//
//  Created by YoYo on 2018/5/7.
//  Copyright © 2018年 yoyo. All rights reserved.
//

#import "CandlestickView.h"
#import "KLineItem.h"
#import "UIBezierPath+curved.h"

@interface CandlestickView ()

@property (nonatomic, strong) CAShapeLayer *horizontalSeparatorLayer;

@end

@implementation CandlestickView

- (void)setSeparatorNumber:(NSInteger)separatorNumber {
    _separatorNumber = MIN(6, MAX(separatorNumber, 2));
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.userInteractionEnabled = NO;
        self.layer.borderColor = [UIColor colorWithRed:223/255.0f green:223/255.0f blue:223/255.0f alpha:1.0].CGColor;
        self.layer.borderWidth = 0.5;
        self.separatorNumber = 4;
    }
    return self;
}

- (void)drawHorizontalSeparator {
    if ([self.layer.sublayers containsObject:self.horizontalSeparatorLayer]) {
        return;
    }
    
    if (self.horizontalSeparatorLayer) {
        [self.layer insertSublayer:self.horizontalSeparatorLayer atIndex:0];
        return;
    }
    
    UIBezierPath *hsPath = [UIBezierPath bezierPath];
    
    float avgHeight = self.frame.size.height/5.0f;
    for (int i = 0; i < 4; i ++) {
        UIBezierPath *path = [UIBezierPath bezierPath];
        [path moveToPoint:CGPointMake(0, avgHeight*(i+1))];
        [path addLineToPoint:CGPointMake(self.frame.size.width, avgHeight*(i+1))];
        
        [hsPath appendPath:path];
    }
    
    self.horizontalSeparatorLayer = [CAShapeLayer layer];
    self.horizontalSeparatorLayer.path = hsPath.CGPath;
    self.horizontalSeparatorLayer.fillColor = [UIColor clearColor].CGColor;
    self.horizontalSeparatorLayer.strokeColor =  [UIColor colorWithRed:223/255.0f green:223/255.0f blue:223/255.0f alpha:1.0].CGColor;
    self.horizontalSeparatorLayer.lineWidth = 0.5;
    self.horizontalSeparatorLayer.lineDashPattern = @[@3, @3];
    self.horizontalSeparatorLayer.lineDashPhase = 2;
    [self.layer insertSublayer:self.horizontalSeparatorLayer atIndex:0];
}

// 垂直方向会动态变化
- (void)drawVerticalAxisSeparatorForData:(NSArray *)data {
    CGFloat quarteredWidth = self.frame.size.width/((self.separatorNumber+1)*1.0);
    NSInteger avgNeedDrawCandleCount = ceil(quarteredWidth/(_kCandleFixedSpacing + _kCandleWidth));

    CGFloat xAxis = avgNeedDrawCandleCount*(_kCandleWidth + _kCandleFixedSpacing) - _kCandleWidth/2.0f;
    
    UIBezierPath *vsPath = [UIBezierPath bezierPath];
    for (int i = 0; i < self.separatorNumber; i ++) {
        UIBezierPath *path = [UIBezierPath bezierPath];
        [path moveToPoint:CGPointMake(xAxis, 0)];
        [path addLineToPoint:CGPointMake(xAxis, self.frame.size.height)];
        
        [vsPath appendPath:path];
        
        // x轴坐标标题
        if ((i + 1)*avgNeedDrawCandleCount < data.count - 1) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(xAxis_coordinate:date:atIndex:)]) {
                KLineItem *item = data[(i + 1)*avgNeedDrawCandleCount];
                [self.delegate xAxis_coordinate:xAxis date:item.date atIndex:i];
            }
        }

        xAxis += avgNeedDrawCandleCount*(_kCandleFixedSpacing + _kCandleWidth);
    }
    
    CAShapeLayer *verticalSeparatorLayer = [CAShapeLayer layer];
    verticalSeparatorLayer.path = vsPath.CGPath;
    verticalSeparatorLayer.fillColor = [UIColor clearColor].CGColor;
    verticalSeparatorLayer.strokeColor =  [UIColor colorWithRed:223/255.0f green:223/255.0f blue:223/255.0f alpha:1.0].CGColor;
    verticalSeparatorLayer.lineWidth = 0.5;
    verticalSeparatorLayer.lineDashPattern = @[@3, @3];
    verticalSeparatorLayer.lineDashPhase = 2;
    [self.layer insertSublayer:verticalSeparatorLayer atIndex:0];
}

#pragma mark - public methods

- (void)updateCandleForData:(NSArray *)data {
    if (!data) return;
    
    [self drawCandleWithData:data];
    
    // 绘制水平方向分割线
    [self drawHorizontalSeparator];
    
    // 垂直方向分割线
    [self drawVerticalAxisSeparatorForData:data];
}

- (void)updateMAWithData:(NSArray *)data {
    if (!data) return;
    
    [self drawMAWithData:data];
    
    // 制水平方向分割线
    [self drawHorizontalSeparator];
}

#pragma mark - draw candle

// 绘制蜡烛图
- (void)drawCandleWithData:(NSArray *)data {
    // 移除layer，重新绘制
    [self.layer.sublayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    
    CGFloat scale = (self.maxmumPrice - self.minmumPrice) / self.frame.size.height;
    if (scale == 0) {
        scale = 1.0;
    }
    
    CGFloat xAxis = _kCandleFixedSpacing;
    
    for (int index = 0; index < data.count; index ++) {
        KLineItem *drawItem = data[index];
        
        //通过开盘价、收盘价判断颜色
        CGFloat open = [drawItem.open floatValue];
        CGFloat close = [drawItem.close floatValue];
        UIColor *fillColor = open > close ? self.positiveCandleColor : self.negativeCandleColor;
        
        CGFloat diffValue = fabs(open - close);
        CGFloat height = MAX(diffValue/scale == 0 ? 1 : diffValue/scale, 0.5);
        CGFloat yAxis = self.frame.size.height - ((MAX(open, close) - self.minmumPrice)/scale == 0 ? 1 : (MAX(open, close) - self.minmumPrice)/scale);
        
        CGRect rect = CGRectMake(xAxis, MAX(0.5, yAxis), _kCandleWidth, MIN(height, self.frame.size.height - 0.5));
        
        UIBezierPath *path = [UIBezierPath bezierPathWithRect:rect];
        
        //上、下影线
        CGFloat highYAxis = self.frame.size.height - ([drawItem.high floatValue] - self.minmumPrice)/scale;
        CGFloat lowYAxis = self.frame.size.height - ([drawItem.low floatValue] - self.minmumPrice)/scale;
        CGPoint highPoint = CGPointMake(xAxis + _kCandleWidth/2.0, highYAxis);
        CGPoint lowPoint = CGPointMake(xAxis + _kCandleWidth/2.0, lowYAxis );
        
        UIBezierPath *linePath = [UIBezierPath bezierPath];
        [linePath moveToPoint:highPoint];
        [linePath addLineToPoint:lowPoint];
        [path appendPath:linePath];
        
        CAShapeLayer *layer;
        layer = [CAShapeLayer new];
        layer.path = path.CGPath;
        layer.fillColor = fillColor.CGColor;
        layer.strokeColor = fillColor.CGColor;
        [self.layer addSublayer:layer];
        
        xAxis += _kCandleWidth + _kCandleFixedSpacing;
    }
}

/**
 *  均线图
 */
- (void)drawMAWithData:(NSArray *)data {
    for (int i = 0; i < data.count; i ++) {
        CGPathRef path = [self getMAPathWithData:data[i]];
        
        CAShapeLayer *layer;
        layer = [CAShapeLayer new];
        layer.path = path;
        layer.fillColor = [UIColor clearColor].CGColor;
        layer.strokeColor = _MAColors[i].CGColor;
        [self.layer addSublayer:layer];
    }
}

/**
 *  均线path
 */
- (CGPathRef)getMAPathWithData:(NSArray *)data {
    UIBezierPath *path;
    CGFloat xAxis = 0.5*_kCandleWidth + _kCandleFixedSpacing;
    
    for (int i = 0; i < data.count; i ++) {
        id ma = data[i];
        if (ma == [NSNull null]) {
            xAxis += self.kCandleWidth + self.kCandleFixedSpacing;
            continue;
        }
        
        float scale = ([ma floatValue] - self.minmumPrice)/(self.maxmumPrice - self.minmumPrice);
        if (scale > 1 || scale <= 0) {
            xAxis += self.kCandleWidth + self.kCandleFixedSpacing;
            continue;
        }
        CGFloat yAxis = self.frame.size.height*(1-scale);
        
        CGPoint maPoint = CGPointMake(xAxis, yAxis);
        if (!path) {
            path = [UIBezierPath bezierPath];
            [path moveToPoint:maPoint];
        } else {
            [path addLineToPoint:maPoint];
        }

        xAxis += self.kCandleWidth + self.kCandleFixedSpacing;
    }

    //圆滑
    path = [path smoothedPathWithGranularity:15];

    return path.CGPath;
}

- (void)clean {
    [self.layer.sublayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
}

@end
