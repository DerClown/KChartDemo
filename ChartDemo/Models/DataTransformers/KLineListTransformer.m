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
NSString *const kCandlerstickChartsRSV9 = @"kCandlerstickChartsRSV9";
NSString *const kCandlerstickChartsKDJ = @"kCandlerstickChartsKDJ";
NSString *const kCandlerstickChartsMACD = @"kCandlerstickChartsMACD";

@implementation KLineListTransformer{
    NSInteger _kCount;
    float sumOfMinLow;      // 最低价总和
    float sumOfMaxHigh;     // 最高价总和 
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
    NSMutableArray *rsv9s = [NSMutableArray new];
    float maxHigh = 0.0, minLow = 0.0, maxVol = 0.0, minVol = 0.0;
    for (int i = (int)cutRawData.count; i > 0; i --) {
        //arr = @["日期,开盘价,最高价,最低价,收盘价,成交量, 调整收盘价"]
        NSArray *arr = [lineRawData[i] componentsSeparatedByString:@","];
        if (arr.count != 7 || !arr) {
            continue;
        }
        
        CGFloat MA5 = [self chartMAWithData:lineRawData sunInRange:NSMakeRange(i, 5)];
        CGFloat MA10 = [self chartMAWithData:lineRawData sunInRange:NSMakeRange(i, 10)];
        CGFloat MA20 = [self chartMAWithData:lineRawData sunInRange:NSMakeRange(i, 20)];
        
        CGFloat rsv9 = [self rsv9WithData:lineRawData sunInRange:NSMakeRange(i, 9)];
        
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
        [rsv9s addObject:@(rsv9)];
    }
    
    NSArray *kdj = [self KDJWithRSV9:rsv9s];
    
    NSArray *macd = [self MACDWithData:cutRawData];
    
#ifdef DEBUG
    NSMutableString *despString = [[NSMutableString alloc] initWithString:@"/************************************ Data Center Control ************************************/"];
    [despString appendFormat:@"Stock Candlers: \t\t\t\t%@\n\n\n", context];
    [despString appendFormat:@"Stock Dates: \t\t\t\t%@\n\n\n", dates];
    [despString appendFormat:@"MaxHigh: \t\t\t\t%.2f\n\n\n", maxHigh];
    [despString appendFormat:@"MinLow: \t\t\t\t%.2f\n\n\n", minLow];
    [despString appendFormat:@"MaxVol: \t\t\t\t%.2f\n\n\n", maxVol];
    [despString appendFormat:@"MinVol: \t\t\t\t%.2f\n\n\n", minVol];
    [despString appendFormat:@"KDJ->[K, D, J]: \t\t\t\t%@\n\n\n", kdj];
    [despString appendFormat:@"MACD->[DIFF, DEA, BAR]: \t\t\t\t%@\n\n\n", macd];
    [despString appendString:@"/************************************************************************/"];
    
    NSLog(@"%@", despString);
#endif
    
    return @{kCandlerstickChartsDate:dates,
             kCandlerstickChartsContext:context,
             kCandlerstickChartsMaxHigh:@(maxHigh),
             kCandlerstickChartsMinLow:@(minLow),
             kCandlerstickChartsMaxVol:@(maxVol),
             kCandlerstickChartsMinVol:@(minVol),
             kCandlerstickChartsRSV9:rsv9s,
             kCandlerstickChartsKDJ:kdj,
             kCandlerstickChartsMACD:macd,
             };
}

// MA
- (CGFloat)chartMAWithData:(NSArray *)data sunInRange:(NSRange)range {
    CGFloat md = 0;
    if (data.count - range.location >= range.length) {
        NSArray *rangeData = [data subarrayWithRange:range];
        for (NSString *item in rangeData) {
            NSArray *arr = [item componentsSeparatedByString:@","];
            md += [[arr objectAtIndex:4] floatValue];
        }
        
        md = md / rangeData.count;
    }
    return md;
}


//RSV(9)=（今日收盘价－9日内最低价）÷（9日内最高价－9日内最低价）×100
- (CGFloat)rsv9WithData:(NSArray *)data sunInRange:(NSRange)range {
    float rsv9 = 100.0;
    float minPriceInNine = MAXFLOAT, maxPriceInNine = -MAXFLOAT;
    
    if (data.count - range.location >= range.length) {
        NSArray *rangeData = [data subarrayWithRange:range];
        for (NSString *item in rangeData) {
            NSArray *arr = [item componentsSeparatedByString:@","];
            //"开盘价,最高价,最低价,收盘价
            float open = [arr[1] floatValue];
            float high = [arr[2] floatValue];
            float low = [arr[3] floatValue];
            float close = [arr[4] floatValue];
            
            // 九天内最低价
            minPriceInNine = MIN(MIN(MIN(MIN(open, high), low), close), minPriceInNine);
            // 九天内最高价
            maxPriceInNine = MAX(MAX(MAX(MAX(open, high), low), close), maxPriceInNine);
        }
        
        float currClose = [[rangeData.firstObject componentsSeparatedByString:@","][4] floatValue];
        if (minPriceInNine != maxPriceInNine) {
            rsv9 = (currClose - minPriceInNine)/(maxPriceInNine - minPriceInNine)*100.0;
        }
    }
    
    return rsv9;
}

// KDJ
- (NSArray *)KDJWithRSV9:(NSArray *)rsv9s {
    NSMutableArray *kdj_ks = [NSMutableArray new];
    NSMutableArray *kdj_ds = [NSMutableArray new];
    NSMutableArray *kdj_js = [NSMutableArray new];
    
    float kdj_k = 50.0f, kdj_d = 50.0f, kdj_j = 50.0f;
    for (int i = (int)(rsv9s.count - 1); i >= 0; i--) {
        kdj_k = ([rsv9s[i] floatValue] + 2*kdj_k)/3.0;  //K(3日)=（当日RSV值+2*前一日K值）÷3
        kdj_d = (kdj_k + 2*kdj_d)/3.0;                  //D(3日)=（当日K值+2*前一日D值）÷3
        kdj_j = 3*kdj_k - 2*kdj_d;                      //J=3K－2D
        
        [kdj_ks addObject:@(kdj_k)];
        [kdj_ds addObject:@(kdj_d)];
        [kdj_js addObject:@(kdj_j)];
    }
    
    // 反转数组数据
    return @[[[kdj_ks reverseObjectEnumerator] allObjects], [[kdj_ds reverseObjectEnumerator] allObjects], [[kdj_js reverseObjectEnumerator] allObjects]];
}

/*
 参数表：
 　　参数名 最小值 最大值 默认值
 　　SHORT 5 40 12
 　　LONG 20 100 26
 　　M 2 60 10
 公式写成如下形式即可：
 　　DIFF:=EMA(CLOSE,SHORT)-EMA(CLOSE,LONG);
 　　DEA:=MA(DIFF,M);
 　　MACD:2*(DIFF-DEA);
 
 
    EMA（m）= 前一日EMA（m）×(m-1)/(m+1)＋今日收盘价×2/(m+1)
    EMA（n）= 前一日EMA（n）×(n-1)/(n+1)＋今日收盘价×2/(n+1)
    DIFF=今日EMA（m）- 今日EMA（n）
    DEA（MACD）= M天的DIF总和/M
    BAR=2×(DIFF－DEA)
 */
- (NSArray *)MACDWithData:(NSArray *)data {
    NSMutableArray *diffs = [NSMutableArray new];
    NSMutableArray *deas = [NSMutableArray new];
    NSMutableArray *bars = [NSMutableArray new];
    //使用默认值，如果有设置需求，可以从保存数据中读取 (SHORT:12, LONG:26 M:10)
    float prvShortEMA = 0.0, prvLongEMA = 0.0;
    for (int i = 0; i < data.count; i ++) {
        NSArray *lineData = [data[i] componentsSeparatedByString:@","];
        float short_ema = i == 0 ? [lineData[4] floatValue] : prvShortEMA*11/13.0 + [lineData[4] floatValue]*2/13.0;
        float long_ema = i == 0 ? [lineData[4] floatValue] : prvLongEMA*25/27.0f + [lineData[4] floatValue]*2/27.0f;
        float diff = i != 0 ? short_ema - long_ema : 0.0;
        [diffs addObject:@(diff)];
        
        NSArray *sumDiff = diffs.count >= 10 ? [diffs subarrayWithRange:NSMakeRange(diffs.count - 10, 10)] : diffs;
        float dea = i == 0 ? 0.0 : [[sumDiff valueForKeyPath:@"@sum.self"] floatValue]/10.0;
        
        float bar = 2*(diff - dea)/1.0;
        
        [deas addObject:@(dea)];
        [bars addObject:@(bar)];
        prvShortEMA = short_ema;
        prvLongEMA = long_ema;
    }
    
    return @[diffs, deas, bars];
}

@end
