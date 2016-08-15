//
//  GApiAgent.m
//  GeitNetwoking
//
//  Created by liuxd on 16/6/2.
//  Copyright © 2016年 liuxd. All rights reserved.
//

#import "GApiAgent.h"
#import "GApiConfig.h"
#import "NSDictionary+NetWorkingMehods.h"
#import "GApiLogger.h"


@interface GApiAgent ()

@property (nonatomic, strong) AFHTTPRequestOperationManager *manager;
@property (nonatomic, strong) NSMutableDictionary *requestsRecord;
@property (nonatomic, strong) NSNumber *recordedRequestId;

@property (nonatomic, strong) GApiConfig *config;

@end

@implementation GApiAgent

+ (instancetype)sharedInstance
{
    static GApiAgent* instance = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [GApiAgent new];
    });

    return instance;
}

- (id)init {
    if (self = [super init]) {
        _requestsRecord = [NSMutableDictionary new];
        _config = [GApiConfig sharedInstance];
        
        _manager = [AFHTTPRequestOperationManager manager];
        _manager.operationQueue.maxConcurrentOperationCount = 3;
        _manager.securityPolicy = _config.securityPolicy;
    }
    return self;
}

- (void)configRequestManagerSerializer {
    AFHTTPRequestSerializer *requestSerializer = [AFHTTPRequestSerializer serializer];
    
    // 用户名密码
    NSArray *authorizationHeaderFieldArray = [_config requestAuthorizationHeaderFieldArray];
    if (authorizationHeaderFieldArray != nil) {
        [_manager.requestSerializer setAuthorizationHeaderFieldWithUsername:(NSString *)authorizationHeaderFieldArray.firstObject
                                                                   password:(NSString *)authorizationHeaderFieldArray.lastObject];
    }
    
    // HTTP报头
    NSDictionary *headerFieldValueDictionary = [_config requestHeaderFieldValueDictionary];
    if (headerFieldValueDictionary != nil) {
        for (id httpHeaderField in headerFieldValueDictionary.allKeys) {
            id value = headerFieldValueDictionary[httpHeaderField];
            if ([httpHeaderField isKindOfClass:[NSString class]] && [value isKindOfClass:[NSString class]]) {
                [_manager.requestSerializer setValue:(NSString *)value forHTTPHeaderField:(NSString *)httpHeaderField];
            } else {
                NSLog(@"Error, class of key/value in headerFieldValueDictionary should be NSString.");
            }
        }
    }
    
    AFHTTPResponseSerializer *responsSerializer = [AFHTTPResponseSerializer serializer];
    if (_config.acceptableContentTypes) {
        responsSerializer.acceptableContentTypes = _config.acceptableContentTypes;
    }
    
    _manager.requestSerializer = requestSerializer;
    _manager.responseSerializer = responsSerializer;
}

- (NSInteger)sendRequestApi:(__kindof GApiBaseManager *)api
                    success:(GAPICallBack)success
                    failure:(GAPICallBack)failure {
    NSAssert(api.child.requestUrl.length != 0, @"作为GApiBaseManager的孩子，必须实现【GAPIManager】的requestUrl协议，同时requestUrl不能为空。");
    
    NSString *url = [self buildRequestUrl:api.child.requestUrl];
    
    NSDictionary *params = [api.dataSource paramsForApi];
    
    NSMutableDictionary *requestParams = params.mutableCopy;
    // 合并全局参数
    [requestParams addEntriesFromDictionary:_config.filterApiParams];
    
    NSString *filteredUrl = [self urlStringWithOriginUrlString:url appendParameters:requestParams];
    
    GAPIManagerRequestType requestType = api.child.requestType;
    
    [self configRequestManagerSerializer];
    
    if (api.child.requestTimeoutInterval > 0) {
        _manager.requestSerializer.timeoutInterval = api.child.requestTimeoutInterval;
    } else {
        _manager.requestSerializer.timeoutInterval = _config.requestTimeoutInterval;
    }
    
    // 之所以不用getter，是因为如果放到getter里面的话，每次调用self.recordedRequestId的时候值就都变了，违背了getter的初衷
    NSNumber *reqeustId = [self generateRequestId];
    
    AFHTTPRequestOperation *requestOperation;
    if (requestType == GAPIManagerRequestTypeGet) {
        if (api.child.resumableDownloadPath) {
            NSURLRequest *requestUrl = [NSURLRequest requestWithURL:[NSURL URLWithString:filteredUrl]];
            AFDownloadRequestOperation *operation = [[AFDownloadRequestOperation alloc] initWithRequest:requestUrl
                                                                                             targetPath:api.child.resumableDownloadPath
                                                                                           shouldResume:YES];
            
            [operation setProgressiveDownloadProgressBlock:api.child.downloadProgressBlock];
            [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                [GApiLogger logDebugInfoWithOperation:operation error:nil];
                GApiResponse *response = [[GApiResponse alloc] initWithRequestId:reqeustId requestParams:params requestOperation:operation];
                success ? success(response) : nil;
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                [GApiLogger logDebugInfoWithOperation:operation error:error];
                GApiResponse *response = [[GApiResponse alloc] initWithRequestId:reqeustId requestParams:params requestOperation:operation error:error];
                failure ? failure(response) : nil;
            }];
            requestOperation = operation;
            [_manager.operationQueue addOperation:operation];
        } else {
            requestOperation = [_manager GET:filteredUrl parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
                [GApiLogger logDebugInfoWithOperation:operation error:nil];
                [self cancelRequestApiWithReqeustId:reqeustId];
                GApiResponse *response = [[GApiResponse alloc] initWithRequestId:reqeustId requestParams:params requestOperation:operation];
                success ? success(response) : nil;
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                [GApiLogger logDebugInfoWithOperation:operation error:error];
                [self cancelRequestApiWithReqeustId:reqeustId];
                GApiResponse *response = [[GApiResponse alloc] initWithRequestId:reqeustId requestParams:params requestOperation:operation error:error];
                failure ? failure(response) : nil;
            }];
        }
    } else {
        if (api.child.constructingBodyBlock) {
            requestOperation = [_manager POST:filteredUrl parameters:nil constructingBodyWithBlock:api.child.constructingBodyBlock success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
                [GApiLogger logDebugInfoWithOperation:operation error:nil];
                [self cancelRequestApiWithReqeustId:reqeustId];
                GApiResponse *response = [[GApiResponse alloc] initWithRequestId:reqeustId requestParams:params requestOperation:operation];
                success ? success(response) : nil;
            } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
                [GApiLogger logDebugInfoWithOperation:operation error:error];
                [self cancelRequestApiWithReqeustId:reqeustId];
                GApiResponse *response = [[GApiResponse alloc] initWithRequestId:reqeustId requestParams:params requestOperation:operation error:error];
                failure ? failure(response) : nil;
            }];
            [requestOperation setUploadProgressBlock:api.child.uploadProgressBlock];
        } else {
            requestOperation = [_manager POST:filteredUrl parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
                [GApiLogger logDebugInfoWithOperation:operation error:nil];
                [self cancelRequestApiWithReqeustId:reqeustId];
                GApiResponse *response = [[GApiResponse alloc] initWithRequestId:reqeustId requestParams:params requestOperation:operation];
                success ? success(response) : nil;
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                [GApiLogger logDebugInfoWithOperation:operation error:error];
                [self cancelRequestApiWithReqeustId:reqeustId];
                GApiResponse *response = [[GApiResponse alloc] initWithRequestId:reqeustId requestParams:params requestOperation:operation error:error];
                failure ? failure(response) : nil;
            }];
        }
    }
    
    switch (api.child.requestPriority) {
        case GAPIManagerRequestPriorityHigh:
            requestOperation.queuePriority = NSOperationQueuePriorityHigh;
            break;
        case GAPIManagerRequestPriorityLow:
            requestOperation.queuePriority = NSOperationQueuePriorityLow;
            break;
        case GAPIManagerRequestPriorityDefault:
        default:
            requestOperation.queuePriority = NSOperationQueuePriorityNormal;
            break;
    }
    
    [GApiLogger logDebugInfoWithRequest:requestOperation.request reqeustParams:params reqeustMethod:(api.child.requestType == GAPIManagerRequestTypeGet ? @"GET" : @"POST")];
    
    if (requestOperation) {
        @synchronized(self) {
            _requestsRecord[reqeustId] = requestOperation;
        }
    }
    
    return reqeustId.integerValue;
}

- (void)cancelRequestApiWithReqeustId:(NSNumber *)requestId {
    @synchronized (self) {
        AFHTTPRequestOperation *requestOperation = _requestsRecord[requestId];
        [requestOperation cancel];
        [_requestsRecord removeObjectForKey:requestId];
    }
}

- (void)cancelRequestApiWithRequestIdList:(NSArray *)requestIdList {
    for (NSNumber *requestId in requestIdList) {
        [self cancelRequestApiWithReqeustId:requestId];
    }
}

#pragma mark - private methods

- (NSString *)buildRequestUrl:(NSString *)requestUrl {
    NSString *applyUrl = requestUrl;
    if ([applyUrl hasPrefix:@"http"]) {
        return applyUrl;
    }
    
    if (![applyUrl hasPrefix:@"/"]) {
        applyUrl = [@"/" stringByAppendingString:applyUrl];
    }
    
    NSAssert(_config.baseUrl.length != 0, @"_baseUrl不能为空。");
    
    return [NSString stringWithFormat:@"%@%@", _config.baseUrl, applyUrl];
}

- (NSString *)urlStringWithOriginUrlString:(NSString *)originUrlString appendParameters:(NSDictionary *)parameters {
    NSString *filteredUrl = originUrlString;
    NSString *paraUrlString = [parameters urlParamsString];
    if (paraUrlString && paraUrlString.length > 0) {
        if ([originUrlString rangeOfString:@"?"].location != NSNotFound) {
            filteredUrl = [filteredUrl stringByAppendingString:paraUrlString];
        } else {
            filteredUrl = [filteredUrl stringByAppendingFormat:@"?%@", paraUrlString];
        }
        return filteredUrl;
    } else {
        return originUrlString;
    }
}

#pragma mark - getters

- (NSNumber *)generateRequestId {
    if (_recordedRequestId == nil) {
        _recordedRequestId = @(1);
    } else {
        if ([_recordedRequestId integerValue] == NSIntegerMax) {
            _recordedRequestId = @(1);
        } else {
            _recordedRequestId = @([_recordedRequestId integerValue] + 1);
        }
    }
    return _recordedRequestId;
}

@end
