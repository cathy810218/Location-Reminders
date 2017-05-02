//
//  LocationController.m
//  LocationReminders
//
//  Created by Cathy Oun on 5/2/17.
//  Copyright © 2017 cathyoun. All rights reserved.
//

#import "LocationController.h"
#import <CoreLocation/CoreLocation.h>
@interface LocationController () <CLLocationManagerDelegate>

@end

@implementation LocationController 

+ (instancetype)shared
{
    // We will need to nil out to avoid retain cycle
    static LocationController *shared = nil;
    
    // Only execute one time!
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[self alloc] init];
    });
    return shared;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self requestPermission];
    }
    return self;
}

- (void)requestPermission
{
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    [self.locationManager requestAlwaysAuthorization];
    self.locationManager.distanceFilter = 100;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [self.locationManager startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    [self.delegate locationControllerUpdatedLocation:locations.lastObject];
}


@end
