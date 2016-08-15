//
//  NSArray+NetWorkingMethods.m
//  GeitNetwoking
//
//  Created by liuxd on 16/6/2.
//  Copyright © 2016年 liuxd. All rights reserved.
//

#import "NSArray+NetWorkingMethods.h"

@implementation NSArray (NetWorkingMethods)

- (NSString *)urlParamsString {
    NSMutableString *urlString = [NSMutableString new];
    NSArray *sortedParams = [self sortedArrayUsingSelector:@selector(compare:)];
    [sortedParams enumerateObjectsUsingBlock:^(NSString *value, NSUInteger idx, BOOL * _Nonnull stop) {
        if (urlString.length == 0) {
            [urlString appendString:value];
        } else {
            [urlString appendFormat:@"&%@", value];
        }
    }];
    
    return urlString;
}

- (NSString *)JSONString {
    NSData *data = [NSJSONSerialization dataWithJSONObject:self options:NSJSONWritingPrettyPrinted error:nil];
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

@end
