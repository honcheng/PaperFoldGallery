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
    if ([self.delegate respondsToSelector:@selector(imageForMultiFoldView:)])
    {
        UIImage *image = [self.delegate imageForMultiFoldView:self];
        if (!image)
        {
            HCPaperFoldGalleryCellView *cell = [self.delegate viewForMultiFoldView:self];
            image = [cell screenshotWithOptimization:NO];
            if ([self.delegate respondsToSelector:@selector(multiFoldView:cell:didGeneratedScreenshot:)])
            {
                [self.delegate multiFoldView:self cell:cell didGeneratedScreenshot:image];
            }
        }
        [self setScreenshotImage:image];
    }
    else if ([self.delegate respondsToSelector:@selector(viewForMultiFoldView:)])
    {
        HCPaperFoldGalleryCellView *cell = [self.delegate viewForMultiFoldView:self];
        UIImage *image = [cell screenshotWithOptimization:NO];
        if ([self.delegate respondsToSelector:@selector(multiFoldView:cell:didGeneratedScreenshot:)])
        {
            [self.delegate multiFoldView:self cell:cell didGeneratedScreenshot:image];
        }
        [self setScreenshotImage:image];
    }
    else
    {
        NSLog(@"Implement either viewForMultiFoldView or imageForMultiFoldView");
    }
}

- (void)reloadScreenshot
{
    [self drawScreenshotOnFolds];
}

- (void)foldDidOpened
{
    
}

@end
