//
//  TipBoardView.h
//  ChartDemo
//
//  Created by xdliu on 16/8/16.
//  Copyright © 2016年 taiya. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TipBoardView : UIView

@property (nonatomic, assign) BOOL showArrow;

@property (nonatomic, strong) UIColor *shadowColor;

@property (nonatomic, assign) CGFloat cornerRadius;

- (void)showForTipPoint:(CGPoint)point;

@end
