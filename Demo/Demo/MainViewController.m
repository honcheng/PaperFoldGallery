//
//  MainViewController.m
//  Demo
//
//  Created by honcheng on 4/2/13.
//  Copyright (c) 2013 Hon Cheng Muh. All rights reserved.
//

#import "MainViewController.h"

@interface MainViewController ()
@end

@implementation MainViewController

- (id)init
{
    self = [super init];
    if (self)
    {
        HCPaperFoldGalleryView *galleryView = [[HCPaperFoldGalleryView alloc] initWithFrame:CGRectMake(0, 0, [self.view bounds].size.width, [self.view bounds].size.height) folds:5];
        [galleryView setDelegate:self];
        [galleryView setDatasource:self];
        [galleryView setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
        [self.view addSubview:galleryView];
        self.galleryView = galleryView;
        
        [self.galleryView reloadData];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark PaperFoldGallery delegate

- (UIView*)paperFoldGalleryView:(HCPaperFoldGalleryView*)galleryView viewAtPageNumber:(int)pageNumber
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [self.view bounds].size.width, [self.view bounds].size.height)];
    if (pageNumber==0) [view setBackgroundColor:[UIColor redColor]];
    else if (pageNumber==1) [view setBackgroundColor:[UIColor blueColor]];
    else [view setBackgroundColor:[UIColor grayColor]];
    
    return view;
}

#pragma mark PaperFoldGallery datasource

- (NSInteger)numbeOfItemsInPaperFoldGalleryView:(HCPaperFoldGalleryView*)galleryView
{
    return 10;
}

@end
