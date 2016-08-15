//
//  KLineListManager.h
//  ChartDemo
//
//  Created by xdliu on 16/8/12.
//  Copyright © 2016年 taiya. All rights reserved.
//

#import "GApiBaseManager.h"

@interface KLineListManager : GApiBaseManager<GAPIManager, GAPIManagerDataSource>

@property (nonatomic, copy) NSString *kLineID;

/**
 *  日期［w, s, d］
 */
@property (nonatomic, copy) NSString *dateType;

@end
