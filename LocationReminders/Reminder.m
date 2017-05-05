//
//  Reminder.m
//  LocationReminders
//
//  Created by Cathy Oun on 5/2/17.
//  Copyright © 2017 cathyoun. All rights reserved.
//

#import "Reminder.h"

@implementation Reminder

// Complier trusts me that the accessors will be available at runtime
@dynamic locationName;
@dynamic geoPoint;
@dynamic radius;
@dynamic user;

// Need to register the subclass could also do it in AppDelegate
// But it's better do it inside the model class
+ (void)load
{
    [super load];
    [self registerSubclass]; // Register the subclass with Parse
}

+ (NSString *)parseClassName
{
    return @"Reminder"; // Name on the Parse dashboard
}

@end
