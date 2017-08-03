//
//  DeviceDetailsViewController.h
//  iotivity_sample
//
//  Created by Pooja Gosavi on 8/2/17.
//  Copyright © 2017 Marko Kiiskila. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Peripheral.h"
#import "iotivity_itf.h"

@interface DeviceDetailsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UINavigationItem *navigationItemBar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *backButton;
@property (weak, nonatomic) IBOutlet UITableView *resourceList;
@property (weak, nonatomic) IBOutlet UIView *backgroundView;
@property (weak, nonatomic) IBOutlet UILabel *manufacturerLbl;
@property (weak, nonatomic) IBOutlet UILabel *carrierLbl;
@property (weak, nonatomic) IBOutlet UILabel *platformIdLbl;
@property (weak, nonatomic) IBOutlet UILabel *uuidLbl;
@property (nonatomic, strong) Peripheral *peripheral;

-(void) platformDetailsForDevice;
@end
