//
//  Peripheral.m
//  iotivity_sample
//
//  Created by Marko Kiiskila on 5/16/17.
//  Copyright © 2017 Marko Kiiskila. All rights reserved.
//

#import "Peripheral.h"


@implementation Peripheral

- (instancetype)initWithUuid:(NSString *)uuidStr
{
    self = [super init];
    
    if (self) {
        _uuid = uuidStr;
        _resources = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)addPeripheralResource:(PeripheralResource *)resource
{
    [_resources addObject:resource];
    NSLog(@"%lu",(unsigned long)[_resources count]);
}
@end

