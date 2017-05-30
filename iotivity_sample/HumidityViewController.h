//
//  HumidityViewController.h
//  iotivity_sample
//
//  Created by Pooja Gosavi on 5/26/17.
//  Copyright © 2017 Marko Kiiskila. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Peripheral.h"

@interface HumidityViewController : UIViewController

@property (nonatomic, strong) Peripheral *peripheral;
@property (nonatomic, strong) NSString *uri;

-(void)populateHumidityData;
@property (weak, nonatomic) IBOutlet UILabel *typeLabel;
@property (weak, nonatomic) IBOutlet UILabel *valueLabel;
@property (weak, nonatomic) IBOutlet UILabel *unitsLabel;
@property (weak, nonatomic) IBOutlet UINavigationBar *navBar;
@property (weak, nonatomic) IBOutlet UINavigationItem *navigationItem;
@property (weak, nonatomic) IBOutlet UIButton *getButton;

@end
