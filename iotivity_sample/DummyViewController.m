//
//  DummyViewController.m
//  iotivity_sample
//
//  Created by Pooja Gosavi on 7/27/17.
//  Copyright © 2017 Marko Kiiskila. All rights reserved.
//

#import "DummyViewController.h"
#import "iotivity_itf.h"
#import "DeviceListViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>

#define CA_GATT_SERVICE_UUID "ADE3D529-C784-4F63-A987-EB69F70EE816"

static CBUUID* g_OICGattServiceUUID = NULL;
bool timeOut = false;

@interface DummyViewController () <CBPeripheralDelegate, CBCentralManagerDelegate>
@property (strong, nonatomic) NSMutableArray *CBPeripheralList;
@property (strong, nonatomic) NSMutableArray *uuidList;
@property (strong, nonatomic) NSArray<CBUUID*>* servicesToScanFor;
@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) NSMutableArray *dataFromIP;
@end

@implementation DummyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
#pragma mark - Bluetooth Init
    _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    g_OICGattServiceUUID = [CBUUID UUIDWithString:@CA_GATT_SERVICE_UUID];
    _servicesToScanFor = @[g_OICGattServiceUUID];
    _CBPeripheralList = [[NSMutableArray alloc] init];
    _uuidList = [[NSMutableArray alloc] init];
    _dataFromIP = [[NSMutableArray alloc] init];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central{
    NSString *messtoshow;
    
    switch (central.state) {
        case CBManagerStateUnknown:
        {
            messtoshow=[NSString stringWithFormat:@"State unknown, update imminent."];
            break;
        }
        case CBManagerStateResetting:
        {
            messtoshow=[NSString stringWithFormat:@"The connection with the system service was momentarily lost, update imminent."];
            break;
        }
        case CBManagerStateUnsupported:
        {
            messtoshow=[NSString stringWithFormat:@"The platform doesn't support Bluetooth Low Energy"];
            break;
        }
        case CBManagerStateUnauthorized:
        {
            messtoshow=[NSString stringWithFormat:@"The app is not authorized to use Bluetooth Low Energy"];
            break;
        }
        case CBManagerStatePoweredOff:
        {
            messtoshow=[NSString stringWithFormat:@"Bluetooth is currently powered off."];
            break;
        }
        case CBManagerStatePoweredOn:
        {
            messtoshow=[NSString stringWithFormat:@"Bluetooth is currently powered on and available to use."];
            NSDictionary* options = @{ CBCentralManagerScanOptionAllowDuplicatesKey: @YES };
            [self startTimer];
            [_centralManager scanForPeripheralsWithServices:_servicesToScanFor options:options];
            
            break;
        }
            
    }
    NSLog(@"%@", messtoshow);
}



- (void) startTimer {
    _timer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(stopTimer) userInfo:nil repeats:nil];
}

- (void) stopTimer {
    [_centralManager stopScan];
    for (CBPeripheral *p in _CBPeripheralList) {
        [_uuidList addObject:[p.identifier UUIDString]];
    }
    [self scanUsingIP];
}

- (void) centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI {
    NSString* deviceName = [advertisementData objectForKey:CBAdvertisementDataLocalNameKey];
    NSLog(@"Device = %@",deviceName);
    NSLog(@"Peripheral Identifier = %@",[peripheral.identifier UUIDString]);
    if (![_CBPeripheralList containsObject:peripheral]) {
        [_CBPeripheralList addObject:peripheral];
    }
    NSLog(@"%lu",(unsigned long)[_CBPeripheralList count]);
}

- (void) scanUsingIP {
    [self timeOutTimer];
    [[iotivity_itf shared] discovery_start:self];
}

- (void) listUpdated {
    NSMutableArray *per = [[iotivity_itf shared] devices_found];
    _dataFromIP = per;
    for (Peripheral * p in per) {
        [_uuidList addObject:p.uuid];
    }
    NSLog(@"222");
    
}

- (void) timeOutTimer {
    _timer = [NSTimer scheduledTimerWithTimeInterval:15 target:self selector:@selector(timeOut) userInfo:nil repeats:nil];
}

- (void) timeOut {
    DeviceListViewController *dvlc = [[DeviceListViewController alloc] initWithNibName:@"DeviceListViewController" bundle:nil];
    dvlc.peripheralList = _uuidList;
    dvlc.dataFromIP = _dataFromIP;
    [self.navigationController pushViewController:dvlc animated:true];
}
@end
