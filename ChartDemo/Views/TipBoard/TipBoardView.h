//
//  TipBoardView.h
//  ChartDemo
//
//  Created by xdliu on 16/8/16.
//  Copyright © 2016年 taiya. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TipBoardView : UIView

@property (nonatomic, assign) CGFloat radius;

- (void)showForTipPoint:(CGPoint)point;

- (void)hide;

@end
