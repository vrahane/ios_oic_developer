//
//  ResourceCell.m
//  iotivity_sample
//
//  Created by Marko Kiiskila on 5/16/17.
//  Copyright © 2017 Marko Kiiskila. All rights reserved.
//

#import "ResourceCell.h"

@implementation ResourceCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.uriLabel.clipsToBounds = true;
    self.uriLabel.backgroundColor = [UIColor lightGrayColor];
    self.uriLabel.layer.cornerRadius = 7.0f;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
