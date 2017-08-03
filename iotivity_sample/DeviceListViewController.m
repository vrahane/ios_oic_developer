//
//  DeviceListViewController.m
//  iotivity_sample
//
//  Created by Marko Kiiskila on 5/15/17.
//  Copyright © 2017 Marko Kiiskila. All rights reserved.
//

#import "DeviceListViewController.h"
#import "DeviceCell.h"
#import "DeviceViewController.h"
#import "DeviceDetailsViewController.h"
#import "iotivity_itf.h"
#import <iotivity-csdk/octypes.h>

@interface DeviceListViewController () <UITableViewDelegate, UITableViewDataSource,UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UIButton *scanButton;
@property (weak, nonatomic) IBOutlet UITableView *deviceList;
@property (nonatomic) bool isFromIP;
@property (strong, nonatomic) NSMutableArray *devices;
@property (strong, nonatomic) Peripheral *peripheralPassed;

@end

@implementation DeviceListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // Notify controller of item being selected, and be source of data.
   
    self.deviceList.delegate = self;
    self.deviceList.dataSource = self;
    
    self.deviceList.rowHeight = UITableViewAutomaticDimension;
    
    self.deviceList.backgroundColor = [UIColor clearColor];
    
    //Scan Label UI Modifications
    self.scanButton.clipsToBounds = true;
    self.scanButton.layer.cornerRadius = 7.0f;
    
    // register tableview class for reuse
    UINib *nib;
    nib = [UINib nibWithNibName:@"DeviceCell" bundle:nil];
    [self.deviceList registerNib:nib
              forCellReuseIdentifier:@"DeviceCell"];

}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:true];
    [[iotivity_itf shared] discovery_end];
}

- (void) viewWillAppear:(BOOL)animated {
    _isFromIP = false;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)scanButtonPressed:(id)sender {
    NSLog(@"scanButtonPressed\n");
    
    [[iotivity_itf shared] discovery_start:self];
}


- (void)getResourceDetails
{
   
}

#pragma mark - DeviceList Table Methods


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_peripheralList count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DeviceCell *cell = [tableView dequeueReusableCellWithIdentifier
                                     :@"DeviceCell"
                                     forIndexPath:indexPath];
    
    
    
    cell.deviceNameLabel.text = _peripheralList[indexPath.row];
    self.uuid = _peripheralList[indexPath.row];
    
    cell.selectionStyle = 0;
    cell.layer.cornerRadius = 8.0f;
    cell.deviceNameLabel.clipsToBounds = true;
    cell.deviceNameLabel.layer.cornerRadius = 7.0f;
    cell.deviceNameLabel.backgroundColor = [UIColor whiteColor];
    [cell.deviceNameLabel.layer setBorderWidth:0.1f];
    [cell.deviceNameLabel.layer setShadowColor:[UIColor grayColor].CGColor];
    [cell.deviceNameLabel.layer setShadowOpacity:0.20f];
    [cell.deviceNameLabel.layer setShadowRadius:2.0f];
    [cell.deviceNameLabel.layer setShadowOffset:CGSizeMake(0.0f, 1.0f)];
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    DeviceViewController *dvc = [[DeviceViewController alloc] init];
//    //Peripheral *
//    
//    Peripheral *p = [[iotivity_itf shared] platformDetails];
//    dvc.manufacturerName = p.manufacturerName;
//    dvc.platformId = p.platformID;
//    
//    p = [[iotivity_itf shared] deviceWithIdx:[indexPath row]];
//    
//    
//    
//    dvc.peripheral = p;
//    
//    [self.navigationController pushViewController:dvc animated:YES];
    
    DeviceCell *cell = [_deviceList cellForRowAtIndexPath:indexPath];
    _uuid = cell.deviceNameLabel.text;
    
    for (Peripheral *p in _dataFromIP) {
        if ([p.uuid isEqualToString:_uuid]) {
            _isFromIP = true;
            _peripheralPassed = [[Peripheral alloc] initWithUuid:p.uuid];
            _peripheralPassed = p;
        }
    }
    
    if (_isFromIP == true) {
        DeviceViewController *dvc = [[DeviceViewController alloc] initWithNibName:@"DeviceViewController" bundle:nil];
        dvc.peripheral = _peripheralPassed;
        [self.navigationController pushViewController:dvc animated:true];
    } else {
        [[iotivity_itf shared] discover_allDevices:self andAddress:_uuid];
    }
    
    
}

- (void) listUpdated {
    
    NSMutableArray *peripheralArr = [[iotivity_itf shared] devices_found];
    
    for (Peripheral *per in peripheralArr) {
        if([per.uuid isEqualToString:_uuid]) {
            _peripheralPassed = [[Peripheral alloc] initWithUuid:per.uuid];
            _peripheralPassed = per;
            break;
        }
    }
    
    DeviceViewController *dvc = [[DeviceViewController alloc] initWithNibName:@"DeviceViewController" bundle:nil];
    dvc.peripheral = _peripheralPassed;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.navigationController pushViewController:dvc animated:true];
    });
    

}

@end
