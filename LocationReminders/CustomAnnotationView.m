//
//  CustomAnnotationView.m
//  LocationReminders
//
//  Created by Cathy Oun on 5/2/17.
//  Copyright © 2017 cathyoun. All rights reserved.
//

#import "CustomAnnotationView.h"

@implementation CustomAnnotationView

-(instancetype)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {

        self.frame = CGRectMake(0, 0, 300, 300);
        self.backgroundColor = [UIColor whiteColor];
        self.canShowCallout = YES;
    }
    return self;
}
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    self.bounds = CGRectMake(0, 0, 500, 500);
    self.backgroundColor = [UIColor redColor];
}


@end
