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

@interface HumidityViewController ()

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
    }
    
    self.getButton.clipsToBounds = true;
    self.getButton.layer.cornerRadius = 7.0f;
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


- (void)getStatus
{
    Peripheral *pr;
    if([self.uri containsString:@"humidity"] || [self.uri containsString:@"hmty"]){
        pr = [[iotivity_itf shared] humidityDetails];
        NSLog(@"%@, %@", pr.resType, pr.humidValue);
        self.unitsLabel.text = @"%";
    }else {
        pr = [[iotivity_itf shared] temperatureDetails];
        NSLog(@"%@, %@, %@", pr.resType, pr.humidValue, pr.tempUnit);
        self.unitsLabel.text = pr.tempUnit;
    }
    
    self.typeLabel.text = pr.resType;
    self.valueLabel.text = pr.humidValue;
    
}

#pragma mark - Go Back
- (IBAction)goBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


@end
