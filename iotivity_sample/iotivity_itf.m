
//
//  iotivity_itf.m
//  iotivity_sample
//
//  Created by Marko Kiiskila on 5/15/17.
//  Copyright © 2017 Marko Kiiskila. All rights reserved.
//

#import "iotivity_itf.h"
#import "DeviceDetailsViewController.h"
#import "ResourceDetailsViewController.h"
#import "DeviceListViewController.h"
#import "NewtManagerViewController.h"
#import "PeripheralResource.h"
#include <iotivity-csdk/octypes.h>
#include <iotivity-csdk/ocstack.h>
#include <iotivity-csdk/ocpayload.h>

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

//Peripheral Resource
@property (nonatomic) PeripheralResource *p;
@property (nonatomic) Peripheral* peripheralObject;
@property (nonatomic) Peripheral* interfaceObject;
@property (nonatomic) OCDoHandle observeHandle;
@property (atomic, retain) id delegate;

@property (atomic) id discovery_watcher;

@end

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
        _p = [[PeripheralResource alloc] init];
        _peripheralObject = [[Peripheral alloc]initWithUuid:@"PeripheralObject"];
        _interfaceObject = [[Peripheral alloc]initWithUuid:@"InterfaceObject"];

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
        [NSThread sleepForTimeInterval:0.01];
    }
}


#pragma mark - Discover Device
- (int) discovery_start:(id)delegate
{
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
    OCResourcePayload *resource;

    if (!rsp) {
        NSLog(@"discovery_cb failed\n");
        return OC_STACK_DELETE_TRANSACTION;
    }
    OCDiscoveryPayload *disc_rsp = (OCDiscoveryPayload *)rsp->payload;
    if (rsp->result == OC_STACK_ERROR) {
        NSLog(@"discovery_cb got error parsing response\n");
        return OC_STACK_KEEP_TRANSACTION;
    }
    if (!disc_rsp) {
        NSLog(@"discovery_cb cannot be converted\n");
        return OC_STACK_DELETE_TRANSACTION;
    }
    NSString *uuidStr = [[NSString alloc] initWithFormat:@"%s", rsp->devAddr.addr];
    
    [itf.mutex lock];
    Peripheral *item;
    
    for (item in itf.peripherals) {
        if ([uuidStr caseInsensitiveCompare:item.uuid] == NSOrderedSame) {
            [itf.mutex unlock];
            
            return OC_STACK_KEEP_TRANSACTION;
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
    
    //NEW CALL
    //[[iotivity_itf shared] discover_deviceDetails:&rsp->devAddr];

    for (resource = disc_rsp->resources; resource; resource = resource->next) {
    
        
        PeripheralResource *pr = [itf parseResourcePayload:resource];
        pr.uri = [[NSString alloc] initWithFormat:@"%s", resource->uri];
        [p addPeripheralResource:pr];
    }
    [itf.peripherals addObject:p];
    
    [itf.mutex unlock];
    
    if (itf.discovery_watcher != (id)nil) {
        [itf.discovery_watcher listUpdated];
    }
    
    return OC_STACK_KEEP_TRANSACTION;
}

- (PeripheralResource *) parseResourcePayload : (OCResourcePayload *) resource {
    PeripheralResource *pr = [[PeripheralResource alloc] init];
    pr.uri = [NSString stringWithUTF8String:resource->uri];
    pr.resourceType = [NSString stringWithUTF8String:resource->types->value];
    pr.resourceInterface = [NSString stringWithUTF8String:resource->interfaces->value];
    return pr;
}



#pragma mark - Discover resources by BLE
- (int) discover_allDevices: (id) delegate andAddress : (NSString *)address{
    delegate = delegate;
    OCDevAddr devAddr;
    strcpy(devAddr.addr,[address UTF8String]);
    devAddr.adapter = OC_ADAPTER_GATT_BTLE;
    OCStackResult rc;
    OCCallbackData cb = {
        .cb = discovery_ble_cb
    };
    OCConnectivityType transport =  CT_ADAPTER_GATT_BTLE;
    
    _discovery_watcher = delegate;
    
    rc = OCDoResource(NULL, OC_REST_DISCOVER, OC_MULTICAST_DISCOVERY_URI, &devAddr, NULL,
                      transport, OC_LOW_QOS, &cb, NULL, 0);
    return rc;
    
}

#pragma mark - Discover resources by BLE callback
static OCStackApplicationResult
discovery_ble_cb(void *ctx, OCDoHandle handle, OCClientResponse *rsp)
{
    iotivity_itf *itf = [iotivity_itf shared];
    OCResourcePayload *resource;
    
    if (!rsp) {
        NSLog(@"discovery_cb failed\n");
        return OC_STACK_DELETE_TRANSACTION;
    }
    OCDiscoveryPayload *disc_rsp = (OCDiscoveryPayload *)rsp->payload;
    if (rsp->result == OC_STACK_ERROR) {
        NSLog(@"discovery_cb got error parsing response\n");
        return OC_STACK_KEEP_TRANSACTION;
    }
    if (!disc_rsp) {
        NSLog(@"discovery_cb cannot be converted\n");
        return OC_STACK_DELETE_TRANSACTION;
    }
    NSString *uuidStr = [[NSString alloc] initWithFormat:@"%s", rsp->devAddr.addr];
    
    NSString *resourceURI = [[NSString alloc] initWithFormat:@"%s", rsp->resourceUri];
    NSLog(@"%@",resourceURI);
    
    [itf.mutex lock];
    Peripheral *item;
    
    for (item in itf.peripherals) {
        if ([uuidStr caseInsensitiveCompare:item.uuid] == NSOrderedSame) {
            [itf.mutex unlock];
            if (itf.discovery_watcher != (id)nil) {
                [itf.discovery_watcher listUpdated];
            }
            return OC_STACK_KEEP_TRANSACTION;
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
    
    p.devAddr = *(&rsp->devAddr);
    
    [itf.mutex unlock];
    for (resource = disc_rsp->resources; resource; resource = resource->next) {
        
        PeripheralResource *pr = [itf parseResourcePayload:resource];
        pr.devAddr = p.devAddr;
        [p addPeripheralResource:pr];
    }
    [itf.peripherals addObject:p];
    
    if (itf.discovery_watcher != (id)nil) {
        [itf.discovery_watcher listUpdated];
    }
    
    return OC_STACK_KEEP_TRANSACTION;
}


- (int) obtain_platform_details: (id) delegate andAddress : (OCDevAddr)address{
    _delegate = delegate;
    OCStackResult rc;
    OCCallbackData cb = {
        .cb = platform_details_cb
    };
    OCConnectivityType transport =  CT_ADAPTER_GATT_BTLE | CT_ADAPTER_IP;
    
    _discovery_watcher = delegate;
    
    rc = OCDoResource(NULL, OC_REST_GET, OC_RSRVD_PLATFORM_URI, &address, NULL,
                      transport, OC_LOW_QOS, &cb, NULL, 0);
    return rc;
    
}

#pragma mark - Discover resources by BLE callback
static OCStackApplicationResult
platform_details_cb(void *ctx, OCDoHandle handle, OCClientResponse *rsp)
{
    iotivity_itf *itf = [iotivity_itf shared];
    
    if (!rsp) {
        NSLog(@"platform_cb failed\n");
        return OC_STACK_DELETE_TRANSACTION;
    }
    if (rsp->result == OC_STACK_ERROR) {
        NSLog(@"discovery_cb got error parsing response\n");
        return OC_STACK_KEEP_TRANSACTION;
    }
    OCPlatformPayload *platform_payload = (OCPlatformPayload *)rsp->payload;
    if (!platform_payload) {
        NSLog(@"cannot be converted\n");
        return OC_STACK_DELETE_TRANSACTION;
    }
    
    [itf.mutex lock];
    
    if (platform_payload->info.manufacturerName!=nil) {
        itf.manufacturerName = [NSString stringWithUTF8String:platform_payload->info.manufacturerName ];
    }
    if (platform_payload->info.platformID!=nil) {
        itf.platformId = [NSString stringWithUTF8String:platform_payload->info.platformID ];
    }
    
    [itf.mutex unlock];
    
    if (itf.delegate != (id)nil) {
        [itf.delegate platformDetailsForDevice];
    }
    
    return OC_STACK_DELETE_TRANSACTION;
}

#pragma mark - Generic Get Call
- (int) get_generic:(id)delegate andURI:(NSString *)uri andDevAddr:(OCDevAddr) devAddr
{
    
    OCStackResult rc;
    OCCallbackData cb = {
        .cb = generic_cb
    };
    OCConnectivityType transport = CT_ADAPTER_IP | CT_ADAPTER_GATT_BTLE;
    
    _discovery_watcher = delegate;
    
    rc = OCDoResource(NULL, OC_REST_GET, [uri UTF8String], &devAddr, NULL,
                      transport, OC_LOW_QOS, &cb, NULL, 0);

    
    return rc;
    
}

static OCStackApplicationResult
generic_cb(void *ctx, OCDoHandle handle, OCClientResponse *rsp){
    
    iotivity_itf *itf = [iotivity_itf shared];
    [itf.mutex lock];
    
    if (rsp -> payload->type == PAYLOAD_TYPE_PLATFORM) {
        itf.peripheralObject = [[Peripheral alloc] initWithUuid:@"ITF Platform"];

        itf.observeHandle = handle;
        OCPlatformPayload *representation_payload = (OCPlatformPayload *)rsp->payload;
        itf.peripheralObject.manufacturerName = [NSString stringWithUTF8String:representation_payload->info.manufacturerName];
        itf.peripheralObject.platformID = [NSString stringWithUTF8String:representation_payload->info.platformID];
        itf.resType = [NSString stringWithUTF8String:representation_payload->interfaces->value];
        NSLog(@"ppp");
    }
    else if (rsp -> payload->type == PAYLOAD_TYPE_DEVICE) {
        itf.peripheralObject = [[Peripheral alloc] initWithUuid:@"ITF Device"];

        itf.observeHandle = handle;
        OCDevicePayload *representation_payload = (OCDevicePayload *)rsp->payload;
        itf.peripheralObject.resStateName = [NSString stringWithUTF8String:representation_payload->deviceName];
        itf.peripheralObject.resType = [NSString stringWithUTF8String:representation_payload->specVersion];
        NSLog(@"ppp");
    }

    else if (rsp -> payload->type == PAYLOAD_TYPE_REPRESENTATION) {
        itf.peripheralObject = [[Peripheral alloc] initWithUuid:@"ITF Representation"];

        itf.observeHandle = handle;
        OCRepPayload *representation_payload = (OCRepPayload *)rsp->payload;
        OCRepPayloadValue *res;
        NSMutableArray *arr = [[NSMutableArray alloc] init];

        for (res = representation_payload ->values; res; res = res->next) {
            PeripheralResource *pr = [[PeripheralResource alloc] init];
            pr.uri = [[NSString alloc] initWithFormat:@"%s", res->name];
            pr.resourceName = [NSString stringWithUTF8String:res->name];
            NSLog(@"%@",pr.resourceName);
            
            pr.type = res->type;
            
            if (res->type == OCREP_PROP_INT) {
                pr.resourceIntegerValue = res->i;
            }else if(res->type == OCREP_PROP_BOOL){
                pr.resourceBoolValue = res->b;
            }else if(res->type == OCREP_PROP_DOUBLE){
                pr.resourceDoubleValue = res->d;
            }else if(res->type == OCREP_PROP_STRING){
                pr.resourceStringValue = [NSString stringWithUTF8String:res->str];
            }else if(res->type == OCREP_PROP_ARRAY){
                if(res->arr.type == OCREP_PROP_INT){
                    for(int i = 0; i < (int)res->ocByteStr.len; i++){
                        NSNumber *number = [NSNumber numberWithLongLong:res->arr.iArray[i]];
                        [arr addObject:number];
                    }
                    pr.resourceArrayValue = [[NSMutableArray alloc] initWithArray:arr];
                }else if(res->arr.type == OCREP_PROP_DOUBLE){
                    for(int i = 0; i < (int)res->ocByteStr.len; i++){
                        NSNumber *number = [NSNumber numberWithDouble:res->arr.dArray[i]];
                        [arr addObject:number];
                    }
                    pr.resourceArrayValue = [[NSMutableArray alloc] initWithArray:arr];
                }else if(res->arr.type == OCREP_PROP_STRING){
                    for(int i = 0; i < (int)res->ocByteStr.len; i++){
                        NSString *string = [NSString stringWithUTF8String:res->arr.strArray[i]];
                        [arr addObject:string];
                    }
                    pr.resourceArrayValue = [[NSMutableArray alloc] initWithArray:arr];
                    if(res->arr.type == OCREP_PROP_BOOL){
                        for(int i = 0; i < (int)res->ocByteStr.len; i++){
                            bool b = res->arr.bArray[i];
                            [arr addObject:[NSNumber numberWithBool:b]];
                        }
                        pr.resourceArrayValue = [[NSMutableArray alloc] initWithArray:arr];
                    }
                    
                }
                
            }
            
            
            
            [itf.peripheralObject addPeripheralResource:pr];
        }
        
    }
    
    [itf.mutex unlock];
    if (itf.discovery_watcher != (id)nil) {
        [itf.discovery_watcher getResourceDetails];
    }
    
    return OC_STACK_DELETE_TRANSACTION;
    
}

#pragma mark - Interfaces Get Call
- (int) get_interfaces:(id)delegate andURI:(NSString *)uri andDevAddr:(OCDevAddr) devAddr
{
    
    OCStackResult rc;
    OCCallbackData cb = {
        .cb = interfaces_cb
    };
    OCConnectivityType transport = CT_ADAPTER_IP | CT_ADAPTER_GATT_BTLE;
    
    _discovery_watcher = delegate;
    
    rc = OCDoResource(NULL, OC_REST_GET, [uri UTF8String], &devAddr, NULL,
                      transport, OC_LOW_QOS, &cb, NULL, 0);
    
    
    return rc;
    
}

static OCStackApplicationResult
interfaces_cb(void *ctx, OCDoHandle handle, OCClientResponse *rsp){
    
    iotivity_itf *itf = [iotivity_itf shared];
    [itf.mutex lock];
    itf.interfaceObject = [[Peripheral alloc] initWithUuid:@"ITF Object"];
    
    NSString *resourceName = [[NSString alloc] init];
    NSString *resourceInterface = [[NSString alloc] init];
    
    if (rsp -> payload->type == PAYLOAD_TYPE_REPRESENTATION) {
        itf.observeHandle = handle;
        OCRepPayload *representation_payload = (OCRepPayload *)rsp->payload;
        OCRepPayloadValue *res;
        
        for (res = representation_payload ->values; res; res = res->next) {
            
            if([[NSString stringWithUTF8String:res -> name] isEqualToString:@"links"]) {
            
                if(res->type == OCREP_PROP_ARRAY){
                    
                    OCRepPayloadValueArray *arr = &res->arr;
                    if(arr->type == OCREP_PROP_OBJECT) {
                        OCRepPayload **payload = arr->objArray;
                        for(int i = 0;i < *arr->dimensions; i++){
                            NSLog(@"%d",i);
                            OCRepPayload *innerPayload = payload[i];
                            PeripheralResource *pres = [[PeripheralResource alloc] init];
                            while (innerPayload->values->next != NULL) {
                                OCRepPayloadValue *resValue = innerPayload->values;
                                NSString *resName = [NSString stringWithUTF8String:resValue->name];
                                if ([resName isEqualToString:@"href"]) {
                                    resourceName = [NSString stringWithUTF8String:resValue->str];
                                    pres.resourceName = resourceName;
                                }
                                if([resName isEqualToString:@"if"]) {
                                    OCRepPayloadValueArray arr = resValue->arr;
                                    resourceInterface = [NSString stringWithUTF8String:*(arr.strArray)];
                                    NSLog(@"%@",resourceInterface);
                                    pres.resourceInterface = resourceInterface;
                                }

                                innerPayload->values = innerPayload->values->next;
                                
                            }
                            [itf.interfaceObject addPeripheralResource:pres];

                        }
                    }
                }
            }
            
        }
        
    }
    
    NSLog(@"%lu",(unsigned long)[itf.interfaceObject.resources count]);
    
    [itf.mutex unlock];
    if (itf.discovery_watcher != (id)nil) {
        [itf.discovery_watcher getInterfaceData];
    }
    
    return OC_STACK_DELETE_TRANSACTION;
    
}

#pragma mark - Set Light Call
- (int) set_generic:(id)delegate andURI:(NSString *)uri andDevAddr:(OCDevAddr)devAddr andPayLoad:(OCRepPayload *) payload{
    OCStackResult rc;
    OCCallbackData cb = {
        .cb = set_cb
    };
    OCConnectivityType transport = CT_ADAPTER_IP | CT_ADAPTER_GATT_BTLE;
    
    _discovery_watcher = delegate;
        
    rc = OCDoResource(NULL, OC_REST_PUT, [uri UTF8String], &devAddr, (OCPayload *)payload,
                      transport, OC_LOW_QOS, &cb, NULL, 0);
    return rc;
}

static OCStackApplicationResult
set_cb(void *ctx, OCDoHandle handle, OCClientResponse *rsp){
    
    return OC_STACK_DELETE_TRANSACTION;

}


/*=================================== NEWT MANAGER========================================*/

#pragma mark - Set Light Call
- (int) set_newt_manager:(id)delegate andURI:(NSString *)uri andDevAddr:(OCDevAddr)devAddr andPayLoad:(OCRepPayload *) payload{
    OCStackResult rc;
    OCCallbackData cb = {
        .cb = newt_manager_cb
    };
    OCConnectivityType transport = CT_ADAPTER_IP | CT_ADAPTER_GATT_BTLE;
    
    _discovery_watcher = delegate;
    
    rc = OCDoResource(NULL, OC_REST_PUT, [uri UTF8String], &devAddr, (OCPayload *)payload,
                      transport, OC_LOW_QOS, &cb, NULL, 0);
    return rc;
}

static OCStackApplicationResult
newt_manager_cb(void *ctx, OCDoHandle handle, OCClientResponse *rsp){
    iotivity_itf *itf = [iotivity_itf shared];
    
    itf.peripheralObject = [[Peripheral alloc] initWithUuid:@"NewtMgr"];
    NSMutableArray *arr = [[NSMutableArray alloc] init];

    [itf.mutex lock];
    if (rsp -> payload->type == PAYLOAD_TYPE_REPRESENTATION) {
        OCRepPayload *representation_payload = (OCRepPayload *)rsp->payload;
        OCRepPayloadValue *res;
        for (res = representation_payload ->values; res; res = res->next) {
            PeripheralResource *pr = [[PeripheralResource alloc] init];
            pr.uri = [[NSString alloc] initWithFormat:@"%s", res->name];
            pr.resourceName = [NSString stringWithUTF8String:res->name];
            NSLog(@"%@",pr.resourceName);
            
            pr.type = res->type;
            
            if (res->type == OCREP_PROP_INT) {
                pr.resourceIntegerValue = res->i;
            }else if(res->type == OCREP_PROP_BOOL){
                pr.resourceBoolValue = res->b;
            }else if(res->type == OCREP_PROP_DOUBLE){
                pr.resourceDoubleValue = res->d;
            }else if(res->type == OCREP_PROP_STRING){
                pr.resourceStringValue = [NSString stringWithUTF8String:res->str];
            }else if(res->type == OCREP_PROP_ARRAY){
                if(res->arr.type == OCREP_PROP_INT){
                    for(int i = 0; i < (int)res->ocByteStr.len; i++){
                        NSNumber *number = [NSNumber numberWithLongLong:res->arr.iArray[i]];
                        [arr addObject:number];
                    }
                    pr.resourceArrayValue = [[NSMutableArray alloc] initWithArray:arr];
                }else if(res->arr.type == OCREP_PROP_DOUBLE){
                    for(int i = 0; i < (int)res->ocByteStr.len; i++){
                        NSNumber *number = [NSNumber numberWithDouble:res->arr.dArray[i]];
                        [arr addObject:number];
                    }
                    pr.resourceArrayValue = [[NSMutableArray alloc] initWithArray:arr];
                }else if(res->arr.type == OCREP_PROP_STRING){
                    for(int i = 0; i < (int)res->ocByteStr.len; i++){
                        NSString *string = [NSString stringWithUTF8String:res->arr.strArray[i]];
                        [arr addObject:string];
                    }
                    pr.resourceArrayValue = [[NSMutableArray alloc] initWithArray:arr];
                    if(res->arr.type == OCREP_PROP_BOOL){
                        for(int i = 0; i < (int)res->ocByteStr.len; i++){
                            bool b = res->arr.bArray[i];
                            [arr addObject:[NSNumber numberWithBool:b]];
                        }
                        pr.resourceArrayValue = [[NSMutableArray alloc] initWithArray:arr];
                    }
                    
                }
                
            }else if(res->type == OCREP_PROP_OBJECT) {
                
                [itf parseObject:res->obj and:itf.peripheralObject];
            }
            [itf.peripheralObject addPeripheralResource:pr];
        }
    }
    
    [itf.mutex unlock];
    if (itf.discovery_watcher != (id)nil) {
        [itf.discovery_watcher obtainData];
    }

    
    [itf.mutex unlock];
    
    return OC_STACK_DELETE_TRANSACTION;
    
}


- (void) parseObject : (OCRepPayload *)object and:(Peripheral *)pObj{
    while (object ->values ->next != NULL) {
        if (object->values->type == OCREP_PROP_OBJECT) {
            OCRepPayload *innerObj = object->values->obj;
            while (innerObj->values->next!=NULL) {
                PeripheralResource *pr = [[PeripheralResource alloc] init];
                OCRepPayloadValue *innerObjValue = innerObj->values;
                pr.resourceName = [NSString stringWithUTF8String:innerObjValue->name];
                pr.type = innerObjValue->type;
                if (pr.type == OCREP_PROP_INT) {
                    pr.resourceIntegerValue = innerObjValue->i;
                }
                innerObj->values = innerObj->values->next;
                [pObj addPeripheralResource:pr];
            }
        }
        object->values = object->values->next;
    }
}

/*=================================== NEWT MANAGER========================================*/


#pragma mark - Cancel Observe API
//This is needed for debugging
- (int) cancel_observer:(id)delegate andURI:(NSString *)uri andDevAddr:(OCDevAddr)devAddr andHandle:(OCDoHandle)handle
{
    OCStackResult rc;
    
    OCCallbackData cb = {
        .cb = cancel_observe_cb
    };
    
    _discovery_watcher = delegate;
    
    rc = //OCDoResource(NULL, OC_REST_CANCEL_OBSERVE, [uri UTF8String], &devAddr, NULL,
           //           transport, OC_LOW_QOS, &cb, NULL, 0);
    OCCancel(handle, OC_LOW_QOS, NULL, 0);
    
    return rc;
}

#pragma mark - Cancel Observe Callback

static OCStackApplicationResult
cancel_observe_cb(void *ctx, OCDoHandle handle, OCClientResponse *rsp)
{
    return OC_STACK_DELETE_TRANSACTION;
}



#pragma mark - Observe Light APICall

- (int) observe_light:(id)delegate andURI:(NSString *)uri andDevAddr:(OCDevAddr)devAddr
{
    OCStackResult rc;
    
    OCCallbackData cb = {
        .cb = observe_light_cb
    };
    OCConnectivityType transport = CT_ADAPTER_IP | CT_ADAPTER_GATT_BTLE;
    
    _discovery_watcher = delegate;
    
    rc = OCDoResource(NULL, OC_REST_OBSERVE, [uri UTF8String], &devAddr, NULL,
                      transport, OC_LOW_QOS, &cb, NULL, 0);
    
    return rc;
}

#pragma mark - Observe Light Cb

static OCStackApplicationResult
observe_light_cb(void *ctx, OCDoHandle handle, OCClientResponse *rsp)
{
    iotivity_itf *itf = [iotivity_itf shared];
    
    itf.peripheralObject = [[Peripheral alloc] initWithUuid:@"ITF Object"];
    
    if (rsp -> payload->type == PAYLOAD_TYPE_REPRESENTATION) {
        OCRepPayload *representation_payload = (OCRepPayload *)rsp->payload;
        OCRepPayloadValue *res;
        NSMutableArray *arr = [[NSMutableArray alloc] init];
        
        itf.observeHandle = handle;
        
        for (res = representation_payload ->values; res; res = res->next) {
            PeripheralResource *pr = [[PeripheralResource alloc] init];
            pr.uri = [[NSString alloc] initWithFormat:@"%s", res->name];
            pr.resourceName = [NSString stringWithUTF8String:res->name];
            NSLog(@"%@",pr.resourceName);
            
            pr.type = res->type;
            
            if (res->type == OCREP_PROP_INT) {
                pr.resourceIntegerValue = res->i;
            }else if(res->type == OCREP_PROP_BOOL){
                pr.resourceBoolValue = res->b;
            }else if(res->type == OCREP_PROP_DOUBLE){
                pr.resourceDoubleValue = res->d;
            }else if(res->type == OCREP_PROP_STRING){
                pr.resourceStringValue = [NSString stringWithUTF8String:res->str];
            }else if(res->type == OCREP_PROP_ARRAY){
                if(res->arr.type == OCREP_PROP_INT){
                    for(int i = 0; i < (int)res->ocByteStr.len; i++){
                        NSNumber *number = [NSNumber numberWithLongLong:res->arr.iArray[i]];
                        [arr addObject:number];
                    }
                    pr.resourceArrayValue = [[NSMutableArray alloc] initWithArray:arr];
                }else if(res->arr.type == OCREP_PROP_DOUBLE){
                    for(int i = 0; i < (int)res->ocByteStr.len; i++){
                        NSNumber *number = [NSNumber numberWithDouble:res->arr.dArray[i]];
                        [arr addObject:number];
                    }
                    pr.resourceArrayValue = [[NSMutableArray alloc] initWithArray:arr];
                }else if(res->arr.type == OCREP_PROP_STRING){
                    for(int i = 0; i < (int)res->ocByteStr.len; i++){
                        NSString *string = [NSString stringWithUTF8String:res->arr.strArray[i]];
                        [arr addObject:string];
                    }
                    pr.resourceArrayValue = [[NSMutableArray alloc] initWithArray:arr];
                    if(res->arr.type == OCREP_PROP_BOOL){
                        for(int i = 0; i < (int)res->ocByteStr.len; i++){
                            bool b = res->arr.bArray[i];
                            [arr addObject:[NSNumber numberWithBool:b]];
                        }
                        pr.resourceArrayValue = [[NSMutableArray alloc] initWithArray:arr];
                    }
                    
                }
                
            }
            
            
            
            [itf.peripheralObject addPeripheralResource:pr];
        }
        
    }
    
    NSLog(@"%lu",(unsigned long)[itf.peripheralObject.resources count]);
    
    [itf.mutex unlock];
    if (itf.discovery_watcher != (id)nil) {
        [itf.discovery_watcher getResourceDetails];
    }
    
    return OC_STACK_KEEP_TRANSACTION;
}

//#pragma mark - Newt Manager Calls
//- (int) set_generic:(id)delegate andURI:(NSString *)uri andDevAddr:(OCDevAddr)devAddr andPayLoad:(OCRepPayload *) payload{
//    OCStackResult rc;
//    OCCallbackData cb = {
//        .cb = set_cb
//    };
//    OCConnectivityType transport = CT_ADAPTER_IP | CT_ADAPTER_GATT_BTLE;
//    
//    _discovery_watcher = delegate;
//    
//    rc = OCDoResource(NULL, OC_REST_PUT, [uri UTF8String], &devAddr, (OCPayload *)payload,
//                      transport, OC_LOW_QOS, &cb, NULL, 0);
//    return rc;
//}




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

- (NSMutableArray *)devices_found
{
    return _peripherals;
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

- (Peripheral *)lightDetails
{
    Peripheral *pObj = [[Peripheral alloc] initWithUuid:@"PeripheralObject"];;
    [_mutex lock];
    
    [pObj.resources addObjectsFromArray:_peripheralObject.resources];
    NSLog(@"%lu",(unsigned long)[pObj.resources count]);
    
    pObj.handle = _observeHandle;
    
    [_mutex unlock];

    return pObj;
    
}

- (Peripheral *)resourceDetails
{
    Peripheral *pObj = [[Peripheral alloc] initWithUuid:@"PeripheralObject"];;
    [_mutex lock];
    
    [pObj.resources addObjectsFromArray:_peripheralObject.resources];
    pObj = _peripheralObject;
    pObj.handle = _observeHandle;
    
    [_mutex unlock];
    
    return pObj;
    
}

- (Peripheral *)newtMgrDetails {
    Peripheral *pObj = [[Peripheral alloc] initWithUuid:@"PeripheralObject"];;
    [_mutex lock];
    
    [pObj.resources addObjectsFromArray:_peripheralObject.resources];
    pObj = _peripheralObject;
    
    [_mutex unlock];
    
    return pObj;

}

-(Peripheral *)interfaceDetails
{
    Peripheral *pObj = [[Peripheral alloc] initWithUuid:@"PeripheralObject"];;
    [_mutex lock];
    
    [pObj.resources addObjectsFromArray:_interfaceObject.resources];
    
    [_mutex unlock];
    return pObj;
    
}


@end
