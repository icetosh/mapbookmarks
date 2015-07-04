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
#import "BookmarkDetailViewController.h"
#import "PopoverTableViewController.h"
#import "WYStoryboardPopoverSegue.h"

@protocol BookmarksPopoverDelegate;

@interface MapViewController () <MKMapViewDelegate, CLLocationManagerDelegate, UIGestureRecognizerDelegate, WYPopoverControllerDelegate, BookmarksPopoverDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) NSManagedObjectContext* managedObjectContext;
@property (strong, nonatomic) Bookmark *selectedBookmark;
@property (strong, nonatomic) WYPopoverController *bookmarksPopover;

@end

@implementation MapViewController

#pragma mark - Accessors

- (NSManagedObjectContext*)managedObjectContext {
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
    } else {
        self.mapView.showsUserLocation = NO;
    }
}

#pragma mark - MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)aUserLocation {
    MKCoordinateSpan span = MKCoordinateSpanMake(.005f, .005f);
    CLLocationCoordinate2D location = self.mapView.userLocation.location.coordinate;
    MKCoordinateRegion region = MKCoordinateRegionMake(location, span);
    
    [self.mapView setRegion:region animated:YES];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    static NSString *reuseIdentifier = @"annotationReuseIdentifier";
    
    if([annotation isKindOfClass:[MKUserLocation class]]) {
        return [mapView viewForAnnotation:annotation];
    }
    
    MKPinAnnotationView *annotationView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:reuseIdentifier];
    
    if (!annotationView) {
        annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    }
    
    annotationView.canShowCallout = YES;
    annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    
    return annotationView;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    if([view.annotation isKindOfClass:[Bookmark class]]) {
        self.selectedBookmark = view.annotation;
        [self performSegueWithIdentifier:@"segueToBookmarkDetailViewController" sender:self];
    }
}

#pragma mark - UIGestureRecognizer

- (IBAction)longTap:(UILongPressGestureRecognizer *)recognized {
    
    if (recognized.state != UIGestureRecognizerStateBegan) {
        return;
    }
    
    CGPoint touchPoint = [recognized locationInView:self.mapView];
    CLLocationCoordinate2D touchCoordinates = [self.mapView convertPoint:touchPoint toCoordinateFromView:self.mapView];
    Bookmark *bookmark = [[CoreDataStorage sharedStorage] createBookmarkNamed:@"Unnamed" withLocation:touchCoordinates];
    
    [self.mapView selectAnnotation:bookmark animated:YES];
}

#pragma mark - Actions

- (IBAction)barButtonRouteAction:(UIBarButtonItem *)sender {
    NSLog(@"barButtonRouteAction:");
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

#pragma mark - Setters

-(void)setMapMode:(MapMode)mapMode {
    _mapMode = mapMode;
}

#pragma mark - BookmarksPopoverDelegate

- (void)popoverTableViewController:(PopoverTableViewController *)popover didSelectBookmark:(Bookmark *)bookmark {
    NSLog(@"draw route");
    [self.bookmarksPopover dismissPopoverAnimated:YES];
}


#pragma mark - Segue

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"segueToBookmarkDetailViewController"]) {
        BookmarkDetailViewController *controller = segue.destinationViewController;
        controller.bookmark = self.selectedBookmark;
    } else if ([segue.identifier isEqualToString:@"segueToPopoverTableViewController"]) {
        PopoverTableViewController *destinationViewController = segue.destinationViewController;
        destinationViewController.delegate = self;
        destinationViewController.preferredContentSize = CGSizeMake(self.view.bounds.size.width, 44.f * 6);
        
        WYStoryboardPopoverSegue *popoverSegue = (WYStoryboardPopoverSegue *)segue;
        
        self.bookmarksPopover = [popoverSegue popoverControllerWithSender:sender
                                                 permittedArrowDirections:WYPopoverArrowDirectionAny
                                                                 animated:YES];
        self.bookmarksPopover.delegate = self;
    }
}

- (IBAction)unwindToMapViewController:(UIStoryboardSegue *)segue {
    if ([segue.identifier isEqualToString:@"segueToMapViewControllerCenter"]) {
        BookmarkDetailViewController *controller = segue.sourceViewController;
        self.mapView.centerCoordinate = controller.bookmark.location.coordinate;
        [self.mapView selectAnnotation:controller.bookmark animated:YES];
    } else if ([segue.identifier isEqualToString:@"segueToMapViewControllerRoute"]) {
        NSLog(@"routing mode");
        [self setMapMode:MapModeRouting];
    }
}

@end
