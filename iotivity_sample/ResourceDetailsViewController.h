//
//  ResourceDetailsViewController.h
//  iotivity_sample
//
//  Created by Pooja Gosavi on 6/6/17.
//  Copyright © 2017 Marko Kiiskila. All rights reserved.
//

#import "Peripheral.h"
#import "DeviceViewController.h"
#import <UIKit/UIKit.h>

@interface ResourceDetailsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UINavigationItem *navBar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *backButton;
@property (strong, nonatomic) IBOutlet UITableView *resourceList;

@property (strong, nonatomic) NSString *navigationTitle;
@property (nonatomic) uint8_t resourceIndex;
@property (strong, nonatomic) Peripheral *peripheral;

-(void) getResourceDetails;
-(void) getInterfaceData;

@property (nonatomic) OCDevAddr devAddr;
@property (nonatomic) OCDoHandle handle;

@property (strong, nonatomic) NSString *interface;
@property (strong, nonatomic) NSString *resourceType;

//Pop Up Menu
@property (strong, nonatomic) IBOutlet UIView *backgroundPopup;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *okButton;
@property (weak, nonatomic) IBOutlet UITextField *valueTextField;


@end
