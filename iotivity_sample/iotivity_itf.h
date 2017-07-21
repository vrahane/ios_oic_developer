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

- (PeripheralResource *) parseResourcePayload : (OCResourcePayload *) resource;


- (int) discover_allDevices: (id) delegate;
- (int) get_generic:(id)delegate andURI:(NSString *)uri andDevAddr:(OCDevAddr) devAddr;

- (int) set_generic:(id)delegate andURI:(NSString *)uri andDevAddr:(OCDevAddr)devAddr andPayLoad:(OCRepPayload *) payload;

- (int) get_interfaces:(id)delegate andURI:(NSString *)uri andDevAddr:(OCDevAddr) devAddr;

- (int) observe_light:(id)delegate andURI:(NSString *)uri andDevAddr:(OCDevAddr)devAddr;

- (int) cancel_observer:(id)delegate andURI:(NSString *)uri andDevAddr:(OCDevAddr)devAddr andHandle:(OCDoHandle)handle;


- (int) discover_resources: (OCDevAddr *)devAddr;

- (void)discovery_end;

@property (nonatomic, strong) NSMutableArray *whiteList;

- (NSUInteger)device_count;
- (NSMutableArray *)deviceWithIdx;//:(NSInteger)index;
- (Peripheral *)platformDetails;
- (Peripheral *)statusDetails;
- (Peripheral *)resourceDetails;
- (Peripheral *)interfaceDetails;

@end

@interface NSObject(DeviceListChangeMethods)
- (void)listUpdated;
@end
