//
//  iotivity_itf.h
//  iotivity_sample
//
//  Created by Pooja Gosavi on 6/16/17.
//  Copyright © 2017 Marko Kiiskila. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Peripheral.h"
#import "PeripheralResource.h"
#include <iotivity-csdk/octypes.h>
#include <iotivity-csdk/ocstack.h>

@interface iotivity_itf : NSObject

/*Creates a single instance of iotivity-itf*/
+ (instancetype)shared;

/* Starts discovery using IP*/
- (int)discovery_start:(id)delegate;

- (PeripheralResource *) parseResourcePayload : (OCResourcePayload *) resource;

/*Unicast BLE resource discovery after scanning*/
- (int) discover_allDevices: (id) delegate andBLEAddress : (NSString *)bleAddr;

/*Get Resources from the devices discovered*/
- (int) get_resources:(id)delegate andURI:(NSString *)uri andDevAddr:(OCDevAddr) devAddr;

/*Set Resource values*/
- (int) set_resource_value:(id)delegate andURI:(NSString *)uri andDevAddr:(OCDevAddr)devAddr andPayLoad:(OCRepPayload *) payload;

/*Observe Resource values*/
- (int) observe:(id)delegate andURI:(NSString *)uri andDevAddr:(OCDevAddr)devAddr;

/* cancel observe on the resource value*/
- (int) cancel_observer:(id)delegate andURI:(NSString *)uri andDevAddr:(OCDevAddr)devAddr andHandle:(OCDoHandle)handle;

/* end of dicovery*/
- (void)discovery_end;

/*Returns the devices after the view controller asks for it*/
- (NSMutableArray *)deviceWithIdx;

/*Returns the resources with details after the view controller asks for it*/
- (Peripheral *)resourceDetails;

@end

/*Return Method After the Callback of discovery*/
@interface NSObject(DeviceListChangeMethods)
- (void)listUpdated;
@end
