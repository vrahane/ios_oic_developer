//
//  LightViewController.m
//  iotivity_sample
//
//  Created by Pooja Gosavi on 5/25/17.
//  Copyright © 2017 Marko Kiiskila. All rights reserved.
//

#import "LightViewController.h"
#import "iotivity_itf.h"
#import "Peripheral.h"

@interface LightViewController ()

@end

@implementation LightViewController
@synthesize peripheral;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.getButton.clipsToBounds = true;
    self.getButton.layer.cornerRadius = 7.0f;
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)getAction:(id)sender {
    
    NSLog(@"%s",peripheral.devAddr.addr);
    self.xOrientation.text = @"";
    self.yOrientation.text = @"";
    self.zOrientation.text = @"";
    [[iotivity_itf shared] discovery_resource:self andURI:self.uri andDevAddr: peripheral.devAddr];
    
}

- (void)populateData
{
    // async notification from another thread, reload devicelist view from UI thread
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self getStatus];
        
    }];
}

- (void)getStatus
{
    Peripheral *pr = [[iotivity_itf shared] statusDetails];
    
    for (int i = 0; i < [pr.orientations count]; i++) {
        NSLog(@"%@", pr.orientations[i]);
    }
    
    self.xOrientation.text = [pr.orientations[0] stringValue];
    self.yOrientation.text = [pr.orientations[1] stringValue];
    self.zOrientation.text = [pr.orientations[2] stringValue];
    
}
- (IBAction)backAction:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end
