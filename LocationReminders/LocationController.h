//
//  LocationController.h
//  LocationReminders
//
//  Created by Cathy Oun on 5/2/17.
//  Copyright © 2017 cathyoun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@protocol LocationControllerDelegate <NSObject>
- (void)locationControllerUpdatedLocation:(CLLocation *)location;
@end

@interface LocationController : NSObject

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *location;
@property (weak, nonatomic) id<LocationControllerDelegate> delegate;

+ (instancetype)shared;
- (void)updateLocation;

- (void)startMonitoringForRegion:(CLRegion *)region;
- (void)stopMonitoringForRegionWithIdentifier:(NSString *)identifier;
@end
