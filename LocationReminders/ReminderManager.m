//
//  ReminderManager.m
//  LocationReminders
//
//  Created by Cathy Oun on 5/4/17.
//  Copyright © 2017 cathyoun. All rights reserved.
//

#import "ReminderManager.h"
#import "NotificationKeys.h"
#import "LocationController.h"
@implementation ReminderManager

+ (instancetype)shared
{
    static ReminderManager *shared = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[self alloc] init];
    });
    return shared;
}

- (void)fetchAllRemindersWithCompletionHandler:(void (^)(NSArray<Reminder *>* reminders))completionHandler;
{
    PFQuery *query = [Reminder query];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (error) {
            NSLog(@"Fetch failed");
            return;
        }
        completionHandler(objects);
    }];
}

- (void)saveReminder:(Reminder *)reminder withCompletionHandler:(void (^)(BOOL succeed))completionHandler
{
    [reminder saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateReminderNotificationKey object:nil];
            completionHandler(YES);
        }
        if (error) {
            completionHandler(NO);
        }
    }];
}

- (void)removeReminder:(Reminder *)reminder
{
    [[LocationController shared] stopMonitoringForRegionWithIdentifier:reminder.locationName];
    [reminder deleteInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded) {
            NSLog(@"Removed object from Parse");
        }
    }];
}

@end
