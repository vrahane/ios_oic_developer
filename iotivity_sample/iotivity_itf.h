//
//  iotivity_itf.h
//  iotivity_sample
//
//  Created by Marko Kiiskila on 5/15/17.
//  Copyright © 2017 Marko Kiiskila. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Peripheral.h"
#import "PeripheralResource.h"
#include <iotivity-csdk/octypes.h>
#include <iotivity-csdk/ocstack.h>

@interface iotivity_itf : NSObject

+ (instancetype)shared;
- (int)discovery_start:(id)delegate;
- (int) discover_allDevices: (id) delegate andAddress : (NSString *)address;
- (int) get_generic:(id)delegate andURI:(NSString *)uri andDevAddr:(OCDevAddr) devAddr;
- (int) set_generic:(id)delegate andURI:(NSString *)uri andDevAddr:(OCDevAddr)devAddr andPayLoad:(OCRepPayload *) payload;
- (int) observe_light:(id)delegate andURI:(NSString *)uri andDevAddr:(OCDevAddr)devAddr;
- (int) cancel_observer:(id)delegate andURI:(NSString *)uri andDevAddr:(OCDevAddr)devAddr andHandle:(OCDoHandle)handle;
- (int) set_newt_manager:(id)delegate andURI:(NSString *)uri andDevAddr:(OCDevAddr)devAddr andPayLoad:(OCRepPayload *) payload;
- (void)discovery_end;

- (int) obtain_platform_details: (id) delegate andAddress : (OCDevAddr)address;
- (Peripheral *)platformDetails;
- (Peripheral *)resourceDetails;
- (NSMutableArray *)devices_found;
- (Peripheral *)newtMgrDetails;

@end

@interface NSObject(DeviceListChangeMethods)
- (void)listUpdated;
@end
