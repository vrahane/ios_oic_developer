//
//  ResourceDetailsViewController.m
//  iotivity_sample
//
//  Created by Pooja Gosavi on 6/6/17.
//  Copyright © 2017 Marko Kiiskila. All rights reserved.
//

#import "ResourceDetailsViewController.h"
#import "ResourceDetailsTableViewCell.h"
#import "DeviceViewController.h"
#import "PeripheralResource.h"
#import "Peripheral.h"
#import "iotivity_itf.h"
#import <iotivity-csdk/ocstack.h>

@interface ResourceDetailsViewController ()
@property (nonatomic) Peripheral *pr;

@end

@implementation ResourceDetailsViewController

@synthesize backButton;
@synthesize navBar;
@synthesize resourceList;
@synthesize peripheral;
@synthesize navigationTitle;


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.resourceList.dataSource = self;
    self.resourceList.delegate = self;
    UINib *nib;
    nib = [UINib nibWithNibName:@"ResourceDetailsTableViewCell" bundle:nil];
    [self.resourceList registerNib:nib
          forCellReuseIdentifier:@"ResourceDetailsTableViewCell"];

}

- (void) viewDidDisappear:(BOOL)animated {
 
    [super viewWillAppear:true];
    [[iotivity_itf shared] cancel_observer:self andURI:self.navigationTitle andDevAddr:self.devAddr andHandle:peripheral.handle];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}

- (void) viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:true];
        navBar.title = navigationTitle;
   NSLog(@"%lu",(unsigned long)[self.peripheral.resources count]);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([peripheral.uuid containsString:@"Platform"]) {
        return 1;
    } else if ([peripheral.uuid containsString:@"Device"]) {
        return 1;
    }else {
        return [self.peripheral.resources count];
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ResourceDetailsTableViewCell *cell = (ResourceDetailsTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"ResourceDetailsTableViewCell" forIndexPath:indexPath];
    
    
    if ([self.interface containsString:@"rw"]) {
        
        cell.putBtn.hidden = false;
        cell.getBtn.hidden = false;
        cell.observeSwitch.hidden = true;
    } else {
        cell.putBtn.hidden = true;
        cell.getBtn.hidden = true;
        cell.observeSwitch.hidden = false;
    }
    
    
    [cell.getBtn addTarget:self action:@selector(getClicked:) forControlEvents:UIControlEventTouchUpInside];
    [cell.putBtn addTarget:self action:@selector(putclicked:) forControlEvents:UIControlEventTouchUpInside];
    //[cell.observeSwitch addTarget:self action:@selector(observeStateChanged:) forControlEvents:UIControlEventValueChanged];
    
    cell.getBtn.tag = indexPath.row;
    cell.putBtn.tag = indexPath.row;
    cell.observeSwitch.tag = indexPath.row;

    cell.uri = self.navigationTitle;
    cell.devAddr = peripheral.devAddr;
    
    if ([peripheral.uuid containsString:@"Platform"]) {
        cell.typeLabel.text = @"Platform ID";
        cell.valueLabel.text = peripheral.platformID;
        cell.observeSwitch.hidden = true;

    } else if ([peripheral.uuid containsString:@"Device"]) {
        cell.observeSwitch.hidden = true;
        cell.typeLabel.text = @"Device Details";
        NSString *devicename = [peripheral.resStateName stringByAppendingString:@" "];
        devicename = [devicename stringByAppendingString:peripheral.resType];
        cell.valueLabel.text = devicename;
    }else {
        PeripheralResource *pres = peripheral.resources[indexPath.row];
        
        cell.typeLabel.text = pres.resourceName;
        if(pres.type == OCREP_PROP_INT){
            cell.valueLabel.text = [[NSNumber numberWithLongLong:pres.resourceIntegerValue] stringValue];
        }else if(pres.type == OCREP_PROP_BOOL){
            NSString *booleanString = pres.resourceBoolValue ? @"true" : @"false";
            cell.valueLabel.text = booleanString;
        }else if(pres.type == OCREP_PROP_DOUBLE){
            cell.valueLabel.text = [[NSNumber numberWithDouble:pres.resourceDoubleValue] stringValue];
        }else if(pres.type == OCREP_PROP_STRING){
            cell.valueLabel.text = pres.resourceStringValue;
        }

    }
    return cell;
}

- (IBAction)backButtonAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (void) getClicked : (UIButton *)sender {
    [[iotivity_itf shared] get_generic:self andURI:self.navigationTitle andDevAddr:peripheral.devAddr];
}

-(void) getResourceDetails {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self receiveData];
        }];
    }
    
-(void)receiveData {
        Peripheral *pr;
        pr = [[iotivity_itf shared] resourceDetails];
    
    for (int i = 0; i < [pr.resources count]; i++) {
        PeripheralResource *per = pr.resources[i];
        if (per.type == OCREP_PROP_BOOL) {
            NSString *booleanValue = per.resourceBoolValue ? @"true" : @"false";
            NSLog(@"%@ - %@", per.resourceName, booleanValue);
        }
    }
    
    NSLog(@"AAAAAAA Cell count: %lu",(unsigned long)[pr.resources count]);
    peripheral.resources = pr.resources;
    peripheral.handle = pr.handle;
    [resourceList reloadData];
}

-(void)getInterfaceData {
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self interfaceData];
    }];
}

-(void)interfaceData {
    Peripheral *pr;
    pr = [[iotivity_itf shared] interfaceDetails];

    for (int i = 0; i < [pr.resources count]; i++) {
        PeripheralResource *per = pr.resources[i];
        for (int j = 0;j < [peripheral.resources count]; j++) {
            PeripheralResource *p = peripheral.resources[j];
            if([p.resourceName isEqualToString:per.resourceName]){
                p.resourceInterface = per.resourceInterface;
                [peripheral.resources replaceObjectAtIndex:j withObject:p];
            }
        }
    }
    for(int i = 0; i < [peripheral.resources count]; i++){
        PeripheralResource *pr = peripheral.resources[i];
        NSLog(@"%@",pr.resourceInterface);
    }
}




- (void)putclicked : (UIButton *)sender {
    
    self.valueTextField.text = @"";
    [self.backgroundPopup setFrame:CGRectMake(10, 10, self.view.bounds.size.width - 20, 200)];
    [self.view addSubview:self.backgroundPopup];
    
    [self.cancelButton addTarget:self action:@selector(cancelAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.okButton addTarget:self action:@selector(okAction:) forControlEvents:UIControlEventTouchUpInside];
    
    self.okButton.tag = sender.tag;
    
    
}


-(void)cancelAction:(UIButton *)sender{
    
    [self.backgroundPopup removeFromSuperview];
}

-(void)okAction:(UIButton *)sender{
    
    OCRepPayload *reprPayload = OCRepPayloadCreate();
    NSLog(@"%ld",(long)[sender tag]);
    
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[sender tag] inSection:0];
    ResourceDetailsTableViewCell *cell = [resourceList cellForRowAtIndexPath:indexPath];
    PeripheralResource *pres = peripheral.resources[indexPath.row];
    NSString *resourceName = cell.typeLabel.text;
    NSLog(@"%@",resourceName);
    NSString *value = self.valueTextField.text;
    NSLog(@"%@",value);
    
    if(pres.type == OCREP_PROP_INT){
        OCRepPayloadSetPropInt(reprPayload, [resourceName UTF8String] , [value intValue]);
    }else if(pres.type == OCREP_PROP_BOOL){
        OCRepPayloadSetPropBool(reprPayload, [resourceName UTF8String] , [value boolValue]);
    }else if(pres.type == OCREP_PROP_DOUBLE){
        OCRepPayloadSetPropDouble(reprPayload, [resourceName UTF8String] , pres.resourceDoubleValue);
    }else if(pres.type == OCREP_PROP_STRING){
        OCRepPayloadSetPropString(reprPayload, [resourceName UTF8String] , [pres.resourceStringValue UTF8String]);
    }
    [[iotivity_itf shared] set_generic:self andURI:self.navigationTitle andDevAddr: peripheral.devAddr andPayLoad:reprPayload];

    [self.backgroundPopup removeFromSuperview];
}

- (IBAction) observeStateChanged: (id)sender {
    
    UISegmentedControl *segment = (UISegmentedControl *)sender;
    
    NSString *title = [segment titleForSegmentAtIndex:segment.selectedSegmentIndex];

    if ([title  isEqual: @"Observe"]) {
        [[iotivity_itf shared] observe_light:self andURI:self.navigationTitle andDevAddr:self.devAddr];
    }else if([title  isEqual: @"Stop"]){
        [[iotivity_itf shared] cancel_observer:self andURI:self.navigationTitle andDevAddr:self.devAddr andHandle:peripheral.handle];
    }
}

@end
