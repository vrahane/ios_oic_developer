//
//  HomeViewController.h
//  iotivity_sample
//
//  Created by Pooja Gosavi on 6/22/17.
//  Copyright © 2017 Marko Kiiskila. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HomeViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
#pragma mark - properties
@property (weak, nonatomic) IBOutlet UIButton *mScanbtn;
@property (weak, nonatomic) IBOutlet UITableView *mTableView;

#pragma mark - methods
@property (strong, nonatomic) NSString *uri;
@end
