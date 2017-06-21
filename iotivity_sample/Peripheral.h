//
//  Peripheral.h
//  iotivity_sample
//
//  Created by Marko Kiiskila on 5/16/17.
//  Copyright © 2017 Marko Kiiskila. All rights reserved.
//

#import "PeripheralResource.h"
#import <Foundation/Foundation.h>
#include <iotivity-csdk/octypes.h>
#include <iotivity-csdk/ocstack.h>


@interface Peripheral : NSObject

@property (nonatomic, copy) NSString *uuid;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, strong) NSMutableArray *resources;
@property (nonatomic) OCDevAddr devAddr;
@property (nonatomic) OCDoHandle handle;
@property (nonatomic, copy) NSString *platformID;
@property (nonatomic, copy) NSString *manufacturerName;

@property (nonatomic, copy) NSString *resStateName;
@property (nonatomic) bool resState;
@property (nonatomic, strong) NSMutableArray *orientations;


//Humidity and Temperature Data
@property (nonatomic, strong) NSString *resType;
@property (nonatomic, strong) NSString *humidValue;
@property (nonatomic, strong) NSString *tempValue;
@property (nonatomic, strong) NSString *tempUnit;


- (instancetype)initWithUuid:(NSString *)uuidStr;
- (void)addPeripheralResource:(PeripheralResource *)resource;

@end
