//
//  Global+Helper.m
//  SCE
//
//  Created by xdliu on 16/9/30.
//  Copyright © 2016年 taiya. All rights reserved.
//

#import "Global+Helper.h"
#import "ACMacros.h"

@implementation Global_Helper

+ (NSAttributedString *)attachmentImageNamed:(NSString *)imageNamed bounds:(CGRect)bounds {
    NSTextAttachment *attachment=[[NSTextAttachment alloc] initWithData:nil ofType:nil];
    UIImage *img = [UIImage imageNamed:imageNamed];
    attachment.image = img;
    attachment.bounds = bounds;
    NSAttributedString *attachmentText = [NSAttributedString attributedStringWithAttachment:attachment];
    return attachmentText;
}

+ (NSAttributedString *)attributeText:(NSString *)text textColor:(UIColor *)color font:(UIFont *)font {
    return [self attributeText:text textColor:color font:font lineSpacing:0];
}

+ (NSAttributedString *)attributeText:(NSString *)text textColor:(UIColor *)color font:(UIFont *)font lineSpacing:(CGFloat)lineSpacing {
    return [self attributeText:text textColor:color font:font lineSpacing:lineSpacing alignment:NSTextAlignmentCenter];
}

+ (NSAttributedString *)attributeText:(NSString *)text textColor:(UIColor *)color font:(UIFont *)font lineSpacing:(CGFloat)lineSpacing alignment:(NSTextAlignment)alignment {
    if (!text) {
        return nil;
    }
    
    NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:text attributes:@{NSFontAttributeName:font, NSForegroundColorAttributeName:color}];
    
    if (lineSpacing != 0) {
        NSMutableParagraphStyle *pStyle = [NSMutableParagraphStyle new];
        pStyle.lineSpacing = lineSpacing;
        pStyle.alignment = alignment;
        [attString addAttributes:@{NSParagraphStyleAttributeName:pStyle} range:NSMakeRange(0, text.length)];
    }
    
    return attString;
}

+ (NSAttributedString *)attributeText:(NSString *)text textColor:(UIColor *)color font:(UIFont *)font alignment:(NSTextAlignment)alignment {
    if (!text) {
        return nil;
    }
    
    NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:text attributes:@{NSFontAttributeName:font, NSForegroundColorAttributeName:color}];
    
    NSMutableParagraphStyle *pStyle = [NSMutableParagraphStyle new];
    pStyle.alignment = alignment;
    [attString addAttributes:@{NSParagraphStyleAttributeName:pStyle} range:NSMakeRange(0, text.length)];
    
    return attString;
}

+ (CGSize)attributeString:(NSAttributedString *)attString boundingRectWithSize:(CGSize)size {
    if (!attString) {
        return CGSizeZero;
    }
    return [attString boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
}

+ (NSString *)safeString:(NSString *)string placeHolder:(NSString *)placeHolder {
    NSString *safeString = string;
    if (EqualString(string, @"")) {
        safeString = placeHolder;
    }
    return safeString;
}

@end
