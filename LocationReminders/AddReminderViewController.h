//
//  AddReminderViewController.h
//  LocationReminders
//
//  Created by Cathy Oun on 5/2/17.
//  Copyright © 2017 cathyoun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

typedef void(^AddReminderCompletion)(MKCircle *circle, NSString *name);

@interface AddReminderViewController : UIViewController

@property (strong, nonatomic) MKPointAnnotation *selectedAnnotation;
@property (strong, nonatomic) AddReminderCompletion completion;

@end
