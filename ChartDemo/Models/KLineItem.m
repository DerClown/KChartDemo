//
//  KLineItem.m
//  ChartDemo
//
//  Created by xdliu on 2016/12/2.
//  Copyright © 2016年 taiya. All rights reserved.
//

#import "KLineItem.h"

@implementation KLineItem

- (NSString *)description {
    NSString *des = [[NSString alloc] initWithFormat:@"open    high    low    close    vol:  %@,  %@  %@  %@  %@", self.open, self.high, self.low, self.close, self.vol];
    return des;
}

@end
