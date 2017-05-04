//
//  LocationController.m
//  LocationReminders
//
//  Created by Cathy Oun on 5/2/17.
//  Copyright © 2017 cathyoun. All rights reserved.
//

#import "LocationController.h"
#import <CoreLocation/CoreLocation.h>
@import UserNotifications;

@interface LocationController () <CLLocationManagerDelegate>

@end

@implementation LocationController 

+ (instancetype)shared
{
    static LocationController *shared = nil;
    
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
    self.locationManager.distanceFilter = 100;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [self.locationManager requestAlwaysAuthorization];
}

- (void)updateLocation
{
    [self.locationManager startUpdatingLocation];
}

- (void)startMonitoringForRegion:(CLRegion *)region
{
    [self.locationManager startMonitoringForRegion:region];
}

-(void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    NSLog(@"User did enter region: %@", region.identifier);
    UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
    content.title = @"You're near!";
    content.body = [NSString stringWithFormat:@"Enter region: %@", region.identifier];
    content.sound = [UNNotificationSound defaultSound];
    
    UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:0.1 repeats:NO];
    
    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:@"Enter" content:content trigger:trigger];
    UNUserNotificationCenter *current = [UNUserNotificationCenter currentNotificationCenter];
    [current removeAllPendingNotificationRequests];
    [current addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
        if (error) {
            NSLog(@"Error: %@", error.localizedDescription);
        }
    }];
}

-(void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    NSLog(@"User did exit region: %@", region.identifier);
}

-(void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region
{
    NSLog(@"User starts monitoring for region: %@", region.identifier);
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    [self.delegate locationControllerUpdatedLocation:locations.lastObject];
}

@end
