//
//  HumidityViewController.m
//  iotivity_sample
//
//  Created by Pooja Gosavi on 5/26/17.
//  Copyright © 2017 Marko Kiiskila. All rights reserved.
//

#import "HumidityViewController.h"
#import "iotivity_itf.h"
#import "Peripheral.h"
#import "PeripheralResource.h"
#include <iotivity-csdk/octypes.h>
#include <iotivity-csdk/ocstack.h>
#include <iotivity-csdk/ocpayload.h>


@interface HumidityViewController ()

@property (nonatomic) OCDoHandle handle;
@end

@implementation HumidityViewController

@synthesize peripheral;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    if([self.uri containsString:@"humid"] || [self.uri containsString:@"hmty"]){
        self.navigationItem.title = @"Humidity Details";
    } else if([self.uri containsString:@"temp"] || [self.uri containsString:@"tmp"]){
        self.navigationItem.title = @"Temperature Details";
    }else if([self.uri containsString:@"light"] || [self.uri containsString:@"light"]){
        self.navigationItem.title = @"Light Details";
    }
    
    self.getButton.clipsToBounds = true;
    self.getButton.layer.cornerRadius = 7.0f;
}

- (void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:true];
   // [[iotivity_itf shared] discovery_end];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Get Humidity Action
- (IBAction)getButton:(id)sender {
    
    if ([self.uri containsString:@"humidity"] || [self.uri containsString:@"hmty"]) {
        [[iotivity_itf shared] discovery_humidity:self andURI:self.uri andDevAddr: peripheral.devAddr];
    }else if([self.uri containsString:@"temp"] || [self.uri containsString:@"tmp"]){
        [[iotivity_itf shared] discovery_temperature:self andURI:self.uri andDevAddr: peripheral.devAddr];
    }else if([self.uri containsString:@"light"] || [self.uri containsString:@"light"]){
        [[iotivity_itf shared] get_generic:self andURI:self.uri andDevAddr: peripheral.devAddr];
    }
    
}

#pragma mark - Humidity API return and data fetch
-(void)populateHumidityData
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self getStatus];
    }];
}

-(void)populateTemperatureData
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self getStatus];
    }];
}

-(void)populateLightData
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self getStatus];
    }];
}


- (void)getStatus
{
    Peripheral *pr;
    if([self.uri containsString:@"humidity"] || [self.uri containsString:@"hmty"]){
        pr = [[iotivity_itf shared] humidityDetails];
        NSLog(@"%@, %@", pr.resType, pr.humidValue);
        self.unitsLabel.text = @"%";
        self.typeLabel.text = pr.resType;
        self.valueLabel.text = pr.humidValue;
    }else if([self.uri containsString:@"temp"] || [self.uri containsString:@"tmp"]){
        pr = [[iotivity_itf shared] temperatureDetails];
        NSLog(@"%@, %@, %@", pr.resType, pr.humidValue, pr.tempUnit);
        self.unitsLabel.text = pr.tempUnit;
        self.typeLabel.text = pr.resType;
        self.valueLabel.text = pr.humidValue;
    }else {
        pr = [[iotivity_itf shared] lightDetails];
        self.handle = pr.handle;
        for (PeripheralResource *pres in pr.resources) {
            NSLog(@"%@",pres.resourceName);
            
            if ([pres.resourceName containsString:@"state"]) {
                self.typeLabel.text = pres.resourceName;
                NSString *booleanString = pres.resourceBoolValue ? @"true" : @"false";
                self.valueLabel.text = booleanString;
            }
            
        }
        
    }     
    
    
    
}

-(IBAction)cancelAction:(id)sender{

    [self.backgroundPopup removeFromSuperview];
}

-(IBAction)okAction:(id)sender{

    OCRepPayload *reprPayload = OCRepPayloadCreate();
    OCRepPayloadSetPropBool(reprPayload, [self.typeLabel.text UTF8String], [self.valueField.text boolValue]);
    [[iotivity_itf shared] set_generic:self andURI:self.uri andDevAddr: peripheral.devAddr andPayLoad:reprPayload];
    [self.backgroundPopup removeFromSuperview];
}


#pragma mark - Set Action
- (IBAction)setAction:(id)sender {
    
    [self.valueField setText:@""];
    [self.backgroundPopup setFrame:CGRectMake(self.view.bounds.origin.x, self.view.bounds.size.height/2 - 50, self.view.bounds.size.width, 200)];
    [self.view addSubview:self.backgroundPopup];
    
    [self.cancelButton addTarget:self action:@selector(cancelAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.okButton addTarget:self action:@selector(okAction:) forControlEvents:UIControlEventTouchUpInside];
    
    
    
}

#pragma mark - Go Back
- (IBAction)goBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)observeAction:(id)sender {
    if ([self.observeSwitch isOn]) {
        [[iotivity_itf shared] observe_light:self andURI:self.uri andDevAddr:peripheral.devAddr];
    }else{
        [[iotivity_itf shared] cancel_observer:self andURI:self.uri andDevAddr:peripheral.devAddr andHandle:self.handle];
    }
}

@end

