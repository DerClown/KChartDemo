//
//  MATipView.h
//  ChartDemo
//
//  Created by xdliu on 16/8/21.
//  Copyright © 2016年 taiya. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MATipView : UIView

@property (nonatomic, strong) UIFont *font;

@property (nonatomic, strong) UIColor *movingAverage5Color;

@property (nonatomic, strong) UIColor *movingAverage10Color;

@property (nonatomic, strong) UIColor *movingAverage20Color;

@property (nonatomic, copy) NSString *movingAverage5;

@property (nonatomic, copy) NSString *movingAverage10;

@property (nonatomic, copy) NSString *movingAverage20;

@end
