//
//  iotivity_itf.m
//  iotivity_sample
//
//  Created by Marko Kiiskila on 5/15/17.
//  Copyright © 2017 Marko Kiiskila. All rights reserved.
//

#import "iotivity_itf.h"
#import "DeviceViewController.h"
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
//@property (nonatomic) OCDevAddr *devAddr;

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
        _p = [[PeripheralResource alloc] init];
        _peripheralObject = [[Peripheral alloc]initWithUuid:@"PeripheralObject"];
        _interfaceObject = [[Peripheral alloc]initWithUuid:@"InterfaceObject"];
        _whiteList = [[NSMutableArray alloc] initWithObjects:@"FA45CAB1-AC80-4A5E-A29C-900AB3F529D9",nil];

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
    NSString *bleAddr = @"FA45CAB1-AC80-4A5E-A29C-900AB3F529D9"; //@"DB767371-B7BE-4580-A938-D8965957124B"; //@"BCC37242-B0CA-4B63-BCD8-41A6ABD138C2";
    OCDevAddr devAddr;
    strcpy(devAddr.addr,[bleAddr UTF8String]);
    OCStackResult rc;
    OCCallbackData cb = {
        .cb = discovery_cb
    };
    OCConnectivityType transport = CT_ADAPTER_IP | CT_ADAPTER_GATT_BTLE;
    
    _discovery_watcher = delegate;
    
    rc = OCDoResource(NULL, OC_REST_DISCOVER, OC_RSRVD_WELL_KNOWN_URI, &devAddr, NULL,
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
    
    NSString *resourceURI = [[NSString alloc] initWithFormat:@"%s", rsp->resourceUri];
    NSLog(@"%@",resourceURI);
    
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

    p.devAddr = *(&rsp->devAddr);
    
    [itf.mutex unlock];
        for (resource = disc_rsp->resources; resource; resource = resource->next) {
    
            PeripheralResource *pr = [itf parseResourcePayload:resource];
            pr.devAddr = p.devAddr;
            pr.carrierType = p.type;
            [p addPeripheralResource:pr];
        }
        [itf.peripherals addObject:p];
        
       
        if (itf.discovery_watcher != (id)nil) {
            [itf.discovery_watcher listUpdated];
        }
        
    //}
    return OC_STACK_KEEP_TRANSACTION;
}


- (PeripheralResource *) parseResourcePayload : (OCResourcePayload *) resource {
    PeripheralResource *pr = [[PeripheralResource alloc] init];
    pr.uri = [NSString stringWithUTF8String:resource->uri];
    pr.resourceType = [NSString stringWithUTF8String:resource->types->value];
    pr.resourceInterface = [NSString stringWithUTF8String:resource->interfaces->value];
    return pr;
}

- (int) discover_resources: (OCDevAddr *)devAddr {
    OCStackResult rc;
    OCCallbackData cb = {
        .cb = resource_details_cb
    };
    OCConnectivityType transport = CT_ADAPTER_IP | CT_ADAPTER_GATT_BTLE;
    
    
    rc = OCDoResource(NULL, OC_REST_GET, OC_MULTICAST_DISCOVERY_URI, devAddr, NULL ,
                      transport, OC_LOW_QOS, &cb, NULL, 0);
    return rc;
}


static OCStackApplicationResult
resource_details_cb(void *ctx, OCDoHandle handle, OCClientResponse *rsp) {

    OCRepPayload *representation_payload = (OCRepPayload *)rsp->payload;
    OCRepPayloadValue *res;
    
     for (res = representation_payload ->values; res; res = res->next) {
         NSLog(@"%@",[NSString stringWithUTF8String:res->name]);
     }
    
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
   // OCResourcePayload *resource;
    
    if (!rsp) {
        NSLog(@"device details callback failed\n");
        return OC_STACK_DELETE_TRANSACTION;
    }
    
    OCPlatformPayload *device_rsp = (OCPlatformPayload *)rsp->payload;
    if (!device_rsp) {
        NSLog(@"device details callback payload\n");
        return OC_STACK_DELETE_TRANSACTION;
    }
    [itf.mutex lock];
    if(device_rsp->info.manufacturerName!=nil){
        itf.manufacturerName = [NSString stringWithUTF8String:device_rsp->info.manufacturerName];
    }
    if(device_rsp->info.platformID!=nil){
        itf.platformId = [NSString stringWithUTF8String:device_rsp->info.platformID];
    }
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
    itf.peripheralObject = [[Peripheral alloc] initWithUuid:@"ITF Object"];
    
    if (rsp -> payload->type == PAYLOAD_TYPE_REPRESENTATION) {
        itf.peripheralObject.devAddr = rsp->devAddr;
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
                    pr.resourceArrayValue = [[NSMutableArray alloc] init];
                    
                    for(int i = 0; i < (int)res->ocByteStr.len; i++){
                        int64_t x = res->arr.iArray[i];
                        //  NSNumber *number = [NSNumber numberWithLongLong:res->arr.iArray[i]];
                       // [arr addObject:number];
                        [pr.resourceArrayValue addObject:[NSNumber numberWithUnsignedLongLong:x]];
                    }
                    //pr.resourceArrayValue = [[NSMutableArray alloc] initWithArray:arr];
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
    
    PeripheralResource *pr = itf.peripheralObject.resources[0];
    NSString *booleanValue = pr.resourceBoolValue ? @"true" : @"false";
    NSLog(@"%@ - %@", pr.resourceName, booleanValue);
    
    
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
    
//    [itf.mutex unlock];
//    if (itf.discovery_watcher != (id)nil) {
//        [itf.discovery_watcher getInterfaceData];
//    }
    
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



#pragma mark - Cancel Observe API
//This is needed for debugging
- (int) cancel_observer:(id)delegate andURI:(NSString *)uri andDevAddr:(OCDevAddr)devAddr andHandle:(OCDoHandle)handle
{
    OCStackResult rc;
    
    OCCallbackData cb = {
        .cb = cancel_observe_cb
    };
    
    OCConnectivityType transport = CT_ADAPTER_IP | CT_ADAPTER_GATT_BTLE;
    _discovery_watcher = delegate;
    
    rc =     OCCancel(handle, OC_LOW_QOS, NULL, 0);
    /*OCDoResource(NULL, OC_REST_CANCEL_OBSERVE, [uri UTF8String], &devAddr, NULL, transport, OC_LOW_QOS, &cb, NULL, 0);*/


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
        itf.peripheralObject.devAddr = rsp->devAddr;
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
                    pr.resourceArrayValue = [[NSMutableArray alloc] init];
                    
                    for(int i = 0; i < (int)res->ocByteStr.len; i++){
                        int64_t x = res->arr.iArray[i];
                        //  NSNumber *number = [NSNumber numberWithLongLong:res->arr.iArray[i]];
                        // [arr addObject:number];
                        [pr.resourceArrayValue addObject:[NSNumber numberWithUnsignedLongLong:x]];
                    }
                    //pr.resourceArrayValue = [[NSMutableArray alloc] initWithArray:arr];
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
        [itf.discovery_watcher listUpdated];
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

- (NSMutableArray *)deviceWithIdx
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

- (Peripheral *)resourceDetails
{
    Peripheral *pObj = [[Peripheral alloc] initWithUuid:@"PeripheralObject"];;
    [_mutex lock];
    pObj.devAddr = _peripheralObject.devAddr;
    [pObj.resources addObjectsFromArray:_peripheralObject.resources];
    NSLog(@"%lu",(unsigned long)[pObj.resources count]);
    PeripheralResource *pr = pObj.resources[0];
    NSString *booleanValue = pr.resourceBoolValue ? @"true" : @"false";
    NSLog(@"%@ - %@", pr.resourceName, booleanValue);
    pObj.handle = _observeHandle;
    
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
