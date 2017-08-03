//
//  NewtManagerViewController.m
//  iotivity_sample
//
//  Created by Pooja Gosavi on 6/9/17.
//  Copyright © 2017 Marko Kiiskila. All rights reserved.
//

#import "NewtManagerViewController.h"
#import "iotivity_itf.h"
#import <iotivity-csdk/octypes.h>
#import <iotivity-csdk/ocpayload.h>

@interface NewtManagerViewController ()

@end

@implementation NewtManagerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Data Button Action
- (IBAction)mGetDataAction:(id)sender {

    //[[iotivity_itf shared] ]
    
    
}

#pragma mark - Picker View Methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return 6;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
   
    if (row == 0) {
        return @"echo";
    } else if (row == 1) {
        return @"console echo";
    } else if (row == 2) {
        return @"task stats";
    } else if (row == 3) {
        return @"mp stats";
    } else if (row == 4) {
        return @"date-time";
    } else if (row == 5) {
        return @"reset";
    }
    return nil;
}


//buildHeader(int op, int group, int sequence, int id)
- (uint8_t *) buildHeader : (int) op andGroup : (int)group andSeq : (int)mSeq andID : (int)id1 {
    uint8_t *retVal = malloc(sizeof(uint8_t) * 8);
    retVal[0] = (uint8_t)op;
    retVal[1] = 0;
    retVal[2] = 0;
    retVal[3] = 0;
    retVal[4] = 0;
    retVal[5] = 0;
    retVal[6] = (uint8_t) mSeq;
    retVal[7] = (uint8_t) id1;
    
    return retVal;
}

/*
 public static byte[] buildHeader(int op, int group, int sequence, int id) {
 byte[] hdr = {(byte)op, 0, 0, 0, 0, 0, (byte)sequence, (byte)id};
 return ByteBuffer.wrap(hdr).putShort(4, (short)group).array();
 }
 */
@end
