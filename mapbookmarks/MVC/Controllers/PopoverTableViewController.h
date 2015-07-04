//
//  PopoverTableViewController.h
//  mapbookmarks
//
//  Created by Коля on 04.07.15.
//  Copyright (c) 2015 Mykola Prokopiev. All rights reserved.
//

#import "BaseTableViewController.h"

@class Bookmark;
@protocol BookmarksPopoverDelegate;

@interface PopoverTableViewController : BaseTableViewController

@property (weak, nonatomic) id <BookmarksPopoverDelegate> delegate;

@end




@protocol BookmarksPopoverDelegate

@required

- (void)popoverTableViewController:(PopoverTableViewController *)popover didSelectBookmark:(Bookmark *)bookmark;

@end
