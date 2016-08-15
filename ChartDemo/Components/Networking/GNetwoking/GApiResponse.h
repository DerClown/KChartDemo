//
//  GURLResponse.h
//  GeitNetwoking
//
//  Created by liuxd on 16/7/8.
//  Copyright © 2016年 liuxd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

typedef NS_ENUM(NSUInteger, GApiResponseStatus) {
    GApiResponseStatusSuccess, //作为底层，请求是否成功只考虑是否成功收到服务器反馈。至于签名是否正确，返回的数据是否完整，由上层的GApiBaseManager来决定。
    GApiResponseStatusErrorTimeout,
    GApiResponseStatusFailed // 默认除了超时以外的错误都是失败。
};

@interface GApiResponse : NSObject

@property (nonatomic, assign, readonly) GApiResponseStatus status;

@property (nonatomic, copy, readonly) id responseObject;
@property (nonatomic, copy, readonly) NSString *responseString;
@property (nonatomic, copy, readonly) NSData *responseData;
@property (nonatomic, copy, readonly) NSDictionary *requestParams;

@property (nonatomic, assign, readonly) NSInteger requestId;
@property (nonatomic, assign, readonly) BOOL isCache;

/**
 *  从请求获取数据 isCache = NO
 */
- (instancetype)initWithRequestId:(NSNumber *)requestId requestParams:(NSDictionary *)requestParams requestOperation:(AFHTTPRequestOperation *)operation;

- (instancetype)initWithRequestId:(NSNumber *)requestId requestParams:(NSDictionary *)requestParams requestOperation:(AFHTTPRequestOperation *)operation error:(NSError *)error;

/**
 *  从cache获取数据 isCache = YES
 */
- (instancetype)initWithData:(NSData *)data;

@end
