//
//  ReminderManager.h
//  LocationReminders
//
//  Created by Cathy Oun on 5/4/17.
//  Copyright © 2017 cathyoun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Reminder.h"
@interface ReminderManager : NSObject

+ (instancetype)shared;

- (void)fetchAllRemindersWithCompletionHandler:(void (^)(NSArray<Reminder *>* reminders))completionHandler;

- (void)saveReminder:(Reminder *)reminder withCompletionHandler:(void (^)(BOOL succeed))completionHandler;
- (void)removeReminder:(Reminder *)reminder;

@end
