//
//  KLineView.h
//  CandlerstickCharts
//
//  Created by xdliu on 16/8/11.
//  Copyright © 2016年 liuxd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TimeShareChartView : UIView

/**
 *  绘制点的个数
 */
@property (nonatomic, assign) NSUInteger needDrawingPointNumber;

/**
 *  线颜色
 */
@property (nonatomic, strong) UIColor *lineColor;

/**
 *  阴影颜色
 */
@property (nonatomic, strong) UIColor *gradientFillColor;

/**
 *  y坐标轴字体
 */
@property (nonatomic, strong) UIFont *yAxisTitleFont;

/**
 *  y坐标轴标题颜色
 */
@property (nonatomic, strong) UIColor *yAxisTitleColor;

/**
 *  x坐标轴字体
 */
@property (nonatomic, strong) UIFont *xAxisTitleFont;

/**
 *  x坐标轴标题颜色
 */
@property (nonatomic, strong) UIColor *xAxisTitleColor;

/**
 *  十字线颜色
 */
@property (nonatomic, strong) UIColor *crossLineColor;

/**
 *  圆滑曲线，默认YES
 */
@property (nonatomic, assign) BOOL smoothPath;

/**
 *  时间和价格提示的字体颜色
 */
@property (nonatomic, strong) UIColor *dateTipAndPriceTipTextColor;

/**
 *  时间和价格提示背景颜色
 */
@property (nonatomic, strong) UIColor *dateTipAndPriceTipBackgroundColor;

/*
 *  保留小数点位数，默认保留两位
 */
@property (nonatomic, assign) NSUInteger  maxnumIntegerDigits;

/**
 *  显示成交量柱形图，默认显示
 */
@property (nonatomic, assign) BOOL showVolChart;

/*
 * self.data 的格式为 @[@KLineItem, @KLineItem, ...]
 */

- (void)drawChartWithData:(NSArray *)data;

@end
