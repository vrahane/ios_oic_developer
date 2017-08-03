//
//  DeviceDetailsViewController.m
//  iotivity_sample
//
//  Created by Pooja Gosavi on 8/2/17.
//  Copyright © 2017 Marko Kiiskila. All rights reserved.
//

#import "DeviceDetailsViewController.h"
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
    [[iotivity_itf shared] obtain_platform_details:self andAddress:_peripheral.devAddr];
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

- (void) platformDetailsForDevice {
    Peripheral *p = [[iotivity_itf shared] platformDetails];
    NSLog(@"%@", p.platformID);
    _manufacturerLbl.text = p.manufacturerName;
    _platformIdLbl.text = p.platformID;
}

@end
