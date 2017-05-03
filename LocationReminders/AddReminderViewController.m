//
//  AddReminderViewController.m
//  LocationReminders
//
//  Created by Cathy Oun on 5/2/17.
//  Copyright © 2017 cathyoun. All rights reserved.
//

#import "AddReminderViewController.h"
#import "Reminder.h"

static const int kInitial_Radius = 250;

@interface AddReminderViewController () 

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UITextField *nameTextfield;
@property (weak, nonatomic) IBOutlet UISlider *slider;

@property (weak, nonatomic) IBOutlet UILabel *radiusLabel;

@end

@implementation AddReminderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSLog(@"%@",self.selectedAnnotation.title);
    NSLog(@"%f %f",self.selectedAnnotation.coordinate.latitude, self.selectedAnnotation.coordinate.longitude);

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
        //TODO: Log in
    }
}

- (void)handleSaveButton:(UIBarButtonItem *)sender
{
    //TODO: Add to the list
    [self showAlert];
}

- (void)showAlert
{
    // ui alert controller
    UIAlertController* addReminderAlert = [UIAlertController alertControllerWithTitle:@"Success" message:[NSString stringWithFormat:@"you have added \"\%@\" to your reminder list", self.nameTextfield.text] preferredStyle:UIAlertControllerStyleAlert];
    
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

@end
