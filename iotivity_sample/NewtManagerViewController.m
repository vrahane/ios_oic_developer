//
//  NewtManagerViewController.m
//  iotivity_sample
//
//  Created by Pooja Gosavi on 8/2/17.
//  Copyright © 2017 Marko Kiiskila. All rights reserved.
//

#import "NewtManagerViewController.h"
#import "NewtMgrTableViewCell.h"
#import "iotivity_itf.h"
#import <iotivity-csdk/octypes.h>
#import <iotivity-csdk/ocpayload.h>

//
// Newt Manager Op Codes
//
static int NMGR_OP_READ                     = 0;
static int NMGR_OP_READ_RSP                 = 1;
static int NMGR_OP_WRITE                    = 2;
static int NMGR_OP_WRITE_RSP                = 3;

//
// Newt Manager groups
//
static int NMGR_GROUP_DEFAULT 	            = 0;
static int NMGR_GROUP_IMAGE 		        = 1;
static int NMGR_GROUP_STATS 		        = 2;
static int NMGR_GROUP_CONFIG 		        = 3;
static int NMGR_GROUP_LOGS                  = 4;
static int NMGR_GROUP_CRASH 		        = 5;
static int NMGR_GROUP_PERUSER 	            = 64;

//
// Newt Manager default group command subcommand IDs
//
static int NMGR_DEFAULT_ID_ECHO             = 0;
static int NMGR_DEFAULT_ID_CONS_ECHO_CTRL   = 1;
static int NMGR_DEFAULT_ID_TASKSTAT         = 2;
static int NMGR_DEFAULT_ID_MPSTAT           = 3;
static int NMGR_DEFAULT_ID_DATETIME_STR     = 4;
static int NMGR_DEFAULT_ID_RESET            = 5;

//
// Newt Manager stats group command IDs
//
static int NMGR_STATS_ID_READ              = 0;
static int NMGR_STATS_ID_LIST              = 1;

//
// Newt manager image group command IDs
//
static int NMGR_IMAGE_ID_LIST		        = 0;
static int NMGR_IMAGE_ID_UPLOAD             = 1;
static int NMGR_IMAGE_ID_BOOT		        = 2;
static int NMGR_IMAGE_ID_FILE		        = 3;
static int NMGR_IMAGE_ID_LIST2		        = 4;
static int NMGR_IMAGE_ID_BOOT2		        = 5;
static int NMGR_IMAGE_ID_CORELIST 	        = 6;
static int NMGR_IMAGE_ID_CORELOAD 	        = 7;

static NSString *mHeaderKey = @"_h";
static int mSeq = 0;

@interface NewtManagerViewController ()
@property (nonatomic, strong) NSMutableArray *peripheralResources;
@property (nonatomic, strong) NSString *chosenField;
@end

@implementation NewtManagerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _noResponseLbl.hidden = true;
    _peripheralResources = [[NSMutableArray alloc] init];
    UINib *nib = [UINib nibWithNibName:@"NewtMgrTableViewCell" bundle:nil];
    [_newtMgrTableView registerNib:nib forCellReuseIdentifier:@"NewtMgrTableViewCell"];
    _mPickerView.layer.borderColor = (__bridge CGColorRef _Nullable)([UIColor blackColor]);
    _mPickerView.layer.borderWidth = 1.0f;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return 7;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (row == 0) {
        return @"Choose from the picker view";
    }
    else if (row == 1) {
        return @"echo";
    } else if (row == 2) {
        return @"console echo";
    } else if (row == 3) {
        return @"task stats";
    } else if (row == 4) {
        return @"mp stats";
    } else if (row == 5) {
        return @"date-time";
    } else if (row == 6) {
        return @"reset";
    }
    return nil;
}
- (IBAction)backAction:(id)sender {
    
    [self.navigationController popViewControllerAnimated:true];
}


- (void) pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (row == 0) {
    }
    else if (row == 1) {
    NSString *str = [[_mPickerView delegate] pickerView:_mPickerView titleForRow:row forComponent:0];
        _chosenField = str;
    } else if (row == 2) {
        NSString *str = [[_mPickerView delegate] pickerView:_mPickerView titleForRow:row forComponent:0];
        _chosenField = str;
    } else if (row == 3) {
        NSString *str = [[_mPickerView delegate] pickerView:_mPickerView titleForRow:row forComponent:0];
        _chosenField = str;
    } else if (row == 4) {
        NSString *str = [[_mPickerView delegate] pickerView:_mPickerView titleForRow:row forComponent:0];
        _chosenField = str;
    } else if (row == 5) {
        NSString *str = [[_mPickerView delegate] pickerView:_mPickerView titleForRow:row forComponent:0];
        _chosenField = str;
    } else if (row == 6) {
        NSString *str = [[_mPickerView delegate] pickerView:_mPickerView titleForRow:row forComponent:0];
        _chosenField = str;
    }

}

- (CGFloat) pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return 35.0;
}

- (IBAction)dataAction:(id)sender {
    if ([_chosenField isEqualToString:@"echo"]) {
        NSString *str = _inputTextField.text;
        NSLog(@"%@",str);
        [self echo:str];
    } else if ([_chosenField isEqualToString:@"console echo"]) {
        NSString *str = _inputTextField.text;
        NSLog(@"%@",str);
        [self consoleEcho:str];
    } else if ([_chosenField isEqualToString:@"task stats"]) {
        [self taskStat];
    } else if ([_chosenField isEqualToString:@"mp stats"]) {
        [self mpStat];
    } else if ([_chosenField isEqualToString:@"date-time"]) {
        NSString *str = _inputTextField.text;
        [self dateTime:str];
    } else if ([_chosenField isEqualToString:@"reset"]) {
        [self reset];
    }
    _noResponseLbl.hidden = true;
    self.inputTextField.text = @"";
}

//buildHeader(int op, int group, int sequence, int id)
+ (uint8_t *) buildHeader : (int) op andGroup : (int)group andSeq : (int)mSeq andID : (int)id1 {
    uint8_t *retVal = malloc(sizeof(uint8_t) * 8);
    retVal[0] = (uint8_t)op;
    retVal[1] = 0;
    retVal[2] = 0;
    retVal[3] = 0;
    retVal[4] = 0;
    retVal[5] = 0;
    retVal[6] = (uint8_t) mSeq;
    retVal[7] = (uint8_t) id1;
    
    NSLog(@"%hhu",retVal[0]);
    NSLog(@"%hhu",retVal[6]);
    NSLog(@"%hhu",retVal[7]);

    return retVal;
}


- (void) consoleEcho: (NSString *) str {
    OCRepPayload *rep = OCRepPayloadCreate();
    uint8_t *nmgrHeader = [NewtManagerViewController buildHeader:NMGR_OP_READ andGroup:NMGR_GROUP_DEFAULT andSeq:mSeq andID:NMGR_DEFAULT_ID_CONS_ECHO_CTRL];
    mSeq++;
    OCByteString byteStr;
    byteStr.bytes = nmgrHeader;
    byteStr.len = sizeof(nmgrHeader);
    OCRepPayloadSetPropByteString(rep,[mHeaderKey UTF8String], byteStr);
    OCRepPayloadSetPropString(rep, [@"echo" UTF8String], [str UTF8String]);
   [[iotivity_itf shared] set_newt_manager:self andURI:@"/omgr" andDevAddr:self.devAddr andPayLoad:rep];
}


- (void) echo :(NSString *) str {
    OCRepPayload *rep = OCRepPayloadCreate();
    uint8_t *nmgrHeader = [NewtManagerViewController buildHeader:NMGR_OP_READ andGroup:NMGR_GROUP_DEFAULT andSeq:mSeq andID:NMGR_DEFAULT_ID_ECHO];
    
    NSLog(@"%hhu",nmgrHeader[0]);
    mSeq++;
    OCByteString byteStr;
    byteStr.bytes = nmgrHeader;
    byteStr.len = sizeof(nmgrHeader);
    OCRepPayloadSetPropByteString(rep,[mHeaderKey UTF8String], byteStr);
    OCRepPayloadSetPropString(rep, [@"d" UTF8String], [str UTF8String]);
    [[iotivity_itf shared] set_newt_manager:self andURI:@"/omgr" andDevAddr:self.devAddr andPayLoad:rep];
}

- (void) taskStat {
    OCRepPayload *rep = OCRepPayloadCreate();
    uint8_t *nmgrHeader = [NewtManagerViewController buildHeader:NMGR_OP_READ andGroup:NMGR_GROUP_DEFAULT andSeq:mSeq andID:NMGR_DEFAULT_ID_TASKSTAT];
    
    NSLog(@"%hhu",nmgrHeader[0]);
    mSeq++;
    OCByteString byteStr;
    byteStr.bytes = nmgrHeader;
    byteStr.len = sizeof(nmgrHeader);
    OCRepPayloadSetPropByteString(rep,[mHeaderKey UTF8String], byteStr);
    [[iotivity_itf shared] set_newt_manager:self andURI:@"/omgr" andDevAddr:self.devAddr andPayLoad:rep];
}

- (void) mpStat {
    OCRepPayload *rep = OCRepPayloadCreate();
    uint8_t *nmgrHeader = [NewtManagerViewController buildHeader:NMGR_OP_READ andGroup:NMGR_GROUP_DEFAULT andSeq:mSeq andID:NMGR_DEFAULT_ID_MPSTAT];
    
    NSLog(@"%hhu",nmgrHeader[0]);
    mSeq++;
    OCByteString byteStr;
    byteStr.bytes = nmgrHeader;
    byteStr.len = sizeof(nmgrHeader);
    OCRepPayloadSetPropByteString(rep,[mHeaderKey UTF8String], byteStr);
    [[iotivity_itf shared] set_newt_manager:self andURI:@"/omgr" andDevAddr:self.devAddr andPayLoad:rep];
}

- (void) dateTime : (NSString *)datetime {
    OCRepPayload *rep = OCRepPayloadCreate();
    uint8_t *nmgrHeader;
    if(datetime == nil || [datetime  isEqual: @""]) {
        nmgrHeader = [NewtManagerViewController buildHeader:NMGR_OP_READ andGroup:NMGR_GROUP_DEFAULT andSeq:mSeq andID:NMGR_DEFAULT_ID_DATETIME_STR];
    } else {
        nmgrHeader = [NewtManagerViewController buildHeader:NMGR_OP_WRITE andGroup:NMGR_GROUP_DEFAULT andSeq:mSeq andID:NMGR_DEFAULT_ID_DATETIME_STR];
    }
    mSeq ++;
    OCByteString byteStr;
    byteStr.bytes = nmgrHeader;
    byteStr.len = sizeof(nmgrHeader);
    OCRepPayloadSetPropByteString(rep,[mHeaderKey UTF8String], byteStr);
    if (datetime!=nil && ![datetime isEqualToString:@""]) {
        OCRepPayloadSetPropString(rep, [@"datetime" UTF8String], [datetime UTF8String]);
    }
    [[iotivity_itf shared] set_newt_manager:self andURI:@"/omgr" andDevAddr:self.devAddr andPayLoad:rep];
}

- (void) reset {
    OCRepPayload *rep = OCRepPayloadCreate();
    uint8_t *nmgrHeader = [NewtManagerViewController buildHeader:NMGR_OP_WRITE andGroup:NMGR_GROUP_DEFAULT andSeq:mSeq andID:NMGR_DEFAULT_ID_RESET];
    mSeq++;
    OCByteString byteStr;
    byteStr.bytes = nmgrHeader;
    byteStr.len = sizeof(nmgrHeader);
    OCRepPayloadSetPropByteString(rep, [mHeaderKey UTF8String], byteStr);
    [[iotivity_itf shared] set_newt_manager:self andURI:@"/omgr" andDevAddr:self.devAddr andPayLoad:rep];
    
}
- (void) obtainData {
    _peripheralResources = [[NSMutableArray alloc] init];
    Peripheral *pr = [[iotivity_itf shared] newtMgrDetails];
    NSLog(@"%@", pr.resStateName);
    
    for (PeripheralResource *per in pr.resources) {
        if ([per.uri isEqualToString:@"_h"]) {
            
        } else {
            [_peripheralResources addObject:per];
        }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [_newtMgrTableView reloadData];
    });

}

#pragma mark - TableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if([_peripheralResources count] == 0) {
        _noResponseLbl.hidden = false;
    }
    return [_peripheralResources count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NewtMgrTableViewCell *cell = (NewtMgrTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"NewtMgrTableViewCell"];
    PeripheralResource *pres = _peripheralResources[indexPath.row];
    
    cell.keyLbl.text = pres.resourceName;
    if(pres.type == OCREP_PROP_INT){
        cell.valueLbl.text = [[NSNumber numberWithLongLong:pres.resourceIntegerValue] stringValue];
    }else if(pres.type == OCREP_PROP_BOOL){
        NSString *booleanString = pres.resourceBoolValue ? @"true" : @"false";
        cell.valueLbl.text = booleanString;
    }else if(pres.type == OCREP_PROP_DOUBLE){
        cell.valueLbl.text = [[NSNumber numberWithDouble:pres.resourceDoubleValue] stringValue];
    }else if(pres.type == OCREP_PROP_STRING){
        cell.valueLbl.text = pres.resourceStringValue;
    }
    

    return cell;
}
@end
