//
//  PeripheralResource.h
//  iotivity_sample
//
//  Created by Pooja Gosavi on 5/25/17.
//  Copyright © 2017 Marko Kiiskila. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PeripheralResource : NSObject

@property (nonatomic, copy) NSString *uri;
@property (nonatomic, copy) NSString *statusName;
@property (nonatomic) bool resState;

@end
