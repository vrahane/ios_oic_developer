//
//  DummyViewController.h
//  iotivity_sample
//
//  Created by Pooja Gosavi on 7/27/17.
//  Copyright © 2017 Marko Kiiskila. All rights reserved.
//

#import <CoreBluetooth/CoreBluetooth.h>
#import <UIKit/UIKit.h>

@interface DummyViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIImageView *mImageView;
@property (strong, nonatomic) CBCentralManager *centralManager;

@end
