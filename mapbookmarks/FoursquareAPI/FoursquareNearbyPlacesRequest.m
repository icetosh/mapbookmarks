//
//  FoursquareNearbyPlacesRequest.m
//  mapbookmarks
//
//  Created by Коля on 05.07.15.
//  Copyright (c) 2015 Mykola Prokopiev. All rights reserved.
//


#import "FoursquareNearbyPlacesRequest.h"
#import "Bookmark.h"

NSString *const kFoursquareURL          = @"https://api.foursquare.com/v2/venues/search";
NSString *const kFoursquareClientId     = @"TRJPXM1GJZBCLQNIIFNHDNDTYSJRRCISWYMBXY0QI1NYNQXU";
NSString *const kFoursquareClientSecret = @"PQUXLDQTN0PQQ30GOBQDMU3EXWEBQMIRHIN3FRIYLA21KUPW";
NSString *const kFoursquareAPIVersion   = @"20150705";

NSString *const kResponse       = @"response";
NSString *const kVenues         = @"venues";
NSString *const kClientId       = @"client_id";
NSString *const kClientSecret   = @"client_secret";
NSString *const kApiVersion     = @"v";
NSString *const kLocation       = @"ll";

@implementation FoursquareNearbyPlacesRequest

+ (void)getNearbyPlacesForBookmark:(Bookmark *)bookmark success:(SuccessBlock)success failure:(FailureBlock)failure {
    
    NSDictionary *parameters = @{kClientId: kFoursquareClientId,
                             kClientSecret: kFoursquareClientSecret,
                             kApiVersion: kFoursquareAPIVersion,
                             kLocation: [NSString stringWithFormat:@"%f,%f", bookmark.location.coordinate.latitude, bookmark.location.coordinate.longitude]};
    
    NSURLRequest *request = [[AFHTTPRequestSerializer serializer] requestWithMethod:@"GET"
                                                                          URLString:kFoursquareURL
                                                                         parameters:parameters
                                                                              error:nil];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *venues = responseObject[kResponse][kVenues];
        if (!venues.count) {
            UIAlertView *aletrView = [[UIAlertView alloc] initWithTitle:@"" message:@"Could not find nearby places :(" delegate:self cancelButtonTitle:nil otherButtonTitles:@"Okay :(", nil];
            [aletrView show];
        }
        success(responseObject[kResponse][kVenues]);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        UIAlertView *aletrView = [[UIAlertView alloc] initWithTitle:@"Something went wrong :(" message:[error localizedDescription] delegate:self cancelButtonTitle:nil otherButtonTitles:@"Okay :(", nil];
        [aletrView show];
        failure(error);
    }];
    
    [operation start];
}

@end
