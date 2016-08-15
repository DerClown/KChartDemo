//
//  NSDictionary+NetWorkingMehods.m
//  GeitNetwoking
//
//  Created by liuxd on 16/6/2.
//  Copyright © 2016年 liuxd. All rights reserved.
//

#import "NSDictionary+NetWorkingMehods.h"
#import "NSArray+NetWorkingMethods.h"

@implementation NSDictionary (NetWorkingMehods)

- (NSString *)urlParamsString {
    return [[self transformUrlParamsToArray] urlParamsString];
}

- (NSString *)JSONString {
    NSData *data = [NSJSONSerialization dataWithJSONObject:self options:NSJSONWritingPrettyPrinted error:nil];
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

#pragma mark - private methods

- (NSArray *)transformUrlParamsToArray {
    NSMutableArray *result = [NSMutableArray new];
    [self enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if (![obj isKindOfClass:[NSString class]]) {
            obj = [NSString stringWithFormat:@"%@", obj];
        }
        
        obj = [self urlEncode:obj];
        
        if ([obj length] > 0) {
            [result addObject:[NSString stringWithFormat:@"%@=%@", key, obj]];
        }
    }];
    
    NSArray *sortResult = [result sortedArrayUsingSelector:@selector(compare:)];
    
    return sortResult;
}

- (NSString*)urlEncode:(NSString*)str {
    //different library use slightly different escaped and unescaped set.
    //below is copied from AFNetworking but still escaped [] as AF leave them for Rails array parameter which we don't use.
    //https://github.com/AFNetworking/AFNetworking/pull/555
    if ([str respondsToSelector:@selector(stringByAddingPercentEncodingWithAllowedCharacters:)]) {
        return [str stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@":/?#[]@!$&'()*+,;="]];
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        return (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (__bridge CFStringRef)str, CFSTR("."), CFSTR(":/?#[]@!$&'()*+,;="), kCFStringEncodingUTF8);
#pragma clang diagnostic pop
    }
}

@end
