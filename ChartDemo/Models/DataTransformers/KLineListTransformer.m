//
//  KLineListTransformer.m
//  ChartDemo
//
//  Created by xdliu on 16/8/12.
//  Copyright © 2016年 taiya. All rights reserved.
//

#import "KLineListTransformer.h"

NSString *const kCandlerstickChartsContext = @"kCandlerstickChartsContext";
NSString *const kCandlerstickChartsDate    = @"kCandlerstickChartsDate";
NSString *const kCandlerstickChartsMaxHigh = @"kCandlerstickChartsMaxHigh";
NSString *const kCandlerstickChartsMinLow  = @"kCandlerstickChartsMinLow";
NSString *const kCandlerstickChartsMaxVol  = @"kCandlerstickChartsMaxVol";
NSString *const kCandlerstickChartsMinVol  = @"kCandlerstickChartsMinVol";

@implementation KLineListTransformer{
    NSInteger _kCount;
}

- (id)manager:(GApiBaseManager *)manager transformData:(id)data {
    _kCount = 150;
    NSString *content = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if (content.length == 0 || !content) {
        return nil;
    }
    
    NSArray *lineRawData = [content componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    NSInteger length = _kCount>=lineRawData.count ? lineRawData.count:_kCount;
    NSArray *cutRawData = [lineRawData subarrayWithRange:NSMakeRange(1, length)];
    
    NSMutableArray *context = [NSMutableArray new];
    NSMutableArray *dates = [NSMutableArray new];
    float maxHigh = 0.0, minLow = 0.0, maxVol = 0.0, minVol = 0.0;
    for (int i = (int)(cutRawData.count - 1); i > 0; i --) {
        //arr = @["日期,开盘价,最高价,最低价,收盘价,成交量, 调整收盘价"]
        NSArray *arr = [lineRawData[i] componentsSeparatedByString:@","];
        if (arr.count != 7 || !arr) {
            continue;
        }
        
        CGFloat MA5 = [self chartMAWithData:lineRawData inRange:NSMakeRange(i, 5)];
        CGFloat MA10 = [self chartMAWithData:lineRawData inRange:NSMakeRange(i, 10)];
        CGFloat MA20 = [self chartMAWithData:lineRawData inRange:NSMakeRange(i, 20)];
        
        //item = @["开盘价,最高价,最低价,收盘价,成交量, MA5, MA10, MA20"]
        NSMutableArray *item = [[NSMutableArray alloc] initWithCapacity:5];
        item[0] = arr[1];
        item[1] = arr[2];
        item[2] = arr[3];
        item[3] = arr[4];
        item[4] = @([arr[5] floatValue]/10000.00);
        item[5] = @(MA5);
        item[6] = @(MA10);
        item[7] = @(MA20);
        
        if (maxHigh < [item[1] floatValue]) {
            maxHigh = [item[1] floatValue];
        }
        
        if (minLow > [item[2] floatValue] || i == (cutRawData.count - 1)) {
            minLow = [item[2] floatValue];
        }
        
        if (maxVol < [item[4] floatValue]) {
            maxVol = [item[4] floatValue];
        }
        
        if (minVol > [item[4] floatValue] || i == (cutRawData.count - 1)) {
            minVol = [item[4] floatValue];
        }
        
        [context addObject:item];
        [dates addObject:arr[0]];
    }
    
    NSLog(@"\n context：\n%@ \n\t\t\t\n\t\t\t\n dates：\n%@ \n\n/*\n maxValue：%.2f \n*/\t\t\t\n\n/*\n minValue：%.2f \n*/\t\t\t\n\n/*\n maxVol：%.2f \n*/\t\t\t\n\n/*\n minVol：%.2f \n*/", context, dates, maxHigh, minLow, maxVol, minVol);
    
    return @{kCandlerstickChartsDate:dates,
             kCandlerstickChartsContext:context,
             kCandlerstickChartsMaxHigh:@(maxHigh),
             kCandlerstickChartsMinLow:@(minLow),
             kCandlerstickChartsMaxVol:@(maxVol),
             kCandlerstickChartsMinVol:@(minVol)
             };
}

- (CGFloat)chartMAWithData:(NSArray *)data inRange:(NSRange)range {
    CGFloat md = 0;
    if (data.count - range.location > range.length) {
        NSArray *rangeData = [data subarrayWithRange:range];
        for (NSString *item in rangeData) {
            NSArray *arr = [item componentsSeparatedByString:@","];
            md += [[arr objectAtIndex:4] floatValue];
        }
        
        md = md / rangeData.count;
    }
    return md;
}

@end
