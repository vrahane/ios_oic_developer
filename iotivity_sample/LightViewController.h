//
//  LightViewController.h
//  iotivity_sample
//
//  Created by Pooja Gosavi on 7/24/17.
//  Copyright © 2017 Marko Kiiskila. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Peripheral.h"
#import "iotivity_itf.h"
#import <iotivity-csdk/octypes.h>

@interface LightViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *mLightView;
@property (weak, nonatomic) IBOutlet UISwitch *mSwitch;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *mbackBtn;
@property (weak, nonatomic) IBOutlet UINavigationItem *navigationItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *observeButton;

@property (strong, nonatomic) NSString *uri;
@property (strong, nonatomic) Peripheral *peripheral;
@property (nonatomic) bool isObserving;
@property (nonatomic) OCDevAddr devAddr;
@end
