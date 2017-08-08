//
//  NewtManagerViewController.h
//  iotivity_sample
//
//  Created by Pooja Gosavi on 6/9/17.
//  Copyright © 2017 Marko Kiiskila. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <iotivity-csdk/octypes.h>

@interface NewtManagerViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource, UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UIPickerView *mPickerView;
@property (weak, nonatomic) IBOutlet UILabel *mOptionsLabel;
@property (weak, nonatomic) IBOutlet UIButton *mDataBtn;
@property (nonatomic) OCDevAddr devAddr;
@property (weak, nonatomic) IBOutlet UITextField *inputTextField;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *backButton;
@property (weak, nonatomic) IBOutlet UITableView *newtMgrTableView;
@property (weak, nonatomic) IBOutlet UILabel *noResponseLbl;
@property (weak, nonatomic) IBOutlet UIButton *getDataBtn;

+ (uint8_t *) buildHeader : (int) op andGroup : (int)group andSeq : (int)mSeq andID : (int)id1;
- (void) obtainData;
@end
