//
//  PeripheralResource.m
//  iotivity_sample
//
//  Created by Pooja Gosavi on 5/25/17.
//  Copyright © 2017 Marko Kiiskila. All rights reserved.
//

#import "PeripheralResource.h"

@implementation PeripheralResource

- (instancetype)init
{
    self = [super init];
    if (self) {
        _uri = [[NSString alloc] init];
        _resState = false;
        _statusName = [[NSString alloc] init];
    }
    return self;
}

@end
