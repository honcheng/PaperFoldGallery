//
//  HCPaperFoldGalleryView.h
//  Demo
//
//  Created by honcheng on 4/2/13.
//  Copyright (c) 2013 Hon Cheng Muh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HCPaperFoldGalleryViewDelegate.h"
#import "HCPaperFoldGalleyMultiFoldView.h"
#import "HCPaperFoldGalleryCellView.h"

@interface HCPaperFoldGalleryView : UIView <HCPaperFoldGalleyMultiFoldViewDelegate, UIScrollViewDelegate>
@property (nonatomic, weak) id<HCPaperFoldGalleryViewDelegate> delegate;
@property (nonatomic, weak) id<HCPaperFoldGalleryViewDatasource> datasource;
@property (nonatomic, assign) int pageNumber;
@property (nonatomic, assign) BOOL useCacheImages;
/**
 * Default NO
 * When set to YES, paperfold may not appear when new panning starts before the previous animation completes
 */
@property (nonatomic, assign) BOOL allowDraggingBeforeAnimationCompletes;
- (id)initWithFrame:(CGRect)frame folds:(int)folds;
- (void)reloadData;
- (HCPaperFoldGalleryCellView*)dequeueReusableCellWithIdentifier:(NSString*)identifier;
- (void)setPageNumber:(int)pageNumber animated:(BOOL)animated;
- (void)setPageNumber:(int)pageNumber animated:(BOOL)animated completed:(void(^)())block;
@end
