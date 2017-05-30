//
//  DeviceViewController.m
//  iotivity_sample
//
//  Created by Marko Kiiskila on 5/16/17.
//  Copyright © 2017 Marko Kiiskila. All rights reserved.
//

#import "DeviceViewController.h"
#import "DetailViewController.h"
#import "LightViewController.h"
#import "ResourceCell.h"
#import "HumidityViewController.h"

#include <iotivity-csdk/octypes.h>
#include <iotivity-csdk/ocstack.h>

@interface DeviceViewController () <UITableViewDelegate,UITableViewDataSource,
UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *uuidLabel;
@property (weak, nonatomic) IBOutlet UILabel *typeLabel;
@property (weak, nonatomic) IBOutlet UILabel *manufacturerLabel;
@property (weak, nonatomic) IBOutlet UITableView *resourceList;
@property (strong, nonatomic) NSMutableArray *peripheralResources;

@end

OCDevAddr *devAddr;

@implementation DeviceViewController

@synthesize peripheral;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    _uuidLabel.text = peripheral.uuid;
    _typeLabel.text = peripheral.type;
    _manufacturerLabel.text = self.manufacturerName;
    _nameLabel.text = self.platformId;
    
    _resourceList.delegate = self;
    _resourceList.dataSource = self;
    _peripheralResources = [[NSMutableArray alloc] initWithArray:peripheral.resources];
    NSLog(@"%s", peripheral.devAddr.addr);
    
    
    for(PeripheralResource *pr in peripheral.resources){
        if([pr.uri containsString:@"oic"]){
            [_peripheralResources removeObject:pr];
        }
    }
    
    NSLog(@"%lu",(unsigned long)[_peripheralResources count]);
    
    UINib *nib;
    nib = [UINib nibWithNibName:@"ResourceCell" bundle:nil];
    [self.resourceList registerNib:nib
              forCellReuseIdentifier:@"ResourceCell"];
    
    //[_resourceList reloadData];
    _resourceList.layer.borderColor = (__bridge CGColorRef _Nullable)([UIColor blackColor]);
    _resourceList.layer.borderWidth = 1.0f;
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    
    //Background View Customization
    self.backgroundView.clipsToBounds = true;
    self.backgroundView.backgroundColor = [UIColor whiteColor];
    self.backgroundView.layer.cornerRadius = 7.0f;
    self.backgroundView.layer.borderWidth = 0.1f;
    self.backgroundView.layer.shadowColor = [UIColor grayColor].CGColor;
    self.backgroundView.layer.shadowOpacity = 0.2f;
    self.backgroundView.layer.shadowRadius = 2.0f;
    self.backgroundView.layer.shadowOffset = CGSizeMake(0.0f, 0.1f);
    
    self.resourceList.backgroundView.clipsToBounds = true;
    self.resourceList.layer.cornerRadius = 7.0f;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_peripheralResources count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // reuse uitableviewcell, if possible
    ResourceCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ResourceCell"
                                                                    forIndexPath:indexPath];
    
    cell.selectionStyle = 0;
    
    PeripheralResource *pr = _peripheralResources[indexPath.row];
    cell.layer.cornerRadius = 8.0f;
    cell.uriLabel.clipsToBounds = true;
    cell.uriLabel.layer.cornerRadius = 7.0f;
    cell.uriLabel.backgroundColor = [UIColor whiteColor];
    [cell.uriLabel.layer setBorderWidth:0.1f];
    [cell.uriLabel.layer setShadowColor:[UIColor grayColor].CGColor];
    [cell.uriLabel.layer setShadowOpacity:0.20f];
    [cell.uriLabel.layer setShadowRadius:2.0f];
    [cell.uriLabel.layer setShadowOffset:CGSizeMake(0.0f, 1.0f)];
    cell.uriLabel.text = pr.uri;

    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    
    PeripheralResource *pr = _peripheralResources[indexPath.row];
    
    if ([pr.uri containsString:@"compass"]) {
        NSLog(@"string contains compass!");
        LightViewController *lvc = [[LightViewController alloc]initWithNibName:@"LightViewController" bundle:nil];
        [self.navigationController pushViewController:lvc animated:YES];
        lvc.peripheral = peripheral;
        lvc.uri = pr.uri;
        
    } else if ([pr.uri containsString:@"humidity"] || [pr.uri containsString:@"temp"] || [pr.uri containsString:@"tmp"] || [pr.uri containsString:@"hmty"]){
        NSLog(@"string contains h or t!");
        HumidityViewController *hvc = [[HumidityViewController alloc]initWithNibName:@"HumidityViewController" bundle:nil];
        [self.navigationController pushViewController:hvc animated:YES];
        hvc.peripheral = peripheral;
        hvc.uri = pr.uri;
        
    }else {
        NSLog(@"string does not contain light");
        DetailViewController *dvc = [[DetailViewController alloc] init];
        [self.navigationController pushViewController:dvc animated:YES];
        dvc.navigationTitle = pr.uri;
    }
    
}


@end
