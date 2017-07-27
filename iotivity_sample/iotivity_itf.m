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
@property (nonatomic) NSMutableArray *peripherals;
@property (nonatomic) NSMutableArray *orientationArray;
@property (nonatomic) Peripheral* peripheralObject;
@property (nonatomic) OCDoHandle observeHandle;
@property (atomic) id discovery_watcher;

@end

static id delegate;

@implementation iotivity_itf

#pragma mark - Initializations
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
        _peripheralObject = [[Peripheral alloc]initWithUuid:@"PeripheralObject"];
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
        [NSThread sleepForTimeInterval:0.02]; /*This is used to change the time of observations*/
    }
}

#pragma mark - Discover Device by IP
- (int) discovery_start:(id)delegate
{
    delegate = delegate;
    OCStackResult rc;
    OCCallbackData cb = {
        .cb = discovery_cb
    };
    OCConnectivityType transport = CT_ADAPTER_IP;
    
    _discovery_watcher = delegate;
    
    rc = OCDoResource(NULL, OC_REST_DISCOVER, OC_RSRVD_WELL_KNOWN_URI, NULL, NULL,
                      transport, OC_LOW_QOS, &cb, NULL, 0);
    return rc;
}

#pragma mark - Discover Device by IP Callback
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
    
    return OC_STACK_KEEP_TRANSACTION;
}


#pragma mark - Parse the obtained Resource Payload
- (PeripheralResource *) parseResourcePayload : (OCResourcePayload *) resource {
    PeripheralResource *pr = [[PeripheralResource alloc] init];
    pr.uri = [NSString stringWithUTF8String:resource->uri];
    pr.resourceType = [NSString stringWithUTF8String:resource->types->value];
    pr.resourceInterface = [NSString stringWithUTF8String:resource->interfaces->value];
    return pr;
}


#pragma mark - Discover resources by BLE
- (int) discover_allDevices: (id) delegate andBLEAddress : (NSString *)bleAddr{
    delegate = delegate;
    OCDevAddr devAddr;
    strcpy(devAddr.addr,[bleAddr UTF8String]);
    OCStackResult rc;
    OCCallbackData cb = {
        .cb = discovery_ble_cb
    };
    OCConnectivityType transport = CT_ADAPTER_IP | CT_ADAPTER_GATT_BTLE;
    
    _discovery_watcher = delegate;
    
    rc = OCDoResource(NULL, OC_REST_DISCOVER, OC_RSRVD_WELL_KNOWN_URI, &devAddr, NULL,
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
    
    return OC_STACK_KEEP_TRANSACTION;
}

#pragma mark - Get resource Call
- (int) get_resources:(id)delegate andURI:(NSString *)uri andDevAddr:(OCDevAddr) devAddr
{
    
    OCStackResult rc;
    OCCallbackData cb = {
        .cb = get_cb
    };
    OCConnectivityType transport = CT_ADAPTER_IP | CT_ADAPTER_GATT_BTLE;
    
    _discovery_watcher = delegate;
    
    rc = OCDoResource(NULL, OC_REST_GET, [uri UTF8String], &devAddr, NULL,
                      transport, OC_LOW_QOS, &cb, NULL, 0);
    
    
    return rc;
    
}

#pragma mark - get resource Callback
static OCStackApplicationResult
get_cb(void *ctx, OCDoHandle handle, OCClientResponse *rsp){
    
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
                        [pr.resourceArrayValue addObject:[NSNumber numberWithUnsignedLongLong:x]];
                    }
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

#pragma mark - Set resource Call
- (int) set_resource_value:(id)delegate andURI:(NSString *)uri andDevAddr:(OCDevAddr)devAddr andPayLoad:(OCRepPayload *) payload{
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

#pragma mark - Set resource Callback
static OCStackApplicationResult
set_cb(void *ctx, OCDoHandle handle, OCClientResponse *rsp){
    
    return OC_STACK_DELETE_TRANSACTION;
    
}



#pragma mark - Cancel Observe API
- (int) cancel_observer:(id)delegate andURI:(NSString *)uri andDevAddr:(OCDevAddr)devAddr andHandle:(OCDoHandle)handle
{
    OCStackResult rc;
    
    OCCallbackData cb = {
        .cb = cancel_observe_cb
    };
    
    OCConnectivityType transport = CT_ADAPTER_IP | CT_ADAPTER_GATT_BTLE;
    _discovery_watcher = delegate;
    
    rc =     OCCancel(handle, OC_LOW_QOS, NULL, 0);
    return rc;
}

#pragma mark - Cancel Observe Callback
//This is needed for debugging
static OCStackApplicationResult
cancel_observe_cb(void *ctx, OCDoHandle handle, OCClientResponse *rsp)
{
    return OC_STACK_DELETE_TRANSACTION;
}

#pragma mark - Observe APICall
- (int) observe:(id)delegate andURI:(NSString *)uri andDevAddr:(OCDevAddr)devAddr
{
    OCStackResult rc;
    
    OCCallbackData cb = {
        .cb = observe_cb
    };
    OCConnectivityType transport = CT_ADAPTER_IP | CT_ADAPTER_GATT_BTLE;
    
    _discovery_watcher = delegate;
    
    rc = OCDoResource(NULL, OC_REST_OBSERVE, [uri UTF8String], &devAddr, NULL,
                      transport, OC_LOW_QOS, &cb, NULL, 0);
    
    return rc;
}

#pragma mark - Observe Cb
static OCStackApplicationResult
observe_cb(void *ctx, OCDoHandle handle, OCClientResponse *rsp)
{
    iotivity_itf *itf = [iotivity_itf shared];
    
    itf.peripheralObject = [[Peripheral alloc] initWithUuid:@"ITF Object"];
    if(rsp->payload) {
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
                            [pr.resourceArrayValue addObject:[NSNumber numberWithUnsignedLongLong:x]];
                        }
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
    }
    NSLog(@"%lu",(unsigned long)[itf.peripheralObject.resources count]);
    
    [itf.mutex unlock];
    if (itf.discovery_watcher != (id)nil) {
        [itf.discovery_watcher listUpdated];
    }
    
    return OC_STACK_KEEP_TRANSACTION;
}

#pragma mark - End discovery
- (void)discovery_end
{
    _discovery_watcher = (id)nil;
}

/*Function to return the discovered Peripherals*/
- (NSMutableArray *)deviceWithIdx
{
    return _peripherals;
}

/*Function to receive Data from the resources - used after the get call*/
- (Peripheral *)resourceDetails
{
    Peripheral *pObj = [[Peripheral alloc] initWithUuid:@"PeripheralObject"];;
    [_mutex lock];
    pObj.devAddr = _peripheralObject.devAddr;
    [pObj.resources addObjectsFromArray:_peripheralObject.resources];
    NSLog(@"%lu",(unsigned long)[pObj.resources count]);
    if ([pObj.resources count] < 1) {
        pObj = nil;
    } else {
        PeripheralResource *pr = pObj.resources[0];
        NSString *booleanValue = pr.resourceBoolValue ? @"true" : @"false";
        NSLog(@"%@ - %@", pr.resourceName, booleanValue);
        pObj.handle = _observeHandle;
    }
    [_mutex unlock];
    
    return pObj;
    
}

@end
