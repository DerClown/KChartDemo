//
//  KLineListTransformer.h
//  ChartDemo
//
//  Created by xdliu on 16/8/12.
//  Copyright © 2016年 taiya. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GApiBaseManager.h"

// 数据
extern NSString *const kCandlerstickChartsContext;

// 日期
extern NSString *const kCandlerstickChartsDate;

// 最高价
extern NSString *const kCandlerstickChartsMaxHigh;

// 最低价
extern NSString *const kCandlerstickChartsMinLow;

// 成交量
extern NSString *const kCandlerstickChartsVol;

/////////////////////////////////////////////////////////

// RSV9
extern NSString *const kCandlerstickChartsRSV9;

// KDJ
extern NSString *const kCandlerstickChartsKDJ;

// MACD
extern NSString *const kCandlerstickChartsMACD;

// RSI
extern NSString *const kCandlerstickChartsRSI;

// BOLL
extern NSString *const kCandlerstickChartsBOLL;

// DMA
extern NSString *const kCandlerstickChartsDMA;

// CCI
extern NSString *const kCandlerstickChartsCCI;

// 威廉指数
extern NSString *const kCandlerstickChartsWR;

// BIAS
extern NSString *const kCandlerstickChartsBIAS;

/**
 *  extern key 可修改为Entity
 */
@interface KLineListTransformer : NSObject<GApiBaseManagerCallBackDataTransformer>

@end
