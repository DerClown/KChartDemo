//
//  KLineListTransformer.h
//  ChartDemo
//
//  Created by xdliu on 16/8/12.
//  Copyright © 2016年 taiya. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GApiBaseManager.h"

extern NSString *const kCandlerstickChartsContext;
extern NSString *const kCandlerstickChartsDate;
extern NSString *const kCandlerstickChartsMaxHigh;
extern NSString *const kCandlerstickChartsMinLow;
extern NSString *const kCandlerstickChartsMaxVol;
extern NSString *const kCandlerstickChartsMinVol;
extern NSString *const kCandlerstickChartsRSV9;
extern NSString *const kCandlerstickChartsKDJ;
extern NSString *const kCandlerstickChartsMACD;
extern NSString *const kCandlerstickChartsRSI;
extern NSString *const kCandlerstickChartsBOLL;
extern NSString *const kCandlerstickChartsDMA;
extern NSString *const kCandlerstickChartsCCI;
extern NSString *const kCandlerstickChartsWR;

/**
 *  extern key 可修改为Entity
 */
@interface KLineListTransformer : NSObject<GApiBaseManagerCallBackDataTransformer>

@end
