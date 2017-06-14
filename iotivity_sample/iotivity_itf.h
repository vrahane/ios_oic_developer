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
- (int) discover_deviceDetails:(OCDevAddr *)devAddr;
- (int) discovery_resource:(id)delegate andURI:(NSString *)uri andDevAddr:(OCDevAddr) devAddr;
- (int) discovery_humidity:(id)delegate andURI:(NSString *)uri andDevAddr:(OCDevAddr) devAddr;
- (int) discovery_temperature:(id)delegate andURI:(NSString *)uri andDevAddr:(OCDevAddr) devAddr;

- (int) get_generic:(id)delegate andURI:(NSString *)uri andDevAddr:(OCDevAddr) devAddr;

- (int) set_generic:(id)delegate andURI:(NSString *)uri andDevAddr:(OCDevAddr)devAddr andPayLoad:(OCRepPayload *) payload;


- (int) observe_light:(id)delegate andURI:(NSString *)uri andDevAddr:(OCDevAddr)devAddr;

- (int) cancel_observer:(id)delegate andURI:(NSString *)uri andDevAddr:(OCDevAddr)devAddr andHandle:(OCDoHandle)handle;

- (void)discovery_end;

- (NSUInteger)device_count;
- (Peripheral *)deviceWithIdx:(NSInteger)index;
- (Peripheral *)platformDetails;
- (Peripheral *)statusDetails;
- (Peripheral *)humidityDetails;
- (Peripheral *)temperatureDetails;
- (Peripheral *)lightDetails;
- (Peripheral *)resourceDetails;

@end

@interface NSObject(DeviceListChangeMethods)
- (void)listUpdated;
@end
