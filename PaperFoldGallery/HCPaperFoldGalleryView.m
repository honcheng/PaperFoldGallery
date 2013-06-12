/**
 * Copyright (c) 2013 Muh Hon Cheng
 * Created by honcheng on 4th February 2013.
 *
 * Permission is hereby granted, free of charge, to any person obtaining
 * a copy of this software and associated documentation files (the
 * "Software"), to deal in the Software without restriction, including
 * without limitation the rights to use, copy, modify, merge, publish,
 * distribute, sublicense, and/or sell copies of the Software, and to
 * permit persons to whom the Software is furnished to do so, subject
 * to the following conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT
 * WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
 * INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR
 * PURPOSE AND NONINFRINGEMENT. IN NO EVENT
 * SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 * LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
 * TORT OR OTHERWISE, ARISING FROM, OUT OF OR
 * IN CONNECTION WITH THE SOFTWARE OR
 * THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 *
 * @author 		Muh Hon Cheng <honcheng@gmail.com>
 * @copyright	2013	Muh Hon Cheng
 * @version
 *
 */


#import "HCPaperFoldGalleryView.h"

@interface HCPaperFoldGalleryView()
@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic, weak) HCPaperFoldGalleyMultiFoldView *centerFoldView;
@property (nonatomic, weak) HCPaperFoldGalleyMultiFoldView *rightFoldView;
@property (nonatomic, weak) UIView *contentView;
@property (nonatomic, strong) NSTimer *animationTimer;
@property (nonatomic, strong) NSMutableSet *recycledPages, *visiblePages;
@property (nonatomic, strong) NSMutableArray *cachedImages;
@property (nonatomic, assign) BOOL isTransitioning;
/**
 * isBouncing - if YES, the view is animating to bounce slightly
 * hasBouncingAnimatingStarted - set to YES when scrollViewDidScroll is called the first time
 */
@property (nonatomic, assign) BOOL isBouncing, hasBouncingAnimatingStarted;
/**
 * isAnimating 
 * to setPageNumber:animated:
 */
@property (nonatomic, assign) BOOL isAnimating;
@property (nonatomic, assign) CGPoint lastTrackingPoint;
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
        self.centerFoldView.hidden = YES;

        HCPaperFoldGalleyMultiFoldView *rightFoldView = [[HCPaperFoldGalleyMultiFoldView alloc] initWithFrame:CGRectMake(frame.size.width, 0, frame.size.width, frame.size.height) foldDirection:FoldDirectionHorizontalRightToLeft folds:folds pullFactor:0.9];
        self.rightFoldView = rightFoldView;
        self.rightFoldView.delegate = self;
        self.rightFoldView.userInteractionEnabled = NO;
        [self.contentView addSubview:self.rightFoldView];
        self.rightFoldView.backgroundColor = self.backgroundColor;
        self.rightFoldView.hidden = YES;
    }
    return self;
}

- (void)reloadData
{
    _cachedImages = nil;
    
//    for (UIView *view in self.scrollView.subviews)
//    {
//        if ([view isKindOfClass:[HCPaperFoldGalleryCellView class]])
//        {
//            [self.recycledPages addObject:view];
//            [view removeFromSuperview];
//        }
//    }
    
    int numberOfPages = [self.datasource numbeOfItemsInPaperFoldGalleryView:self];
    CGSize contentSize = CGSizeMake(self.frame.size.width*numberOfPages, self.frame.size.height);
    [self.scrollView setContentSize:contentSize];
    
    
    
//    UIView *centerPageContentView = [self.delegate paperFoldGalleryView:self viewAtPageNumber:self.pageNumber];
    UIView *centerPageContentView = [self viewAtPageNumber:self.pageNumber];
    [self.centerFoldView setContent:centerPageContentView];
    [self.centerFoldView unfoldWithParentOffset:-self.frame.size.width];
    
//    UIView *rightPageContentView = [self.delegate paperFoldGalleryView:self viewAtPageNumber:self.pageNumber+1];
    UIView *rightPageContentView = [self viewAtPageNumber:self.pageNumber+1];
    [self.rightFoldView setContent:rightPageContentView];
    
    [self tilePages];
    
    [self.scrollView scrollRectToVisible:CGRectMake(self.pageNumber*self.scrollView.frame.size.width,0,10,10) animated:NO];
}

- (void)bouncesToHintNextPage
{
    if (![self.scrollView isTracking] && self.pageNumber==0 && !self.isTransitioning)
    {
        _isBouncing = YES;
        
        CGPoint offset = [self.scrollView contentOffset];
        offset.x += PAPERFOLD_GALLERY_VIEW_BOUNCE_DISTANCE;
        [self.scrollView setContentOffset:offset animated:YES];
    }
    
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
			[self.visiblePages addObject:page];
		}
        else
        {
            HCPaperFoldGalleryCellView *page = (HCPaperFoldGalleryCellView*)[self.scrollView viewWithTag:(TAG_PAGE+index)];
            [page setTag:TAG_PAGE+index];
            // this page may not exists after reloadData is called
//            if (!page)
//            {
//                HCPaperFoldGalleryCellView *page = [self.delegate paperFoldGalleryView:self viewAtPageNumber:index];
//                int x = self.frame.size.width*index;
//                CGRect pageFrame = CGRectMake(x,0,self.scrollView.frame.size.width,self.scrollView.frame.size.height);
//                
//                [page setFrame:pageFrame];
//                [page setTag:TAG_PAGE+index];
//                [page setPageNumber:index];
//                
//                [self.scrollView insertSubview:page belowSubview:self.contentView];
//                [self.visiblePages addObject:page];
//            }
//            else [page setTag:TAG_PAGE+index];
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
    HCPaperFoldGalleryCellView *view = (HCPaperFoldGalleryCellView*)[self.scrollView viewWithTag:TAG_PAGE+pageNumber];
    if (!view)
    {
        view = [self.delegate paperFoldGalleryView:self viewAtPageNumber:pageNumber];
    }

    return view;
}

- (BOOL)isDisplayingPageForIndex:(int)index
{
    BOOL isDisplayingPage = NO;
	for (HCPaperFoldGalleryCellView *page in self.visiblePages)
	{
		if (page.pageNumber==index)
        {
            isDisplayingPage = YES;
            break;
        }
	}
	return isDisplayingPage;
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
//        HCPaperFoldGalleryCellView *page = [self.delegate paperFoldGalleryView:self viewAtPageNumber:self.pageNumber];
        HCPaperFoldGalleryCellView *page = [self viewAtPageNumber:self.pageNumber];
        [page setTag:TAG_PAGE+self.pageNumber];
        int x = self.frame.size.width*self.pageNumber;
        CGRect pageFrame = CGRectMake(x,0,self.scrollView.frame.size.width,self.scrollView.frame.size.height);
        [page setFrame:pageFrame];
        return page;
    }
    else if (foldView==self.rightFoldView)
    {
//        HCPaperFoldGalleryCellView *page = [self.delegate paperFoldGalleryView:self viewAtPageNumber:self.pageNumber+1];
        HCPaperFoldGalleryCellView *page = [self viewAtPageNumber:self.pageNumber+1];
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
    if (_isBouncing)
    {
        if (!_hasBouncingAnimatingStarted)
        {
            _hasBouncingAnimatingStarted = YES;
            _isTransitioning = YES;
            
            // move right, folding
            int n_pages_on_left = floor(scrollView.contentOffset.x / scrollView.frame.size.width);
            float distance = scrollView.contentOffset.x - n_pages_on_left*scrollView.frame.size.width;
            if ([self.delegate respondsToSelector:@selector(paperFoldGalleryView:willFoldToPageNumber:foldDistance:)])
            {
                [self.delegate paperFoldGalleryView:self willFoldToPageNumber:n_pages_on_left foldDistance:distance];
            }
        }
        
    }
    else if ([self.delegate respondsToSelector:@selector(paperFoldGalleryView:willUnfoldToPageNumber:unfoldDistance:)] ||
        [self.delegate respondsToSelector:@selector(paperFoldGalleryView:willFoldToPageNumber:foldDistance:)])
    {
        if (!self.isTransitioning && !scrollView.isTracking)
        {
            self.isTransitioning = YES;
            if( (scrollView.contentOffset.x - self.lastTrackingPoint.x > 0)   ||
               (scrollView.contentOffset.x <0 && self.lastTrackingPoint.x < 0) )
            {
                // move left, unfolding
                int n_pages_on_left = floor(scrollView.contentOffset.x / scrollView.frame.size.width);
                float distance = scrollView.frame.size.width - (scrollView.contentOffset.x - n_pages_on_left*scrollView.frame.size.width);
                if ([self.delegate respondsToSelector:@selector(paperFoldGalleryView:willUnfoldToPageNumber:unfoldDistance:)])
                {
                    [self.delegate paperFoldGalleryView:self willUnfoldToPageNumber:n_pages_on_left+1 unfoldDistance:distance];
                }
                else
                {
                    
                }
            }
            else if( (scrollView.contentOffset.x - self.lastTrackingPoint.x < 0))
            {
                // move right, folding
                int n_pages_on_left = floor(scrollView.contentOffset.x / scrollView.frame.size.width);
                float distance = scrollView.contentOffset.x - n_pages_on_left*scrollView.frame.size.width;
                if ([self.delegate respondsToSelector:@selector(paperFoldGalleryView:willFoldToPageNumber:foldDistance:)])
                {
                    [self.delegate paperFoldGalleryView:self willFoldToPageNumber:n_pages_on_left foldDistance:distance];
                }
            }
        }
        else
        {
            self.lastTrackingPoint = scrollView.contentOffset;
        }
    }
    
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
    if (_isBouncing)
    {
        _isBouncing = NO;
        _hasBouncingAnimatingStarted = NO;
        CGPoint offset = [self.scrollView contentOffset];
        offset.x -= PAPERFOLD_GALLERY_VIEW_BOUNCE_DISTANCE;
        [self.scrollView setContentOffset:offset animated:YES];
        return;
    }
    
    _isTransitioning = NO;
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

//    HCPaperFoldGalleryCellView *page = [self.delegate paperFoldGalleryView:self viewAtPageNumber:self.pageNumber+1];
    HCPaperFoldGalleryCellView *page = [self viewAtPageNumber:self.pageNumber+1];
    [page setHidden:YES];
    
}

- (void)setPageNumber:(int)pageNumber
{
    [self setPageNumber:pageNumber animated:NO];
}

- (void)setPageNumber:(int)pageNumber animated:(BOOL)animated
{
    if (!_isAnimating)
    {
        _isAnimating = YES;
//        self.userInteractionEnabled = NO;
        __weak HCPaperFoldGalleryView *weakSelf = self;
        [self setPageNumber:pageNumber animated:animated completed:^{
            double delayInSeconds = 0.2;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                weakSelf.isAnimating = NO;
//                weakSelf.userInteractionEnabled = YES;
            });
           
        }];
    }
}

- (void)setPageNumber:(int)pageNumber animated:(BOOL)animated completed:(void(^)())block
{
    self.scrollCompletion = block;
    [self scrollViewWillBeginDragging:self.scrollView];
    
    [self.scrollView scrollRectToVisible:CGRectMake(self.scrollView.frame.size.width*pageNumber, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height) animated:animated];
    double delayInSeconds = 0.35;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        self.isTransitioning = NO;
    });
    
    if (!animated)
    {
        _pageNumber = pageNumber;
        [self scrollViewDidEndDecelerating:self.scrollView];
        self.lastTrackingPoint = CGPointMake(self.scrollView.frame.size.width*_pageNumber,0);
    }
}

@end
