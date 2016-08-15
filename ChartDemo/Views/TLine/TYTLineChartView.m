//
//  KLineView.m
//  CandlerstickCharts
//
//  折线图
//  Created by xdliu on 16/8/11.
//  Copyright © 2016年 liuxd. All rights reserved.
//

#import "TYTLineChartView.h"

@interface TYTLineChartView ()

@property (nonatomic, strong) NSArray *contexts;

@property (nonatomic, assign) CGFloat xAxisWidth;

@property (nonatomic, assign) CGFloat yAxisHeight;

@property (nonatomic, assign) NSInteger kGraphDrawCount;

@property (nonatomic, assign) CGFloat maxValue;

@property (nonatomic, assign) CGFloat minValue;

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
    self.pointPadding = 1.0;
    
    self.separatorColor = [UIColor colorWithRed:230/255.0f green:230/255.0f blue:230/255.0f alpha:1.0];
    
    self.yAxisTitleFont = [UIFont systemFontOfSize:8.0];
    self.yAxisTitleColor = [UIColor colorWithRed:(130/255.0f) green:(130/255.0f) blue:(130/255.0f) alpha:1.0];
    
    self.showBarChart = YES;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    //画坐标轴
    [self drawAxisInRect:rect];
    
    //折线图
    [self drawLineChart];
}

#pragma mark - public methods

- (void)drawChartWithData:(NSDictionary *)data {
    [self setNeedsDisplay];
}

#pragma mark - private methods

//坐标轴
- (void)drawAxisInRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //k线边框
    CGRect strokeRect = CGRectMake(self.leftMargin, self.topMargin, self.xAxisWidth, self.yAxisHeight);
    CGContextSetLineWidth(context, self.axisShadowWidth);
    CGContextSetStrokeColorWithColor(context, self.axisShadowColor.CGColor);
    CGContextStrokeRect(context, strokeRect);
    
    //这必须把dash给初始化一次，不然会影响其他线条的绘制
    CGContextSetLineDash(context, 0, 0, 0);
    
    //k线y坐标
    CGFloat avgValue = (self.maxValue - self.minValue) / 5.0;
    CGFloat avgHeight = strokeRect.size.height/5.0;
    
    for (int i = 0; i < 6; i ++) {
        float yAxisValue = self.minValue - avgValue*i;
        NSAttributedString *attString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%.2f", yAxisValue] attributes:@{NSFontAttributeName:self.yAxisTitleFont, NSForegroundColorAttributeName:self.yAxisTitleColor}];
        CGSize size = [attString boundingRectWithSize:CGSizeMake(self.leftMargin, self.yAxisTitleFont.lineHeight) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
        
        [attString drawInRect:CGRectMake(self.leftMargin - size.width - 2.0f, self.topMargin + avgHeight*i - size.height/2.0, size.width, size.height)];
    }
}

//折线图
- (void)drawLineChart {
    
}

- (CGPathRef)getLineChartPath {
    UIBezierPath *path;
    
    //NSArray *data = self.contexts && self.contexts.count > 0 ? nil : self.contexts.count >= self.kGraphDrawCount ? [self.contexts subarrayWithRange:NSMakeRange(0, self.kGraphDrawCount - 1)] : self.contexts;
    
    return path.CGPath;
}

@end
