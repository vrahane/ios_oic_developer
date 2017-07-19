//
//  PeripheralResource.h
//  iotivity_sample
//
//  Created by Pooja Gosavi on 5/25/17.
//  Copyright © 2017 Marko Kiiskila. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <iotivity-csdk/octypes.h>
#include <iotivity-csdk/ocstack.h>

@interface PeripheralResource : NSObject

@property (nonatomic) OCDevAddr devAddr;
@property (nonatomic, strong) NSString *carrierType;
@property (nonatomic) OCRepPayloadPropType type;
@property (nonatomic, copy) NSString *uri;
@property (nonatomic, copy) NSString *resourceName;
@property (nonatomic) bool resourceBoolValue;
@property (nonatomic) int64_t resourceIntegerValue;
@property (nonatomic) double resourceDoubleValue;
@property (nonatomic) NSString *resourceStringValue;
@property (nonatomic) NSMutableArray *resourceArrayValue;
@property (nonatomic, copy) NSString *resourceInterface;
@property (nonatomic, copy) NSString *resourceType;
@end
