//
//  Reminder.h
//  LocationReminders
//
//  Created by Cathy Oun on 5/2/17.
//  Copyright © 2017 cathyoun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface Reminder : PFObject <PFSubclassing>

// We didn't get setter and getter for free because of PFObject
@property (strong, nonatomic) NSString *locationName;
@property (strong, nonatomic) PFGeoPoint *geoPoint;
@property (assign, nonatomic) NSNumber *radius;
@property (strong, nonatomic) PFUser *user;

@end
