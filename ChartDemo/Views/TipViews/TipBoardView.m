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

#pragma mark - life cycle

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
    self.triangleWidth = 5.0;
    self.radius = 4.0;
    self.hideDuration = 2.5;
    
    self.open = @"0.0";
    self.close = @"0.0";
    self.high = @"0.0";
    self.low = @"0.0";
    
    self.openColor = [UIColor whiteColor];
    self.closeColor = [UIColor whiteColor];
    self.highColor = [UIColor whiteColor];
    self.lowColor = [UIColor whiteColor];
    
    self.font = [UIFont systemFontOfSize:8.0f];
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    //图形
    [self drawInContext];
    
    //文字
    [self drawText];
}

#pragma mark - private methods

- (void)drawInContext {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 1.0);
    CGContextSetFillColorWithColor(context, [UIColor colorWithWhite:0.35 alpha:0.9].CGColor);
    CGContextSetStrokeColorWithColor(context, [UIColor blueColor].CGColor);
    [self getDrawPath:context];
    CGContextFillPath(context);
    CGContextStrokePath(context);
}

- (void)getDrawPath:(CGContextRef)context {
    CGRect rrect = CGRectMake(0.5, 0.5, self.bounds.size.width-1, self.bounds.size.height-1);
    
    CGFloat minx = CGRectGetMinX(rrect), maxx = CGRectGetMaxX(rrect);
    CGFloat miny = CGRectGetMinY(rrect), midy = CGRectGetMidY(rrect), maxy = CGRectGetMaxY(rrect);
    
    CGFloat startMoveX = !_arrowInLeft ? _triangleWidth : maxx - _triangleWidth;
    CGContextMoveToPoint(context, startMoveX, midy - _triangleWidth);
    CGContextAddLineToPoint(context, (!_arrowInLeft ? minx : maxx), midy);
    CGContextAddLineToPoint(context, startMoveX, midy+_triangleWidth);
    
    CGPoint p1 = !_arrowInLeft ? CGPointMake(_triangleWidth, maxy) : CGPointMake(maxx - _triangleWidth, miny);
    CGPoint p2 = !_arrowInLeft ? CGPointMake(maxx, maxy) : CGPointMake(minx, miny);
    CGPoint p3 = !_arrowInLeft ? CGPointMake(maxx, miny) : CGPointMake(minx, maxy);
    CGPoint p4 = !_arrowInLeft ? CGPointMake(_triangleWidth, miny) : CGPointMake(maxx - _triangleWidth, maxy);
    CGPoint p5 = !_arrowInLeft ? CGPointMake(_triangleWidth, midy) : CGPointMake(maxx - _triangleWidth, miny);
    NSArray *points = @[NSStringFromCGPoint(p1), NSStringFromCGPoint(p2),NSStringFromCGPoint(p3),NSStringFromCGPoint(p4),NSStringFromCGPoint(p5)];
    
    for (int i = 0; i < points.count - 1; i ++) {
        p1 = CGPointFromString(points[i]);
        p2 = CGPointFromString(points[i + 1]);
        CGContextAddArcToPoint(context, p1.x, p1.y, p2.x, p2.y, _radius);
    }
    CGContextClosePath(context);
}

- (void)drawText {
    NSArray *titles = @[[@"开盘价：" stringByAppendingString:self.open], [@"收盘价：" stringByAppendingString:self.close], [@"最高价：" stringByAppendingString:self.high], [@"最低价：" stringByAppendingString:self.low]];
    NSArray<UIColor *> *colors = @[self.openColor, self.closeColor, self.highColor, self.lowColor];
    
    CGFloat padding = (self.frame.size.height - 2*self.font.lineHeight) / 3.0;
    
    for (int i = 0; i < 4; i ++) {
        NSAttributedString *attString = [[NSAttributedString alloc] initWithString:titles[i] attributes:@{NSFontAttributeName:self.font, NSForegroundColorAttributeName:colors[i]}];
        CGFloat originY = i == 0 || i == 1 ? padding - 2 : padding*2 + 4 + self.font.lineHeight;
        CGFloat originX = i == 0 || i == 2 ? self.triangleWidth + 2 : (self.frame.size.width - self.triangleWidth - 4 - 2)/2.0 + self.triangleWidth + 2.0;
        [attString drawInRect:CGRectMake(originX, originY, self.frame.size.width, self.font.lineHeight)];
    }
}

#pragma mark - public methods

- (void)showForTipPoint:(CGPoint)point {
    self.hidden = NO;
    [self.layer removeAllAnimations];
    
    CGRect rect = self.superview.frame;
    if ((CGPointEqualToPoint(_tipPoint, point))) {
        return;
    }
    _arrowInLeft = NO;
    CGRect frame = self.frame;
    
    if (point.x > rect.origin.x && point.x < rect.origin.x + frame.size.width + 20.0f + 2) {
        frame.origin.x = point.x + 2;
    } else if (point.x > rect.origin.x + rect.size.width - frame.size.width - 20.0f - 2) {
        frame.origin.x = point.x - frame.size.width - 2;
        _arrowInLeft = YES;
    }else if (point.x < (rect.origin.x + rect.size.width - frame.size.width - 20 - 2) && point.x > (rect.origin.x + frame.size.width + 20 + 2)) {
        if (CGPointEqualToPoint(_tipPoint, CGPointZero)) {
            if (point.x - rect.origin.x > rect.size.width/2.0) {
                frame.origin.x = point.x - frame.size.width - 2;
                _arrowInLeft = YES;
            } else {
                frame.origin.x = point.x + 2;
            }
        } else {
            if (_tipPoint.x < point.x) {
                frame.origin.x = point.x - frame.size.width - 2;
                _arrowInLeft = YES;
            } else {
                frame.origin.x = point.x + 2;
            }
        }
        
    }
    
    frame.origin.y = (point.y - frame.size.height - 2.0) < rect.origin.y ? rect.origin.y : point.y - frame.size.height - 2.0;
    
    _tipPoint = point;
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
