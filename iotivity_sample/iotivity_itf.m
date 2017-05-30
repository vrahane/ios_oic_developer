//
//  iotivity_itf.m
//  iotivity_sample
//
//  Created by Marko Kiiskila on 5/15/17.
//  Copyright © 2017 Marko Kiiskila. All rights reserved.
//

#import "iotivity_itf.h"
#import "LightViewController.h"
#import "HumidityViewController.h"
#include <iotivity-csdk/octypes.h>
#include <iotivity-csdk/ocstack.h>

@interface iotivity_itf ()

@property (strong, nonatomic) NSLock *mutex;

// peripherals array should protected by mutex
@property (nonatomic) NSMutableArray *peripherals;
@property (nonatomic, retain) NSString *platformId;
@property (nonatomic, retain) NSString *manufacturerName;
@property (nonatomic) bool resourceStatus;
@property (nonatomic, retain) NSString *resName;
@property (nonatomic) NSMutableArray *orientationArray;

//HumidityData and TempData
@property (nonatomic, retain) NSString *resType;
@property (nonatomic, retain) NSString *humidValue;
@property (nonatomic, retain) NSString *tempValue;
@property (nonatomic, retain) NSString *tempUnit;

@property (nonatomic) OCDevAddr *devAddr;

@property (atomic) id discovery_watcher;

@end
static id delegate;

@implementation iotivity_itf

+ (instancetype)shared
{
    static iotivity_itf *itf;
    
    if (!itf) {
        itf = [[iotivity_itf alloc] initPrivate];
    }
    return itf;
}

- (instancetype)init
{
    @throw [NSException exceptionWithName:@"Singleton"
                                   reason:@"use +[iotifity_itf shared]"
                                   userInfo: nil];
    return nil;
}

- (instancetype)initPrivate
{
    self = [super init];
    if (self) {
        _mutex = [[NSLock alloc] init];
        _peripherals = [[NSMutableArray alloc] init];
        [self performSelectorInBackground:@selector(doWork) withObject:nil];
    }
    return self;
}

- (instancetype)doWork
{
    OCStackResult rc;

    rc = OCInit(NULL, 0, OC_CLIENT);
    if (rc != 0) {
        NSLog(@"OCInit failed: %d\n", rc);
        return NULL;
    }
    while (1) {
        OCProcess();
        [NSThread sleepForTimeInterval:1];
    }
}


#pragma mark - Discover Device
- (int) discovery_start:(id)delegate
{
    delegate = delegate;
    
    OCStackResult rc;
    OCCallbackData cb = {
        .cb = discovery_cb
    };
    OCConnectivityType transport = CT_ADAPTER_IP | CT_ADAPTER_GATT_BTLE;
    
    _discovery_watcher = delegate;
    
    rc = OCDoResource(NULL, OC_REST_DISCOVER, OC_RSRVD_WELL_KNOWN_URI, NULL, NULL,
                      transport, OC_LOW_QOS, &cb, NULL, 0);
    return rc;
}

#pragma mark - Discover Device Callback
static OCStackApplicationResult
discovery_cb(void *ctx, OCDoHandle handle, OCClientResponse *rsp)
{
    iotivity_itf *itf = [iotivity_itf shared];
    OCDiscoveryPayload *disc_rsp = (OCDiscoveryPayload *)rsp->payload;
    OCResourcePayload *resource;

    if (!rsp || !disc_rsp) {
        NSLog(@"discovery_cb failed\n");
    }
    
    NSString *uuidStr = [[NSString alloc] initWithFormat:@"%s", rsp->devAddr.addr];
    
    [itf.mutex lock];
    Peripheral *item;
    
    for (item in itf.peripherals) {
        if ([uuidStr caseInsensitiveCompare:item.uuid] == NSOrderedSame) {
            [itf.mutex unlock];
            return OC_STACK_DELETE_TRANSACTION;
        }
    }
    
    Peripheral *p = [[Peripheral alloc] initWithUuid:uuidStr];
    
    if (rsp->devAddr.adapter == OC_ADAPTER_GATT_BTLE) {
        p.type = @"BLE";
    } else if (rsp->devAddr.adapter == OC_ADAPTER_IP) {
        p.type = @"IP";
    } else {
        p.type = @"unkwn";
    }

    p.devAddr = rsp->devAddr;
    itf.devAddr = &(rsp->devAddr);
    
    NSLog(@"%s", itf.devAddr->addr);
    //NEW CALL
    [[iotivity_itf shared] discover_deviceDetails:&rsp->devAddr];

    for (resource = disc_rsp->resources; resource; resource = resource->next) {
        PeripheralResource *pr = [[PeripheralResource alloc] init];
        pr.uri = [[NSString alloc] initWithFormat:@"%s", resource->uri];
        [p addPeripheralResource:pr];
    }
    [itf.peripherals addObject:p];
    
    [itf.mutex unlock];
    /*if (itf.discovery_watcher != (id)nil) {
        [itf.discovery_watcher listUpdated];
    }*/
    
    return OC_STACK_DELETE_TRANSACTION;
}

#pragma mark - Obtain Manufacturer using "/oic/p"
- (int) discover_deviceDetails:(OCDevAddr *)devAddr
{
    OCStackResult rc;
    OCCallbackData cb = {
        .cb = deviceDetails_cb
        //Write a new Callback
    };
    OCConnectivityType transport = CT_ADAPTER_IP | CT_ADAPTER_GATT_BTLE;
    
    //_discovery_watcher = delegate;
    
    rc = OCDoResource(NULL, OC_REST_DISCOVER, OC_RSRVD_PLATFORM_URI, devAddr, NULL ,
                      transport, OC_LOW_QOS, &cb, NULL, 0);
    return rc;
}


#pragma mark - Obtain Manufacturer using "/oic/p" callback
static OCStackApplicationResult
deviceDetails_cb(void *ctx, OCDoHandle handle, OCClientResponse *rsp)
{
    iotivity_itf *itf = [iotivity_itf shared];
    OCPlatformPayload *device_rsp = (OCPlatformPayload *)rsp->payload;
   // OCResourcePayload *resource;
    
    if (!rsp || !device_rsp) {
        NSLog(@"device details callback failed\n");
    }
    NSLog(@"***** %s", device_rsp->info.manufacturerName);
    NSLog(@"***** %s", device_rsp->info.platformID);
    
    [itf.mutex lock];
    itf.manufacturerName = [NSString stringWithUTF8String:device_rsp->info.manufacturerName];
    itf.platformId = [NSString stringWithUTF8String:device_rsp->info.platformID];
    [itf.mutex unlock];

    for(int i = 0;i < [itf.peripherals count]; i++)
    {
        Peripheral *p = itf.peripherals[i];
        p.manufacturerName = itf.manufacturerName;
        p.platformID = itf.platformId;
    }
    
    
    if (itf.discovery_watcher != (id)nil) {
        [itf.discovery_watcher listUpdated];
    }
    
    return OC_STACK_DELETE_TRANSACTION;
}

#pragma mark - Humidity data get
- (int) discovery_humidity:(id)delegate andURI:(NSString *)uri andDevAddr:(OCDevAddr) devAddr
{
    
    OCStackResult rc;
    OCCallbackData cb = {
        .cb = humidity_cb
    };
    OCConnectivityType transport = CT_ADAPTER_IP | CT_ADAPTER_GATT_BTLE;
    
    _discovery_watcher = delegate;
    
    
    
    rc = OCDoResource(NULL, OC_REST_GET, [uri UTF8String], &devAddr, NULL,
                      transport, OC_LOW_QOS, &cb, NULL, 0);
    return rc;
    
    
}

#pragma mark - Humidity data callback

static OCStackApplicationResult
humidity_cb(void *ctx, OCDoHandle handle, OCClientResponse *rsp){
    iotivity_itf *itf = [iotivity_itf shared];
    
    itf.orientationArray = [[NSMutableArray alloc] init];
    
    OCRepPayload *resource_resp = (OCRepPayload *)rsp->payload;
    
    OCRepPayloadValue *res = resource_resp->values;
    
    
    [itf.mutex lock];
    for (res = resource_resp->values; res; res = res->next) {
        NSLog(@"%s", res->name);
        NSLog(@"%s", res->str);
        
        itf.resType = [NSString stringWithUTF8String:res->name];
        itf.humidValue = [NSString stringWithUTF8String:res->str];

    }
    [itf.mutex unlock];
    if (itf.discovery_watcher != (id)nil) {
        [itf.discovery_watcher populateHumidityData];
    }
    
    return OC_STACK_DELETE_TRANSACTION;
    
}

#pragma mark - Temperature data get
- (int) discovery_temperature:(id)delegate andURI:(NSString *)uri andDevAddr:(OCDevAddr) devAddr
{
    
    OCStackResult rc;
    OCCallbackData cb = {
        .cb = temperature_cb
    };
    OCConnectivityType transport = CT_ADAPTER_IP | CT_ADAPTER_GATT_BTLE;
    
    _discovery_watcher = delegate;
    
    
    
    rc = OCDoResource(NULL, OC_REST_GET, [uri UTF8String], &devAddr, NULL,
                      transport, OC_LOW_QOS, &cb, NULL, 0);
    return rc;
    
    
}

#pragma mark - Temperature data callback

static OCStackApplicationResult
temperature_cb(void *ctx, OCDoHandle handle, OCClientResponse *rsp){
    iotivity_itf *itf = [iotivity_itf shared];
    
    itf.orientationArray = [[NSMutableArray alloc] init];
    
    OCRepPayload *resource_resp = (OCRepPayload *)rsp->payload;
    
    OCRepPayloadValue *res = resource_resp->values;
    
    
    [itf.mutex lock];
    for (res = resource_resp->values; res; res = res->next) {
        
        NSLog(@"%s", res->name);
        NSLog(@"%s", res->str);
        if(strcmp(res->name,"temperature") == 0){
            itf.resType = [NSString stringWithUTF8String:res->name];
            itf.tempValue = [NSString stringWithUTF8String:res->str];
        }else if(strcmp(res->name,"units") == 0){
            itf.tempUnit = [NSString stringWithUTF8String:res->str];
        }
        
    }
    [itf.mutex unlock];
    if (itf.discovery_watcher != (id)nil) {
        [itf.discovery_watcher populateHumidityData];
    }
    
    return OC_STACK_DELETE_TRANSACTION;
    
}

#pragma mark - Compass data get
- (int) discovery_resource:(id)delegate andURI:(NSString *)uri andDevAddr:(OCDevAddr) devAddr
{
    
    OCStackResult rc;
    OCCallbackData cb = {
        .cb = resource_cb
    };
    OCConnectivityType transport = CT_ADAPTER_IP | CT_ADAPTER_GATT_BTLE;
    
    _discovery_watcher = delegate;
    
    
    
    rc = OCDoResource(NULL, OC_REST_GET, [uri UTF8String], &devAddr, NULL,
                      transport, OC_LOW_QOS, &cb, NULL, 0);
    return rc;

    
}

#pragma mark - Compass call back
static OCStackApplicationResult
resource_cb(void *ctx, OCDoHandle handle, OCClientResponse *rsp){
    iotivity_itf *itf = [iotivity_itf shared];
    
    itf.orientationArray = [[NSMutableArray alloc] init];
    
    OCRepPayloadValue *res;
    
    OCRepPayload *resource_resp = (OCRepPayload *)rsp->payload;
    
    [itf.mutex lock];
    for (res = resource_resp->values; res; res = res->next) {
        NSLog(@"%zu", res->ocByteStr.len);
        int len = (int)res->ocByteStr.len;
        for (int i = 0;i < len; i++) {
            //NSLog(@"%lld", res->arr.iArray[i]);
            int64_t x = res->arr.iArray[i];
            [itf.orientationArray addObject: [NSNumber numberWithLongLong:x]];
        }
    }
    [itf.mutex unlock];
    if (itf.discovery_watcher != (id)nil) {
        [itf.discovery_watcher populateData];
    }
    
    return OC_STACK_DELETE_TRANSACTION;
 
}

#pragma mark - End discovery
- (void)discovery_end
{
    _discovery_watcher = (id)nil;
}
- (NSUInteger) device_count
{
    NSUInteger cnt;
    
    [_mutex lock];
    cnt = [_peripherals count];
    [_mutex unlock];
    
    return cnt;
}

- (Peripheral *)deviceWithIdx:(NSInteger)index
{
    Peripheral *p;
    
    [_mutex lock];
    p = _peripherals[index];
    // XXX make a copy of p, or ref count it
    NSLog(@"%s", p.devAddr.addr);
    [_mutex unlock];

    return p;
}

- (Peripheral *)platformDetails
{
    Peripheral *p = [[Peripheral alloc] init];
    
    [_mutex lock];
    iotivity_itf *itf = [iotivity_itf shared];
    NSLog(@"%@", itf.manufacturerName);
    p.manufacturerName = itf.manufacturerName;
    p.platformID = itf.platformId;
    [_mutex unlock];
    return p;
    
}

- (Peripheral *)statusDetails
{
    
    Peripheral *pr1 = [[Peripheral alloc] init];
    
    [_mutex lock];
    
    NSLog(@"%lu",(unsigned long)[_orientationArray count]);
    
    for (int i = 0; i < [_orientationArray count]; i++) {
        NSLog(@"%lld", [_orientationArray[i] longLongValue]);
    }
    pr1.orientations = _orientationArray;
    
    NSLog(@"%@",pr1.orientations);
    
    [_mutex unlock];
    return pr1;
}

- (Peripheral *)humidityDetails
{
    Peripheral *pr = [[Peripheral alloc]init];
    [_mutex lock];
    
    NSLog(@"%@", _resType);
    NSLog(@"%@", _humidValue);
    
    pr.resType = _resType;
    pr.humidValue = _humidValue;
    
    NSLog(@"%@, %@",pr.resType,pr.humidValue);
    
    [_mutex unlock];
    return pr;
}

- (Peripheral *)temperatureDetails
{
    Peripheral *pr = [[Peripheral alloc]init];
    [_mutex lock];
    
    NSLog(@"%@", _resType);
    NSLog(@"%@", _tempValue);
    NSLog(@"%@", _tempUnit);
    
    pr.resType = _resType;
    pr.humidValue = _tempValue;
    pr.tempUnit = _tempUnit;
    
    NSLog(@"%@, %@, %@",pr.resType,pr.tempValue,pr.tempUnit);
    
    [_mutex unlock];
    return pr;
}


@end
