//
//  ResourceDetailsTableViewCell.h
//  iotivity_sample
//
//  Created by Pooja Gosavi on 6/5/17.
//  Copyright © 2017 Marko Kiiskila. All rights reserved.
//

#import <UIKit/UIKit.h>
#include <iotivity-csdk/octypes.h>
#include <iotivity-csdk/ocstack.h>
#include <iotivity-csdk/ocpayload.h>
#import "Peripheral.h"

@interface ResourceDetailsTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UITextField *typeLabel;
@property (weak, nonatomic) IBOutlet UITextField *valueLabel;
@property (weak, nonatomic) IBOutlet UIButton *getBtn;
@property (weak, nonatomic) IBOutlet UIButton *putBtn;
@property (weak, nonatomic) IBOutlet UISegmentedControl *observeSwitch;
@property(weak, nonatomic) IBOutlet UIView *mybgView;

@property (strong, nonatomic) NSString *uri;
@property (nonatomic) OCDevAddr devAddr;

@end
