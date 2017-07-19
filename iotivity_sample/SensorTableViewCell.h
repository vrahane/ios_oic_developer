//
//  SensorTableViewCell.h
//  iotivity_sample
//
//  Created by Pooja Gosavi on 7/17/17.
//  Copyright © 2017 Marko Kiiskila. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SensorTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *valueLabel;
@property (strong, nonatomic) IBOutlet UIImageView *imgView;
@property (strong, nonatomic) IBOutlet UISwitch *mSwitch;

@end
