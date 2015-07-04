//
//  Bookmark.h
//  mapbookmarks
//
//  Created by Коля on 04.07.15.
//  Copyright (c) 2015 Mykola Prokopiev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <MapKit/MapKit.h>

@interface Bookmark : NSManagedObject <MKAnnotation>

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) CLLocation *location;

@end
