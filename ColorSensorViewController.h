//
//  ColorSensorViewController.h
//  iotivity_sample
//
//  Created by Pooja Gosavi on 7/7/17.
//  Copyright © 2017 Marko Kiiskila. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Charts/Charts-Swift.h>
#import "Peripheral.h"
#import "iotivity_itf.h"

@interface ColorSensorViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UISwitch *mSwitch;
@property (weak, nonatomic) IBOutlet UITableView *mSmartDeviceList;
@property (strong, nonatomic) IBOutlet LineChartView *chartView;

@property (strong, nonatomic) NSString *uri;
@property (strong, nonatomic) Peripheral *peripheral;
@end
