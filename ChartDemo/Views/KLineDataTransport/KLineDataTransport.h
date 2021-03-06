//
//  KLineDataTransport.h
//  ChartDemo
//
//  Created by YoYo on 2018/5/7.
//  Copyright © 2018年 yoyo. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol KLineDataTransportDelegate <NSObject>

@optional

- (NSArray *)MAs;

- (NSArray *)kLineDataSources;

@end

@class KLineItem;

@interface KLineDataTransport : NSObject

@property (nonatomic) NSInteger startIndex;

@property (nonatomic) NSInteger needDrawingCandleNumber;

/**
 *  小数点位数，默认保留两位(最多两位)
 */
@property (nonatomic) NSUInteger  maxnumIntegerDigits;;

// 是否可见部分最值
@property (nonatomic) BOOL isVisableExtremeValue;

@property (nonatomic, weak) id<KLineDataTransportDelegate>delegate;

/*
 *  k线图最大值价格
 */
- (float)maxmumPrice;

/*
 *  k线图最小价格
 */
- (float)minmumPrice;

/*
 *  分时图最大值价格
 */
- (float)timeSharingChartMaxPrice;

/*
 *  分时图最小价格
 */
- (float)timeSharingChartMinPrice;

/*
 *  最大值成交量
 */
- (float)maxmumVol;

/*
 *  最小成交量
 */
- (float)minmumVol;

// 绘制k线图数据
- (NSArray *)getNeedDrawingCandleData;

/*
 *  均线数据
 *  注意：可能有些均线个别点绘制不满足条件，不满足条件的点，则使用[NSNull null] 占位填充
 */
- (NSArray *)getMovingAverageData;

// 分时图数据
- (NSArray *)getNeedDrawingTimeSharingChartData;

/*
 *  价格字符串
 */
- (NSString *)getPriceString:(NSNumber *)price;
@end
