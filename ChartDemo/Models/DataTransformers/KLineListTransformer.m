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
NSString *const kCandlerstickChartsRSI = @"kCandlerstickChartsRSI";
NSString *const kCandlerstickChartsBOLL = @"kCandlerstickChartsBOLL";

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
    NSMutableArray *rsis = [NSMutableArray new];
    NSMutableArray *bolls = [NSMutableArray new];
    float maxHigh = 0.0, minLow = 0.0, maxVol = 0.0, minVol = 0.0;
    for (int i = (int)cutRawData.count; i > 0; i --) {
        //arr = @["日期,开盘价,最高价,最低价,收盘价,成交量, 调整收盘价"]
        NSArray *arr = [lineRawData[i] componentsSeparatedByString:@","];
        if (arr.count != 7 || !arr) {
            continue;
        }
        
        CGFloat MA5 = [self chartMAWithData:lineRawData subInRange:NSMakeRange(i, 5)];
        CGFloat MA10 = [self chartMAWithData:lineRawData subInRange:NSMakeRange(i, 10)];
        CGFloat MA20 = [self chartMAWithData:lineRawData subInRange:NSMakeRange(i, 20)];
        
        CGFloat rsv9 = [self rsv9WithData:lineRawData sunInRange:NSMakeRange(i, 9)];
        
        CGFloat rsi = [self rsiWithData:lineRawData subWithRange:NSMakeRange(i, 12)];
        
        NSArray *boll = [self bollWithData:lineRawData subWithRange:NSMakeRange(i, 20)];
        
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
        [rsis addObject:@(rsi)];
        [bolls addObject:boll];
    }
    
    NSArray *kdj = [self kdjWithRSV9:rsv9s];
    
    NSArray *macd = [self macdWithData:cutRawData];
    
#ifdef DEBUG
    NSMutableString *despString = [[NSMutableString alloc] initWithString:@"\n\n\n\n/************************************ Data Center Control ************************************/\n\n\n\n"];
    [despString appendFormat:@"Stock Candlers: \t\t\t\t%@\n\n\n", context];
    [despString appendFormat:@"Stock Dates: \t\t\t\t%@\n\n\n", dates];
    [despString appendFormat:@"MaxHigh: \t\t\t\t%.2f\n\n\n", maxHigh];
    [despString appendFormat:@"MinLow: \t\t\t\t%.2f\n\n\n", minLow];
    [despString appendFormat:@"MaxVol: \t\t\t\t%.2f\n\n\n", maxVol];
    [despString appendFormat:@"MinVol: \t\t\t\t%.2f\n\n\n", minVol];
    [despString appendFormat:@"KDJ->[K, D, J]: \t\t\t\t%@\n\n\n", kdj];
    [despString appendFormat:@"MACD->[DIFF, DEA, BAR]: \t\t\t\t%@\n\n\n", macd];
    [despString appendFormat:@"RSI: \t\t\t\t%@\n\n\n", rsis];
    [despString appendFormat:@"BOLL: \t\t\t\t%@\n\n\n", bolls];
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
             kCandlerstickChartsRSI:rsis,
             kCandlerstickChartsBOLL:bolls
             };
}

// MA
- (CGFloat)chartMAWithData:(NSArray *)data subInRange:(NSRange)range {
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
- (NSArray *)kdjWithRSV9:(NSArray *)rsv9s {
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
- (NSArray *)macdWithData:(NSArray *)data {
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
    
    return @[[[diffs reverseObjectEnumerator] allObjects], [[deas reverseObjectEnumerator] allObjects], [[bars reverseObjectEnumerator] allObjects]];
}

/*
 计算公式
 RSI=100×RS/(1+RS)
 
 计算RSI的步骤如下：
 其中 RS=N天内收市价上涨数之和的平均值 && N天内收市价下跌数之和的平均值
 例子：
 如果最近14天涨跌情形是： 
    第一天升2元，第二天跌2元，第三至第五天各升3元；第六天跌4元 第七天升2元，第八天跌5元；第九天跌6元，第十至十二天各升1元；第十三至十四天各跌3元。
 (一)将14天上升的数目相加，除以14，上例中总共上升16元除以14得1.143(精确到小数点后三位)；
 (二)将14天下跌的数目相加，除以14，上例中总共下跌23元除以14得1.643(精确到小数点后三位)； 
 (三)求出相对强度RS，即RS=1.143/1.643=0.696(精确到小数点后三位)；    
 (四)1+RS=1+0.696=1.696；   
 (五)以100除以1+RS，即100/1.696=58.962；
 (六)100-58.962=41.038。   
 结果14天的强弱指标RS1为41.038。    
 不同日期的14天RSI值当然是不同的，连接不同的点，即成RSI的轨迹。
 
 @param range.length 表示N天
 */
- (float)rsiWithData:(NSArray *)data subWithRange:(NSRange)range {
    // length + 1 获取 N+1 天的数据
    float sumOfRise = 0.0, sumOfFall = 0.0;
    NSArray *rangeData = [data subarrayWithRange:NSMakeRange(range.location, data.count - range.location)];
    if ((data.count - range.location >= range.length + 1)) {
        rangeData = [data subarrayWithRange:NSMakeRange(range.location, range.length + 1)];
    }
    
    if (rangeData.count == 0) {
        return 0.0;
    }
    
    //如果只有一个数据不全
    if (rangeData.count == 1) {
        rangeData = [rangeData arrayByAddingObject:@"0,0,0,0,0,0,0"];
    }
    
    for (int i = 0; i < rangeData.count - 1; i ++) {
        NSArray *currLineData = [rangeData[i] componentsSeparatedByString:@","];
        NSArray *prvLineData = [rangeData[i + 1] componentsSeparatedByString:@","];
        float currClose = [currLineData[4] floatValue], prvClose = [prvLineData[4] floatValue];
        float diff = currClose - prvClose;
        sumOfRise += diff > 0 ? diff : 0;
        sumOfFall += diff < 0 ? fabsf(diff) : 0;
    }
    
    float rs = sumOfFall == 0 ? 0.0 : sumOfRise/sumOfFall;
    
    return 100*rs/(1+rs);
}

/*
  日BOLL指标的计算过程
 （1）计算MA 　　         MA=N日内的收盘价之和÷N
 （2）计算标准差MD 　　    MD=平方根N日的（C－MA）的两次方之和除以N
 （3）计算MB、UP、DN线 　　MB=（N－1）日的MA 　　UP=MB＋k×MD 　　DN=MB－k×MD
 */
- (NSArray *)bollWithData:(NSArray *)data subWithRange:(NSRange)range {
    NSArray *boll = @[];
    NSArray *rangeData = [data subarrayWithRange:NSMakeRange(range.location, data.count - range.location)];
    if (data.count - range.location >= range.length) {
        rangeData = [data subarrayWithRange:range];
    }
    
    NSMutableArray *closes = [NSMutableArray new];
    for (int i = 0; i < rangeData.count; i ++) {
        NSArray *lineData = [rangeData[i] componentsSeparatedByString:@","];
        [closes addObject:lineData[4]];
    }
    
    float avgClose = [[closes valueForKeyPath:@"@sum.floatValue"] floatValue]/range.length;
    float sum = 0.0;
    for (int i = 0; i < closes.count; i ++) {
        sum += pow(([closes[i] floatValue] - avgClose), 2);
    }
    
    float md = sqrt(sum/range.length);
    float mid = (avgClose*range.length - [closes.lastObject floatValue]) / (range.length - 1);
    float up = mid + 2*md, dn = mid - 2*md;
    
    boll = @[@(up), @(mid), @(dn)];
    
    return boll;
}


@end
