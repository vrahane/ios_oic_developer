//
//  AccelerometerViewController.m
//  iotivity_sample
//
//  Created by Pooja Gosavi on 7/7/17.
//  Copyright © 2017 Marko Kiiskila. All rights reserved.
//

#import "AccelerometerViewController.h"
#import "SmartDeviceTableViewCell.h"

@interface AccelerometerViewController () <ChartViewDelegate>
@property (strong, nonatomic) NSMutableArray *chartValues;

@end

@implementation AccelerometerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    UINib *nib = [UINib nibWithNibName:@"SmartDeviceTableViewCell" bundle:nil];
    [_mSmartDeviceList registerNib:nib forCellReuseIdentifier:@"SmartDeviceTableViewCell"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - TableView methods

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.peripheral.resources count];
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SmartDeviceTableViewCell *cell = (SmartDeviceTableViewCell *) [tableView dequeueReusableCellWithIdentifier:@"SmartDeviceTableViewCell"];
    
    return cell;
}


@end
