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

@property (nonatomic) BOOL arrowInLeft;

@property (nonatomic) CGPoint tipPoint;

@end

@implementation TipBoardView

#pragma mark - private methods

- (void)getDrawPath:(CGContextRef)context {
    CGRect rrect = CGRectMake(0.5, 0.5, self.bounds.size.width-1, self.bounds.size.height-1);
    
    CGFloat minx = CGRectGetMinX(rrect), maxx = CGRectGetMaxX(rrect);
    CGFloat miny = CGRectGetMinY(rrect), midy = CGRectGetMidY(rrect), maxy = CGRectGetMaxY(rrect);
    
    CGFloat startMoveX = !self.arrowInLeft ? self.triangleWidth : maxx - self.triangleWidth;
    CGContextMoveToPoint(context, startMoveX, midy - self.triangleWidth);
    CGContextAddLineToPoint(context, (!self.arrowInLeft ? minx : maxx), midy);
    CGContextAddLineToPoint(context, startMoveX, midy + self.triangleWidth);
    
    CGPoint p1 = !self.arrowInLeft ? CGPointMake(self.triangleWidth, maxy) : CGPointMake(maxx - self.triangleWidth, miny);
    CGPoint p2 = !self.arrowInLeft ? CGPointMake(maxx, maxy) : CGPointMake(minx, miny);
    CGPoint p3 = !self.arrowInLeft ? CGPointMake(maxx, miny) : CGPointMake(minx, maxy);
    CGPoint p4 = !self.arrowInLeft ? CGPointMake(self.triangleWidth, miny) : CGPointMake(maxx - self.triangleWidth, maxy);
    CGPoint p5 = !self.arrowInLeft ? CGPointMake(self.triangleWidth, midy) : CGPointMake(maxx - self.triangleWidth, miny);
    NSArray *points = @[NSStringFromCGPoint(p1), NSStringFromCGPoint(p2),NSStringFromCGPoint(p3),NSStringFromCGPoint(p4),NSStringFromCGPoint(p5)];
    
    for (int i = 0; i < points.count - 1; i ++) {
        p1 = CGPointFromString(points[i]);
        p2 = CGPointFromString(points[i + 1]);
        CGContextAddArcToPoint(context, p1.x, p1.y, p2.x, p2.y, self.radius);
    }
    CGContextClosePath(context);
}

#pragma mark - public methods

- (void)drawInContext {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 1.0);
    CGContextSetFillColorWithColor(context, [UIColor colorWithWhite:0.35 alpha:0.9].CGColor);
    CGContextSetStrokeColorWithColor(context, [UIColor blueColor].CGColor);
    [self getDrawPath:context];
    CGContextFillPath(context);
    CGContextStrokePath(context);
}

- (void)showWithTipPoint:(CGPoint)point {
    self.hidden = NO;
    [self.layer removeAllAnimations];
    
    CGRect rect = self.superview.frame;
    if ((CGPointEqualToPoint(self.tipPoint, point))) {
        return;
    }
    self.arrowInLeft = NO;
    CGRect frame = self.frame;
    
    if (point.x > rect.origin.x && point.x < rect.origin.x + frame.size.width + 20.0f + 2) {
        frame.origin.x = point.x + 2;
    } else if (point.x > rect.origin.x + rect.size.width - frame.size.width - 20.0f - 2) {
        frame.origin.x = point.x - frame.size.width - 2;
        self.arrowInLeft = YES;
    }else if (point.x < (rect.origin.x + rect.size.width - frame.size.width - 20 - 2) && point.x > (rect.origin.x + frame.size.width + 20 + 2)) {
        if (CGPointEqualToPoint(self.tipPoint, CGPointZero)) {
            if (point.x - rect.origin.x > rect.size.width/2.0) {
                frame.origin.x = point.x - frame.size.width - 2;
                self.arrowInLeft = YES;
            } else {
                frame.origin.x = point.x + 2;
            }
        } else {
            if (self.tipPoint.x < point.x) {
                frame.origin.x = point.x - frame.size.width - 2;
                self.arrowInLeft = YES;
            } else {
                frame.origin.x = point.x + 2;
            }
        }
        
    }
    
    frame.origin.y = point.y;//(point.y - frame.size.height - 2.0) < rect.origin.y ? rect.origin.y : point.y - frame.size.height - 2.0;
    
    self.tipPoint = point;
    self.frame = frame;
    [self setNeedsDisplay];
}

- (void)hide {
    CATransition *animation = [CATransition animation];
    animation.type = kCATransitionFade;
    animation.duration = self.hideDuration;
    animation.startProgress = 0.0;
    animation.endProgress = 0.35;
    [self.layer addAnimation:animation forKey:nil];
    self.hidden = YES;
}

@end
