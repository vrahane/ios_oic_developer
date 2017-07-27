//
//  LightViewController.m
//  iotivity_sample
//
//  Created by Pooja Gosavi on 7/24/17.
//  Copyright © 2017 Marko Kiiskila. All rights reserved.
//

#import "LightViewController.h"
#import "SmartDeviceTableViewCell.h"
#import <iotivity-csdk/ocstack.h>
#import <iotivity-csdk/ocpayload.h>

@interface LightViewController ()

@end

@implementation LightViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    UINib *nib;
    nib =[UINib nibWithNibName:@"SmartDeviceTableViewCell" bundle:nil];
    [_mLightView registerNib:nib forCellReuseIdentifier:@"SmartDeviceTableViewCell"];
    _isObserving = true;
    NSLog(@"%lu",(unsigned long)[_peripheral.resources count]);
    self.navigationItem.title = self.uri;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)mSwitchChanged:(id)sender {
    
    OCRepPayload *reprPayload = OCRepPayloadCreate();
    NSLog(@"%ld",(long)[sender isOn]);
    
    if ([_mSwitch isOn]) {
            OCRepPayloadSetPropBool(reprPayload, [@"value" UTF8String] , true);
    } else {
        OCRepPayloadSetPropBool(reprPayload, [@"value" UTF8String], false);
    }
    
    [[iotivity_itf shared] set_resource_value:self andURI:self.uri andDevAddr: self.devAddr andPayLoad:reprPayload];
}
- (IBAction)observeAction:(id)sender {
    [[iotivity_itf shared] get_resources:self andURI:self.uri andDevAddr:self.devAddr];
}
- (IBAction)backAction:(id)sender {
    [self.navigationController popViewControllerAnimated:true];
}


- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_peripheral.resources count];
}


- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SmartDeviceTableViewCell *cell = (SmartDeviceTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"SmartDeviceTableViewCell"];
    PeripheralResource *pr = _peripheral.resources[indexPath.row];
    cell.mDataTypeLbl.text = pr.resourceName;
    if(pr.type == OCREP_PROP_DOUBLE) {
        cell.mValueLbl.text = [[NSNumber numberWithDouble:pr.resourceDoubleValue] stringValue];
    } else if(pr.type == OCREP_PROP_STRING) {
        cell.mValueLbl.text = pr.resourceStringValue;
        
    }else if(pr.type == OCREP_PROP_INT){
        cell.mValueLbl.text = [[NSNumber numberWithLongLong:pr.resourceIntegerValue] stringValue];
    }else if(pr.type == OCREP_PROP_BOOL){
        NSString *booleanString = pr.resourceBoolValue ? @"true" : @"false";
        if ([booleanString isEqualToString:@"true"]) {
            [_mSwitch setOn:true];
        } else {
            [_mSwitch setOn:false];
        }
        cell.mValueLbl.text = booleanString;
    }
    return cell;
}

-(void) getResourceDetails {
    [self receiveData];
}

-(void) receiveData {
    Peripheral *pr;
    pr = [[iotivity_itf shared] resourceDetails];
    
    for (PeripheralResource *resource in pr.resources) {
        NSLog(@"%@",resource.resourceName);
    }
    
    self.peripheral = pr;
    _peripheral.devAddr = pr.devAddr;
    _peripheral.handle = pr.handle;
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self.mLightView reloadData];
    }];
    
}

@end
