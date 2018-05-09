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
/*                                   showVolChart = YES                 |           */
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
@property (nonatomic, assign) CGFloat kCandleWidth;

/**
 *  k线图间距
 */
@property (nonatomic, assign) CGFloat kCandleFixedSpacing;

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
 *  坐标轴边框颜色
 */
@property (nonatomic, strong) UIColor *axisColor;

/**
 *  坐标轴边框宽度
 */
@property (nonatomic, assign) CGFloat axisWidth;

/**
 *  分割线个数
 */
@property (nonatomic, assign) NSInteger separatorNumber;

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
 *  默认显示移动均线
 */
@property (nonatomic, assign) BOOL showMA;

/**
 *  显示成交量柱形图，默认显示
 */
@property (nonatomic, assign) BOOL showVolChart;

/**
 *  YES表示：Y坐标的值根据视图中呈现的k线图的最大值最小值变化而变化；NO表示：Y坐标是所有数据中的最大值最小值，不管k线图呈现如何都不会变化。默认YES
 */
@property (nonatomic, assign) BOOL isVisiableViewerExtremeValue;

/**
 *  保留小数点位数，默认保留两位(最多两位)
 */
@property (nonatomic, assign) NSInteger  saveDecimalPlaces;

/**
 *  k线最大宽度
 */
@property (nonatomic, assign) CGFloat maxCandleWidth;

/**
 *  k线最小宽度
 */
@property (nonatomic, assign) CGFloat minCandleWidth;

/**
 *  时间和价格提示的字体颜色
 */
@property (nonatomic, strong) UIColor *dateTipAndPriceTipTextColor;

/**
 *  时间和价格提示背景颜色
 */
@property (nonatomic, strong) UIColor *dateTipAndPriceTipBackgroundColor;

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
@property (nonatomic, strong) NSArray<UIColor *> *MAColors;

/*
 *  全屏绘制时，topMargin无效
 */
@property (nonatomic, assign) BOOL fullScreen;

/*
 * self.data 的格式为 @[@KLineItem, @KLineItem, ...]
 */
- (void)drawChartWithData:(NSArray *)data;

- (void)clear;

@end
