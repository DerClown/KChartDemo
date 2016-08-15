//
//  GApiLog.m
//  GeitNetwoking
//
//  Created by liuxd on 16/7/13.
//  Copyright © 2016年 liuxd. All rights reserved.
//

#import "GApiLogger.h"

@implementation GApiLogger

+ (void)logDebugInfoWithRequest:(NSURLRequest *)request reqeustParams:(NSDictionary *)params reqeustMethod:(NSString *)requestMethod {
#ifdef DEBUG
    NSMutableString *logString = [NSMutableString stringWithString:@"\n\n**************************************************************\n*                       Request Start                        *\n**************************************************************\n\n"];
    
    [logString appendFormat:@"Method:\t\t\t\t%@\n", requestMethod];
    [logString appendFormat:@"Params:\t\t\n%@", params];
    
    [logString appendFormat:@"\n\nHTTP URL:\n\t%@", request.URL];
    [logString appendFormat:@"\n\nHTTP Header:\n%@", request.allHTTPHeaderFields ? request.allHTTPHeaderFields : @"\t\t\t\t\tN/A"];
    NSString *bodyString = [[NSString alloc] initWithData:request.HTTPBody encoding:NSUTF8StringEncoding];
    [logString appendFormat:@"\n\nHTTP Body:\n\t%@", bodyString ? bodyString : @"\t\t\t\t\tN/A"];
    
    [logString appendFormat:@"\n\n**************************************************************\n*                         Request End                        *\n**************************************************************\n\n\n\n"];
    NSLog(@"%@", logString);
#endif
}

+ (void)logDebugInfoWithOperation:(AFHTTPRequestOperation *)operation error:(NSError *)error {
#ifdef DEBUG
    BOOL shouldLogError = error ? YES : NO;
    
    NSMutableString *logString = [NSMutableString stringWithString:@"\n\n==============================================================\n=                        API Response                        =\n==============================================================\n\n"];
    
    [logString appendFormat:@"Status:\t%ld\t(%@)\n\n", (long)operation.response.statusCode, [NSHTTPURLResponse localizedStringForStatusCode:operation.response.statusCode]];
    id reponseObject;
    if (operation.responseObject) {
        reponseObject = [NSJSONSerialization JSONObjectWithData:operation.responseObject options:NSJSONReadingMutableContainers error:NULL];
    }
    [logString appendFormat:@"Content:\n%@\n\n", reponseObject ? reponseObject : @"\t\t\t\t\tN/A"];
    if (shouldLogError) {
        [logString appendFormat:@"Error Domain:\t\t\t\t\t\t\t%@\n", error.domain];
        [logString appendFormat:@"Error Domain Code:\t\t\t\t\t\t%ld\n", (long)error.code];
        [logString appendFormat:@"Error Localized Description:\t\t\t%@\n", error.localizedDescription];
        [logString appendFormat:@"Error Localized Failure Reason:\t\t\t%@\n", error.localizedFailureReason];
        [logString appendFormat:@"Error Localized Recovery Suggestion:\t%@\n\n", error.localizedRecoverySuggestion];
    }
    
    [logString appendString:@"\n---------------  Related Request Content  --------------\n"];
    
    [logString appendFormat:@"\n\nHTTP URL:\n\t%@", operation.request.URL];
    [logString appendFormat:@"\n\nHTTP Header:\n%@", operation.request.allHTTPHeaderFields ? operation.request.allHTTPHeaderFields : @"\t\t\t\t\tN/A"];
    NSString *bodyString = [[NSString alloc] initWithData:operation.request.HTTPBody encoding:NSUTF8StringEncoding];
    [logString appendFormat:@"\n\nHTTP Body:\n\t%@", bodyString ? bodyString : @"\t\t\t\t\tN/A"];
    
    [logString appendFormat:@"\n\n==============================================================\n=                        Response End                        =\n==============================================================\n\n\n\n"];
    
    NSLog(@"%@", logString);
#endif

}

@end
