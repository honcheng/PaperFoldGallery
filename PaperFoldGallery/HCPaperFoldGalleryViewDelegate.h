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


#import <UIKit/UIKit.h>
#import "HCPaperFoldGalleyMultiFoldView.h"
@class HCPaperFoldGalleryView;
@class HCPaperFoldGalleryCellView;
@class HCPaperFoldGalleyMultiFoldView;

@protocol HCPaperFoldGalleryViewDelegate <NSObject>
- (HCPaperFoldGalleryCellView*)paperFoldGalleryView:(HCPaperFoldGalleryView*)galleryView viewAtPageNumber:(int)pageNumber;
@optional
- (void)paperFoldGalleryView:(HCPaperFoldGalleryView *)galleryView didScrollToPageNumber:(int)pageNumber;
- (void)paperFoldGalleryView:(HCPaperFoldGalleryView *)galleryView willFoldToPageNumber:(int)pageNumber foldDistance:(float)foldDistance;
- (void)paperFoldGalleryView:(HCPaperFoldGalleryView *)galleryView willUnfoldToPageNumber:(int)pageNumber unfoldDistance:(float)unfoldDistance;
@end

@protocol HCPaperFoldGalleryViewDatasource <NSObject>
- (NSInteger)numbeOfItemsInPaperFoldGalleryView:(HCPaperFoldGalleryView*)galleryView;
@optional
- (UIImage*)paperFoldGalleryView:(HCPaperFoldGalleryView*)galleryView imageAtPageNumber:(int)pageNumber;
@end
