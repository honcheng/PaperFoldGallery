//
//  DemoCell.m
//  Demo
//
//  Created by honcheng on 5/2/13.
//  Copyright (c) 2013 Hon Cheng Muh. All rights reserved.
//

#import "DemoCell.h"

@implementation DemoCell

- (id)initWithIdentifier:(NSString *)identifier
{
    self = [super initWithIdentifier:identifier];
    if (self) {
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        titleLabel.backgroundColor = [UIColor whiteColor];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.font = [UIFont boldSystemFontOfSize:300];
        titleLabel.adjustsFontSizeToFitWidth = YES;
        [self addSubview:titleLabel];
        self.titleLabel = titleLabel;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self.titleLabel setFrame:CGRectMake(20, 0, self.frame.size.width-40, self.frame.size.height)];
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(contextRef, [UIColor colorWithWhite:0.894 alpha:1.000].CGColor);
    CGContextFillRect(contextRef, CGRectMake(rect.size.width-1, 0, 1, rect.size.height));
}

@end
