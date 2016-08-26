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

// 注意、注意、注意（重要的事情要说三遍）！！！：为了配合实时数据，timer OR socket有实时数据过来，就需要避免和交互产生冲突，利用这两个通知可以很好的解决问题。
/**
 *  开始交互通知
 */
UIKIT_EXTERN NSString *const TLineKeyStartUserInterfaceNotification __TVOS_PROHIBITED;

/**
 *  结束交互通知
 */
UIKIT_EXTERN NSString *const TLineKeyEndOfUserInterfaceNotification __TVOS_PROHIBITED;

- (void)drawChartWithData:(NSDictionary *)data;

@end
