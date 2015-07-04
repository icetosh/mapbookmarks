//
//  FoursquareNearbyPlacesRequest.h
//  mapbookmarks
//
//  Created by Коля on 05.07.15.
//  Copyright (c) 2015 Mykola Prokopiev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>

typedef void (^SuccessBlock)(NSArray *venues);
typedef void (^FailureBlock)(NSError *error);

@class Bookmark;

@interface FoursquareNearbyPlacesRequest : NSObject

+ (void)getNearbyPlacesForBookmark:(Bookmark *)bookmark success:(SuccessBlock)success failure:(FailureBlock)failure;

@end
