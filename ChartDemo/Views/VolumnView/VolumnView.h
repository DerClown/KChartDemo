//
//  VolumnView.h
//  ChartDemo
//
//  Created by xdliu on 2016/11/17.
//  Copyright © 2016年 yoyo. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, CandlerstickChartsVolStyle) {
    CandlerstickChartsVolStyleDefault = 0,
    CandlerstickChartsVolStyleRSV9,
    CandlerstickChartsVolStyleKDJ,
    CandlerstickChartsVolStyleMACD,
    CandlerstickChartsVolStyleRSI,
    CandlerstickChartsVolStyleBOLL,
    CandlerstickChartsVolStyleDMA,
    CandlerstickChartsVolStyleCCI,
    CandlerstickChartsVolStyleWR,
    CandlerstickChartsVolStyleBIAS
};

@interface VolumnView : UIView

/**
 *  k线图宽度
 */
@property (nonatomic, assign) CGFloat kLineWidth;

/**
 *  y坐标轴字体
 */
@property (nonatomic, strong) UIFont *yAxisTitleFont;

/**
 *  y坐标轴标题颜色
 */
@property (nonatomic, strong) UIColor *yAxisTitleColor;

/**
 *  坐标轴边框颜色
 */
@property (nonatomic, strong) UIColor *AxisColor;

/**
 *  坐标轴边框宽度
 */
@property (nonatomic, assign) CGFloat AxisWidth;

/**
 *  交易量阳线颜色
 */
@property (nonatomic, strong) UIColor *positiveVolColor;

/**
 *  交易量阴线颜色
 */
@property (nonatomic, strong) UIColor *negativeVolColor;

/**
 *  分割线大小
 */
@property (nonatomic, assign) CGFloat separatorWidth;

/**
 *  分割线颜色
 */
@property (nonatomic, strong) UIColor *separatorColor;

@end
