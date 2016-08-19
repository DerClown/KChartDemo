//
//  TYBarChartView.h
//  CandlerstickCharts
//
//  Created by xdliu on 16/8/11.
//  Copyright © 2016年 liuxd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TYKLineChartView : UIView

/************************************************************************************/
/*                                          |                                       */
/*                                      topMargin                                   */
/*                                          |                                       */
/*                    *------------------------------------------*                  */
/*                    |                                          |                  */
/*                    |                                          |                  */
/* <-  leftMargin   ->|                    k线图                  | <- leftMargin -> */
/*                    |                                          |                  */
/*                    |                                          |                  */
/*                    *------------------------------------------*                  */
/*                                          |                                       */
/*                                      bottomMargin                                */
/*                                          |                                       */
/************************************************************************************/


/**
 *  内容距离父试图顶部高度
 */
@property (nonatomic, assign) CGFloat topMargin;

/**
 *  内容距离父试图左边距离
 */
@property (nonatomic, assign) CGFloat leftMargin;

/**
 *  内容距离父试图右边距离
 */
@property (nonatomic, assign) CGFloat rightMargin;

/**
 *  内容距离父试图底部距离
 */
@property (nonatomic, assign) CGFloat bottomMargin;

/**
 *  k线图宽度
 */
@property (nonatomic, assign) CGFloat kLineWidth;

/**
 *  k线图间距
 */
@property (nonatomic, assign) CGFloat kLinePadding;

/**
 *  均线宽度
 */
@property (nonatomic, assign) CGFloat avgLineWidth;

/**
 *  上升颜色
 */
@property (nonatomic, strong) UIColor *barRiseColor;

/**
 *  下跌颜色
 */
@property (nonatomic, strong) UIColor *barFallColor;

/**
 *  上影线
 */
@property (nonatomic, strong) UIColor *upperShadowColor;

/**
 *  下影线
 */
@property (nonatomic, strong) UIColor *lowerShadowColor;

/**
 *  5日
 */
@property (nonatomic, strong) UIColor *avgLineMA5Color;

/**
 *  顿号10
 */
@property (nonatomic, strong) UIColor *avgLineMA10Color;

/**
 *  日顿号20
 */
@property (nonatomic, strong) UIColor *avgLineMA20Color;

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
 *  坐标轴边框颜色
 */
@property (nonatomic, strong) UIColor *axisShadowColor;

/**
 *  坐标轴边框宽度
 */
@property (nonatomic, assign) CGFloat axisShadowWidth;

/**
 *  分割线大小
 */
@property (nonatomic, assign) CGFloat separatorWidth;

/**
 *  分割线颜色
 */
@property (nonatomic, strong) UIColor *separatorColor;

/**
 *   默认可以放大缩小
 */
@property (nonatomic, assign) BOOL zoomEnable;

/**
 *  默认可以滑动
 */
@property (nonatomic, assign) BOOL scrollEnable;

/**
 *  默认显示均线
 */
@property (nonatomic, assign) BOOL showAvgLine;

/**
 *  显示柱形图，默认显示
 */
@property (nonatomic, assign) BOOL showBarChart;

/**
 *  YES表示Y坐标的值，根据试图中呈现的k线图的最大值最小值变化而变化；NO表示Y坐标的最大和最小值初始设定多少就多少，不管k线图呈现如何都不会变化。默认YES
 */
@property (nonatomic, assign) BOOL yAxisTitleIsChange;

/**
 *  k线最大宽度
 */
@property (nonatomic, assign) CGFloat maxKLineWidth;

/**
 *  k线最小宽度
 */
@property (nonatomic, assign) CGFloat minKLineWidth;

- (void)drawChartWithData:(NSDictionary *)data;

- (void)clear;

@end
