//
//  HCPaperFoldGalleyMultiFoldView.m
//  Demo
//
//  Created by honcheng on 5/2/13.
//  Copyright (c) 2013 Hon Cheng Muh. All rights reserved.
//

#import "HCPaperFoldGalleyMultiFoldView.h"
#import "HCPaperFoldGalleryView.h"
#import "UIView+Screenshot.h"

@implementation HCPaperFoldGalleyMultiFoldView

- (void)drawScreenshotOnFolds
{
    HCPaperFoldGalleryCellView *cell = [self.delegate viewForMultiFoldView:self];
    UIImage *image = [cell screenshotWithOptimization:NO];
    [self setScreenshotImage:image];
}

- (void)reloadScreenshot
{
    [self drawScreenshotOnFolds];
}

- (void)foldDidOpened
{
    
}

@end
