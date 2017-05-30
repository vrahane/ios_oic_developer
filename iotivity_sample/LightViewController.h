//
//  LightViewController.h
//  iotivity_sample
//
//  Created by Pooja Gosavi on 5/25/17.
//  Copyright © 2017 Marko Kiiskila. All rights reserved.
//

#import <UIKit/UIKit.h>
#include <iotivity-csdk/octypes.h>
#include <iotivity-csdk/ocstack.h>
#import "Peripheral.h"

@interface LightViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UIButton *getButton;
@property (nonatomic, strong) Peripheral *peripheral;

@property (nonatomic, strong) NSString *uri;

- (void)populateData;

@property (weak, nonatomic) IBOutlet UILabel *xOrientation;
@property (weak, nonatomic) IBOutlet UILabel *yOrientation;
@property (weak, nonatomic) IBOutlet UILabel *zOrientation;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *backButton;

@end
