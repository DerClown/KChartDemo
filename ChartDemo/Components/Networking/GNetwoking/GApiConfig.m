//
//  GApiConfig.m
//  GeitNetwoking
//
//  Created by liuxd on 16/7/8.
//  Copyright © 2016年 liuxd. All rights reserved.
//

#import "GApiConfig.h"

@interface GApiConfig ()
@property (nonatomic, strong, readwrite) NSDictionary *filterApiParams;
@property (nonatomic, strong, readwrite) NSArray *requestAuthorizationHeaderFieldArray;
@property (nonatomic, strong, readwrite) NSDictionary *requestHeaderFieldValueDictionary;
@end

@implementation GApiConfig

+ (instancetype)sharedInstance
{
    static GApiConfig* instance = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });

    return instance;
}

- (id)init {
    if (self = [super init]) {
        _securityPolicy = [AFSecurityPolicy defaultPolicy];
        _filterApiParams = [NSDictionary new];
        _acceptableContentTypes = [NSSet setWithObjects:@"text/html",nil];
        _cacheTimeInterval = -1;
        _requestTimeoutInterval = 30.0;
    }
    return self;
}

- (void)addFilterApiParams:(NSDictionary *)params {
    if (params && params.count > 0) {
        NSMutableDictionary *copyParms = _filterApiParams.mutableCopy;
        [copyParms addEntriesFromDictionary:params];
        _filterApiParams = copyParms;
    }
}

- (void)setAuthorizationHeaderFieldWithUsername:(NSString *)username password:(NSString *)password {
    if (username.length > 0 && password.length > 0) {
        _requestAuthorizationHeaderFieldArray = @[username, password];
    }
}

- (void)setApiRequestHeaderFieldValueDictionary:(NSDictionary *)headerFiled {
    _requestHeaderFieldValueDictionary = headerFiled;
}

- (NSString *)appVersionString {
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
}

@end
