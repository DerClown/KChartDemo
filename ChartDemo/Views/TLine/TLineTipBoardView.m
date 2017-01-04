//
//  TLineTipBoardView.m
//  ChartDemo
//
//  Created by xdliu on 16/8/23.
//  Copyright © 2016年 taiya. All rights reserved.
//

#import "TLineTipBoardView.h"

@implementation TLineTipBoardView

#pragma mark - life cycle

- (id)init {
    if (self = [super init]) {
        [self _setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self _setup];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self _setup];
    }
    return self;
}

- (void)_setup {
    self.triangleWidth = 5.0;
    self.radius = 4.0;
    self.hideDuration = 2.5;
    
    self.font = [UIFont systemFontOfSize:10.0f];
    self.contentColor = [UIColor colorWithWhite:0.35 alpha:0.9];
    self.strockColor = [UIColor redColor];
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    [self drawInContext];
    
    [self drawText];
}

- (void)drawText {
    if (self.content.length == 0 || !self.content) {
        self.content = @"";
    }
    NSAttributedString *attString = [[NSAttributedString alloc] initWithString:self.content attributes:@{NSFontAttributeName:self.font, NSForegroundColorAttributeName:self.contentColor}];
    CGSize size = [attString boundingRectWithSize:CGSizeMake(self.frame.size.width, self.frame.size.height) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
    [attString drawInRect:CGRectMake((self.frame.size.width - size.width)/2.0, (self.frame.size.height - size.height)/2.0, size.width, size.height)];
}

@end
