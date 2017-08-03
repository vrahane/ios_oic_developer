//
//  DeviceListViewController.h
//  iotivity_sample
//
//  Created by Marko Kiiskila on 5/15/17.
//  Copyright © 2017 Marko Kiiskila. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DeviceListViewController : UIViewController

@property (nonatomic, strong) NSString *uuid;
@property (nonatomic, strong) NSMutableArray *peripheralList;
@property (nonatomic, strong) NSMutableArray *dataFromIP;
- (void) platformDetailsForDevice;
@end
