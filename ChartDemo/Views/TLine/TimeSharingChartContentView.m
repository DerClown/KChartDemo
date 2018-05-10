//
//  TimeSharingChartContentView.m
//  ChartDemo
//
//  Created by YoYo on 2018/5/10.
//  Copyright © 2018年 taiya. All rights reserved.
//

#import "TimeSharingChartContentView.h"
#import "KLineItem.h"
#import "UIBezierPath+curved.h"

@interface TimeSharingChartContentView ()

@property (nonatomic, strong) CAShapeLayer *lineLayer;
@property (nonatomic, strong) CAShapeLayer *gradientLayer;

@property (nonatomic) float linePadding;

@end

@implementation TimeSharingChartContentView

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.userInteractionEnabled = NO;
        self.backgroundColor = [UIColor colorWithRed:37/255.0f green:37/255.0f blue:37/255.0f alpha:1.0];
        self.strokeColor = [UIColor colorWithRed:197/255.0f green:197/255.0f blue:197/255.0f alpha:1.0];
        self.fillColor = [UIColor colorWithRed:197/255.0f green:197/255.0f blue:197/255.0f alpha:0.5];
        self.smoothPath = YES;
    }
    return self;
}

- (void)drawSeparator {
    NSInteger verticalSeparatorNum = 5, horizontalSeparatorNum = 5;
    
    UIBezierPath *sPath = [UIBezierPath bezierPathWithRect:self.bounds];
    sPath.lineWidth = 0.5;
    
    // 水平方向
    float avgHeight = self.frame.size.height/(verticalSeparatorNum*1.0);
    for (int i = 0; i < (verticalSeparatorNum - 1) ; i ++) {
        UIBezierPath *path = [UIBezierPath bezierPath];
        [path moveToPoint:CGPointMake(0, avgHeight*(i+1))];
        [path addLineToPoint:CGPointMake(self.frame.size.width, avgHeight*(i+1))];
        
        [sPath appendPath:path];
    }
    
    // 垂直方向
    float verticalAvgHeight = self.needDrawingPointNumber/5*self.linePadding+0.5;
    for (int i = 0; i < (horizontalSeparatorNum - 1); i ++) {
        UIBezierPath *path = [UIBezierPath bezierPath];
        [path moveToPoint:CGPointMake(verticalAvgHeight, 0)];
        [path addLineToPoint:CGPointMake(verticalAvgHeight, self.frame.size.height)];
        
        [sPath appendPath:path];
        
        verticalAvgHeight += self.needDrawingPointNumber/5*self.linePadding;
    }
    
    CAShapeLayer *separatorLayer = [CAShapeLayer new];
    separatorLayer.fillColor = [UIColor clearColor].CGColor;
    separatorLayer.strokeColor = [UIColor colorWithRed:223/255.0f green:223/255.0f blue:223/255.0f alpha:1.0].CGColor;
    separatorLayer.lineWidth = 0.5;
    separatorLayer.lineDashPattern = @[@3, @3];
    separatorLayer.lineDashPhase = 2;
    separatorLayer.path = sPath.CGPath;
    
    [self.layer addSublayer:separatorLayer];
}

- (void)updateChartWithData:(NSArray *)data {
    if (!data) return;
    
    [self drawTSChartForData:data];
    
    [self updateAxisTitleWithData:data];
}

- (void)drawTSChartForData:(NSArray *)data {
    [self.lineLayer removeFromSuperlayer];
    self.lineLayer = nil;
    
    float avgPrice = (self.maxmumPrice - self.minmumPrice)/3.0f;
    self.minmumPrice -= avgPrice;
    self.maxmumPrice += avgPrice;
    
    float scale = (self.maxmumPrice - self.minmumPrice)/(self.frame.size.height*1.0);
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    float xAxis = 0.5;
    for (int i = 0; i < data.count; i ++) {
        KLineItem *item = data[i];
        
        float height = self.frame.size.height - (item.close.floatValue - self.minmumPrice)/scale;
        if (i == 0) {
            [path moveToPoint:CGPointMake(xAxis, height)];
        } else {
            [path addLineToPoint:CGPointMake(xAxis, height)];
        }
        
        xAxis += self.linePadding;
    }
    
    if (self.smoothPath) {
        path = [path smoothedPathWithGranularity:15];
    }
    
    self.lineLayer = [CAShapeLayer new];
    self.lineLayer.lineWidth = 2.0;
    self.lineLayer.path = path.CGPath;
    self.lineLayer.strokeColor = self.strokeColor.CGColor;
    self.lineLayer.fillColor = [UIColor clearColor].CGColor;
    [self.layer addSublayer:self.lineLayer];
    
    [self.gradientLayer removeFromSuperlayer];
    self.gradientLayer = nil;
    
    [path addLineToPoint:CGPointMake(xAxis - self.linePadding, self.frame.size.height - 0.5)];
    [path addLineToPoint:CGPointMake(0.5, self.frame.size.height - 0.5)];
    [path closePath];

    self.gradientLayer = [CAShapeLayer new];
    self.gradientLayer.path = path.CGPath;
    self.gradientLayer.strokeColor = [UIColor clearColor].CGColor;
    self.gradientLayer.fillColor = self.fillColor.CGColor;
    [self.layer addSublayer:self.gradientLayer];
}

- (void)updateAxisTitleWithData:(NSArray *)data {
    // 绘制坐标内容需要
    NSInteger avgNeedDrawingCount = self.needDrawingPointNumber/5;
    
    CGFloat dateXAxis = 0.5;
    for (int i = 0; i < 5; i ++) {
        if (i*avgNeedDrawingCount < data.count - 1) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(xAxis_coordinate:date:atIndex:)]) {
                KLineItem *item = data[i*avgNeedDrawingCount];
                [self.delegate xAxis_coordinate:dateXAxis date:item.date atIndex:i];
            }
        }
        
        dateXAxis += avgNeedDrawingCount*self.linePadding;
    }
}

- (void)setNeedDrawingPointNumber:(NSUInteger)needDrawingPointNumber {
    _needDrawingPointNumber = needDrawingPointNumber;
    self.linePadding = (self.frame.size.width - 1.0f)/(self.needDrawingPointNumber - 1);
    
    [self drawSeparator];
}

@end
