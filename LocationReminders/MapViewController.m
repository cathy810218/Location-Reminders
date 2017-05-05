//
//  MapViewController.m
//  LocationReminders
//
//  Created by Cathy Oun on 5/1/17.
//  Copyright © 2017 cathyoun. All rights reserved.
//

#import "MapViewController.h"
#import "LocationCoordinates.h"
#import "AddReminderViewController.h"
#import "LocationController.h"
#import "NotificationKeys.h"
#import <Parse/Parse.h>
#import "ReminderManager.h"
#import "Reminder.h"

@import MapKit;

@interface MapViewController () <MKMapViewDelegate, LocationControllerDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIButton *currentLocationButton;
@property (strong, nonatomic) LocationController *locationController;
@property (strong, nonatomic) MKPointAnnotation *annotationPin;
@property (strong, nonatomic) MKAnnotationView *currentAnnotationView;
@property (strong, nonatomic) NSMutableArray *allReminders;

@end

@implementation MapViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.mapView.showsUserLocation = YES;
    self.mapView.delegate = self;
    [self showAllAnnotationWithOverlays];

    [LocationController shared].delegate = self;
    [[LocationController shared] updateLocation];
    self.allReminders = [[NSMutableArray alloc] init];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleDone target:self action:nil];
    
    UILongPressGestureRecognizer *gesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    [self.mapView addGestureRecognizer:gesture];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reminderSavedToParse:) name:kUpdateReminderNotificationKey object:nil];
}

- (void)reminderSavedToParse:(id)sender
{
    [self showAllAnnotationWithOverlays];
}

- (void)showAllAnnotationWithOverlays
{
    [self.mapView removeOverlays:self.mapView.overlays];
    [self.mapView removeAnnotations:self.mapView.annotations];
    [[ReminderManager shared] fetchAllRemindersWithCompletionHandler:^(NSArray<Reminder *> *reminders) {
        for (Reminder *reminder in reminders) {
            [self dropPinForReminder:reminder];
        }
        self.allReminders = [reminders mutableCopy];
    }];
}

- (void)handleLongPress:(UIGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateBegan) {
        // get the touch point on the map
        CGPoint point = [gesture locationInView:self.mapView];
        // conver it to coordinates
        CLLocationCoordinate2D locationCoordinate = [self.mapView convertPoint:point toCoordinateFromView:self.mapView];
        
        // drop the pin
        [self dropPinWithCoordinate:locationCoordinate];
    }
}

- (void)dropPinForReminder:(Reminder *)reminder
{
    MKPointAnnotation *pointAnnotation = [[MKPointAnnotation alloc] init];
    
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(reminder.geoPoint.latitude, reminder.geoPoint.longitude);
    MKCircle *circle = [MKCircle circleWithCenterCoordinate:coordinate radius:[reminder.radius intValue]];
    circle.title = reminder.locationName;
    pointAnnotation.coordinate = coordinate;
    pointAnnotation.title = reminder.locationName;
    [self.mapView addAnnotation:pointAnnotation];
    [self.mapView addOverlay:circle];
}

- (void)dropPinWithCoordinate:(CLLocationCoordinate2D)coordinate
{
    MKPointAnnotation *pointAnnotation;
    
    BOOL hasAnnotation = NO;
    for (MKPointAnnotation *a in self.mapView.annotations) {
        if ((a.coordinate.latitude == coordinate.latitude) && (a.coordinate.longitude == coordinate.longitude)) {
            pointAnnotation = a;
            hasAnnotation = YES;
            break;
        }
    }
    if (!hasAnnotation) {
        pointAnnotation = [[MKPointAnnotation alloc] init];
        pointAnnotation.coordinate = coordinate;
        pointAnnotation.title = @"Monitor Location";
        [self.mapView addAnnotation:pointAnnotation];
    }
    self.annotationPin = pointAnnotation;
    [self.mapView selectAnnotation:self.annotationPin animated:YES];
}



-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [super prepareForSegue:segue sender:sender];
    if ([segue.identifier isEqualToString:@"AddReminderViewController"]
        && [sender isKindOfClass:[MKAnnotationView class]]) {
        
        MKAnnotationView *view = (MKAnnotationView *)sender;
        AddReminderViewController *addReminderVC = [segue destinationViewController];
        
        addReminderVC.selectedAnnotation  = view.annotation;
        __weak __typeof__(self) weakSelf = self;
        addReminderVC.completion = ^(MKCircle *circle, NSString *name) {
            __strong __typeof__(weakSelf) fakeStrong = weakSelf;
            [fakeStrong.mapView addOverlay:circle];
        };
    }
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kUpdateReminderNotificationKey object:nil];
}

#pragma mark - UISegmentedControl
- (IBAction)mapSegment:(UISegmentedControl *)sender {
    switch (sender.selectedSegmentIndex){
        case 0:
            [self.mapView setMapType:MKMapTypeStandard];
            break;
        case 1:
            [self.mapView setMapType:MKMapTypeHybrid];
            break;
        case 2:
            [self.mapView setMapType:MKMapTypeSatellite];
            break;
        default:
            break;
    }
}

#pragma mark - Buttons Action
- (IBAction)parisButtonPressed:(id)sender {
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(kLatitudeParis, kLongitudeParis);
    [self dropPinWithCoordinate:coordinate];
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(coordinate, 500.0, 500.0);
    [self.mapView setRegion:region animated:YES];
}

- (IBAction)taipeiButtonPressed:(id)sender {
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(kLatitudeTaipei, kLongitudeTaipei);
    [self dropPinWithCoordinate:coordinate];
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(coordinate, 500.0, 500.0);
    [self.mapView setRegion:region animated:YES];
}

- (IBAction)currentLocationButtonPressed:(id)sender
{
    CLLocationCoordinate2D coordinate = self.mapView.userLocation.coordinate;
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(coordinate, 500.0, 500.0);
    [self.mapView setRegion:region animated:YES];

}

- (IBAction)removeAnnotationPressed:(id)sender {
    for (Reminder *reminder in self.allReminders) {
        if ([reminder.locationName isEqualToString: self.currentAnnotationView.annotation.title]) {
            [[ReminderManager shared] removeReminder:reminder];
            [self showAllAnnotationWithOverlays];
            return;
        }
    }
}

#pragma mark - LocationControllerDelegate
-(void)locationControllerUpdatedLocation:(CLLocation *)location
{
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(location.coordinate, 500, 500);
    [self.mapView setRegion:region animated:YES];
}

#pragma mark - MKMapViewDelegate
-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;
    }
    MKPinAnnotationView *pinView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"Annotation"];
    pinView.annotation = annotation;
    UIButton *addButton = [UIButton buttonWithType:UIButtonTypeContactAdd];
    if (!pinView) {
        pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"Annotation"];
    }
    pinView.draggable      = YES;
    pinView.animatesDrop   = YES;
    pinView.canShowCallout = YES; // This has to be set to show right call out
    pinView.rightCalloutAccessoryView = addButton;
    return pinView;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    self.annotationPin = view.annotation;
    [self performSegueWithIdentifier:@"AddReminderViewController" sender:view];
}

-(void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    self.currentAnnotationView = view;
}

-(MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay
{
    MKCircleRenderer *circleRender = [[MKCircleRenderer alloc] initWithCircle:overlay];
    circleRender.fillColor = [UIColor redColor];
    circleRender.alpha = 0.3;
    
    return circleRender;
}

@end

// MKAnnotation is a protocol you need to adopt if you wish to show your object on a MKMapView.
// The coordinate property tells MKMapView where to place it. title and subtitle properties are optional
// but if you wish to show a callout view you are expected to implement title at a minimum.
//
// MKAnnotationView visually presents the MKAnnotation on the MKMapView.
// The image property can be set to determine what to show for the annotation.
// However you can subclass it and implement drawRect: yourself.
//
// MKPinAnnotationView is a subclass of MKAnnotationView that uses a Pin graphic as the image property.
// You can set the pin color and drop animation.
