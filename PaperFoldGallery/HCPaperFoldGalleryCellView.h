//
//  HCPaperFoldGalleryCellView.h
//  Demo
//
//  Created by honcheng on 5/2/13.
//  Copyright (c) 2013 Hon Cheng Muh. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HCPaperFoldGalleryCellView : UIView
@property (nonatomic, assign) int pageNumber;
@property (nonatomic, copy) NSString *identifier;
- (id)initWithIdentifier:(NSString*)identifier;
- (void)viewDidAppear;
- (void)viewDidDisappear;
@end
