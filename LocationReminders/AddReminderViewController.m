//
//  AddReminderViewController.m
//  LocationReminders
//
//  Created by Cathy Oun on 5/2/17.
//  Copyright © 2017 cathyoun. All rights reserved.
//

#import "AddReminderViewController.h"
#import "Reminder.h"
#import "NotificationKeys.h"
#import <ParseUI/ParseUI.h>
#import "LocationController.h"

static const int kInitial_Radius = 250;

@interface AddReminderViewController () <PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UITextField *nameTextfield;
@property (weak, nonatomic) IBOutlet UISlider *slider;

@property (weak, nonatomic) IBOutlet UILabel *radiusLabel;

@end

@implementation AddReminderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupNavigationItems];
    [self setupSlider];
    [self login];
}

- (void)setupNavigationItems
{
    UIBarButtonItem *saveItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(handleSaveButton:)];
    self.navigationItem.title = self.selectedAnnotation.title;
    self.navigationItem.rightBarButtonItem = saveItem;
}

- (void)setupSlider
{
    self.slider.minimumValue = 0.0;
    self.slider.maximumValue = 500.0;
    self.slider.value = kInitial_Radius;
    self.radiusLabel.text = [NSString stringWithFormat:@"%i", kInitial_Radius];
}


- (void)login
{
    if (![PFUser currentUser]) {
        PFLogInViewController *loginVC = [[PFLogInViewController alloc] init];
        loginVC.delegate = self;
        loginVC.signUpController.delegate = self;
        [loginVC setFields:PFLogInFieldsFacebook | PFLogInFieldsTwitter | PFLogInFieldsDefault];

        [self presentViewController:loginVC animated:true completion:nil];
    }
}

- (void)handleSaveButton:(UIBarButtonItem *)sender
{
    Reminder *newReminder = [Reminder object];
    newReminder.locationName = self.nameTextfield.text;
    newReminder.geoPoint = [PFGeoPoint geoPointWithLatitude:self.selectedAnnotation.coordinate.latitude longitude:self.selectedAnnotation.coordinate.longitude];
    [newReminder saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        NSLog(@"%@",self.selectedAnnotation.title);
        NSLog(@"%f %f",self.selectedAnnotation.coordinate.latitude, self.selectedAnnotation.coordinate.longitude);
        if (succeeded) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kSavedReminderNotificationKey object:nil];
            
            [self showAlertWithTitle:@"Succeed" andMessage:[NSString stringWithFormat:@"you have added \"\%@\" to your reminder list", self.nameTextfield.text]];
        } else {
            [self showAlertWithTitle:@"Error" andMessage:@"Something is wrong!"];
            NSLog(@"%@", error.localizedDescription);
        }
    }];
    
    if (self.completion) {
        CGFloat radius = self.slider.value;
        MKCircle *circle = [MKCircle circleWithCenterCoordinate:self.selectedAnnotation.coordinate radius:radius];
        if ([CLLocationManager isMonitoringAvailableForClass:[CLCircularRegion class]]) {
            CLCircularRegion *region = [[CLCircularRegion alloc] initWithCenter:self.selectedAnnotation.coordinate radius:radius identifier:newReminder.locationName];
            [[LocationController shared] startMonitoringForRegion:region];
        }
        self.completion(circle, self.nameTextfield.text);
    }
}

- (void)showAlertWithTitle:(NSString *)title andMessage:(NSString *)message
{
    UIAlertController* addReminderAlert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        [self.navigationController popToRootViewControllerAnimated:true];
    }];
    [addReminderAlert addAction:defaultAction];
    [self presentViewController:addReminderAlert animated:YES completion:nil];
}

- (IBAction)sliderAction:(id)sender {
    NSNumber *radius = [NSNumber numberWithInt:self.slider.value];
    self.radiusLabel.text = [NSString stringWithFormat:@"%@", radius];
}

#pragma mark - PFLogInViewControllerDelegate
-(void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)signUpViewController:(PFSignUpViewController *)signUpController didSignUpUser:(PFUser *)user
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
