//
//  NewtManagerViewController.h
//  iotivity_sample
//
//  Created by Pooja Gosavi on 6/9/17.
//  Copyright © 2017 Marko Kiiskila. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewtManagerViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource>
@property (weak, nonatomic) IBOutlet UIPickerView *mPickerView;
@property (weak, nonatomic) IBOutlet UILabel *mOptionsLabel;
@property (weak, nonatomic) IBOutlet UIButton *mDataBtn;

@end
