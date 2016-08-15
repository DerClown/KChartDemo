//
//  UIColor+Ext.h
//  CandlerstickCharts
//
//  Created by liuxd on 16/7/19.
//  Copyright © 2016年 liuxd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (Ext)

+ (UIColor *)colorWithHexString:(NSString *)color;
+ (UIColor *)colorWithHexString:(NSString *)color withAlpha:(float)alpha;

@end
