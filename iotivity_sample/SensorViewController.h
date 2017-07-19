//
//  SensorViewController.h
//  iotivity_sample
//
//  Created by Pooja Gosavi on 7/17/17.
//  Copyright © 2017 Marko Kiiskila. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Charts/Charts.h>
#import "iotivity_itf.h"
#import "Peripheral.h"

@interface SensorViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UILabel *displayLabel;
@property (weak, nonatomic) IBOutlet UINavigationItem *navigationItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *backButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *observeButton;
@property (weak, nonatomic) IBOutlet UITableView *sensorData;
@property (strong, nonatomic) IBOutlet LineChartView *chartView;

@property (strong, nonatomic) NSString *uri;
@property (strong, nonatomic) NSString *navTitle;
@property (strong, nonatomic) Peripheral *peripheral;
@property (strong, nonatomic) NSMutableDictionary *dict;
@property (nonatomic) bool isObserving;
@end
