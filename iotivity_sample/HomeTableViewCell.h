//
//  HomeTableViewCell.h
//  iotivity_sample
//
//  Created by Pooja Gosavi on 6/26/17.
//  Copyright © 2017 Marko Kiiskila. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HomeTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (weak, nonatomic) IBOutlet UILabel *typeLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;
@end
