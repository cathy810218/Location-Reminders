//
//  Reminder.m
//  LocationReminders
//
//  Created by Cathy Oun on 5/2/17.
//  Copyright © 2017 cathyoun. All rights reserved.
//

#import "Reminder.h"

@implementation Reminder

-(instancetype)initWithLocationName:(NSString *)locationName geoPoint:(PFGeoPoint *)geoPoint radius:(NSNumber *)radius withUser:(PFUser *)user
{
    self = [super init];
    if (self) {
        self.locationName = locationName;
        self.geoPoint = geoPoint;
        self.radius = radius;
        self.user = user;
        
    }
    return self;
}

+ (NSString *)parseClassName
{
    return @"LocationReminders";
}

@end
