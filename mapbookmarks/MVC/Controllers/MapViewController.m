//
//  MapViewController.m
//  mapbookmarks
//
//  Created by Коля on 04.07.15.
//  Copyright (c) 2015 Mykola Prokopiev. All rights reserved.
//

#import "MapViewController.h"
#import "Constants.h"
#import "CoreDataManager.h"
#import "CoreDataStorage.h"
#import "Bookmark.h"

@interface MapViewController () <MKMapViewDelegate, CLLocationManagerDelegate, UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) NSManagedObjectContext* managedObjectContext;

@end

@implementation MapViewController

#pragma mark - Accessors

- (NSManagedObjectContext*) managedObjectContext {
    if (!_managedObjectContext) {
        _managedObjectContext = [[CoreDataManager sharedManager] managedObjectContext];
    }
    return _managedObjectContext;
}

#pragma mark - Initialization

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self getBookmarks];
    
    [self subscribeToNotifications];
    
    [self setupLocationManager];
}

- (void)subscribeToNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDataChanges:) name:NSManagedObjectContextObjectsDidChangeNotification object:_managedObjectContext];
}

- (void)getBookmarks {
    [self.mapView addAnnotations:[[CoreDataStorage sharedStorage] getAllBookmarks]];
}

- (void)setupLocationManager {
    self.locationManager = [[CLLocationManager alloc] init];
    
    self.locationManager.delegate = self;
    
    if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
        [self.locationManager requestAlwaysAuthorization];
    }
    
    [self.locationManager startUpdatingLocation];
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status == kCLAuthorizationStatusAuthorizedAlways || status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        self.mapView.showsUserLocation = YES;
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    MKCoordinateSpan span = MKCoordinateSpanMake(.005f, .005f);
    CLLocationCoordinate2D location = self.mapView.userLocation.location.coordinate;
    MKCoordinateRegion region = MKCoordinateRegionMake(location, span);

    [self.mapView setRegion:region animated:YES];
}

#pragma mark - MKMapViewDelegate

#pragma mark - UIGestureRecognizer

- (IBAction)longTap:(UILongPressGestureRecognizer *)recognized {
    
    if (recognized.state != UIGestureRecognizerStateBegan) {
        return;
    }
    
    CGPoint touchPoint = [recognized locationInView:self.mapView];
    CLLocationCoordinate2D touchCoordinates = [self.mapView convertPoint:touchPoint toCoordinateFromView:self.mapView];
    [[CoreDataStorage sharedStorage] createBookmarkNamed:@"Unnamed" withLocation:touchCoordinates];
}

#pragma mark - NSManagedObjectContext

- (void)handleDataChanges:(NSNotification *)note {
    NSSet *deletedObjects = [[note userInfo] objectForKey:NSDeletedObjectsKey];
    NSSet *insertedObjects = [[note userInfo] objectForKey:NSInsertedObjectsKey];
    
    if (insertedObjects.count) {
        [self.mapView addAnnotations:[insertedObjects allObjects]];
    }
    
    if (deletedObjects.count) {
        [self.mapView removeAnnotations:[deletedObjects allObjects]];
    }
}

@end
