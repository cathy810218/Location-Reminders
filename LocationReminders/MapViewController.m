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
@import MapKit;

@interface MapViewController () <MKMapViewDelegate, LocationControllerDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIButton *currentLocationButton;
@property (strong, nonatomic) LocationController *locationController;
@end

@implementation MapViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.mapView.showsUserLocation = YES;
    self.mapView.delegate = self;
    [LocationController shared].delegate = self;
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleDone target:self action:nil];
    
    UILongPressGestureRecognizer *gesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    [self.mapView addGestureRecognizer:gesture];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reminderSavedToParse:) name:kSavedReminderNotificationKey object:nil];
}

- (void)reminderSavedToParse:(id)sender
{
    NSLog(@"HI");
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
    [self.mapView selectAnnotation:pointAnnotation animated:YES];
}



-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [super prepareForSegue:segue sender:sender];
    if ([segue.identifier isEqualToString:@"AddReminderViewController"]
        && [sender isKindOfClass:[MKAnnotationView class]]) {
        
        MKAnnotationView *view = (MKAnnotationView *)sender;
        AddReminderViewController *addReminderVC = [segue destinationViewController];
        
        
        addReminderVC.selectedAnnotation  = view.annotation;
        __weak __typeof__(self) weakSelf = self;
        addReminderVC.completion = ^(MKCircle *circle) {
            __strong typeof(weakSelf) hulk = weakSelf; //to prevent retain cycles
            [hulk.mapView removeAnnotation:view.annotation];
            [hulk.mapView addOverlay:circle];
        };
    }
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kSavedReminderNotificationKey object:nil];
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
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(kLatitudeCF, kLongitudeCF);
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(coordinate, 500.0, 500.0);
    [self.mapView setRegion:region animated:YES];

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

-(MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay
{
    MKCircleRenderer *circleRender = [[MKCircleRenderer alloc] init];
    circleRender.fillColor = [UIColor redColor];
    circleRender.alpha = 0.3;
    
    return circleRender;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    [self performSegueWithIdentifier:@"AddReminderViewController" sender:view];
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
