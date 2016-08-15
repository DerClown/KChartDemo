//
//  NWCache.m
//  GeitNetwoking
//
//  Created by liuxd on 16/6/2.
//  Copyright © 2016年 liuxd. All rights reserved.
//

#import "GApiCache.h"
#import "NSDictionary+NetWorkingMehods.h"
#import "GApiConfig.h"
#import "NSString+md5.h"
#import "GApiCachedObject.h"

@interface GApiCache ()

@property (nonatomic, strong) NSCache *cache;

@end

@implementation GApiCache

+ (instancetype)sharedInstance
{
    static GApiCache* instance = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [GApiCache new];
    });

    return instance;
}

- (NSCache *)cache {
    if (!_cache) {
        _cache = [NSCache new];
        _cache.countLimit = 1000;
    }
    return _cache;
}

- (void)saveCacheWithData:(NSData *)cacheData requestURL:(NSString *)requestUrl requestParams:(NSDictionary *)params {
    if (cacheData != nil) {
        [NSKeyedArchiver archiveRootObject:cacheData toFile:[self cacheFilePathWithRequestURL:requestUrl requestParams:params]];
        [NSKeyedArchiver archiveRootObject:@([self cacheVersion]) toFile:[self cacheVersionFilePathWithRequestURL:requestUrl requestParams:params]];
    }
}

- (void)deleteCacheDataWithRequestURL:(NSString *)requestUrl requestParams:(NSDictionary *)params {
    [NSKeyedArchiver archiveRootObject:[NSNull null] toFile:[self cacheFilePathWithRequestURL:requestUrl requestParams:params]];
}

- (NSData *)fetchCacheDataWithRequestURL:(NSString *)requestUrl requestParams:(NSDictionary *)params {
    NSData *data = [NSKeyedUnarchiver unarchiveObjectWithFile:[self cacheFilePathWithRequestURL:requestUrl requestParams:params]];
    return data;
}

- (void)saveMemoryCacheWithData:(NSData *)cacheData requestURL:(NSString *)requestUrl requestParams:(NSDictionary *)params {
    NSString *key = [[self cacheKeyWithRequestURL:requestUrl requestParams:params] md5];
    GApiCachedObject *cachedObject = [self.cache objectForKey:key];
    if (cachedObject == nil) {
        cachedObject = [[GApiCachedObject alloc] init];
    }
    [cachedObject updateContent:cacheData];
    [self.cache setObject:cachedObject forKey:key];
}

- (void)deleteMemoryCacheDataWithRequestURL:(NSString *)requestUrl requestParams:(NSDictionary *)params {
    NSString *key = [[self cacheKeyWithRequestURL:requestUrl requestParams:params] md5];
    [self.cache removeObjectForKey:key];
}

- (NSData *)fetchMemoryCacheDataWithRequestURL:(NSString *)requestUrl requestParams:(NSDictionary *)params {
    NSString *key = [[self cacheKeyWithRequestURL:requestUrl requestParams:params] md5];
    GApiCachedObject *cachedObject = [self.cache objectForKey:key];
    if (cachedObject.isOutdated || cachedObject.isEmpty) {
        [self.cache removeObjectForKey:key];
        return nil;
    } else {
        return cachedObject.content;
    }
    return nil;
}

- (void)clearMemoryCache {
    [self.cache removeAllObjects];
}

- (long long)cacheVersion {
    return 0;
}

#pragma mark - private methods

- (void)checkDirectory:(NSString *)path {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir;
    if (![fileManager fileExistsAtPath:path isDirectory:&isDir]) {
        [self createBaseDirectoryAtPath:path];
    } else {
        if (!isDir) {
            NSError *error = nil;
            [fileManager removeItemAtPath:path error:&error];
            [self createBaseDirectoryAtPath:path];
        }
    }
}

- (void)createBaseDirectoryAtPath:(NSString *)path {
    __autoreleasing NSError *error = nil;
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES
                                               attributes:nil error:&error];
    if (error) {
        NSLog(@"create cache directory failed, error = %@", error);
    } else {
        [self addDoNotBackupAttribute:path];
    }
}

- (NSString *)cacheBasePath {
    NSString *pathOfLibrary = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *path = [pathOfLibrary stringByAppendingPathComponent:@"LazyRequestCache"];
    
    [self checkDirectory:path];
    
    return path;
}

- (NSString *)cacheFileNameWithRequestURL:(NSString *)requestUrl requestParams:(NSDictionary *)params {
    // 请求参数包含时间戳，获取的是当前时间，那么md5的出来的结果每次都不一致，这个和设计的初衷不一直，所以直接将时间戳换改成key，保证每次的md5一致性
    NSMutableDictionary *paramsCopy = params.mutableCopy;
    NSEnumerator *keys = [paramsCopy keyEnumerator];
    for (NSString *key in keys) {
        if ([[key lowercaseString] rangeOfString:@"time"].location != NSNotFound) {
            paramsCopy[key] = key;
        }
    }
    NSString *baseUrl = [GApiConfig sharedInstance].baseUrl;
    NSString *cacheFileName = [NSString stringWithFormat:@"Host:%@ Url:%@ Argument:%@ AppVersion:%@", baseUrl, requestUrl,
                               [paramsCopy urlParamsString], [GApiConfig sharedInstance].appVersionString];
    return [cacheFileName md5];
}

- (NSString *)cacheFilePathWithRequestURL:(NSString *)requestUrl requestParams:(NSDictionary *)params {
    NSString *cacheFileName = [self cacheFileNameWithRequestURL:requestUrl requestParams:params];
    NSString *path = [self cacheBasePath];
    path = [path stringByAppendingPathComponent:cacheFileName];
    
    return path;
}

- (NSString *)cacheVersionFilePathWithRequestURL:(NSString *)requestUrl requestParams:(NSDictionary *)params {
    NSString *cacheVersionFileName = [NSString stringWithFormat:@"%@.version", [self cacheFileNameWithRequestURL:requestUrl requestParams:params]];
    NSString *path = [self cacheBasePath];
    path = [path stringByAppendingPathComponent:cacheVersionFileName];
    return path;
}

- (long long)cacheVersionFileContentWithRequestURL:(NSString *)requestUrl requestParams:(NSDictionary *)params {
    NSString *path = [self cacheVersionFilePathWithRequestURL:requestUrl requestParams:params];
    NSFileManager * fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:path isDirectory:nil]) {
        NSNumber *version = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
        return [version longLongValue];
    } else {
        return 0;
    }
}

- (int)cacheFileDuration:(NSString *)path {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    // get file attribute
    NSError *attributesRetrievalError = nil;
    NSDictionary *attributes = [fileManager attributesOfItemAtPath:path
                                                             error:&attributesRetrievalError];
    if (!attributes) {
        NSLog(@"Error get attributes for file at %@: %@", path, attributesRetrievalError);
        return -1;
    }
    int seconds = -[[attributes fileModificationDate] timeIntervalSinceNow];
    return seconds;
}

- (NSString *)cacheKeyWithRequestURL:(NSString *)requestUrl requestParams:(NSDictionary *)params {
    return [NSString stringWithFormat:@"%@%@", requestUrl, [params urlParamsString]];
}

- (void)addDoNotBackupAttribute:(NSString *)path {
    NSURL *url = [NSURL fileURLWithPath:path];
    NSError *error = nil;
    [url setResourceValue:[NSNumber numberWithBool:YES] forKey:NSURLIsExcludedFromBackupKey error:&error];
    if (error) {
        NSLog(@"error to set do not backup attribute, error = %@", error);
    }
}

@end
