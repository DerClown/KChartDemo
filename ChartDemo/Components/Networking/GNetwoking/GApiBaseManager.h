//
//  GApiBaseManager.h
//  GeitNetwoking
//
//  Created by liuxd on 16/6/1.
//  Copyright © 2016年 liuxd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
#import "AFDownloadRequestOperation.h"

// 在调用成功之后的params字典里面，用这个key可以取出requestID
static NSString * const kGAPIBaseManagerRequestID = @"kGAPIBaseManagerRequestID";

@class GApiBaseManager;
@class GApiResponse;

/**
 *  请求类型
 */
typedef NS_ENUM(NSUInteger, GAPIManagerRequestType) {
    /**
     *  get 请求
     */
    GAPIManagerRequestTypeGet = 0,
    /**
     *  post 请求
     */
    GAPIManagerRequestTypePost,
};

/**
 *  网络请求处理类型
 */
typedef NS_ENUM(NSUInteger, GAPIManagerRequestHandlerType) {
    /**
     *  没有发起网络请求，默认状态
     */
    GAPIManagerRequestHandlerTypeDefault = 0,
    /**
     *  请求成功,数据可以直接使用
     */
    GAPIManagerRequestHandlerTypeSuccess,
    /**
     *  请求失败,数据不可用
     */
    GAPIManagerRequestHandlerTypeFailure,
    /**
     *  参数错误，在API请求之前验证，如果验证函数为NO，就是这个状态s
     */
    GAPIManagerRequestHandlerTypeParamsError,
    /**
     *  API请求成功但数据有误， 验证函数如果返回NO，就是这个状态
     */
    GAPIManagerRequestHandlerTypeNoContent,
    /**
     *  请求超时，超时时间在网络请求代理可看
     */
    GAPIManagerRequestHandlerTypeTimeout,
    /**
     *  无网络，发起请求的时候会判断当前网络是否通畅
     */
    GAPIManagerRequestHandlerTypeNoNetWork,
};

/**
 *  请求优先级
 */
typedef NS_ENUM(NSInteger , GAPIManagerRequestPriority) {
    /**
     *  最低级，排在所有请求最后面
     */
    GAPIManagerRequestPriorityLow = -4L,
    /**
     *  默认，排在最高级请求后面
     */
    GAPIManagerRequestPriorityDefault = 0,
    /**
     *  最高级，请求排在最前
     */
    GAPIManagerRequestPriorityHigh = 4,
};



/**********************************************************/
/*                      接口请求回调                        */
/**********************************************************/

@protocol GAPIBaseManagerRequestCallBackDelegate <NSObject>

@required
- (void)managerApiCallBackDidSuccess:(__kindof GApiBaseManager *)manager;
- (void)managerApiCallBackDidFailed:(__kindof GApiBaseManager *)manager;

@end

/**********************************************************/
/*                      数据转换器                         */
/**********************************************************/

@protocol GApiBaseManagerCallBackDataTransformer <NSObject>

@required
- (id)manager:(GApiBaseManager *)manager transformData:(id)data;

@end


/**********************************************************/
/*           验证器【请求参数验证、回调数据验证】               */
/**********************************************************/

/*
 * 使用场景：
            1.请求参数的判断有利于我们优化网络请求，当参数有误，可以不发起没必要的网络请求。比如注册验证手机号码、邮箱等，可以提前预判是否正确，然后发起请求。
 
            2.当请求完成回调时，不光是要看status，还有返回的数据格式是否正确。由于每个api内容中的key都是不一样的，数据结构也是不一样，因此对每个api返回的数据格式进行判断是有必要的。
 */
@protocol GAPIManagerValiator <NSObject>

@optional
- (BOOL)manager:(GApiBaseManager *)manager isCorrectWithRequestParams:(NSDictionary *)params;

- (BOOL)manager:(GApiBaseManager *)manager isCorrectWithCallBackData:(id)data;

@end


/**********************************************************/
/*                     API调用请求参数                      */
/**********************************************************/

@protocol GAPIManagerDataSource <NSObject>

@optional
- (NSDictionary *)paramsForApi;

@end


typedef void (^AFConstructingBlock)(id<AFMultipartFormData> formData);
typedef void (^AFUploadProgressBlock)(NSUInteger bytes, long long totalBytes, long long totalBytesExpected);

typedef void (^AFDownloadProgressBlock)(AFDownloadRequestOperation *operation, NSInteger bytesRead, long long totalBytesRead, long long totalBytesExpected, long long totalBytesReadForFile, long long totalBytesExpectedToReadForFile);


/**********************************************************/
/*                     API调用请求参数                      */
/**********************************************************/

//GAPIBaseManager的派生类必须符合这些protocal
@protocol GAPIManager <NSObject>

@required
- (NSString *)requestUrl;

@optional

// 下载
- (NSString *)resumableDownloadPath;
- (AFDownloadProgressBlock)downloadProgressBlock;

// 上传
- (AFConstructingBlock)constructingBodyBlock;
- (AFUploadProgressBlock)uploadProgressBlock;

- (GAPIManagerRequestType)requestType;
- (GAPIManagerRequestPriority)requestPriority;
- (NSTimeInterval)requestTimeoutInterval;
- (BOOL)shouldCache;
- (void)cleanData;

@end


/**********************************************************/
/*                         API拦截器                       */
/**********************************************************/

//GApiBaseManager的派生类必须符合这些protocal
@protocol GApiBaseManagerInterceptor <NSObject>

@optional

- (void)manager:(GApiBaseManager *)manager beforePerformSuccessWithResult:(GApiResponse *)response;
- (void)manager:(GApiBaseManager *)manager afterPerformSuccessWithResult:(GApiResponse *)response;

- (void)manager:(GApiBaseManager *)manager beforePerformFailWithResult:(GApiResponse *)response;
- (void)manager:(GApiBaseManager *)manager afterPerformFailWithResult:(GApiResponse *)response;

- (BOOL)manager:(GApiBaseManager *)manager shouldCallApiWithParams:(NSDictionary *)params;
- (void)manager:(GApiBaseManager *)manager afterCallingApiWithParams:(NSDictionary *)params;

@end




@interface GApiBaseManager : NSObject

@property (nonatomic, weak) id<GAPIBaseManagerRequestCallBackDelegate>delegate;
@property (nonatomic, weak) id<GAPIManagerDataSource> dataSource;
@property (nonatomic, weak) id<GAPIManagerValiator> validator;
@property (nonatomic, weak) NSObject<GAPIManager> *child;
@property (nonatomic, weak) id<GApiBaseManagerInterceptor> interceptor;

//请求处理类型
@property (nonatomic, readonly) GAPIManagerRequestHandlerType requestHandleType;

@property (nonatomic, readonly, getter=isReachable) BOOL networkAvailable;
@property (nonatomic, readonly, getter=isExecuting) BOOL executing;

//错误信息，这个由子类提供、设置
@property (nonatomic, copy, readonly) NSString *errorMessage;

// 先从缓存取数据, 默认为NO
@property (nonatomic, assign) BOOL isDataFromCacheFirst;

//派生子类发送网络请求统一调用方法。
- (NSInteger)startRequest;

- (void)cancelAllRequests;
- (void)cancelRequestWithRequestId:(NSInteger)requestId;

//获取可直接使的数据
- (id)fetchDataWithTransformer:(id<GApiBaseManagerCallBackDataTransformer>)transformer;

/*
 *  主意：
        1.重载不需要实现 super 方法.
 */

// 断点续传路劲
- (NSString *)resumableDownloadPath;
- (AFDownloadProgressBlock)downloadProgressBlock;

// 上传
- (AFConstructingBlock)constructingBodyBlock;
- (AFUploadProgressBlock)uploadProgressBlock;

// 请求类型
- (GAPIManagerRequestType)requestType;

// 请求优先级
- (GAPIManagerRequestPriority)requestPriority;

/**
 *  超时时间
 *
 *  主意：设置了这个，请求超时时间已这个为准
 */
- (NSTimeInterval)requestTimeoutInterval;

// 是否缓存
- (BOOL)shouldCache;

// 清除数据
- (void)cleanData;

@end
