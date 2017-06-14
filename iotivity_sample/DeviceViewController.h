//
//  DeviceViewController.h
//  iotivity_sample
//
//  Created by Marko Kiiskila on 5/16/17.
//  Copyright © 2017 Marko Kiiskila. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Peripheral.h"
#include <iotivity-csdk/octypes.h>
#include <iotivity-csdk/ocstack.h>

@protocol ResourceDelegate <NSObject>

@optional
-(void) sendData:(Peripheral *)peripheralObject;

@end

@interface DeviceViewController : UIViewController <ResourceDelegate>

@property (nonatomic, strong) Peripheral *peripheral;
@property (nonatomic, strong) NSString *manufacturerName;
@property (weak, nonatomic) IBOutlet UIView *backgroundView;
@property (nonatomic, strong) NSString *platformId;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *backButton;
@property(retain, nonatomic) id<ResourceDelegate> delegate;

-(void) getResourceDetails;

@end
