//
//  TipBoardView.m
//  ChartDemo
//
//  Created by xdliu on 16/8/16.
//  Copyright © 2016年 taiya. All rights reserved.
//

#import "TipBoardView.h"

#define kPopupTriangleHeigh 8
#define kPopupTriangleWidth 5
#define kBorderOffset       0.5f

@interface TipBoardView ()

@property (nonatomic) BOOL tipBoardInLeft;
@property (nonatomic) CGPoint tipPoint;

@end

@implementation TipBoardView

#pragma mark - life cycle

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    [self drawInContext:UIGraphicsGetCurrentContext()];
}

-(void)drawInContext:(CGContextRef)context{
    //设置当前图形的宽度
    CGContextSetLineWidth(context, 1.0);
    //填充的颜色
    CGContextSetFillColorWithColor(context, [UIColor colorWithWhite:0.35 alpha:0.9].CGColor);
    CGContextSetStrokeColorWithColor(context, [UIColor blueColor].CGColor);
    [self getDrawPath:context];
    //填充形状内的颜色
    CGContextFillPath(context);
    CGContextStrokePath(context);
}
-(void)getDrawPath:(CGContextRef)context{
    CGRect rrect = CGRectMake(0.5, 0.5, self.bounds.size.width-1, self.bounds.size.height-1);
    //设置园弧度
    CGFloat radius = 4;
    
    CGFloat minx = CGRectGetMinX(rrect),//0
    //中点
    midy = CGRectGetMidY(rrect),
    //最大的宽度的X
    maxx = CGRectGetMaxX(rrect);
    CGFloat miny = CGRectGetMinY(rrect),
    //最大的高度Y
    maxy = CGRectGetMaxY(rrect);
    
    if (!_tipBoardInLeft) {
        CGContextMoveToPoint(context, 5, midy - 5);
        CGContextAddLineToPoint(context, minx, midy);
        CGContextAddLineToPoint(context, 5, midy+5);
        
        CGContextAddArcToPoint(context, 5, maxy, maxx, maxy, radius);
        CGContextAddArcToPoint(context, maxx, maxy, maxx, miny, radius);
        CGContextAddArcToPoint(context, maxx, miny, 5, miny, radius);
        CGContextAddArcToPoint(context, 5, miny, 5, midy, radius);
        CGContextClosePath(context);
    } else {
        CGContextMoveToPoint(context, maxx - 5, midy - 5);
        CGContextAddLineToPoint(context, maxx, midy);
        CGContextAddLineToPoint(context, maxx - 5, midy+5);
        
        CGContextAddArcToPoint(context, maxx - 5, miny, minx, miny, radius);
        CGContextAddArcToPoint(context, minx, miny, minx, maxy, radius);
        CGContextAddArcToPoint(context, minx, maxy, maxx - 5, maxy, radius);
        CGContextAddArcToPoint(context, maxx - 5, maxy, maxx - 5, miny, radius);
        CGContextClosePath(context);
    }
}

#pragma mark - public methods

- (void)showForTipPoint:(CGPoint)point {
    CGRect rect = self.superview.frame;
    if ((CGPointEqualToPoint(_tipPoint, point))) {
        return;
    }
    _tipBoardInLeft = NO;
    CGRect frame = self.frame;
    frame.origin.y = point.y - frame.size.height/2.0;
    
    if (point.x > rect.origin.x && point.x < rect.origin.x + frame.size.width + 20.0f) {
        frame.origin.x = point.x;
    } else if (point.x > rect.origin.x + rect.size.width - frame.size.width - 20.0f) {
        frame.origin.x = point.x - frame.size.width;
        _tipBoardInLeft = YES;
    }else if (point.x < (rect.origin.x + rect.size.width - frame.size.width - 20) && point.x > (rect.origin.x + frame.size.width + 20)) {
        if (CGPointEqualToPoint(_tipPoint, CGPointZero)) {
            if (point.x - rect.origin.x > rect.size.width/2.0) {
                frame.origin.x = point.x - frame.size.width;
                _tipBoardInLeft = YES;
            } else {
                frame.origin.x = point.x;
            }
        } else {
            if (_tipPoint.x < point.x) {
                frame.origin.x = point.x - frame.size.width;
                _tipBoardInLeft = YES;
            } else {
                frame.origin.x = point.x;
            }
        }
        
    }
    
    _tipPoint = point;
    
    self.frame = frame;
    
    [self setNeedsDisplay];
}

@end
