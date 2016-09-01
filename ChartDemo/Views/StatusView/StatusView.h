//
//  StatusView.h
//  ChartDemo
//
//  Created by xdliu on 16/8/25.
//  Copyright © 2016年 taiya. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^ReloadDataBlock)();

typedef NS_ENUM(NSInteger, StatusStyle) {
    StatusStyleLoading = 0,         //请求
    StatusStyleSuccess,             //成功
    StatusStyleNoNetWork,           //无网络
    StatusStyleFailed               //失败: 无数据等都算失败！！！
};

@interface StatusView : UIView

/**
 *  风火轮颜色 default: gray color
 */
@property (nonatomic, strong) UIColor *indicatorColor;

/**
 *  风火轮大小 default: (30.0f, 30.0f)
 */
@property (nonatomic, assign) CGSize indicatorSize;

/**
 *  内容  default：@[@"正努力加载...", @"网络出错❗", @"获取失败❗"]
 */
@property (nonatomic, strong) NSArray *texts;

/**
 *  字体颜色 default: gray color
 */
@property (nonatomic, strong) UIColor *textColor;

/**
 *  字体大小 default: system font size 16.0f
 */
@property (nonatomic, strong) UIFont *font;

/**
 *  状态 default: StatusStyleLoading
 */
@property (nonatomic, assign) StatusStyle status;

/**
 *  出错加载
 */
@property (nonatomic, copy) ReloadDataBlock reloadBlock;

@end
