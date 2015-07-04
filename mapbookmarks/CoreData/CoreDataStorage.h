//
//  CoreDataStorage.h
//  mapbookmarks
//
//  Created by Коля on 04.07.15.
//  Copyright (c) 2015 Mykola Prokopiev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@class Bookmark;

@interface CoreDataStorage : NSObject

+ (CoreDataStorage*)sharedStorage;

- (void)createBookmarkNamed:(NSString *)name withLocation:(CLLocationCoordinate2D)location;

- (NSArray *)getAllBookmarks;

@end
