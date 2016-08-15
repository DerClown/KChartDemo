//
//  KLineListManager.m
//  ChartDemo
//
//  Created by xdliu on 16/8/12.
//  Copyright © 2016年 taiya. All rights reserved.
//

#import "KLineListManager.h"

@implementation KLineListManager

- (id)init {
    if (self = [super init]) {
        self.dataSource = self;
    }
    return self;
}

- (NSString *)requestUrl {
    return @"http://ichart.yahoo.com/table.csv";
}

- (NSDictionary *)paramsForApi {
    return @{@"s":self.kLineID,
             @"g":self.dateType
             };
}

@end
