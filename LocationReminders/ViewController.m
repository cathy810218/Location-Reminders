//
//  ViewController.m
//  LocationReminders
//
//  Created by Cathy Oun on 5/1/17.
//  Copyright © 2017 cathyoun. All rights reserved.
//

#import "ViewController.h"
@import MapKit;

static const CLLocationDegrees kLatitudeCF = 47.618217;
static const CLLocationDegrees klongitudeCF = -122.351832;

@interface ViewController ()

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIButton *currentLocationButton;
@property (strong, nonatomic) CLLocationManager *locationManager;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self requestPermission];
    self.mapView.showsUserLocation = YES;
}

- (void)requestPermission
{
    self.locationManager = [[CLLocationManager alloc] init];
    [self.locationManager requestAlwaysAuthorization];
}

- (IBAction)currentLocationButtonPressed:(id)sender
{
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(kLatitudeCF, klongitudeCF);
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(coordinate, 500.0, 500.0);
    [self.mapView setRegion:region animated:YES];

}

@end
