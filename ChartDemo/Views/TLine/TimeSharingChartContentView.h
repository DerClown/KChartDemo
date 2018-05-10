//
//  TimeSharingChartContentView.h
//  ChartDemo
//
//  Created by YoYo on 2018/5/10.
//  Copyright © 2018年 taiya. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TimeSharingChartContentViewDelegate <NSObject>

// 日期的x坐标位置 + 日期
- (void)xAxis_coordinate:(float)x_coordinate date:(NSString *)date atIndex:(NSInteger)index;

@end

@interface TimeSharingChartContentView : UIView

@property (nonatomic, weak) id<TimeSharingChartContentViewDelegate>delegate;

@property (nonatomic, assign, readonly) float linePadding;

/**
 *  绘制点的个数
 */
@property (nonatomic, assign) NSUInteger needDrawingPointNumber;

/**
 *  线颜色
 */
@property (nonatomic, strong) UIColor *strokeColor;

/**
 *  填充颜色
 */
@property (nonatomic, strong) UIColor *fillColor;

/**
 *  阴影颜色
 */
@property (nonatomic, strong) UIColor *gradientFillColor;

/**
 *  圆滑曲线，默认YES
 */
@property (nonatomic, assign) BOOL smoothPath;

/*
 *  最大价格
 */
@property (nonatomic) float maxmumPrice;

/*
 *  最小价格
 */
@property (nonatomic) float minmumPrice;

- (void)updateChartWithData:(NSArray *)data;

@end
