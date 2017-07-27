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
#import "iotivity_itf.h"

@interface DeviceListViewController () <UITableViewDelegate, UITableViewDataSource,UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UIButton *scanButton;
@property (weak, nonatomic) IBOutlet UITableView *deviceList;

@property (strong, nonatomic) NSMutableArray *devices;

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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)scanButtonPressed:(id)sender {
    NSLog(@"scanButtonPressed\n");
    
   // [[iotivity_itf shared] discovery_start:self];
}


- (void)listUpdated
{
    // async notification from another thread, reload devicelist view from UI thread
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [_deviceList reloadData];
        
    }];
}

#pragma mark - DeviceList Table Methods


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DeviceCell *cell = [tableView dequeueReusableCellWithIdentifier
                                     :@"DeviceCell"
                                     forIndexPath:indexPath];
    
    Peripheral *p;
    //p = [[iotivity_itf shared] deviceWithIdx:[indexPath row]];
    
    
    cell.deviceNameLabel.text = p.uuid;
    self.uuid = p.uuid;
    
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
    DeviceViewController *dvc = [[DeviceViewController alloc] init];
    //Peripheral *
    
    Peripheral *p;// = [[iotivity_itf shared] platformDetails];
    dvc.manufacturerName = p.manufacturerName;
    dvc.platformId = p.platformID;
    
    //p = [[iotivity_itf shared] deviceWithIdx:[indexPath row]];
    
    
    
    dvc.peripheral = p;
    
    [self.navigationController pushViewController:dvc animated:YES];
}

@end
