//
//  KLineView.h
//  CandlerstickCharts
//
//  Created by xdliu on 16/8/11.
//  Copyright © 2016年 liuxd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TYTLineChartView : UIView

/**
 *  顶部距离
 */
@property (nonatomic, assign) CGFloat topMargin;

/**
 *  左边距离
 */
@property (nonatomic, assign) CGFloat leftMargin;

/**
 *  右边距离
 */
@property (nonatomic, assign) CGFloat rightMargin;

/**
 *  底部距离
 */
@property (nonatomic, assign) CGFloat bottomMargin;

/**
 *  折线图宽度
 */
@property (nonatomic, assign) CGFloat lineWidth;

/**
 *  折线图颜色
 */
@property (nonatomic, strong) UIFont *lineColor;

/**
 *  点之间的间距 
 */
@property (nonatomic, assign) CGFloat pointPadding;

/**
 *  坐标轴边框颜色
 */
@property (nonatomic, strong) UIColor *axisShadowColor;

/**
 *  坐标轴边框宽度
 */
@property (nonatomic, assign) CGFloat axisShadowWidth;

/**
 *  y坐标轴字体
 */
@property (nonatomic, strong) UIFont *yAxisTitleFont;

/**
 *  x坐标轴字体
 */
@property (nonatomic, strong) UIFont *xAxisTitleFont;

/**
 *  x坐标轴标题颜色
 */
@property (nonatomic, strong) UIColor *xAxisTitleColor;

/**
 *  y坐标轴标题颜色
 */
@property (nonatomic, strong) UIColor *yAxisTitleColor;

/**
 *  分割线颜色
 */
@property (nonatomic, strong) UIColor *separatorColor;

/**
 *  显示柱形图，默认不显示
 */
@property (nonatomic, assign) BOOL showBarChart;


- (void)drawChartWithData:(NSDictionary *)data;

@end
