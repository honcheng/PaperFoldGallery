//
//  HCPaperFoldGalleryView.h
//  Demo
//
//  Created by honcheng on 4/2/13.
//  Copyright (c) 2013 Hon Cheng Muh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HCPaperFoldGalleryViewDelegate.h"
#import "MultiFoldView.h"

@interface HCPaperFoldGalleryView : UIView <MultiFoldViewDelegate, UIScrollViewDelegate>
@property (nonatomic, weak) id<HCPaperFoldGalleryViewDelegate> delegate;
@property (nonatomic, weak) id<HCPaperFoldGalleryViewDatasource> datasource;
@property (nonatomic, assign) int pageNumber;
- (id)initWithFrame:(CGRect)frame folds:(int)folds;
- (void)reloadData;
@end
