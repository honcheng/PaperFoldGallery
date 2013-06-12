PaperFoldGallery 
================

PaperFoldGallery displays multiple views in a paginated UIScrollView, but uses PaperFold library to animate in the next view. 

<img width=150 src="https://github.com/honcheng/PaperFoldGallery/raw/master/Screenshots/dispatch-1.png"/> <img width=150 src="https://github.com/honcheng/PaperFoldGallery/raw/master/Screenshots/dispatch-2.png"/>

<img width=300 src="https://github.com/honcheng/PaperFoldGallery/raw/master/Screenshots/demo.gif"/>

How it works
-----------

The first level is a paginated UIScrollView that displays views in each page. The second level contains 2 PaperFold views that are folded/unfolded/hidden depending on the scroll view offset. These views show a folded screenshot of the views below it, and are hidden once the UIScrollView snaps to page. 

The subviews can be any UIView subclasses, so it can be static view, or other views like UITableView. 

The library takes a screenshot often to get the state of the view below it. If you are using static views, you can improve the unfolding performance by providing screenshots.

Usage
-----
# HCPaperFoldGalleryView

### initWithFrame:folds:
Initialize the gallery view

    - (id)initWithFrame:(CGRect)frame folds:(int)folds

#### Parameters
##### frame
This value specifies the size of the frame
##### folds
This value specifies number of folds 

### reloadData
Reloads content in the gallery view

    - (void)reloadData

### bouncesToHintNextPage
Bounces the view to the left slightly to show the next fold on the right

    - (void)bouncesToHintNextPage

### setPageNumber:animated:
Changes the current page

   - (void)setPageNumber:(int)pageNumber animated:(BOOL)animated

#### Parameters
##### pageNumber
This value specifies the page number to change to
##### animated
This value specifies whether the page change should be animated 

### setPageNumber:animated:completed:

    - (void)setPageNumber:(int)pageNumber animated:(BOOL)animated completed:(void(^)())block

#### Parameters
##### pageNumber
This value specifies the page number to change to
##### animated
This value specifies whether the page change should be animated 
##### block
This block is called when the animation is complete

# HCPaperFoldGalleryViewDelegate

### paperFoldGalleryView:viewAtPageNumber:
A non-optional method. Ask the delegate for cells at each page.

    - (HCPaperFoldGalleryCellView*)paperFoldGalleryView:(HCPaperFoldGalleryView*)galleryView viewAtPageNumber:(int)pageNumber

#### Parameters
##### galleryView
The gallery view that requests for cell views
##### pageNumber
The page number requested

### paperFoldGalleryView:didScrollToPageNumber:
Notifies the delegate when page changes

    - (void)paperFoldGalleryView:(HCPaperFoldGalleryView *)galleryView didScrollToPageNumber:(int)pageNumber;

#### Parameters
##### galleryView
The gallery view where the page change happens
##### pageNumber
The page number of the new page after scrolling 

# HCPaperFoldGalleryViewDatasource

### numbeOfItemsInPaperFoldGalleryView:
Requests dataSource for number if items to be displayed in the galleyView

    - (NSInteger)numbeOfItemsInPaperFoldGalleryView:(HCPaperFoldGalleryView*)galleryView

#### Parameters
##### galleryView
The gallery view that will display the views

### paperFoldGalleryView:imageAtPageNumber:
An optional method. Requests dataSource for UIImage to be displayed in the views' folds. If nil is returned, the library will take a screenshot automatically each time before folding. If a UIImage is returned, the library will use the image without taking screenshots (for better performance).

    - (UIImage*)paperFoldGalleryView:(HCPaperFoldGalleryView*)galleryView imageAtPageNumber:(int)pageNumber

#### Parameters
##### galleryView
The gallery view that will display the views
##### pageNumber
The page number of the requested UIImage


Requirements
-----------

This project uses ARC. If you are not using ARC in your project, add '-fobjc-arc' as a compiler flag for all the files in this project.
XCode 4.4 is required for auto-synthesis.

Contact
------

[twitter.com/honcheng](http://twitter.com/honcheng)
[honcheng.com](http://honcheng.com)