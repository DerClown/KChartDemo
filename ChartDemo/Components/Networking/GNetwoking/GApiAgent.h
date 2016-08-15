//
//  GApiAgent.h
//  GeitNetwoking
//
//  Created by liuxd on 16/6/2.
//  Copyright © 2016年 liuxd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GApiBaseManager.h"
#import "GApiResponse.h"
#import "AFDownloadRequestOperation.h"

typedef void(^GAPICallBack)(GApiResponse *);

@interface GApiAgent : NSObject

+ (instancetype)sharedInstance;

- (NSInteger)sendRequestApi:(__kindof GApiBaseManager *)api
                    success:(GAPICallBack)success
                    failure:(GAPICallBack)failure;

- (void)cancelRequestApiWithReqeustId:(NSNumber *)requestId;

- (void)cancelRequestApiWithRequestIdList:(NSArray *)requestIdList;

@end
