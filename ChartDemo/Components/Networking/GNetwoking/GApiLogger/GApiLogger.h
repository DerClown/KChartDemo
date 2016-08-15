//
//  GApiLog.h
//  GeitNetwoking
//
//  Created by liuxd on 16/7/13.
//  Copyright © 2016年 liuxd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPRequestOperation.h"

@interface GApiLogger : NSObject

+ (void)logDebugInfoWithRequest:(NSURLRequest *)request reqeustParams:(NSDictionary *)params reqeustMethod:(NSString *)requestMethod;

+ (void)logDebugInfoWithOperation:(AFHTTPRequestOperation *)operation error:(NSError *)error;

@end
