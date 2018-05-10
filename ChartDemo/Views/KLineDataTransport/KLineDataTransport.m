//
//  KLineDataTransport.m
//  ChartDemo
//
//  Created by YoYo on 2018/5/7.
//  Copyright © 2018年 yoyo. All rights reserved.
//

#import "KLineDataTransport.h"
#import "KLineItem.h"

@implementation KLineDataTransport

- (id)init {
    if (self = [super init]) {
        _maxnumIntegerDigits = 2;
    }
    return self;
}

- (float)maxmumPrice {
    return [self getExtremeValue:YES isVol:NO isCandle:YES];
}

- (float)minmumPrice {
    return [self getExtremeValue:NO isVol:NO isCandle:YES];
}

- (float)timeSharingChartMaxPrice {
    return [self getExtremeValue:NO isVol:NO isCandle:NO];
}

- (float)timeSharingChartMinPrice {
    return [self getExtremeValue:NO isVol:NO isCandle:NO];
}

- (float)maxmumVol {
    return [self getExtremeValue:YES isVol:YES isCandle:NO];
}

- (float)minmumVol {
    return [self getExtremeValue:NO isVol:YES isCandle:NO];
}

- (float)getExtremeValue:(BOOL)isMax isVol:(BOOL)vol isCandle:(BOOL)isCandle {
    NSArray *data = self.delegate.kLineDataSources;
    
    if (!data) return 0.0;
    
    float extremeValue = isMax ? -MAXFLOAT : MAXFLOAT;
    if (self.isVisableExtremeValue) {
        NSRange range = NSMakeRange(self.startIndex, self.needDrawingCandleNumber);
        data = [data subarrayWithRange:range];
    }
    
    if (vol) {
        for (int i = 0; i < data.count; i ++) {
            KLineItem *obj = data[i];
            extremeValue = isMax ? MAX(fabs(obj.rise_and_fall_value.floatValue), extremeValue) : MIN(extremeValue, fabs(obj.rise_and_fall_value.floatValue));
        }
    } else if(isCandle) {
        for (int i = 0; i < data.count; i ++) {
            KLineItem *obj = data[i];
            extremeValue = isMax ? MAX(obj.high.floatValue, extremeValue) : MIN(extremeValue, obj.low.floatValue);
        }
    } else {
        for (int i = 0; i < data.count; i ++) {
            KLineItem *obj = data[i];
            extremeValue = isMax ? MAX(obj.close.floatValue, extremeValue) : MIN(extremeValue, obj.close.floatValue);
        }
    }
    
    return extremeValue;
}

// 绘制k线图数据
- (NSArray *)getNeedDrawingCandleData {
    NSArray *data = self.delegate.kLineDataSources;
    
    if (!data) nil;
    
    NSArray *drawingCxt = [data subarrayWithRange:NSMakeRange(self.startIndex, self.needDrawingCandleNumber)];
    return drawingCxt;
}

// 获取均线数据
- (NSArray *)getMovingAverageData {
    NSArray *MAs = self.delegate.MAs;
    
    if (!MAs) {
        NSAssert(!MAs, @"没有均线类型.");
        return nil;
    }
    
    NSArray *rawData = self.delegate.kLineDataSources;
    
    NSMutableArray *MAContainerLists = [[NSMutableArray alloc] initWithCapacity:MAs.count];
    
    for (int i = 0; i < MAs.count; i ++) {
        NSMutableArray *MAContainers = [NSMutableArray new];
        NSInteger MASize = [MAs[i] integerValue];
        
        NSArray *candleData;
        
        NSInteger newStartIndex = self.startIndex;
        NSInteger endIndex = self.startIndex + self.needDrawingCandleNumber;
        NSInteger needDrawTotalSize  = self.needDrawingCandleNumber + MASize;
        
        int diff = (int)(endIndex - needDrawTotalSize);
        if (diff < 0) {
            needDrawTotalSize = endIndex;
            newStartIndex = 0;
            for (int i = 0; i < ABS(diff); i ++) {
                // 填充数据
                [MAContainers addObject:[NSNull null]];
            }
        } else {
            newStartIndex -= MASize;
        }
        candleData = [rawData subarrayWithRange:NSMakeRange(newStartIndex, needDrawTotalSize)];
        
        for (int index = 0; index < (self.needDrawingCandleNumber + (diff > 0 ? 0 : diff)); index ++) {
            NSArray *availableMA = [candleData subarrayWithRange:NSMakeRange(index, MASize)];
            float sum = 0;
            for (KLineItem *item in availableMA) {
                sum += item.close.floatValue;
            }
            [MAContainers addObject:@(sum/MASize)];
        }
        
        [MAContainerLists addObject:MAContainers];
    }
    
    return MAContainerLists;
}

- (NSArray *)getNeedDrawingTimeSharingChartData {
    NSArray *data = self.delegate.kLineDataSources;
    
    if (!data) return nil;
    
    if (self.needDrawingCandleNumber > data.count) {
        return data;
    }
    
    return [data subarrayWithRange:NSMakeRange(data.count - self.needDrawingCandleNumber, self.needDrawingCandleNumber)];
}

- (NSString *)getPriceString:(NSNumber *)price {
    if (!price) {
        return nil;
    }else if (_maxnumIntegerDigits == 0) {
        return @(price.floatValue/1).stringValue;
    }
    
    NSString *positiveString = @"###0.";
    NSUInteger count = _maxnumIntegerDigits;
    while (count) {
        positiveString = [positiveString stringByAppendingString:@"#"];
        count --;
    }
    
    NSNumberFormatter *numberFormatter = [NSNumberFormatter new];
    [numberFormatter setPositiveFormat:positiveString];
    
    NSString *resultString = [numberFormatter stringFromNumber:price];
    if (![resultString containsString:@"."]) {
        resultString = [resultString stringByAppendingString:@"."];
    }
    
    NSArray *nums = [resultString componentsSeparatedByString:@"."];
    if (nums.count == 2) {
        count = _maxnumIntegerDigits - [nums.lastObject length];
    } else {
        count = _maxnumIntegerDigits;
    }
    while (count) {
        resultString = [resultString stringByAppendingString:@"0"];
        count --;
    }
    
    return resultString;
}

@end
