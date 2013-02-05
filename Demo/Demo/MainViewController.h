//
//  MainViewController.h
//  Demo
//
//  Created by honcheng on 4/2/13.
//  Copyright (c) 2013 Hon Cheng Muh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HCPaperFoldGalleryView.h"

@interface MainViewController : UIViewController <HCPaperFoldGalleryViewDelegate, HCPaperFoldGalleryViewDatasource>
@property (nonatomic, weak) HCPaperFoldGalleryView *galleryView;
@end
