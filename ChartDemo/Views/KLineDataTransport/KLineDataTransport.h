//
//  KLineDataTransport.h
//  ChartDemo
//
//  Created by YoYo on 2018/5/7.
//  Copyright © 2018年 yoyo. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol KLineDataTransportDelegate <NSObject>

- (NSArray *)MAs;

- (NSArray *)kLineDataSources;

@end

@class KLineItem;

@interface KLineDataTransport : NSObject

@property (nonatomic) NSInteger startIndex;

@property (nonatomic) NSInteger needDrawingCandleNumber;

// 是否可见部分最值
@property (nonatomic) BOOL isVisableExtremeValue;

@property (nonatomic, weak) id<KLineDataTransportDelegate>delegate;

/*
 *  最大值
 */
- (float)maxValue;

/*
 *  最小值
 */
- (float)minValue;

// 绘制k线图数据
- (NSArray *)getNeedDrawingCandleData;

/*
 *  均线数据
 *  注意：可能有些均线个别点绘制不满足条件，不满足条件的点，则使用[NSNull null] 占位填充
 */
- (NSArray *)getMovingAverageData;

@end
