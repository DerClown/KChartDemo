//
//  CandlestickTipView.m
//  ChartDemo
//
//  Created by YoYo on 2018/5/11.
//  Copyright © 2018年 taiya. All rights reserved.
//

#import "CandlestickTipView.h"
#import <Masonry.h>

@interface CandlestickTipView ()

@property (nonatomic) CGSize fitSize;

@property (nonatomic, strong) UILabel *closeLabel;
@property (nonatomic, strong) UILabel *openLabel;
@property (nonatomic, strong) UILabel *highLabel;
@property (nonatomic, strong) UILabel *lowLabel;

@end

@implementation CandlestickTipView

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.layer.cornerRadius = 3.0f;
        self.layer.borderWidth = 0.5;
        self.layer.borderColor = [UIColor colorWithRed:(215/255.0f) green:(0/255.0f) blue:(2/255.0f) alpha:1.0].CGColor;
        self.backgroundColor = [UIColor whiteColor];
        
        _closeLabel = [UILabel new];
        _closeLabel.font = [UIFont systemFontOfSize:10.0f];
        
        _openLabel = [UILabel new];
        _openLabel.font = [UIFont systemFontOfSize:10.0f];
        
        _highLabel = [UILabel new];
        _highLabel.font = [UIFont systemFontOfSize:10.0f];
        
        _lowLabel = [UILabel new];
        _lowLabel.font = [UIFont systemFontOfSize:10.0f];
        
        [self addSubview:_closeLabel];
        [self addSubview:_openLabel];
        [self addSubview:_highLabel];
        [self addSubview:_lowLabel];
        
        [@[_openLabel, _highLabel, _lowLabel, _closeLabel] mas_distributeViewsAlongAxis:MASAxisTypeVertical withFixedSpacing:2.5 leadSpacing:5.0f tailSpacing:5.0f];
        
        [@[_openLabel, _highLabel, _lowLabel, _closeLabel] mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(5.0f);
        }];
    }
    return self;
}

- (void)setClose:(NSString *)close {
    _closeLabel.text = [@"收盘价：" stringByAppendingString:close];
}

- (void)setOpen:(NSString *)open {
    self.openLabel.text = [@"开盘价：" stringByAppendingString:open];
}

- (void)setHigh:(NSString *)high {
    self.highLabel.text = [@"最高价：" stringByAppendingString:high];
}

- (void)setLow:(NSString *)low {
    self.lowLabel.text = [@"最低价：" stringByAppendingString:low];
}

- (CGSize)fitSize {
    CGSize size = [_closeLabel sizeThatFits:CGSizeMake(100, 100)];
    return CGSizeMake(size.width + 10.0f, size.height*4 + 10.0f + 2.5*3);
}

@end
