//
//  CandlestickTipView.h
//  ChartDemo
//
//  Created by YoYo on 2018/5/11.
//  Copyright © 2018年 taiya. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CandlestickTipView : UIView

@property (nonatomic, readonly) CGSize fitSize;

@property (nonatomic, copy) NSString *open;
@property (nonatomic, copy) NSString *close;
@property (nonatomic, copy) NSString *high;
@property (nonatomic, copy) NSString *low;

@end
