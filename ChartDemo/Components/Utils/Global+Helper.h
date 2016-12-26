//
//  Global+Helper.h
//  SCE
//
//  Created by xdliu on 16/9/30.
//  Copyright © 2016年 taiya. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Global_Helper : NSObject

#pragma mark - (NSAttributedString)

+ (NSAttributedString *)attachmentImageNamed:(NSString *)imageNamed bounds:(CGRect)bounds;

+ (NSAttributedString *)attributeText:(NSString *)text textColor:(UIColor *)color font:(UIFont *)font;

+ (NSAttributedString *)attributeText:(NSString *)text textColor:(UIColor *)color font:(UIFont *)font lineSpacing:(CGFloat)lineSpacing;

+ (NSAttributedString *)attributeText:(NSString *)text textColor:(UIColor *)color font:(UIFont *)font alignment:(NSTextAlignment)alignment;

+ (CGSize)attributeString:(NSAttributedString *)attString boundingRectWithSize:(CGSize)size;

#pragma mark - String

+ (NSString *)safeString:(NSString *)string placeHolder:(NSString *)placeHolder;

@end
