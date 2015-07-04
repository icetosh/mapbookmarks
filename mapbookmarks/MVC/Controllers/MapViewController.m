//
//  MapViewController.m
//  mapbookmarks
//
//  Created by Коля on 04.07.15.
//  Copyright (c) 2015 Mykola Prokopiev. All rights reserved.
//

#import "MapViewController.h"
#import "CoreDataManager.h"
#import "CoreDataStorage.h"
#import "Bookmark.h"
#import "BookmarkDetailViewController.h"
#import "PopoverTableViewController.h"
#import "WYStoryboardPopoverSegue.h"
#import <SAMHUDView/SAMHUDView.h>

@protocol BookmarksPopoverDelegate;

@interface MapViewController () <MKMapViewDelegate, CLLocationManagerDelegate, UIGestureRecognizerDelegate, WYPopoverControllerDelegate, BookmarksPopoverDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) NSManagedObjectContext* managedObjectContext;
@property (strong, nonatomic) Bookmark *selectedBookmark;
@property (strong, nonatomic) WYPopoverController *bookmarksPopover;
@property (strong, nonatomic) MKDirections *currentRouteDirections;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *barButtonRoute;

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
    
    [self addBookmarksAnnotations];
    
    [self subscribeToNotifications];
    
    [self setupLocationManager];
}

- (void)subscribeToNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDataChanges:) name:NSManagedObjectContextObjectsDidChangeNotification object:_managedObjectContext];
}

- (void)addBookmarksAnnotations {
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

-(MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
    MKPolylineRenderer  *routeLineRenderer = [[MKPolylineRenderer alloc] initWithOverlay:overlay];
    routeLineRenderer.strokeColor = [UIColor blueColor];
    routeLineRenderer.lineWidth = 5.f;
    return routeLineRenderer;
}

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
        [mapView deselectAnnotation:view.annotation animated:YES];
        [self performSegueWithIdentifier:@"segueToBookmarkDetailViewController" sender:self];
    }
}

#pragma mark - UIGestureRecognizer

- (IBAction)longTap:(UILongPressGestureRecognizer *)recognized {
    
    if (self.mapMode == MapModeRouting) {
        self.mapMode = MapModeNormal;
    }
    
    if (recognized.state != UIGestureRecognizerStateBegan) {
        return;
    }
    
    CGPoint touchPoint = [recognized locationInView:self.mapView];
    CLLocationCoordinate2D touchCoordinates = [self.mapView convertPoint:touchPoint toCoordinateFromView:self.mapView];
    Bookmark *bookmark = [[CoreDataStorage sharedStorage] createBookmarkNamed:@"Unnamed" withLocation:touchCoordinates];
    
    [self.mapView selectAnnotation:bookmark animated:YES];
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
    switch (mapMode) {
        case MapModeNormal:
            [self.mapView removeOverlays:self.mapView.overlays];
            [self.mapView removeAnnotations:self.mapView.annotations];
            [self addBookmarksAnnotations];
            [self.barButtonRoute setTitle:@"Route"];
            break;
            
        case MapModeRouting:
            [self.barButtonRoute setTitle:@"Clear route"];
            break;
            
        default:
            break;
    }
    
    _mapMode = mapMode;
}

#pragma mark - BookmarksPopoverDelegate

- (void)popoverTableViewController:(PopoverTableViewController *)popover didSelectBookmark:(Bookmark *)bookmark {
    [self.bookmarksPopover dismissPopoverAnimated:YES];
    [self getRouteToBookmark:bookmark];
}

#pragma mark - Routes

- (void)getRouteToBookmark:(Bookmark *)bookmark {
    MKDirectionsRequest *directionsRequest = [[MKDirectionsRequest alloc] init];
    MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:bookmark.coordinate addressDictionary:nil];
    
    [directionsRequest setSource:[MKMapItem mapItemForCurrentLocation]];
    [directionsRequest setDestination:[[MKMapItem alloc] initWithPlacemark:placemark]];
    directionsRequest.transportType = MKDirectionsTransportTypeAutomobile;
    MKDirections *directions = [[MKDirections alloc] initWithRequest:directionsRequest];
    
    SAMHUDView *hudView = [[SAMHUDView alloc] initWithTitle:@"Calculating directions..."];
    [hudView show];
    
    [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
        if (!error) {
            [self.mapView removeAnnotations:self.mapView.annotations];
            [self.mapView addAnnotation:bookmark];
            [self drawRoute:response];
            [hudView dismiss];
        } else {
            [hudView dismiss];
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"Unable to calculate route :(" delegate:self cancelButtonTitle:nil otherButtonTitles:@"Okay :(", nil];
            [alertView show];
        }
    }];
}

-(void)drawRoute:(MKDirectionsResponse *)response {
    MKMapRect totalRect = MKMapRectNull;
    for (MKRoute *route in response.routes) {
        [self.mapView addOverlay:route.polyline level:MKOverlayLevelAboveRoads];
        
        MKPolygon *polygon = [MKPolygon polygonWithPoints:route.polyline.points count:route.polyline.pointCount];
        MKMapRect routeRect = [polygon boundingMapRect];
        totalRect = MKMapRectUnion(totalRect, routeRect);
    }
    [self.mapView setVisibleMapRect:totalRect edgePadding:UIEdgeInsetsMake(50, 50, 50, 50) animated:YES];
    self.mapMode = MapModeRouting;
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

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if ([identifier isEqualToString:@"segueToPopoverTableViewController"] && self.mapMode == MapModeRouting) {
        self.mapMode = MapModeNormal;
        return NO;
    }
    
    return YES;
}

- (IBAction)unwindToMapViewController:(UIStoryboardSegue *)segue {
    if ([segue.identifier isEqualToString:@"segueToMapViewControllerCenter"]) {
        BookmarkDetailViewController *controller = segue.sourceViewController;
        self.mapView.centerCoordinate = controller.bookmark.location.coordinate;
        [self.mapView selectAnnotation:controller.bookmark animated:YES];
    } else if ([segue.identifier isEqualToString:@"segueToMapViewControllerRoute"]) {
        BookmarkDetailViewController *controller = segue.sourceViewController;
        [self.mapView removeOverlays:self.mapView.overlays];
        [self getRouteToBookmark:controller.bookmark];
    }
}

@end
