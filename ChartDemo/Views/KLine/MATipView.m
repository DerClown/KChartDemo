//
//  MATipView.m
//  ChartDemo
//
//  Created by xdliu on 16/8/21.
//  Copyright © 2016年 taiya. All rights reserved.
//

#import "MATipView.h"
#import <Masonry.h>
#import "UIColor+Ext.h"

@interface MATipView ()

@property (nonatomic, strong) UILabel *movingAverage5Lbl;

@property (nonatomic, strong) UILabel *movingAverage10Lbl;

@property (nonatomic, strong) UILabel *movingAverage20Lbl;

@end

@implementation MATipView

- (id)init {
    if (self = [super init]) {
        [self setup];
        [self addPageSubviews];
        [self layoutPageSubviews];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self setup];
        [self addPageSubviews];
        [self layoutPageSubviews];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setup];
        [self addPageSubviews];
        [self layoutPageSubviews];
    }
    return self;
}

- (void)setup {
    self.font = [UIFont systemFontOfSize:10.0f];
    
    self.movingAverage5Color = [UIColor colorWithHexString:@"#019FFD"];
    self.movingAverage10Color = [UIColor colorWithHexString:@"#FF99OO"];
    self.movingAverage20Color = [UIColor colorWithHexString:@"#FF00FF"];
}

- (void)addPageSubviews {
    [self addSubview:self.movingAverage5Lbl];
    [self addSubview:self.movingAverage10Lbl];
    [self addSubview:self.movingAverage20Lbl];
}

- (void)layoutPageSubviews {
    [self.movingAverage5Lbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(@5.0f);
        make.centerY.equalTo(self.mas_centerY);
    }];
    
    [self.movingAverage10Lbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.mas_centerX);
        make.centerY.equalTo(self.mas_centerY);
    }];
    
    [self.movingAverage20Lbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self.mas_trailing).with.offset(-5.0f);
        make.centerY.equalTo(self.mas_centerY);
    }];
}

#pragma mark - getters

- (UILabel *)movingAverage5Lbl {
    if (!_movingAverage5Lbl) {
        _movingAverage5Lbl = [UILabel new];
        _movingAverage5Lbl.font = self.font;
        _movingAverage5Lbl.textColor = self.movingAverage5Color;
    }
    return _movingAverage5Lbl;
}

- (UILabel *)movingAverage10Lbl {
    if (!_movingAverage10Lbl) {
        _movingAverage10Lbl = [UILabel new];
        _movingAverage10Lbl.font = self.font;
        _movingAverage10Lbl.textColor = self.movingAverage10Color;
    }
    return _movingAverage10Lbl;
}

- (UILabel *)movingAverage20Lbl {
    if (!_movingAverage20Lbl) {
        _movingAverage20Lbl = [UILabel new];
        _movingAverage20Lbl.font = self.font;
        _movingAverage20Lbl.textColor = self.movingAverage20Color;
    }
    return _movingAverage20Lbl;
}

#pragma mark - setters

- (void)setMovingAverage5:(NSString *)movingAverage5 {
    _movingAverage5Lbl.text = movingAverage5 == nil ? @"MA5：0.00" : [@"MA5：" stringByAppendingString:movingAverage5];
}

- (void)setMovingAverage10:(NSString *)movingAverage10 {
    _movingAverage10Lbl.text = movingAverage10 == nil ? @"MA10：0.00" : [@"MA10：" stringByAppendingString:movingAverage10];
}

- (void)setMovingAverage20:(NSString *)movingAverage20 {
    _movingAverage20Lbl.text = movingAverage20 == nil ? @"MA20：0.00" : [@"MA20：" stringByAppendingString:movingAverage20];
}

@end
