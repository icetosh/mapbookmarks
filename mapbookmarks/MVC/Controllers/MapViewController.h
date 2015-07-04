//
//  MapViewController.h
//  mapbookmarks
//
//  Created by Коля on 04.07.15.
//  Copyright (c) 2015 Mykola Prokopiev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

typedef NS_ENUM(NSInteger, MapMode) {
    MapModeNormal,
    MapModeRouting
};

@interface MapViewController : UIViewController

@property (assign, nonatomic) MapMode mapMode;

@end
