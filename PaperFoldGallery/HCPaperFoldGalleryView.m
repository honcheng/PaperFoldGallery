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
@property (nonatomic, weak) MultiFoldView *centerFoldView;
@property (nonatomic, weak) MultiFoldView *rightFoldView;
@property (nonatomic, weak) UIView *contentView;
@property (nonatomic, strong) NSTimer *animationTimer;
@end

@implementation HCPaperFoldGalleryView

- (id)initWithFrame:(CGRect)frame folds:(int)folds
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor blackColor];
        
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
        
        MultiFoldView *centerFoldView = [[MultiFoldView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height) foldDirection:FoldDirectionHorizontalRightToLeft folds:folds pullFactor:0.9];
        self.centerFoldView = centerFoldView;
        self.centerFoldView.delegate = self;
        self.centerFoldView.userInteractionEnabled = NO;
        [self.contentView addSubview:self.centerFoldView];
        

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
    
    UIView *centerPageContentView = [self.delegate paperFoldGalleryView:self viewAtPageNumber:self.pageNumber];
    [self.centerFoldView setContent:centerPageContentView];
    [self.centerFoldView unfoldWithParentOffset:-self.frame.size.width];
    
    UIView *rightPageContentView = [self.delegate paperFoldGalleryView:self viewAtPageNumber:self.pageNumber+1];
    [self.rightFoldView setContent:rightPageContentView];
}

- (float)displacementOfMultiFoldView:(id)multiFoldView
{
    if (multiFoldView==self.rightFoldView)
    {
        CGPoint offset = self.scrollView.contentOffset;
        float x_offset = -1*(offset.x - self.scrollView.frame.size.width*self.pageNumber);
        return x_offset;
    }
    else if (multiFoldView==self.centerFoldView)
    {
        CGPoint offset = self.scrollView.contentOffset;
        float x_offset = -1*(offset.x + self.scrollView.frame.size.width*(1-self.pageNumber));
        return x_offset;
    }
    else return 0;
}

#pragma mark scroll view delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGPoint offset = scrollView.contentOffset;
    float x_offset = -1*(offset.x - scrollView.frame.size.width*self.pageNumber);
    [self.rightFoldView unfoldWithParentOffset:x_offset];
    
    float x_offset2 = -1*(offset.x + self.scrollView.frame.size.width*(1-self.pageNumber));
    [self.centerFoldView unfoldWithParentOffset:x_offset2];
 
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    self.pageNumber = scrollView.contentOffset.x/scrollView.frame.size.width;
    
    CGRect contentViewFrame = [self.contentView frame];
    contentViewFrame.origin.x = scrollView.frame.size.width*self.pageNumber;
    [self.contentView setFrame:contentViewFrame];
    
    [self.centerFoldView unfoldWithParentOffset:-self.frame.size.width];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{

}

@end
