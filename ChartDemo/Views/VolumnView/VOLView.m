//
//  VolumnView.m
//  ChartDemo
//
//  Created by xdliu on 2016/11/17.
//  Copyright © 2016年 yoyo. All rights reserved.
//

#import "VOLView.h"
#import "KLineItem.h"

@interface VOLView ()

@end

@implementation VOLView

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.userInteractionEnabled = NO;
        self.layer.borderColor = [UIColor colorWithRed:223/255.0f green:223/255.0f blue:223/255.0f alpha:1.0].CGColor;
        self.layer.borderWidth = 0.5;
    }
    return self;
}

- (void)updateVolWithData:(NSArray *)data {
    [self clean];
    if (!data) return;
    
    [self drawVolWithData:data];
}

- (void)drawVolWithData:(NSArray *)data {
    // 移除layer，重新绘制
    [self.layer.sublayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    
    CGFloat scale = (self.maxmumVol - self.minmunVol) / self.frame.size.height;
    if (scale == 0) {
        scale = 1.0;
    }
    
    CGFloat xAxis = _barFixedSpacing;
    
    for (int index = 0; index < data.count; index ++) {
        KLineItem *drawItem = data[index];
        
        float rise_and_fall_value = [drawItem.rise_and_fall_value floatValue];
        
        UIColor *fillColor = rise_and_fall_value > 0 ? self.positiveVOLColor : self.negativeVOLColor;
        
        
        float height = MAX(MIN(fabs(rise_and_fall_value)/scale, self.frame.size.height - 0.5), 0.5);
        float yAxis = self.frame.size.height - height - 0.5;
        
        CGRect rect = CGRectMake(xAxis, yAxis, _barWidth, height);
        UIBezierPath *path = [UIBezierPath bezierPathWithRect:rect];
        
        CAShapeLayer *layer;
        layer = [CAShapeLayer new];
        layer.path = path.CGPath;
        layer.fillColor = fillColor.CGColor;
        layer.strokeColor = fillColor.CGColor;
        [self.layer addSublayer:layer];
        
        xAxis += _barWidth + _barFixedSpacing;
    }
}

- (void)clean {
    [self.layer.sublayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
}

@end
