//
//  ResourceDetailsTableViewCell.m
//  iotivity_sample
//
//  Created by Pooja Gosavi on 6/5/17.
//  Copyright © 2017 Marko Kiiskila. All rights reserved.
//

#import "ResourceDetailsTableViewCell.h"
#import "iotivity_itf.h"

@implementation ResourceDetailsTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.layer.cornerRadius = 8.0f;
    
    self.mybgView.clipsToBounds = true;
    self.mybgView.layer.cornerRadius = 7.0;
    self.mybgView.backgroundColor = [UIColor whiteColor];
    
    self.getBtn.clipsToBounds = true;
    self.getBtn.layer.cornerRadius = 7.0f;
    
    self.putBtn.clipsToBounds = true;
    self.putBtn.layer.cornerRadius = 7.0f;
    
    
    self.mybgView.backgroundColor = [UIColor whiteColor];
    [self.mybgView.layer setBorderWidth:0.1f];
    [self.mybgView.layer setShadowColor:[UIColor grayColor].CGColor];
    [self.mybgView.layer setShadowOpacity:0.20f];
    [self.mybgView.layer setShadowRadius:2.0f];
    [self.mybgView.layer setShadowOffset:CGSizeMake(0.0f, 1.0f)];

    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
