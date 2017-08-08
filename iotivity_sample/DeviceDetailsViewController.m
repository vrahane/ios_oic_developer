//
//  DeviceDetailsViewController.m
//  iotivity_sample
//
//  Created by Pooja Gosavi on 8/2/17.
//  Copyright © 2017 Marko Kiiskila. All rights reserved.
//

#import "DeviceDetailsViewController.h"
#import "ResourceDetailsViewController.h"
#import "NewtManagerViewController.h"
#import "ResourceCell.h"
#import "Peripheral.h"
#import "iotivity_itf.h"

@interface DeviceDetailsViewController ()
@property (strong, nonatomic) PeripheralResource *pResource;
@property (strong, nonatomic) NSMutableArray *peripheralResources;
@end

@implementation DeviceDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    UINib *nib = [UINib nibWithNibName:@"ResourceCell" bundle:nil];
    [_resourceList registerNib:nib forCellReuseIdentifier:@"ResourceCell"];
    _peripheralResources = [[NSMutableArray alloc] initWithArray:_peripheral.resources];
    
    _resourceList.layer.borderColor = (__bridge CGColorRef _Nullable)([UIColor blackColor]);
    _resourceList.layer.borderWidth = 1.0f;
    
    self.view.backgroundColor = [UIColor whiteColor];
    _uuidLbl.text = _peripheral.uuid;
    _carrierLbl.text = _peripheral.type;
    _manufacturerLbl.text = _manufacturerName;
    _platformIdLbl.text = _platformId;
    
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
}

- (IBAction)backAction:(id)sender {
    [self.navigationController popViewControllerAnimated:true];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_peripheralResources count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ResourceCell *cell = (ResourceCell *)[tableView dequeueReusableCellWithIdentifier:@"ResourceCell"];
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

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ResourceCell *cell = [_resourceList cellForRowAtIndexPath:indexPath];
    NSLog(@"%@",cell.uriLabel.text);
    _pResource = _peripheralResources[indexPath.row];
    if ([cell.uriLabel.text containsString:@"omgr"]) {
        NewtManagerViewController *nvc = [[NewtManagerViewController alloc] initWithNibName:@"NewtManagerViewController" bundle:nil];
        nvc.devAddr = _peripheral.devAddr;
        [self.navigationController pushViewController:nvc animated:true];
    } else {
        [[iotivity_itf shared] get_generic:self andURI:cell.uriLabel.text andDevAddr:_peripheral.devAddr];
    }
}

- (void) getResourceDetails {
    
    Peripheral *p = [[iotivity_itf shared] resourceDetails];
    NSLog(@"Resource Details");
    ResourceDetailsViewController *rvc = [[ResourceDetailsViewController alloc] initWithNibName:@"ResourceDetailsViewController" bundle:nil];
    rvc.resourceType = _pResource.resourceType;
    rvc.interface = _pResource.resourceInterface;
    rvc.peripheral = p;
    rvc.devAddr = _pResource.devAddr;
    rvc.navigationTitle = _pResource.uri;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.navigationController pushViewController:rvc animated:true];
    });
}
@end
