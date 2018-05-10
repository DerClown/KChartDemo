//
//  CandlestickView.h
//  ChartDemo
//
//  Created by YoYo on 2018/5/7.
//  Copyright © 2018年 yoyo. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CandlestickViewDelegate <NSObject>

// 日期的x坐标位置 + 日期
- (void)xAxis_coordinate:(float)x_coordinate date:(NSString *)date atIndex:(NSInteger)index;

@end

@interface CandlestickView : UIView

@property (nonatomic, weak) id<CandlestickViewDelegate>delegate;

/**
 *  k线图宽度
 */
@property (nonatomic, assign) CGFloat kCandleWidth;

/**
 *  k线图间距
 */
@property (nonatomic, assign) CGFloat kCandleFixedSpacing;

/**
 *  阳线颜色
 */
@property (nonatomic, strong) UIColor *positiveCandleColor;

/**
 *  阴线颜色
 */
@property (nonatomic, strong) UIColor *negativeCandleColor;

/*
 *  最大价格
 */
@property (nonatomic, assign) CGFloat maxmumPrice;

/*
 *  最小价格
 */
@property (nonatomic, assign) CGFloat minmumPrice;

/*
 *  均线颜色值 (默认 HexRGB(0x019FFD)、HexRGB(0xFF9900)、HexRGB(0xFF00FF))
 */
@property (nonatomic, strong) NSArray<UIColor *> *MAColors;

/**
 *  分割线个数
 */
@property (nonatomic, assign) NSInteger separatorNumber;

// 更新k线图
- (void)updateCandleForData:(NSArray *)data;

// 均线
- (void)updateMAWithData:(NSArray *)data;

// 清除绘制
- (void)clean;

@end
