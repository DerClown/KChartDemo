//
//  GApiBaseManager.m
//  GeitNetwoking
//
//  Created by liuxd on 16/6/1.
//  Copyright © 2016年 liuxd. All rights reserved.
//

#import "GApiBaseManager.h"
#import <netinet/in.h>

#import "GApiCache.h"
#import "AFNetworkReachabilityManager.h"
#import "GApiAgent.h"
#import "GApiResponse.h"

@interface GApiBaseManager ()

@property (nonatomic, strong, readwrite) id fetchedRawData;

@property (nonatomic, copy, readwrite) NSString *errorMessage;
@property (nonatomic, readwrite) GAPIManagerRequestHandlerType requestHandleType;
@property (nonatomic, strong) NSMutableArray *requestIdList;

@property (nonatomic, strong) GApiCache *cache;

@end

@implementation GApiBaseManager

- (void)dealloc {
    [self cancelAllRequests];
    self.requestIdList = nil;
}

- (instancetype)init {
    if (self = [super init]) {
        _delegate = nil;
        _dataSource = nil;
        _validator = nil;
        
        _fetchedRawData = nil;
        
        _errorMessage = nil;
        _requestHandleType = GAPIManagerRequestHandlerTypeDefault;
        
        if ([self conformsToProtocol:@protocol(GAPIManager)]) {
            self.child = (id<GAPIManager>)self;
        } else {
            NSAssert(NO, @"子类必须实现GAPIManager这个protocal");
        }
    }
    return self;
}

#pragma mark - start reqeust

//派生子类发送网络请求统一调用该方法。
- (NSInteger)startRequest {
    NSDictionary *params = [self.dataSource paramsForApi];
    NSInteger requestId = [self loadDataWithParams:params];
    return requestId;
}

- (NSInteger)loadDataWithParams:(NSDictionary *)params {
    NSInteger requestId = 0;
    
    if ([self shouldCallingAPIWithParams:params]) {
        if ([self requestParamsIsCorrect:params]) {
            if ([self isReachable]) {
                requestId = [[GApiAgent sharedInstance] sendRequestApi:self success:^(GApiResponse *response) {
                                [self handleSuccessRequestResult:response];
                            } failure:^(GApiResponse *response) {
                                [self handleFailureRequestResult:response withRequestHandlerType:GAPIManagerRequestHandlerTypeDefault];
                            }];
                [self.requestIdList addObject:@(requestId)];
                
                NSMutableDictionary *paramsCopy = [params mutableCopy];
                paramsCopy[kGAPIBaseManagerRequestID] = @(requestId);
                [self afterCallingAPIWithParams:paramsCopy];
                
                return requestId;
            } else {
                [self handleFailureRequestResult:nil withRequestHandlerType:GAPIManagerRequestHandlerTypeNoNetWork];
            }
        }
    } else {
        [self handleFailureRequestResult:nil withRequestHandlerType:GAPIManagerRequestHandlerTypeParamsError];
    }
    
    return requestId;
}


#pragma mark - api call back handle methods

- (void)handleSuccessRequestResult:(GApiResponse *)response {
    switch (response.status) {
        case GApiResponseStatusSuccess: {
            if (response.responseObject) {
                _fetchedRawData = [response.responseObject copy];
            } else {
                _fetchedRawData = [response.responseData copy];
            }
            
            [self removeRequestIdWithRequestID:response.requestId];
            if ([self callBackDataIsCorrect:response]) {
                // 缓存数据
                if (!response.isCache && [self shouldCache]) {
                    [self.cache saveCacheWithData:response.responseData requestURL:self.child.requestUrl requestParams:response.requestParams];
                }
                
                [self beforPerformSuccessWithResult:response];
                [self.delegate managerApiCallBackDidSuccess:self];
                [self afterPerformSuccessWithResult:response];
                
            } else {
                [self handleFailureRequestResult:nil withRequestHandlerType:GAPIManagerRequestHandlerTypeNoContent];
            }
            
            break;
        }
        case GApiResponseStatusErrorTimeout: {
            [self handleFailureRequestResult:nil withRequestHandlerType:GAPIManagerRequestHandlerTypeTimeout];
            break;
        }
        case GApiResponseStatusFailed: {
            [self handleFailureRequestResult:nil withRequestHandlerType:GAPIManagerRequestHandlerTypeFailure];
            break;
        }
    }
}

- (void)handleFailureRequestResult:(GApiResponse *)response withRequestHandlerType:(GAPIManagerRequestHandlerType)handlerType {
    self.requestHandleType = handlerType;
    [self removeRequestIdWithRequestID:response.requestId];
    [self beforPerformFailureWithResult:response];
    [self.delegate managerApiCallBackDidFailed:self];
    [self afterPerformFailureWithResult:response];
}

#pragma mark - child methods

- (NSString *)resumableDownloadPath {
    return nil;
}

- (AFDownloadProgressBlock)downloadProgressBlock {
    return nil;
}

// 上传
- (AFConstructingBlock)constructingBodyBlock {
    return nil;
}

- (AFUploadProgressBlock)uploadProgressBlock {
    return nil;
}

- (GAPIManagerRequestType)requestType {
    return GAPIManagerRequestTypePost;
}

- (GAPIManagerRequestPriority)requestPriority {
    return GAPIManagerRequestPriorityDefault;
}

- (NSTimeInterval)requestTimeoutInterval {
    return 0;
}

- (void)cleanData {
    IMP childIMP = [self.child methodForSelector:@selector(cleanData)];
    IMP selfIMP = [self methodForSelector:@selector(cleanData)];
    
    if (childIMP == selfIMP) {
        self.fetchedRawData = nil;
        self.errorMessage = nil;
        self.requestHandleType = GAPIManagerRequestHandlerTypeDefault;
    } else {
        if ([self.child respondsToSelector:@selector(cleanData)]) {
            [self.child cleanData];
        }
    }
}

- (BOOL)shouldCache {
    return NO;
}

#pragma mark - public methods

- (void)cancelAllRequests {
    [[GApiAgent sharedInstance] cancelRequestApiWithRequestIdList:self.requestIdList];
    [self.requestIdList removeAllObjects];
}

- (void)cancelRequestWithRequestId:(NSInteger)requestId {
    [[GApiAgent sharedInstance] cancelRequestApiWithReqeustId:@(requestId)];
    [self.requestIdList removeObject:@(requestId)];
}

- (id)fetchDataWithTransformer:(id<GApiBaseManagerCallBackDataTransformer>)transformer {
    id resultData;
    if ([transformer respondsToSelector:@selector(manager:transformData:)]) {
        resultData = [transformer manager:self transformData:self.fetchedRawData];
    } else {
        resultData = [self.fetchedRawData mutableCopy];
    }
    
    return resultData;
}

#pragma mark - private method for interceptor

- (void)beforPerformSuccessWithResult:(GApiResponse *)response {
    self.requestHandleType = GAPIManagerRequestHandlerTypeSuccess;
    if (self.interceptor != self && [self.interceptor respondsToSelector:@selector(manager:beforePerformSuccessWithResult:)]) {
        [self.interceptor manager:self beforePerformSuccessWithResult:response];
    }
}

- (void)afterPerformSuccessWithResult:(GApiResponse *)response {
    if (self.interceptor != self && [self.interceptor respondsToSelector:@selector(manager:afterPerformSuccessWithResult:)]) {
        [self.interceptor manager:self beforePerformSuccessWithResult:response];
    }
}

- (void)beforPerformFailureWithResult:(GApiResponse *)response {
    if (self.interceptor != self && [self.interceptor respondsToSelector:@selector(manager:beforePerformFailWithResult:)]) {
        [self.interceptor manager:self beforePerformFailWithResult:response];
    }
}

- (void)afterPerformFailureWithResult:(GApiResponse *)response {
    if (self.interceptor != self && [self.interceptor respondsToSelector:@selector(manager:afterPerformFailWithResult:)]) {
        [self.interceptor manager:self afterPerformFailWithResult:response];
    }
}

- (BOOL)shouldCallingAPIWithParams:(NSDictionary *)params {
    if (self != self.interceptor && [self.interceptor respondsToSelector:@selector(manager:shouldCallApiWithParams:)]) {
        return [self.interceptor manager:self shouldCallApiWithParams:params];
    }
    
    return YES;
}

- (void)afterCallingAPIWithParams:(NSDictionary *)params {
    if (self != self.interceptor && [self.interceptor respondsToSelector:@selector(manager:afterCallingApiWithParams:)]) {
        [self.interceptor manager:self afterCallingApiWithParams:params];
    }
}

#pragma mark - valiator methods

- (BOOL)requestParamsIsCorrect:(NSDictionary *)params {
    if ([self.validator respondsToSelector:@selector(manager:isCorrectWithRequestParams:)]) {
        return [self.validator manager:self isCorrectWithRequestParams:params];
    }
    
    return YES;
}

- (BOOL)callBackDataIsCorrect:(GApiResponse *)response {
    if ([self.validator respondsToSelector:@selector(manager:isCorrectWithCallBackData:)]) {
        return [self.validator manager:self isCorrectWithCallBackData:response.responseObject];
    }
    return YES;
}

#pragma mark - private methods

- (void)removeRequestIdWithRequestID:(NSInteger)requestId {
    NSNumber *requestIDToRemove = nil;
    for (NSNumber *storedRequestId in self.requestIdList) {
        if ([storedRequestId integerValue] == requestId) {
            requestIDToRemove = storedRequestId;
        }
    }
    if (requestIDToRemove) {
        [self.requestIdList removeObject:requestIDToRemove];
    }
}

- (BOOL)hasCacheWithParams:(NSDictionary *)params {
    NSString *requestUrl = self.child.requestUrl;
    NSData *cacheData = [self.cache fetchCacheDataWithRequestURL:requestUrl requestParams:params];
    
    return cacheData ? YES : NO;
}

#pragma mark - getters

- (GApiCache *)cache {
    if (!_cache) {
        _cache = [GApiCache sharedInstance];
    }
    return _cache;
}

- (NSMutableArray *)requestIdList {
    if (!_requestIdList) {
        _requestIdList = [NSMutableArray new];
    }
    return _requestIdList;
}

- (BOOL)isReachable {
    struct sockaddr_in address;
    bzero(&address, sizeof(address));
    address.sin_len = sizeof(address);
    address.sin_family = AF_INET;
    
    SCNetworkReachabilityRef reachabilityRed = SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr *)&address);
    SCNetworkReachabilityFlags flags;
    BOOL retrieveFlags = SCNetworkReachabilityGetFlags(reachabilityRed, &flags);
    CFRelease(reachabilityRed);
    if (!retrieveFlags) {
        return NO;
    }
    
    BOOL flagsReachable = flags & kSCNetworkFlagsReachable;
    BOOL flagsConnection = flags & kSCNetworkFlagsConnectionRequired;
    
    BOOL isReachability = flagsReachable && !flagsConnection ? YES : NO;
   
    if (!isReachability) {
        _requestHandleType = GAPIManagerRequestHandlerTypeNoNetWork;
    }
    return isReachability;
}

- (BOOL)isExecuting {
    return self.requestIdList.count > 0;
}

#pragma mark - setters 

- (void)setIsDataFromCacheFirst:(BOOL)isDataFromCacheFirst {
    _isDataFromCacheFirst = isDataFromCacheFirst;
    
    if (isDataFromCacheFirst && [self hasCacheWithParams:[self.dataSource paramsForApi]]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"data from cache. \t\t\t\t\t\t\n\n");
            
            NSDictionary *apiParams = [self.dataSource paramsForApi];
            NSData *cacheData = [self.cache fetchCacheDataWithRequestURL:self.child.requestUrl requestParams:apiParams];
            GApiResponse *response = [[GApiResponse alloc] initWithData:cacheData];
            [self handleSuccessRequestResult:response];
        });
    } else {
        NSLog(@"no cache");
    }
}

@end
