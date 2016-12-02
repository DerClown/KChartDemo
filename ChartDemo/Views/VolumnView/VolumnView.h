//
//  VolumnView.h
//  ChartDemo
//
//  Created by xdliu on 2016/11/17.
//  Copyright © 2016年 taiya. All rights reserved.
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

/*
 * 边框开始坐标点
 */
@property (nonatomic, assign) float boxOriginX;

/*
 *  边框距离右边距离
 */
@property (nonatomic, assign) float boxRightMargin;

/**
 *  k线图宽度
 */
@property (nonatomic, assign) CGFloat kLineWidth;

/**
 *  k线图间距
 */
@property (nonatomic, assign) CGFloat linePadding;

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
@property (nonatomic, strong) UIColor *axisShadowColor;

/**
 *  坐标轴边框宽度
 */
@property (nonatomic, assign) CGFloat axisShadowWidth;

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

/*
 *  取值位置
 */
@property (nonatomic, assign) NSInteger startDrawIndex;

/*
 *  绘制个数 
 */
@property (nonatomic, assign) NSInteger numberOfDrawCount;

//默认 YES
@property (nonatomic, assign) BOOL gestureEnable;

@property (nonatomic, strong) NSArray *data;

/*
 * 柱状图类型
 */
@property (nonatomic) CandlerstickChartsVolStyle volStyle;

- (void)update;

@end
