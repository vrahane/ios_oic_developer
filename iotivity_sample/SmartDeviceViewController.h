//
//  SmartDeviceViewController.h
//  iotivity_sample
//
//  Created by Pooja Gosavi on 6/26/17.
//  Copyright © 2017 Marko Kiiskila. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Charts/Charts.h>
#import "Peripheral.h"

@interface SmartDeviceViewController : UIViewController <UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *mSmartDeviceList;
@property (weak, nonatomic) IBOutlet UISwitch *mSwitch;

@property (strong, nonatomic) NSString *uri;
@property (strong, nonatomic) Peripheral *peripheral;

@end
