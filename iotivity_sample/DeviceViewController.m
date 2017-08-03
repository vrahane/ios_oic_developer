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
#import "ResourceDetailsViewController.h"
#import "NewtManagerViewController.h"
#import "iotivity_itf.h"
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
@property (strong, nonatomic) PeripheralResource *pResource;
@property (nonatomic, strong) NSString *uri;
@property (nonatomic) uint8_t index;
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
    _pResource = [[PeripheralResource alloc] init];
    NSLog(@"%s", peripheral.devAddr.addr);
    
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

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:true];
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
    
    _pResource = _peripheralResources[indexPath.row];
    cell.layer.cornerRadius = 8.0f;
    cell.uriLabel.clipsToBounds = true;
    cell.uriLabel.layer.cornerRadius = 7.0f;
    cell.uriLabel.backgroundColor = [UIColor whiteColor];
    [cell.uriLabel.layer setBorderWidth:0.1f];
    [cell.uriLabel.layer setShadowColor:[UIColor grayColor].CGColor];
    [cell.uriLabel.layer setShadowOpacity:0.20f];
    [cell.uriLabel.layer setShadowRadius:2.0f];
    [cell.uriLabel.layer setShadowOffset:CGSizeMake(0.0f, 1.0f)];
    cell.uriLabel.text = _pResource.uri;

    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    //*** NEED TO MAKE THIS PR GLOBAL ***//
    _pResource = _peripheralResources[indexPath.row];
    if ([_pResource.uri containsString:@"omgr"]) {
        NewtManagerViewController *nvc = [[NewtManagerViewController alloc] initWithNibName:@"NewtManagerViewController" bundle:nil];
        [self.navigationController pushViewController:nvc animated:true];
        
    } else {
        _pResource = _peripheralResources[indexPath.row];
        self.uri = _pResource.uri;
        self.index = (uint8_t) indexPath.row;
        [[iotivity_itf shared] get_generic:self andURI:_pResource.uri andDevAddr: peripheral.devAddr];
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
    for (PeripheralResource *pres in pr.resources) {
        NSLog(@"%@",pres.resourceName);
    }
    NSLog(@"AAAAAAA L: %lu",(unsigned long)[pr.resources count]);
    pr.devAddr = peripheral.devAddr;
    
    ResourceDetailsViewController *rvc = [[ResourceDetailsViewController alloc] initWithNibName:@"ResourceDetailsViewController" bundle:nil];
    [self.navigationController pushViewController:rvc animated:YES];
    NSLog(@"%lu",(unsigned long)[peripheral.resources count]);
    if([rvc.peripheral.resources count] > 0){
        [rvc.peripheral.resources removeAllObjects];
    }
    rvc.peripheral = pr;
    rvc.navigationTitle = self.uri;
    rvc.resourceIndex = self.index;
    rvc.resourceType = _pResource.resourceType;
    rvc.interface = _pResource.resourceInterface;
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

@end
