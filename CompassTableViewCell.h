//
//  CompassTableViewCell.h
//  iotivity_sample
//
//  Created by Pooja Gosavi on 6/26/17.
//  Copyright © 2017 Marko Kiiskila. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CompassTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *mTypeLbl;
@property (weak, nonatomic) IBOutlet UILabel *mValueLbl;

@end
