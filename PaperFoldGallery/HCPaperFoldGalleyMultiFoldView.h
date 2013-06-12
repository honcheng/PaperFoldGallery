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
#import "MultiFoldView.h"
#import "HCPaperFoldGalleryViewDelegate.h"
@class HCPaperFoldGalleryCellView;
@class HCPaperFoldGalleyMultiFoldView;

@protocol HCPaperFoldGalleyMultiFoldViewDelegate <MultiFoldViewDelegate>
- (HCPaperFoldGalleryCellView*)viewForMultiFoldView:(HCPaperFoldGalleyMultiFoldView*)foldView;
@optional
/**
 * Optional method, used images as screenshot instead of taking new screenshots
 * Faster
 */
- (UIImage*)imageForMultiFoldView:(HCPaperFoldGalleyMultiFoldView*)foldView;
/**
 * Optional method, sends generated screenshots to its delegate
 * Used for caching
 */
- (void)multiFoldView:(HCPaperFoldGalleyMultiFoldView*)foldView cell:(HCPaperFoldGalleryCellView*)cell didGeneratedScreenshot:(UIImage*)screenshot;
@end

@interface HCPaperFoldGalleyMultiFoldView : MultiFoldView
@property (nonatomic, weak) id<HCPaperFoldGalleyMultiFoldViewDelegate> delegate;
- (void)reloadScreenshot;
@end


