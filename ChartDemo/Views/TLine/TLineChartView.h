//
//  KLineView.h
//  CandlerstickCharts
//
//  Created by xdliu on 16/8/11.
//  Copyright © 2016年 liuxd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TLineChartView : UIView

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
 *  线宽度
 */
@property (nonatomic, assign) CGFloat lineWidth;

/**
 *  线颜色
 */
@property (nonatomic, strong) UIColor *lineColor;

/**
 *  阴影颜色
 */
@property (nonatomic, strong) UIColor *gradientFillColor;

/**
 *  坐标轴边框颜色
 */
@property (nonatomic, strong) UIColor *AxisColor;

/**
 *  坐标轴边框宽度
 */
@property (nonatomic, assign) CGFloat AxisWidth;

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
 *  分割线条数, 默认4条
 */
@property (nonatomic, assign) NSInteger separatorNumber;

/**
 *  分割线颜色
 */
@property (nonatomic, strong) UIColor *separatorColor;

/**
 *  十字线颜色
 */
@property (nonatomic, strong) UIColor *crossLineColor;

/**
 *  圆滑曲线，默认YES
 */
@property (nonatomic, assign) BOOL smoothPath;

/**
 *  YES表示：Y坐标的值根据视图中呈现的k线图的最大值最小值变化而变化；NO表示：Y坐标的最大和最小值初始设定多少就多少，不管k线图呈现如何都不会变化。默认YES
 */
@property (nonatomic, assign) BOOL isVisiableViewerExtremeValue;

/**
 *  时间和价格提示的字体颜色
 */
@property (nonatomic, strong) UIColor *dateTipAndPriceTipTextColor;

/**
 *  时间和价格提示背景颜色
 */
@property (nonatomic, strong) UIColor *dateTipAndPriceTipBackgroundColor;

/*
 *  保留小数点位数，默认保留两位(最多两位)
 */
@property (nonatomic, assign) NSInteger  saveDecimalPlaces;

/*
 * self.data 的格式为 @[@KLineItem, @KLineItem, ...]
 */

- (void)drawChartWithData:(NSArray *)data;

@end
