//
//  HCPaperFoldGalleryView.m
//  Demo
//
//  Created by honcheng on 4/2/13.
//  Copyright (c) 2013 Hon Cheng Muh. All rights reserved.
//

#import "HCPaperFoldGalleryView.h"

@interface HCPaperFoldGalleryView()
@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic, weak) MultiFoldView *rightFoldView;
@property (nonatomic, weak) UIView *contentView;
@property (nonatomic, strong) NSTimer *animationTimer;
@end

@implementation HCPaperFoldGalleryView

- (id)initWithFrame:(CGRect)frame folds:(int)folds
{
    self = [super initWithFrame:frame];
    if (self) {
        
        UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        scrollView.pagingEnabled = YES;
        scrollView.delegate = self;
        [self addSubview:scrollView];
        self.scrollView = scrollView;
        
        UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        contentView.backgroundColor = [UIColor clearColor];
        contentView.userInteractionEnabled = NO;
        [self.scrollView addSubview:contentView];
        self.contentView = contentView;

        MultiFoldView *rightFoldView = [[MultiFoldView alloc] initWithFrame:CGRectMake(frame.size.width, 0, frame.size.width, frame.size.height) foldDirection:FoldDirectionHorizontalRightToLeft folds:folds pullFactor:0.9];
        self.rightFoldView = rightFoldView;
        self.rightFoldView.delegate = self;
        self.rightFoldView.userInteractionEnabled = NO;
        [self.contentView addSubview:self.rightFoldView];

    }
    return self;
}

- (void)reloadData
{
    int numberOfPages = [self.datasource numbeOfItemsInPaperFoldGalleryView:self];
    CGSize contentSize = CGSizeMake(self.frame.size.width*numberOfPages, self.frame.size.height);
    [self.scrollView setContentSize:contentSize];
    
    UIView *rightPageContentView = [self.delegate paperFoldGalleryView:self viewAtPageNumber:self.pageNumber];
    [self.rightFoldView setContent:rightPageContentView];
}

- (float)displacementOfMultiFoldView:(id)multiFoldView
{
    CGPoint offset = self.scrollView.contentOffset;
    float x_offset = -1*(offset.x - self.scrollView.frame.size.width*self.pageNumber);
    return x_offset;
}

#pragma mark scroll view delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGPoint offset = scrollView.contentOffset;
    float x_offset = -1*(offset.x - scrollView.frame.size.width*self.pageNumber);
    [self.rightFoldView unfoldWithParentOffset:x_offset];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    self.pageNumber = scrollView.contentOffset.x/scrollView.frame.size.width;
    
    CGRect contentViewFrame = [self.contentView frame];
    contentViewFrame.origin.x = scrollView.frame.size.width*self.pageNumber;
    [self.contentView setFrame:contentViewFrame];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{

}

@end
