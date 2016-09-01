//
//  StatusView.m
//  ChartDemo
//
//  Created by xdliu on 16/8/25.
//  Copyright © 2016年 taiya. All rights reserved.
//

#import "StatusView.h"
#import <Masonry.h>

@interface StatusView ()

@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;
@property (nonatomic, strong) UILabel *contentLbl;

@property (nonatomic, copy) NSString *text;
@property (nonatomic, assign) StatusStyle aStatus;

@end

@implementation StatusView

#pragma mark - life cycle

- (id)init {
    if (self = [super init]) {
        [self _setup];
        [self addPageSubviews];
        [self layoutPageSubviews];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self _setup];
        [self addPageSubviews];
        [self layoutPageSubviews];
    }
    return self;
}

- (void)_setup {
    self.texts = @[@"正努力加载...", @"网络出错❗", @"获取失败❗"];
    self.text = self.texts[0];
    self.font = [UIFont systemFontOfSize:16.0f];
    self.textColor = [UIColor grayColor];
    
    self.indicatorColor = [UIColor grayColor];
    self.indicatorSize = CGSizeMake(30.0f, 30.0f);
    self.status = StatusStyleLoading;
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(reloadPressEvent:)];
    [self addGestureRecognizer:tapGesture];
}

- (void)addPageSubviews {
    [self addSubview:self.indicatorView];
    [self addSubview:self.contentLbl];
}

- (void)layoutPageSubviews {
    [self.indicatorView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self.contentLbl.mas_leading).with.offset(-5);
        make.centerY.equalTo(self.mas_centerY);
        make.height.equalTo(@(self.indicatorSize.width));
        make.width.equalTo(@(self.indicatorSize.height));
    }];
    
    [self.contentLbl mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.mas_centerY);
        make.centerX.equalTo(self.mas_centerX).with.offset(self.indicatorSize.width/2.0);
    }];
}

#pragma mark - reponse events

- (void)reloadPressEvent:(id)sender {
    switch (self.aStatus) {
        case StatusStyleNoNetWork:
        case StatusStyleFailed: {
            self.status = StatusStyleLoading;
            if (self.reloadBlock) {
                self.reloadBlock();
            }
            break;
        }
        default:
            break;
    }
}

#pragma mark - getters

- (UIActivityIndicatorView *)indicatorView {
    if (!_indicatorView) {
        _indicatorView = [UIActivityIndicatorView new];
        _indicatorView.color = self.indicatorColor;
        _indicatorView.hidesWhenStopped = YES;
    }
    return _indicatorView;
}

- (UILabel *)contentLbl {
    if (!_contentLbl) {
        _contentLbl = [[UILabel alloc] init];
        _contentLbl.text = self.text;
        _contentLbl.font = self.font;
        _contentLbl.textColor = self.textColor;
    }
    return _contentLbl;
}

#pragma mark - setters

- (void)setStatus:(StatusStyle)status {
    _aStatus = status;
    _contentLbl.hidden = NO;
    switch (status) {
        case StatusStyleLoading: {
            [self.indicatorView startAnimating];
            self.text = self.texts[0];
            break;
        }
        case StatusStyleSuccess: {
            [self.indicatorView stopAnimating];
            _contentLbl.hidden = YES;
            break;
        }
        case StatusStyleNoNetWork: {
            [self.indicatorView stopAnimating];
            self.text = self.texts[1];
            break;
        }
        case StatusStyleFailed: {
            [self.indicatorView stopAnimating];
            self.text = self.texts[2];
            break;
        }
    }
}

- (void)setText:(NSString *)text {
    _text = text;
    
    _contentLbl.text = text;
}

@end
