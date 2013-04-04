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
@property (nonatomic, weak) HCPaperFoldGalleyMultiFoldView *centerFoldView;
@property (nonatomic, weak) HCPaperFoldGalleyMultiFoldView *rightFoldView;
@property (nonatomic, weak) UIView *contentView;
@property (nonatomic, strong) NSTimer *animationTimer;
@property (nonatomic, strong) NSMutableSet *recycledPages, *visiblePages;
@property (nonatomic, strong) NSMutableArray *cachedImages;
@property (nonatomic, copy) void (^scrollCompletion)();
- (void)tilePages;
@end

@implementation HCPaperFoldGalleryView

- (id)initWithFrame:(CGRect)frame folds:(int)folds
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor blackColor];
        
        _recycledPages = [NSMutableSet set];
        _visiblePages = [NSMutableSet set];
        
        UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        scrollView.pagingEnabled = YES;
        scrollView.delegate = self;
        scrollView.scrollsToTop = NO;
        scrollView.showsHorizontalScrollIndicator = NO;
        [self addSubview:scrollView];
        self.scrollView = scrollView;
        
        UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        contentView.backgroundColor = [UIColor clearColor];
        contentView.userInteractionEnabled = NO;
        [self.scrollView addSubview:contentView];
        self.contentView = contentView;
        
        HCPaperFoldGalleyMultiFoldView *centerFoldView = [[HCPaperFoldGalleyMultiFoldView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height) foldDirection:FoldDirectionHorizontalRightToLeft folds:folds pullFactor:0.9];
        self.centerFoldView = centerFoldView;
        self.centerFoldView.delegate = self;
        self.centerFoldView.userInteractionEnabled = NO;
        [self.contentView addSubview:self.centerFoldView];
        self.centerFoldView.backgroundColor = self.backgroundColor;

        HCPaperFoldGalleyMultiFoldView *rightFoldView = [[HCPaperFoldGalleyMultiFoldView alloc] initWithFrame:CGRectMake(frame.size.width, 0, frame.size.width, frame.size.height) foldDirection:FoldDirectionHorizontalRightToLeft folds:folds pullFactor:0.9];
        self.rightFoldView = rightFoldView;
        self.rightFoldView.delegate = self;
        self.rightFoldView.userInteractionEnabled = NO;
        [self.contentView addSubview:self.rightFoldView];
        self.rightFoldView.backgroundColor = self.backgroundColor;
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
    
    [self tilePages];
    [self.scrollView scrollRectToVisible:CGRectMake(self.pageNumber*self.scrollView.frame.size.width,0,10,10) animated:NO];
}

#pragma mark scroll view data

#define TAG_PAGE 101

- (void)tilePages
{
    int numberOfItems = [self.datasource numbeOfItemsInPaperFoldGalleryView:self];
    CGRect visibleBounds = [self.scrollView bounds];
	int firstNeededPageIndex = floorf(CGRectGetMinX(visibleBounds) / CGRectGetWidth(visibleBounds));
	int lastNeededPageIndex = floorf((CGRectGetMaxX(visibleBounds)-1) / CGRectGetWidth(visibleBounds));
	firstNeededPageIndex = MAX(firstNeededPageIndex,0);
	lastNeededPageIndex = MIN(lastNeededPageIndex, numberOfItems-1);
    
    for (HCPaperFoldGalleryCellView *page in self.visiblePages)
	{
		if (page.pageNumber < firstNeededPageIndex || page.pageNumber > lastNeededPageIndex)
		{
			[self.recycledPages addObject:page];
            [page viewDidDisappear];
			[page removeFromSuperview];
		}
	}
	[self.visiblePages minusSet:self.recycledPages];
    
    for (int index=firstNeededPageIndex; index<=lastNeededPageIndex; index++)
	{
		if (![self isDisplayingPageForIndex:index])
		{
			HCPaperFoldGalleryCellView *page = [self.delegate paperFoldGalleryView:self viewAtPageNumber:index];
            int x = self.frame.size.width*index;
			CGRect pageFrame = CGRectMake(x,0,self.scrollView.frame.size.width,self.scrollView.frame.size.height);

            [page setFrame:pageFrame];
            [page setTag:TAG_PAGE+index];
			[page setPageNumber:index];

            [self.scrollView insertSubview:page belowSubview:self.contentView];
			//[self.scrollView addSubview:page];
			[self.visiblePages addObject:page];
		}
        else
        {
            HCPaperFoldGalleryCellView *page = (HCPaperFoldGalleryCellView*)[self.scrollView viewWithTag:(TAG_PAGE+index)];
            [page setTag:TAG_PAGE+index];
        }
	}
    if (numberOfItems==1)
    {
        [self.scrollView setContentSize:CGSizeMake(self.scrollView.frame.size.width+1,self.scrollView.frame.size.height)];
    }
    else
    {
        [self.scrollView setContentSize:CGSizeMake(self.scrollView.frame.size.width*numberOfItems,self.scrollView.frame.size.height)];
    }
}

- (HCPaperFoldGalleryCellView*)viewAtPageNumber:(int)pageNumber
{
    return (HCPaperFoldGalleryCellView*)[self.scrollView viewWithTag:TAG_PAGE+pageNumber];
}

- (BOOL)isDisplayingPageForIndex:(int)index
{
	for (HCPaperFoldGalleryCellView *page in self.visiblePages)
	{
		if (page.pageNumber==index) return YES;
	}
	return NO;
}

- (HCPaperFoldGalleryCellView*)dequeueReusableCellWithIdentifier:(NSString*)identifier
{
    HCPaperFoldGalleryCellView *page = nil;
    for (HCPaperFoldGalleryCellView *view in self.recycledPages)
    {
        if ([view.identifier isEqualToString:identifier])
        {
            page = view;
            break;
        }
    }
    if (page) [self.recycledPages removeObject:page];
    return page;
}

#pragma mark MultiFoldView delegate

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

- (HCPaperFoldGalleryCellView*)viewForMultiFoldView:(HCPaperFoldGalleyMultiFoldView*)foldView
{
    if (foldView==self.centerFoldView)
    {
        HCPaperFoldGalleryCellView *page = [self.delegate paperFoldGalleryView:self viewAtPageNumber:self.pageNumber];
        [page setTag:TAG_PAGE+self.pageNumber];
        int x = self.frame.size.width*self.pageNumber;
        CGRect pageFrame = CGRectMake(x,0,self.scrollView.frame.size.width,self.scrollView.frame.size.height);
        [page setFrame:pageFrame];
        return page;
    }
    else if (foldView==self.rightFoldView)
    {
        HCPaperFoldGalleryCellView *page = [self.delegate paperFoldGalleryView:self viewAtPageNumber:self.pageNumber+1];
        [page setTag:TAG_PAGE+self.pageNumber+1];
        int x = self.frame.size.width*(self.pageNumber+1);
        CGRect pageFrame = CGRectMake(x,0,self.scrollView.frame.size.width,self.scrollView.frame.size.height);
        [page setFrame:pageFrame];
        return page;
    }
    else return nil;
}

- (UIImage*)imageForMultiFoldView:(HCPaperFoldGalleyMultiFoldView*)foldView
{
    UIImage *image = nil;
    if ([self.datasource respondsToSelector:@selector(paperFoldGalleryView:imageAtPageNumber:)])
    {
        if (foldView==self.centerFoldView)
            image = [self.datasource paperFoldGalleryView:self imageAtPageNumber:self.pageNumber];
        else if (foldView==self.rightFoldView)
            image = [self.datasource paperFoldGalleryView:self imageAtPageNumber:self.pageNumber+1];
    }
    
    if (image) return image;
    else
    {
        if (self.useCacheImages)
        {
            if (foldView==self.centerFoldView)
            {
                if (self.pageNumber<[self.cachedImages count])
                {
                    return self.cachedImages[self.pageNumber];
                }
                else return nil;
            }
            else if (foldView==self.rightFoldView)
            {
                if (self.pageNumber+1<[self.cachedImages count])
                {
                    return self.cachedImages[self.pageNumber+1];
                }
                else return nil;
            }
            else return nil;
        }
        else return nil;
    }
    
    
}

- (void)multiFoldView:(HCPaperFoldGalleyMultiFoldView*)foldView  cell:(HCPaperFoldGalleryCellView *)cell didGeneratedScreenshot:(UIImage *)screenshot 
{
    if (!_cachedImages) _cachedImages = [NSMutableArray array];
    
    int pageNumber = [cell tag] - TAG_PAGE;
    if (pageNumber<[self.cachedImages count])
    {
        self.cachedImages[pageNumber] = screenshot;
    }
    else
    {
        if (pageNumber==[self.cachedImages count])
        {
            [self.cachedImages addObject:screenshot];
        }
    }
}

#pragma mark scroll view delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGPoint offset = scrollView.contentOffset;
    float x_offset = -1*(offset.x - scrollView.frame.size.width*self.pageNumber);
    [self.rightFoldView unfoldWithParentOffset:x_offset];
    
    float x_offset2 = -1*(offset.x + self.scrollView.frame.size.width*(1-self.pageNumber));
    [self.centerFoldView unfoldWithParentOffset:x_offset2];
    
    if (x_offset2<=-self.scrollView.frame.size.width) [self.centerFoldView setHidden:YES];
    else [self.centerFoldView setHidden:NO];
    
    if (x_offset<=-2*self.scrollView.frame.size.width) [self.rightFoldView setHidden:YES];
    else [self.rightFoldView setHidden:NO];
    
    [self tilePages];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    [self scrollViewDidEndDecelerating:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!self.allowDraggingBeforeAnimationCompletes)
        [self.scrollView setScrollEnabled:NO];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    _pageNumber = scrollView.contentOffset.x/scrollView.frame.size.width;
    
    CGRect contentViewFrame = [self.contentView frame];
    contentViewFrame.origin.x = scrollView.frame.size.width*self.pageNumber;
    [self.contentView setFrame:contentViewFrame];
    
    [self.centerFoldView unfoldWithParentOffset:-self.frame.size.width];
    [self.centerFoldView setHidden:YES];
    [self.rightFoldView setHidden:YES];
    
//    HCPaperFoldGalleryCellView *page = [self.delegate paperFoldGalleryView:self viewAtPageNumber:self.pageNumber+1];
    HCPaperFoldGalleryCellView *page = [self viewAtPageNumber:self.pageNumber+1];
    [page setHidden:NO];
    
    if (self.scrollCompletion)
    {
        self.scrollCompletion();
        self.scrollCompletion = nil;
    }
    
    [[self viewAtPageNumber:self.pageNumber] viewDidAppear];
    
    if ([self.delegate respondsToSelector:@selector(paperFoldGalleryView:didScrollToPageNumber:)])
    {
        [self.delegate paperFoldGalleryView:self didScrollToPageNumber:self.pageNumber];
    }
    
    if (!self.allowDraggingBeforeAnimationCompletes)
        [self.scrollView setScrollEnabled:YES];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.centerFoldView setHidden:NO];
    [self.rightFoldView setHidden:NO];
    
    [self.centerFoldView reloadScreenshot];
    [self.rightFoldView reloadScreenshot];

    HCPaperFoldGalleryCellView *page = [self.delegate paperFoldGalleryView:self viewAtPageNumber:self.pageNumber+1];
    [page setHidden:YES];
    
}

- (void)setPageNumber:(int)pageNumber
{
    [self setPageNumber:pageNumber animated:NO];
}

- (void)setPageNumber:(int)pageNumber animated:(BOOL)animated
{
    [self setPageNumber:pageNumber animated:animated completed:^{
        
    }];
}

- (void)setPageNumber:(int)pageNumber animated:(BOOL)animated completed:(void(^)())block
{
    self.scrollCompletion = block;
    [self scrollViewWillBeginDragging:self.scrollView];
    
    [self.scrollView scrollRectToVisible:CGRectMake(self.scrollView.frame.size.width*pageNumber, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height) animated:animated];
}

@end
