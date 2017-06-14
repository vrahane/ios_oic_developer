//
//  PeripheralResource.m
//  iotivity_sample
//
//  Created by Pooja Gosavi on 5/25/17.
//  Copyright © 2017 Marko Kiiskila. All rights reserved.
//

#import "PeripheralResource.h"

@implementation PeripheralResource

- (instancetype)initWithURI:(NSString *)uri
{
    self = [super init];
    
    if (self) {
        _uri = uri;
    }
    return self;
}


@end
