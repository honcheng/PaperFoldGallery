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


#import "HCPaperFoldGalleyMultiFoldView.h"
#import "HCPaperFoldGalleryView.h"
#import "UIView+Screenshot.h"

@implementation HCPaperFoldGalleyMultiFoldView

- (void)drawScreenshotOnFolds
{
    if ([self.delegate respondsToSelector:@selector(imageForMultiFoldView:)])
    {
        UIImage *image = [self.delegate imageForMultiFoldView:self];
        if (!image)
        {
            HCPaperFoldGalleryCellView *cell = [self.delegate viewForMultiFoldView:self];
            image = [cell screenshotWithOptimization:NO];
            if ([self.delegate respondsToSelector:@selector(multiFoldView:cell:didGeneratedScreenshot:)])
            {
                [self.delegate multiFoldView:self cell:cell didGeneratedScreenshot:image];
            }
        }
        [self setScreenshotImage:image];
    }
    else if ([self.delegate respondsToSelector:@selector(viewForMultiFoldView:)])
    {
        HCPaperFoldGalleryCellView *cell = [self.delegate viewForMultiFoldView:self];
        UIImage *image = [cell screenshotWithOptimization:NO];
        if ([self.delegate respondsToSelector:@selector(multiFoldView:cell:didGeneratedScreenshot:)])
        {
            [self.delegate multiFoldView:self cell:cell didGeneratedScreenshot:image];
        }
        [self setScreenshotImage:image];
    }
    else
    {
        NSLog(@"Implement either viewForMultiFoldView or imageForMultiFoldView");
    }
}

- (void)reloadScreenshot
{
    [self drawScreenshotOnFolds];
}

- (void)foldDidOpened
{
    
}

@end
