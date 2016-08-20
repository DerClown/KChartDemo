//
//  TipBoardView.h
//  ChartDemo
//
//  Created by xdliu on 16/8/16.
//  Copyright © 2016年 taiya. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TipBoardView : UIView

@property (nonatomic, assign) CGFloat triangleWidth;

@property (nonatomic, assign) CGFloat radius;

/**
 *  开盘价
 */
@property (nonatomic, copy) NSString *open;

/**
 *  收盘价
 */
@property (nonatomic, copy) NSString *close;

/**
 *  最高价
 */
@property (nonatomic, copy) NSString *high;

/**
 *  最低价
 */
@property (nonatomic, copy) NSString *low;

/**************************************************/
/*                     字体颜色                    */
/**************************************************/
//提供不一样的字体颜色可供选择， 默认都｛白色｝

/**
 *  开盘价颜色
 */
@property (nonatomic, strong) UIColor *openColor;

/**
 *  收盘价颜色
 */
@property (nonatomic, strong) UIColor *closeColor;

/**
 *  最高价颜色
 */
@property (nonatomic, strong) UIColor *highColor;

/**
 *  最低价颜色
 */
@property (nonatomic, strong) UIColor *lowColor;

/**
 *  字体， 默认系统字体，大小 10
 */
@property (nonatomic, strong) UIFont *font;

- (void)showForTipPoint:(CGPoint)point;

- (void)hide;

@end
