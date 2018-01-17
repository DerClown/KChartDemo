//
//  TYBarChartView.h
//  CandlerstickCharts
//
//  Created by xdliu on 16/8/11.
//  Copyright © 2016年 liuxd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KLineChartView : UIView

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
/*                    *------------------------------------------*      -           */
/*                                                                      |           */
/*                                                                      |           */
/*                                                                      |           */
/***********************************************************************|************/
/*                                   showBarChart = YES                 |           */
/****************************************************************** bottomMargin ****/
/*                    *------------------------------------------*      |           */
/*                    |                                          |      |           */
/*                    |                    柱形图                 |      |           */
/*                    |                                          |      |           */
/*                    *------------------------------------------*      _           */
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
@property (nonatomic, assign) CGFloat movingAvgLineWidth;

/**
 *  阳线颜色(negative line)
 */
@property (nonatomic, strong) UIColor *positiveLineColor;

/**
 *  阴线颜色
 */
@property (nonatomic, strong) UIColor *negativeLineColor;

/**
 *  上影线
 */
@property (nonatomic, strong) UIColor *upperShadowColor;

/**
 *  下影线
 */
@property (nonatomic, strong) UIColor *lowerShadowColor;

/**
 *  交易量阳线颜色
 */
@property (nonatomic, strong) UIColor *positiveVolColor;

/**
 *  交易量阴线颜色
 */
@property (nonatomic, strong) UIColor *negativeVolColor;

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
 *   时间轴高度（默认20.0f）
 */
@property (nonatomic, assign) CGFloat timeAxisHeight;

/**
 *  坐标轴边框颜色
 */
@property (nonatomic, strong) UIColor *axisShadowColor;

/**
 *  坐标轴边框宽度
 */
@property (nonatomic, assign) CGFloat axisShadowWidth;

/**
 *  分割线个数
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
 *  YES表示：Y坐标的值根据视图中呈现的k线图的最大值最小值变化而变化；NO表示：Y坐标是所有数据中的最大值最小值，不管k线图呈现如何都不会变化。默认YES
 */
@property (nonatomic, assign) BOOL yAxisTitleIsChange;

/**
 *  保留小数点位数，默认保留两位(最多两位)
 */
@property (nonatomic, assign) NSInteger  saveDecimalPlaces;

/**
 *  k线最大宽度
 */
@property (nonatomic, assign) CGFloat maxKLineWidth;

/**
 *  k线最小宽度
 */
@property (nonatomic, assign) CGFloat minKLineWidth;

/**
 *  时间和价格提示的字体颜色
 */
@property (nonatomic, strong) UIColor *timeAndPriceTextColor;

/**
 *  时间和价格提示背景颜色
 */
@property (nonatomic, strong) UIColor *timeAndPriceTipsBackgroundColor;

/**
 *  支持手势（默认支持）
 */
@property (nonatomic, assign) BOOL supportGesture;

/**
 *  均线个数（默认ma5, ma10, ma20）
 */
@property (nonatomic, strong) NSArray *Mas;

/*
 *  均线颜色值 (默认 HexRGB(0x019FFD)、HexRGB(0xFF9900)、HexRGB(0xFF00FF))
 */
@property (nonatomic, strong) NSArray<UIColor *> *masColors;

/**
 *  动态更新显示最新, 默认不开启。
 *
 *  注意⚠️
 1. 有新数据过来，新数据会呈现高亮状态提示为最新数据
 2. 开启，有新数据过来，会以最新数据显示为准绘制在UI；优先级优于用户操作；忽略用户操作的结果。
 3. 不开启，优先级低于手势，处理完手势，才会处理最新数据，用户的操作为准。
 */
@property (nonatomic, assign) BOOL dynamicUpdateIsNew;

/*
 *  全屏绘制时，topMargin无效
 */
@property (nonatomic, assign) BOOL fullScreen;

/*
 * self.data 的格式为 @[@KLineItem, @KLineItem, ...]
 */

- (void)drawChartWithData:(NSArray *)data;

// 更新数据
- (void)updateChartWithOpen:(NSNumber *)open
                      close:(NSNumber *)close
                       high:(NSNumber *)high
                        low:(NSNumber *)low
                       date:(NSString *)date
                      isNew:(BOOL)isNew;

- (void)clear;

@end
