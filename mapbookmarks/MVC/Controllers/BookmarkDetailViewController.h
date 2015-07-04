//
//  BookmarkDetailViewController.h
//  mapbookmarks
//
//  Created by Коля on 04.07.15.
//  Copyright (c) 2015 Mykola Prokopiev. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Bookmark;

@interface BookmarkDetailViewController : UIViewController

@property (strong, nonatomic) Bookmark *bookmark;

@end
