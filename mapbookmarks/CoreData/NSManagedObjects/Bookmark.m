//
//  Bookmark.m
//  mapbookmarks
//
//  Created by Коля on 04.07.15.
//  Copyright (c) 2015 Mykola Prokopiev. All rights reserved.
//

#import "Bookmark.h"


@implementation Bookmark

@dynamic name;
@dynamic location;

- (CLLocationCoordinate2D)coordinate
{
    return self.location.coordinate;
}

- (NSString *)title
{
    return self.name;
}

@end
