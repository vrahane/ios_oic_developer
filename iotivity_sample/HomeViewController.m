//
//  HomeViewController.m
//  iotivity_sample
//
//  Created by Pooja Gosavi on 6/22/17.
//  Copyright © 2017 Marko Kiiskila. All rights reserved.
//

#import "HomeViewController.h"
#import "HomeTableViewCell.h"
#import "CompassViewController.h"
#import "SmartDeviceViewController.h"
#import "HumidityViewController.h"
#import "iotivity_itf.h"
#import "GraphViewController.h"

@interface HomeViewController ()
@property (strong, nonatomic) NSMutableArray *mResources;
@property (strong, nonatomic) NSMutableDictionary *mResourceData;
@property (strong, nonatomic) NSMutableArray *mSmartDevices;
@property (strong, nonatomic) NSMutableArray *mSensors;
@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    UINib *nib;
    nib = [UINib nibWithNibName:@"HomeTableViewCell" bundle:nil];
    [self.mTableView registerNib:nib
            forCellReuseIdentifier:@"HomeTableViewCell"];

    _mResources = [[NSMutableArray alloc] init];
    _mSensors = [[NSMutableArray alloc] init];
    _mSmartDevices = [[NSMutableArray alloc] init];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated {

 
}

- (IBAction)iScanAction:(id)sender {
    
    [[iotivity_itf shared] discovery_start:self];
    
}

- (void)listUpdated {
    
    NSMutableArray *deviceArray = [[iotivity_itf shared] deviceWithIdx];
    
    for (Peripheral *p in deviceArray) {
        
        NSMutableArray *resources = [[NSMutableArray alloc]initWithArray:p.resources];
        for (PeripheralResource *pr in resources) {
            NSLog(@"%@",pr.uri);
            
            if([pr.uri containsString:@"/oic"] || [pr.uri containsString:@"/omgr"]) {
                
            } else {
                if([_mResources containsObject:pr]) {
                    //[_mResources removeObject:pr];
                }else {
                    [_mResources addObject:pr];
                }
            }
        }
    }
    
    for (PeripheralResource *pr in _mResources) {
        if ([pr.uri containsString:@"humidity"] || [pr.uri containsString:@"compass"] || [pr.uri containsString:@"tmp"] || [pr.uri containsString:@"temp"] || [pr.uri containsString:@"mag"] || [pr.uri containsString:@"lacc"]) {
            [_mSensors addObject:pr];
        }else {
            [_mSmartDevices addObject:pr];
        }
    }
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [_mTableView reloadData];
        
    }];
}

#pragma mark - UItableview
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(section == 0) {
        return [_mSmartDevices count];
    }else {
        return [_mSensors count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    HomeTableViewCell *cell = (HomeTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"HomeTableViewCell"];
    cell.selectionStyle = UITableViewCellSeparatorStyleNone;
    cell.layer.cornerRadius = 8.0f;
    cell.bgView.clipsToBounds = true;
    cell.bgView.layer.cornerRadius = 7.0f;
    cell.bgView.backgroundColor = [UIColor whiteColor];
    [cell.bgView.layer setBorderWidth:0.1f];
    [cell.bgView.layer setShadowColor:[UIColor grayColor].CGColor];
    [cell.bgView.layer setShadowOpacity:0.20f];
    [cell.bgView.layer setShadowRadius:2.0f];
    [cell.bgView.layer setShadowOffset:CGSizeMake(0.0f, 1.0f)];

    if(indexPath.section == 0) {
        PeripheralResource *pr = _mSmartDevices[indexPath.row];
        cell.uriLbl.text = pr.uri;
        cell.carrierLbl.text = pr.carrierType;
        cell.deviceAddr.text = [NSString stringWithUTF8String:pr.devAddr.addr ];
    } else {
        PeripheralResource *pr = _mSensors[indexPath.row];
        if([pr.uri containsString:@"temp"]){
            cell.uriLbl.text = @"Temperature";
        } else if([pr.uri containsString:@"compass"]){
            cell.uriLbl.text = @"Compass";
        }else if([pr.uri containsString:@"humid"]){
            cell.uriLbl.text = @"Humidity";
        }else if([pr.uri containsString:@"lacc"]){
            cell.uriLbl.text = @"Accelerometer";
        }else if([pr.uri containsString:@"mag"]){
            cell.uriLbl.text = @"Magnetometer";
        }
        cell.carrierLbl.text = pr.carrierType;
        cell.deviceAddr.text = [NSString stringWithUTF8String:pr.devAddr.addr ];

    }
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
   
    if (section == 0) {
        return @"Smart Devices";
    } else {
        return @"Sensors";
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //NSString *uri = @"";
    if(indexPath.section == 0) {
        PeripheralResource *pr = _mSmartDevices[indexPath.row];
        self.uri = pr.uri;
        [[iotivity_itf shared] get_generic:self andURI:pr.uri andDevAddr:pr.devAddr];
    } else {
        PeripheralResource *pr = _mSensors[indexPath.row];
        self.uri = pr.uri;
        [[iotivity_itf shared] get_generic:self andURI:pr.uri andDevAddr:pr.devAddr];
    }
}

-(void) getResourceDetails {
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self receiveData];
    }];
}

-(void) receiveData {
    Peripheral *pr;
    pr = [[iotivity_itf shared] resourceDetails];
    
    for (PeripheralResource *resource in pr.resources) {
        NSLog(@"%@",resource.resourceName);
    }
    if([self.uri containsString:@"compass"]) {
        CompassViewController *cvc = [[CompassViewController alloc] initWithNibName:@"CompassViewController" bundle:nil];
        cvc.peripheral = pr;
        cvc.peripheral.devAddr = pr.devAddr;
        cvc.uri = self.uri;
        [self.navigationController pushViewController:cvc animated:true];
    } else if ([self.uri containsString:@"hmty"] || [self.uri containsString:@"humid"]) {
        HumidityViewController *svc = [[HumidityViewController alloc] initWithNibName:@"HumidityViewController" bundle:nil];
        
        svc.peripheral = pr;
        svc.peripheral.devAddr = pr.devAddr;
        svc.uri = self.uri;
        
        [self.navigationController pushViewController:svc animated:true];

    }
    else {
        SmartDeviceViewController *svc = [[SmartDeviceViewController alloc] initWithNibName:@"SmartDeviceViewController" bundle:nil];
        
        svc.peripheral = pr;
        svc.peripheral.devAddr = pr.devAddr;
        svc.uri = self.uri;
        
        [self.navigationController pushViewController:svc animated:true];

    }
}


@end
