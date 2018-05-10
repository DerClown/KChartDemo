//
//  VolumnView.h
//  ChartDemo
//
//  Created by xdliu on 2016/11/17.
//  Copyright © 2016年 yoyo. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, CandlerstickChartsVolStyle) {
    CandlerstickChartsVolStyleDefault = 0,
    CandlerstickChartsVolStyleRSV9,
    CandlerstickChartsVolStyleKDJ,
    CandlerstickChartsVolStyleMACD,
    CandlerstickChartsVolStyleRSI,
    CandlerstickChartsVolStyleBOLL,
    CandlerstickChartsVolStyleDMA,
    CandlerstickChartsVolStyleCCI,
    CandlerstickChartsVolStyleWR,
    CandlerstickChartsVolStyleBIAS
};

@interface VOLView : UIView

/**
 *  柱体宽度
 */
@property (nonatomic, assign) CGFloat barWidth;

/**
 *  k线图间距
 */
@property (nonatomic, assign) CGFloat barFixedSpacing;

/**
 *  交易量阳线颜色
 */
@property (nonatomic, strong) UIColor *positiveVOLColor;

/**
 *  交易量阴线颜色
 */
@property (nonatomic, strong) UIColor *negativeVOLColor;

/**
*  最大成交量
*/
@property (nonatomic, assign) float maxmumVol;

/**
*  最小成交量
*/
@property (nonatomic, assign) float minmunVol;

- (void)updateVolWithData:(NSArray *)data;

@end
