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

@interface iotivity_itf : NSObject

+ (instancetype)shared;
- (int)discovery_start:(id)delegate;
- (int) discover_deviceDetails:(OCDevAddr *)devAddr;
- (int) discovery_resource:(id)delegate andURI:(NSString *)uri andDevAddr:(OCDevAddr) devAddr;
- (int) discovery_humidity:(id)delegate andURI:(NSString *)uri andDevAddr:(OCDevAddr) devAddr;
- (int) discovery_temperature:(id)delegate andURI:(NSString *)uri andDevAddr:(OCDevAddr) devAddr;
- (void)discovery_end;

- (NSUInteger)device_count;
- (Peripheral *)deviceWithIdx:(NSInteger)index;
- (Peripheral *)platformDetails;
- (Peripheral *)statusDetails;
- (Peripheral *)humidityDetails;
- (Peripheral *)temperatureDetails;

@end

@interface NSObject(DeviceListChangeMethods)
- (void)listUpdated;
@end
