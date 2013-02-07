//
//  HCPaperFoldGalleyMultiFoldView.h
//  Demo
//
//  Created by honcheng on 5/2/13.
//  Copyright (c) 2013 Hon Cheng Muh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MultiFoldView.h"
#import "HCPaperFoldGalleryViewDelegate.h"
@class HCPaperFoldGalleryCellView;
@class HCPaperFoldGalleyMultiFoldView;

@protocol HCPaperFoldGalleyMultiFoldViewDelegate <MultiFoldViewDelegate>
- (HCPaperFoldGalleryCellView*)viewForMultiFoldView:(HCPaperFoldGalleyMultiFoldView*)foldView;
@optional
/**
 * Optional method, used images as screenshot instead of taking new screenshots
 * Faster
 */
- (UIImage*)imageForMultiFoldView:(HCPaperFoldGalleyMultiFoldView*)foldView;
/**
 * Optional method, sends generated screenshots to its delegate
 * Used for caching
 */
- (void)multiFoldView:(HCPaperFoldGalleyMultiFoldView*)foldView cell:(HCPaperFoldGalleryCellView*)cell didGeneratedScreenshot:(UIImage*)screenshot;
@end

@interface HCPaperFoldGalleyMultiFoldView : MultiFoldView
@property (nonatomic, weak) id<HCPaperFoldGalleyMultiFoldViewDelegate> delegate;
- (void)reloadScreenshot;
@end


