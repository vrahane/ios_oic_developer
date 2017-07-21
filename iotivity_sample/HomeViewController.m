//
//  HomeViewController.m
//  iotivity_sample
//
//  Created by Pooja Gosavi on 6/22/17.
//  Copyright © 2017 Marko Kiiskila. All rights reserved.
//

#import "HomeViewController.h"
#import "CompassViewController.h"
#import "HomeTableViewCell.h"
#import "SmartDeviceViewController.h"
#import "SensorViewController.h"
#import "iotivity_itf.h"

@interface HomeViewController ()
@property (strong, nonatomic) NSMutableArray *mResources;
@property (strong, nonatomic) NSMutableDictionary *mResourceData;
@property (strong, nonatomic) NSMutableArray *mSmartDevices;
@property (strong, nonatomic) NSMutableArray *mSensors;
@property (strong, nonatomic) NSString *resourceURI;

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

- (void) viewWillDisappear:(BOOL)animated {
    [[iotivity_itf shared] discovery_end];
}

- (IBAction)iScanAction:(id)sender {
    
    [[iotivity_itf shared] discovery_start:self];
    
}

- (void)listUpdated {
    
    NSMutableArray *deviceArray = [[iotivity_itf shared] deviceWithIdx];
    _mResources = [[NSMutableArray alloc] init];
    for (Peripheral *p in deviceArray) {
        
        NSMutableArray *resources = [[NSMutableArray alloc]initWithArray:p.resources];
        for (PeripheralResource *pr in resources) {
            NSLog(@"%@",pr.uri);
            
            if([pr.uri containsString:@"/oic"] || [pr.uri containsString:@"/omgr"]) {
                
            } else {
                 [_mResources addObject:pr];
            }
        }
    }
    
    _mSensors = [[NSMutableArray alloc] init];
    _mSmartDevices = [[NSMutableArray alloc] init];
    
    for (PeripheralResource *pr in _mResources) {
        if ([pr.resourceType containsString:@"x.mynewt.snsr"]) {
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
    //lightimg.png
    //sensorimg.png
    if(indexPath.section == 0) {
        PeripheralResource *pr = _mSmartDevices[indexPath.row];
        cell.imgView.image = [UIImage imageNamed:@"lightimg.png"];
        cell.typeLabel.text = [self humanReadableResourceName:pr.uri];
        NSString *str = [[pr.uri componentsSeparatedByString:@"/"] objectAtIndex:1];
        cell.detailLabel.text = str;
    } else {
        PeripheralResource *pr = _mSensors[indexPath.row];
        cell.imgView.image = [UIImage imageNamed:@"sensorimg.png"];
        cell.typeLabel.text = [self humanReadableResourceName:pr.uri];
        NSString *str = [[pr.uri componentsSeparatedByString:@"/"] objectAtIndex:1];
        cell.detailLabel.text = str;
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
        self.resourceURI = pr.uri;
        self.uri = pr.resourceType;
        [[iotivity_itf shared] get_generic:self andURI:pr.uri andDevAddr:pr.devAddr];
    } else {
        PeripheralResource *pr = _mSensors[indexPath.row];
        self.resourceURI = pr.uri;
        self.uri = pr.resourceType;
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
    
    NSMutableDictionary *resourceDictionary = [self sortPeripheralsForSensors:(NSMutableArray *)pr.resources andType: (NSString *)self.uri];
    
    if([self.uri containsString:@"x.mynewt.snsr"]) {
        SensorViewController *svc = [[SensorViewController alloc] initWithNibName:@"SensorViewController" bundle:nil];
        
        svc.peripheral = pr;
        svc.dict = resourceDictionary;
        svc.peripheral.devAddr = pr.devAddr;
        svc.navTitle = [self humanReadableResourceName:self.uri];
        svc.uri = self.resourceURI;
        [self.navigationController pushViewController:svc animated:true];
    }
    else
    {

        if ([self.uri containsString:@"oic.r.3"]) {
            CompassViewController *cvc = [[CompassViewController alloc] initWithNibName:@"CompassViewController" bundle:nil];
            cvc.peripheral = pr;
            cvc.peripheral.devAddr = pr.devAddr;
            cvc.uri = self.uri;
            [self.navigationController pushViewController:cvc animated:true];

        } else {
            SmartDeviceViewController *svc = [[SmartDeviceViewController alloc] initWithNibName:@"SmartDeviceViewController" bundle:nil];
        
            svc.peripheral = pr;
            svc.peripheral.devAddr = pr.devAddr;
            svc.uri = self.resourceURI;
            [self.navigationController pushViewController:svc animated:true];
        }

    }
}

- (NSMutableDictionary *) sortPeripheralsForSensors:(NSMutableArray *)resources andType: (NSString *) resourceURI{
    
    NSMutableDictionary *resourceDictionary = [[NSMutableDictionary alloc] init];
    
    if([resourceURI containsString:@"acc"]) {
        for (PeripheralResource *pr in resources) {
            NSString *uri = pr.resourceName;
            if([uri isEqualToString:@"x"]) {
                [resourceDictionary setObject:[NSNumber numberWithDouble:pr.resourceDoubleValue] forKey:uri];
            }
            if([uri isEqualToString:@"y"]) {
                [resourceDictionary setObject:[NSNumber numberWithDouble:pr.resourceDoubleValue] forKey:uri];
            }
            if([uri isEqualToString:@"z"]) {
                [resourceDictionary setObject:[NSNumber numberWithDouble:pr.resourceDoubleValue] forKey:uri];
            }
        }
    } else if([resourceURI containsString:@"mag"]) {
        for (PeripheralResource *pr in resources) {
            NSString *uri = pr.resourceName;
            if([uri isEqualToString:@"x"]) {
                [resourceDictionary setObject:[NSNumber numberWithDouble:pr.resourceDoubleValue] forKey:uri];
            }
            if([uri isEqualToString:@"y"]) {
                [resourceDictionary setObject:[NSNumber numberWithDouble:pr.resourceDoubleValue] forKey:uri];
            }
            if([uri isEqualToString:@"z"]) {
                [resourceDictionary setObject:[NSNumber numberWithDouble:pr.resourceDoubleValue] forKey:uri];
            }
        }
        
    }else if([resourceURI containsString:@"tmp"] || [resourceURI containsString:@"temp"] ) {
        for (PeripheralResource *pr in resources) {
            NSString *uri = pr.resourceName;
            if([uri isEqualToString:@"temp"]) {
                [resourceDictionary setObject:[NSNumber numberWithDouble:pr.resourceDoubleValue] forKey:uri];
            }
        }
    }else if([resourceURI containsString:@"hmty"] || [resourceURI containsString:@"humid"]) {
        for (PeripheralResource *pr in resources) {
            NSString *uri = pr.resourceName;
            if([uri isEqualToString:@"humid"]) {
                [resourceDictionary setObject:[NSNumber numberWithDouble:pr.resourceDoubleValue] forKey:uri];
            }
        }
    } else if([resourceURI containsString:@"psr"]) {
        for (PeripheralResource *pr in resources) {
            NSString *uri = pr.resourceName;
            if([uri isEqualToString:@"press"]) {
                [resourceDictionary setObject:[NSNumber numberWithDouble:pr.resourceDoubleValue] forKey:uri];
            }
        }
        
    } else if([resourceURI containsString:@"col"]) {
        for (PeripheralResource *pr in resources) {
            NSString *uri = pr.resourceName;
            if([uri isEqualToString:@"r"]) {
                [resourceDictionary setObject:[NSNumber numberWithDouble:pr.resourceDoubleValue] forKey:uri];
            }
            if([uri isEqualToString:@"g"]) {
                [resourceDictionary setObject:[NSNumber numberWithDouble:pr.resourceDoubleValue] forKey:uri];
            }
            if([uri isEqualToString:@"b"]) {
                [resourceDictionary setObject:[NSNumber numberWithDouble:pr.resourceDoubleValue] forKey:uri];
            }
            if([uri isEqualToString:@"lux"]) {
                [resourceDictionary setObject:[NSNumber numberWithDouble:pr.resourceDoubleValue] forKey:uri];
            }
            
        }
        
    } else if([resourceURI containsString:@"gyr"]) {
        for (PeripheralResource *pr in resources) {
            NSString *uri = pr.resourceName;
            if([uri isEqualToString:@"x"]) {
                [resourceDictionary setObject:[NSNumber numberWithDouble:pr.resourceDoubleValue] forKey:uri];
            }
            if([uri isEqualToString:@"y"]) {
                [resourceDictionary setObject:[NSNumber numberWithDouble:pr.resourceDoubleValue] forKey:uri];
            }
            if([uri isEqualToString:@"z"]) {
                [resourceDictionary setObject:[NSNumber numberWithDouble:pr.resourceDoubleValue] forKey:uri];
            }
        }
        
    }else if([resourceURI containsString:@"eul"]) {
        for (PeripheralResource *pr in resources) {
            NSString *uri = pr.resourceName;
            if([uri isEqualToString:@"h"]) {
                [resourceDictionary setObject:[NSNumber numberWithDouble:pr.resourceDoubleValue] forKey:uri];
            }
            if([uri isEqualToString:@"r"]) {
                [resourceDictionary setObject:[NSNumber numberWithDouble:pr.resourceDoubleValue] forKey:uri];
            }
            if([uri isEqualToString:@"p"]) {
                [resourceDictionary setObject:[NSNumber numberWithDouble:pr.resourceDoubleValue] forKey:uri];
            }
        }
        
    }else if([resourceURI containsString:@"quat"]) {
        for (PeripheralResource *pr in resources) {
            NSString *uri = pr.resourceName;
            if([uri isEqualToString:@"x"]) {
                [resourceDictionary setObject:[NSNumber numberWithDouble:pr.resourceDoubleValue] forKey:uri];
            }
            if([uri isEqualToString:@"y"]) {
                [resourceDictionary setObject:[NSNumber numberWithDouble:pr.resourceDoubleValue] forKey:uri];
            }
            if([uri isEqualToString:@"z"]) {
                [resourceDictionary setObject:[NSNumber numberWithDouble:pr.resourceDoubleValue] forKey:uri];
            }
            if([uri isEqualToString:@"w"]) {
                [resourceDictionary setObject:[NSNumber numberWithDouble:pr.resourceDoubleValue] forKey:uri];
            }
            
        }
        
    }else if([resourceURI containsString:@"grav"]) {
        for (PeripheralResource *pr in resources) {
            NSString *uri = pr.resourceName;
            if([uri isEqualToString:@"x"]) {
                [resourceDictionary setObject:[NSNumber numberWithDouble:pr.resourceDoubleValue] forKey:uri];
            }
            if([uri isEqualToString:@"y"]) {
                [resourceDictionary setObject:[NSNumber numberWithDouble:pr.resourceDoubleValue] forKey:uri];
            }
            if([uri isEqualToString:@"z"]) {
                [resourceDictionary setObject:[NSNumber numberWithDouble:pr.resourceDoubleValue] forKey:uri];
            }
        }
        
    }else if([resourceURI containsString:@"lt"]) {
        for (PeripheralResource *pr in resources) {
            NSString *uri = pr.resourceName;
            if([uri isEqualToString:@"ir"]) {
                [resourceDictionary setObject:[NSNumber numberWithDouble:pr.resourceDoubleValue] forKey:uri];
            }
            if([uri isEqualToString:@"full"]) {
                [resourceDictionary setObject:[NSNumber numberWithDouble:pr.resourceDoubleValue] forKey:uri];
            }
            if([uri isEqualToString:@"lux"]) {
                [resourceDictionary setObject:[NSNumber numberWithDouble:pr.resourceDoubleValue] forKey:uri];
            }
        }
        
    }
    
    
    return resourceDictionary;
    
}

- (NSString *) humanReadableResourceName : (NSString *) resourceURI {
    
    NSString *readableString = @"";
    if([resourceURI containsString:@"acc"]) {
        if ([resourceURI containsString:@"lacc"]) {
            readableString = @"Linear Accelerometer";
        } else {
            readableString = @"Accelerometer";
        }
    } else if([resourceURI containsString:@"mag"]) {
        readableString = @"Magnetometer";
    }else if([resourceURI containsString:@"tmp"] || [resourceURI containsString:@"temp"] ) {
        if([resourceURI containsString:@"ambtmp"]){
            readableString = @"Ambient Temperature Sensor";
        } else {
            readableString = @"Temperature Sensor";
        }
    }else if([resourceURI containsString:@"hmty"] || [resourceURI containsString:@"humid"]) {
        if([resourceURI containsString:@"tmp"]){
           readableString = @"Relative Humidity Sensor";
        }else {
            readableString = @"Humidity Sensor";
        }
    } else if([resourceURI containsString:@"psr"]) {
        readableString = @"Pressure Sensor";
    } else if([resourceURI containsString:@"col"]) {
        readableString = @"Color Sensor";
    } else if([resourceURI containsString:@"gyr"]) {
        readableString = @"Gyroscope";
    }else if([resourceURI containsString:@"eul"]) {
        readableString = @"Euler Sensor";
    }else if([resourceURI containsString:@"quat"]) {
        readableString = @"Rotation Vector (Quaternion)";
    }else if([resourceURI containsString:@"grav"]) {
        readableString = @"Gravity Sensor";
    }else if([resourceURI containsString:@"lt"]) {
        readableString = @"Light Sensor";
    }else if([resourceURI containsString:@"light"]) {
        readableString = @"Light";
    }else if([resourceURI containsString:@"compass"]) {
        readableString = @"Compass";
    }
    return readableString;
}

@end
