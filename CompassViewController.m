//
//  CompassViewController.m
//  iotivity_sample
//
//  Created by Pooja Gosavi on 6/26/17.
//  Copyright © 2017 Marko Kiiskila. All rights reserved.
//

#import "CompassViewController.h"
#import "CompassTableViewCell.h"
#import "iotivity_itf.h"

@interface CompassViewController ()

@end

@implementation CompassViewController

@synthesize mTableView;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    int64_t x[3];
    for (PeripheralResource *res in self.peripheral.resources) {
        NSLog(@"%@",res.resourceName);
        for (int i = 0; i < [res.resourceArrayValue count]; i++) {
            x[i] = [res.resourceArrayValue[i] unsignedLongLongValue];
            NSString *str = [NSString stringWithFormat:@"%lld",x[i]];
            NSLog(@"%@",str);
        }
        
    }
    
    UINib *nib;
    nib = [UINib nibWithNibName:@"CompassTableViewCell" bundle:nil];
    [self.mTableView registerNib:nib
            forCellReuseIdentifier:@"CompassTableViewCell"];
    self.navigationItem.title = self.uri;
}

-(void) viewWillDisappear:(BOOL)animated {
    }

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - table view
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CompassTableViewCell *cell = (CompassTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"CompassTableViewCell"];
    int64_t x[3];
    PeripheralResource *res = _peripheral.resources[0];
    x[indexPath.row] = [res.resourceArrayValue[indexPath.row] unsignedLongLongValue];
    cell.mValueLbl.text = [NSString stringWithFormat:@"%lld",x[indexPath.row]];
    if (indexPath.row == 0) {
       cell.mTypeLbl.text = @"X";
    }else if(indexPath.row == 1) {
       cell.mTypeLbl.text = @"Y";
    } else if(indexPath.row == 2) {
        cell.mTypeLbl.text = @"Z";
    }
    return cell;
}

#pragma mark - Observe
- (IBAction)mSwitchMethod:(id)sender {
    
    if ([self.mSwitch isOn]) {
        [[iotivity_itf shared] observe_light:self andURI:self.uri andDevAddr:self.peripheral.devAddr];
    }else {
        [[iotivity_itf shared] cancel_observer:self andURI:self.uri andDevAddr:_peripheral.devAddr andHandle:_peripheral.handle];
    }
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
        [mTableView reloadData];
    }];
    
}
- (IBAction)backBtnAction:(id)sender {

    [self.navigationController popViewControllerAnimated:true];
}

@end
