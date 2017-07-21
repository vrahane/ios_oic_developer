//
//  CompassViewController.h
//  iotivity_sample
//
//  Created by Pooja Gosavi on 6/26/17.
//  Copyright © 2017 Marko Kiiskila. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Peripheral.h"
#import <Charts/Charts.h>

@interface CompassViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *mTableView;
@property (weak, nonatomic) IBOutlet UISwitch *mSwitch;

@property (strong, nonatomic) Peripheral *peripheral;
@property (strong, nonatomic) NSString *uri;
@property (weak, nonatomic) IBOutlet UINavigationItem *mNavigationBar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *backBtn;
@property (strong, nonatomic) IBOutlet LineChartView *chartView;
@end
