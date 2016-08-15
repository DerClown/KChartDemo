//
//  GURLResponse.m
//  GeitNetwoking
//
//  Created by liuxd on 16/7/8.
//  Copyright © 2016年 liuxd. All rights reserved.
//

#import "GApiResponse.h"

@interface GApiResponse ()

@property (nonatomic, assign, readwrite) GApiResponseStatus status;

@property (nonatomic, copy, readwrite) id responseObject;
@property (nonatomic, copy, readwrite) NSString *reponseString;
@property (nonatomic, copy, readwrite) NSData *responseData;
@property (nonatomic, copy, readwrite) NSDictionary *requestParams;

@property (nonatomic, assign, readwrite) NSInteger requestId;
@property (nonatomic, assign, readwrite) BOOL isCache;

@end

@implementation GApiResponse

- (instancetype)initWithRequestId:(NSNumber *)requestId requestParams:(NSDictionary *)requestParams requestOperation:(AFHTTPRequestOperation *)operation {
    self = [super init];
    if (self) {
        self.status = GApiResponseStatusSuccess;
        self.responseObject = [NSJSONSerialization JSONObjectWithData:operation.responseObject options:NSJSONReadingMutableContainers error:NULL];
        self.responseData = operation.responseData;
        self.reponseString = operation.responseString;
        self.requestParams = requestParams;
        
        self.requestId = [requestId integerValue];
        self.isCache = NO;
    }
    return self;
}

- (instancetype)initWithRequestId:(NSNumber *)requestId requestParams:(NSDictionary *)requestParams requestOperation:(AFHTTPRequestOperation *)operation error:(NSError *)error {
    self = [super init];
    if (self) {
        self.status = [self responseStatusWithError:error];
        self.responseObject = operation.responseObject;
        self.responseData = operation.responseData;
        self.reponseString = operation.responseString;
        self.requestParams = requestParams;
        
        self.requestId = [requestId integerValue];
        self.isCache = NO;
    }
    return self;
}

- (instancetype)initWithData:(NSData *)data {
    self = [super init];
    if (self) {
        self.status = [self responseStatusWithError:nil];
        self.responseObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:NULL];
        self.responseData = data;
        self.reponseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        self.requestId = 0;
        self.isCache = YES;
    }
    return self;
}

#pragma mark - private methods
- (GApiResponseStatus)responseStatusWithError:(NSError *)error {
    if (error) {
        GApiResponseStatus result = GApiResponseStatusFailed;
        
        // 除了超时以外，所有错误都当成是无网络
        if (error.code == NSURLErrorTimedOut) {
            result = GApiResponseStatusErrorTimeout;
        }
        return result;
    } else {
        return GApiResponseStatusSuccess;
    }
}

@end
