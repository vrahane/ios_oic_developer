//
//  HomeViewController.h
//  iotivity_sample
//
//  Created by Pooja Gosavi on 6/22/17.
//  Copyright © 2017 Marko Kiiskila. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface HomeViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, CBCentralManagerDelegate, CBPeripheralDelegate>
#pragma mark - properties
@property (weak, nonatomic) IBOutlet UIButton *mScanbtn;
@property (weak, nonatomic) IBOutlet UITableView *mTableView;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *mScanBtn;

#pragma mark - methods
@property (strong, nonatomic) NSString *uri;
@property (strong, nonatomic) CBCentralManager *centralManager;
@end
