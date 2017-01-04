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
 *  底部距离 必须 >= timeAxisHeigth
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
 *  阴影开始绘制颜色
 */
@property (nonatomic, strong) UIColor *gradientStartColor;

/**
 *  阴影绘制结束颜色
 */
@property (nonatomic, strong) UIColor *gradientEndColor;

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
 *  x坐标轴时间字体
 */
@property (nonatomic, strong) UIFont *xAxisPriceFont;

/**
 *   时间轴高度（默认20.0f）
 */
@property (nonatomic, assign) CGFloat timeAxisHeigth;

/**
 *  分割线条数, 默认4条
 */
@property (nonatomic, assign) NSInteger separatorNum;

/**
 *  分割线大小
 */
@property (nonatomic, assign) CGFloat separatorWidth;

/**
 *  分割线颜色
 */
@property (nonatomic, strong) UIColor *separatorColor;

/**
 *  十字线颜色
 */
@property (nonatomic, strong) UIColor *crossLineColor;

/**
 *  虚线边框
 */
@property (nonatomic, assign) BOOL dashLineBorder;

/**
 *  圆滑曲线，默认YES
 */
@property (nonatomic, assign) BOOL smoothPath;

/**
 *  闪烁点颜色
 */
@property (nonatomic, strong) UIColor *flashPointColor;

/**
 *  闪烁点，默认不显示
 */
@property (nonatomic, assign) BOOL flashPoint;

/**
 *  YES表示：Y坐标的值根据视图中呈现的k线图的最大值最小值变化而变化；NO表示：Y坐标的最大和最小值初始设定多少就多少，不管k线图呈现如何都不会变化。默认YES
 */
@property (nonatomic, assign) BOOL yAxisTitleIsChange;

/**
 *  时间和价格提示的字体颜色
 */
@property (nonatomic, strong) UIColor *timeTipTextColor;

/**
 *  时间和价格提示背景颜色
 */
@property (nonatomic, strong) UIColor *timeTipBackgroundColor;

/*
 *  全屏绘制时，topMargin无效
 */
@property (nonatomic, assign) BOOL fullScreen;

/*
 *  保留小数点位数，默认保留两位(最多两位)
 */
@property (nonatomic, assign) NSInteger  saveDecimalPlaces;

/*
 * self.data 的格式为 @[@KLineItem, @KLineItem, ...]
 */

- (void)drawChartWithData:(NSArray *)data;

@end
