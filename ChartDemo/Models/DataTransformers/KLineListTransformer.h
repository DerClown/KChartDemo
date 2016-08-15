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

@interface KLineListTransformer : NSObject<GApiBaseManagerCallBackDataTransformer>

@end
