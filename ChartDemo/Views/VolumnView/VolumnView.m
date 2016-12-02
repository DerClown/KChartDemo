//
//  VolumnView.m
//  ChartDemo
//
//  Created by xdliu on 2016/11/17.
//  Copyright © 2016年 taiya. All rights reserved.
//

#import "VolumnView.h"
#import "KLineListTransformer.h"
#import "Global+Helper.h"
#import "KLineItem.h"

@interface VolumnView ()

@property (nonatomic) float maxValue;

@property (nonatomic) float minValue;

@property (nonatomic, strong) UITapGestureRecognizer *switchGesture;

@end

@implementation VolumnView

#pragma mark - life cycle

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self _setup];
        [self addGestureRecognizer:self.switchGesture];
    }
    return self;
}

- (void)_setup {
    self.volStyle = CandlerstickChartsVolStyleDefault;
    
    _maxValue = -MAXFLOAT;
    _minValue = MAXFLOAT;
}

// overrite
- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    [self drawAxis];
    
    [self drawChart];
}

#pragma mark - public methods

- (void)update {
    [self reset];
    [self setNeedsDisplay];
}

#pragma mark - private methods

- (void)reset {
    _maxValue = -MAXFLOAT;
    _minValue = MAXFLOAT;
    switch (_volStyle) {
        case CandlerstickChartsVolStyleDefault: {
            NSArray *volums = [self.data subarrayWithRange:NSMakeRange(self.startDrawIndex, self.numberOfDrawCount)];
            for (KLineItem *item in volums) {
                if (self.maxValue < [item.vol floatValue]) {
                    self.maxValue = [item.vol floatValue];
                }
                
                if (self.minValue > [item.vol floatValue]) {
                    self.minValue = [item.vol floatValue];
                }
            }
            break;
        }
        default:
            break;
    }
}

- (void)drawAxis {
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetLineWidth(context, self.axisShadowWidth);
    CGContextSetStrokeColorWithColor(context, self.axisShadowColor.CGColor);
    CGRect strokeRect = CGRectMake(self.boxOriginX, 0, self.bounds.size.width - self.boxOriginX - self.boxRightMargin, self.bounds.size.height);
    CGContextStrokeRect(context, strokeRect);
}

- (void)drawChart {
    switch (_volStyle) {
        case CandlerstickChartsVolStyleDefault: {
            [self showYAxisTitleWithTitles:@[[NSString stringWithFormat:@"%.f", self.maxValue], [NSString stringWithFormat:@"%.f", self.maxValue/2.0], @"万"]];
            [self drawVol];
            break;
        }
        case CandlerstickChartsVolStyleRSV9: {
            break;
        }
            
        case CandlerstickChartsVolStyleKDJ: {
            break;
        }
            
        case CandlerstickChartsVolStyleMACD: {
            break;
        }
            
        case CandlerstickChartsVolStyleRSI: {
            break;
        }
            
        case CandlerstickChartsVolStyleBOLL: {
            break;
        }
            
        case CandlerstickChartsVolStyleDMA: {
            break;
        }
            
        case CandlerstickChartsVolStyleCCI: {
            break;
        }
            
        case CandlerstickChartsVolStyleWR: {
            break;
        }
        case CandlerstickChartsVolStyleBIAS: {
            break;
        }
        default:
            break;
    }
}

/**
 *  交易量
 */
- (void)drawVol {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, self.kLineWidth);
    
    CGRect rect = self.bounds;
    
    CGFloat xAxis = self.linePadding + self.boxOriginX;
    
    CGFloat boxOriginY = self.axisShadowWidth;
    CGFloat boxHeight = rect.size.height - boxOriginY;
    CGFloat scale = self.maxValue/boxHeight;
    
    NSArray *contentValues = [self.data subarrayWithRange:NSMakeRange(self.startDrawIndex, self.numberOfDrawCount)];
    for (KLineItem *item in contentValues) {
        CGFloat open = [item.open floatValue];
        CGFloat close = [item.close floatValue];
        UIColor *fillColor = open > close ? self.positiveVolColor : self.negativeVolColor;
        CGContextSetFillColorWithColor(context, fillColor.CGColor);
        
        CGFloat height = [item.vol floatValue]/scale == 0 ? 1.0 : [item.vol floatValue]/scale;
        CGRect pathRect = CGRectMake(xAxis, boxOriginY + boxHeight - height, self.kLineWidth, height - self.axisShadowWidth);
        CGContextAddRect(context, pathRect);
        CGContextFillPath(context);
        
        xAxis += _kLineWidth + _linePadding;
    }
}

- (void)showYAxisTitleWithTitles:(NSArray *)yAxis {
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGRect rect = self.bounds;
    //交易量边框
    CGContextSetLineWidth(context, self.axisShadowWidth);
    CGContextSetStrokeColorWithColor(context, self.axisShadowColor.CGColor);
    CGRect strokeRect = CGRectMake(self.boxOriginX, self.axisShadowWidth/2.0, rect.size.width - _boxOriginX - self.boxRightMargin, rect.size.height);
    CGContextStrokeRect(context, strokeRect);
    
    [self drawDashLineInContext:context movePoint:CGPointMake(self.boxOriginX + 1.25, rect.size.height/2.0)
                        toPoint:CGPointMake(rect.size.width  - self.boxRightMargin - 0.8, rect.size.height/2.0)];
    
    //这必须把dash给初始化一次，不然会影响其他线条的绘制
    CGContextSetLineDash(context, 0, 0, 0);
    
    for (int i = 0; i < yAxis.count; i ++) {
        NSAttributedString *attString = [Global_Helper attributeText:yAxis[i] textColor:self.yAxisTitleColor font:self.yAxisTitleFont];
        CGSize size = [Global_Helper attributeString:attString boundingRectWithSize:CGSizeMake(self.boxOriginX, self.yAxisTitleFont.lineHeight)];
        
        [attString drawInRect:CGRectMake(self.boxOriginX - size.width - 2.0f, strokeRect.origin.y + i*strokeRect.size.height/2.0 - size.height/2.0*i - (i==0?2 : 0), size.width, size.height)];
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

#pragma mark - events

- (void)switchEvent:(UITapGestureRecognizer *)tapGesture {
    return;
    switch (_volStyle) {
        case CandlerstickChartsVolStyleDefault: {
            _volStyle = CandlerstickChartsVolStyleRSV9;
            break;
        }
        case CandlerstickChartsVolStyleRSV9: {
            _volStyle = CandlerstickChartsVolStyleKDJ;
            break;
        }
            
        case CandlerstickChartsVolStyleKDJ: {
            _volStyle = CandlerstickChartsVolStyleMACD;
            break;
        }
            
        case CandlerstickChartsVolStyleMACD: {
            _volStyle = CandlerstickChartsVolStyleRSI;
            break;
        }
            
        case CandlerstickChartsVolStyleRSI: {
            _volStyle = CandlerstickChartsVolStyleBOLL;
            break;
        }
            
        case CandlerstickChartsVolStyleBOLL: {
            _volStyle = CandlerstickChartsVolStyleDMA;
            break;
        }
            
        case CandlerstickChartsVolStyleDMA: {
            _volStyle = CandlerstickChartsVolStyleCCI;
            break;
        }
            
        case CandlerstickChartsVolStyleCCI: {
            _volStyle = CandlerstickChartsVolStyleWR;
            break;
        }
            
        case CandlerstickChartsVolStyleWR: {
            _volStyle = CandlerstickChartsVolStyleBIAS;
            break;
        }
        case CandlerstickChartsVolStyleBIAS: {
            _volStyle = CandlerstickChartsVolStyleDefault;
            break;
        }
        default:
            break;
    }
    
    [self update];
    [self setNeedsDisplay];
}

#pragma mark - getters

- (UITapGestureRecognizer *)switchGesture {
    if (!_switchGesture) {
        _switchGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(switchEvent:)];
    }
    return _switchGesture;
}

#pragma mark - setters

- (void)setGestureEnable:(BOOL)gestureEnable {
    self.switchGesture.enabled = gestureEnable;
}

@end
