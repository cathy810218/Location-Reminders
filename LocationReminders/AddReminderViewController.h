//
//  AddReminderViewController.h
//  LocationReminders
//
//  Created by Cathy Oun on 5/2/17.
//  Copyright © 2017 cathyoun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface AddReminderViewController : UIViewController

typedef void(^AddReminderCompletion)(MKCircle *);

@property (strong, nonatomic) MKPointAnnotation *selectedAnnotation;
@property (strong, nonatomic) AddReminderCompletion completion;

@end
