//
//  GApiConfig.h
//  GeitNetwoking
//
//  Created by liuxd on 16/7/8.
//  Copyright © 2016年 liuxd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFSecurityPolicy.h"

@interface GApiConfig : NSObject

@property (nonatomic, readonly) NSString *appVersionString;

@property (strong, nonatomic) NSString *baseUrl;

@property (strong, nonatomic) AFSecurityPolicy *securityPolicy;

@property (nonatomic, strong) NSSet *acceptableContentTypes;

@property (nonatomic, assign) NSTimeInterval cacheTimeInterval;

/// 请求超时时间
@property (nonatomic, assign) NSTimeInterval requestTimeoutInterval;

// 给url追加全局参数，比如AppVersion, ApiVersion等
@property (nonatomic, strong, readonly) NSDictionary *filterApiParams;

/// 请求的Server用户名和密码
@property (nonatomic, strong, readonly) NSArray *requestAuthorizationHeaderFieldArray;

/// 在HTTP报头添加的自定义参数
@property (nonatomic, strong, readonly) NSDictionary *requestHeaderFieldValueDictionary;

+ (instancetype)sharedInstance;

// 可以追加局部参数
- (void)addFilterApiParams:(NSDictionary *)params;
- (void)setAuthorizationHeaderFieldWithUsername:(NSString *)username password:(NSString *)password;
- (void)setApiRequestHeaderFieldValueDictionary:(NSDictionary *)headerFiled;

@end
