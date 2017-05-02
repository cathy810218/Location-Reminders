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

@import MapKit;

@interface MapViewController () <MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIButton *currentLocationButton;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) MKPointAnnotation *selectedAnnotation;
@end

@implementation MapViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self requestPermission];
    self.mapView.showsUserLocation = YES; // Drop a pin initially at user location
    self.mapView.delegate = self;
    UILongPressGestureRecognizer *gesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    [self.mapView addGestureRecognizer:gesture];
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
    MKPointAnnotation *pointAnnotation = [[MKPointAnnotation alloc] init];
    pointAnnotation.coordinate = coordinate;
    pointAnnotation.title = @"Monitor Location";
    
    [self.mapView addAnnotation:pointAnnotation];
}

- (void)requestPermission
{
    self.locationManager = [[CLLocationManager alloc] init];
    [self.locationManager requestAlwaysAuthorization];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"AddReminderViewController"]) {
        AddReminderViewController *addReminderVC = [segue destinationViewController];
        addReminderVC.selectedAnnotation  = self.selectedAnnotation;
    }
}

#pragma mark - Buttons Action

- (IBAction)parisButtonPressed:(id)sender {
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(kLatitudeParis, kLongitudeParis);
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(coordinate, 500.0, 500.0);
    [self.mapView setRegion:region animated:YES];
}

- (IBAction)taipeiButtonPressed:(id)sender {
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(kLatitudeTaipei, kLongitudeTaipei);
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(coordinate, 500.0, 500.0);
    [self.mapView setRegion:region animated:YES];
}

- (IBAction)currentLocationButtonPressed:(id)sender
{
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(kLatitudeCF, kLongitudeCF);
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(coordinate, 500.0, 500.0);
    [self.mapView setRegion:region animated:YES];

}

#pragma mark - MKMapViewDelegate
-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    UIButton *addButton = [UIButton buttonWithType:UIButtonTypeContactAdd];
    
    MKPinAnnotationView *pinView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"Annotation"];
    pinView.annotation = annotation;
    
    if (!pinView) {
        pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"Annotation"];
    }
    pinView.draggable = YES;
    pinView.animatesDrop = YES;
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
    self.selectedAnnotation = view.annotation;
    [self performSegueWithIdentifier:@"AddReminderViewController" sender:view];
}

@end
