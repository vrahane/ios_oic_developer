//
//  PressureViewController.h
//  iotivity_sample
//
//  Created by Pooja Gosavi on 7/7/17.
//  Copyright © 2017 Marko Kiiskila. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Charts/Charts.h>
#import "Peripheral.h"

@interface PressureViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) IBOutlet LineChartView *chartView;
@property (weak, nonatomic) IBOutlet UITableView *mSmartDeviceList;
@property (weak, nonatomic) IBOutlet UISwitch *mSwitch;

@property (strong, nonatomic) Peripheral *peripheral;
@property (strong, nonatomic) NSString *uri;

@end
