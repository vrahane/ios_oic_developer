//
//  SmartDeviceTableViewCell.h
//  iotivity_sample
//
//  Created by Pooja Gosavi on 6/26/17.
//  Copyright © 2017 Marko Kiiskila. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SmartDeviceTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UITextField *mDataTypeLbl;
@property (weak, nonatomic) IBOutlet UITextField *mValueLbl;
@property (weak, nonatomic) IBOutlet UIButton *mPutBtn;

@end
