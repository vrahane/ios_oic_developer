//
//  HumidityViewController.h
//  iotivity_sample
//
//  Created by Pooja Gosavi on 7/6/17.
//  Copyright © 2017 Marko Kiiskila. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Charts/Charts.h>
#import "iotivity_itf.h"
#import "Peripheral.h"

@interface HumidityViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UISwitch *observeSwitch;
@property (weak, nonatomic) IBOutlet UITableView *sensorDetails;
@property (weak, nonatomic) IBOutlet LineChartView *chartView;

@property (strong, nonatomic) Peripheral *peripheral;
@property (strong, nonatomic) NSString *uri;

@end
