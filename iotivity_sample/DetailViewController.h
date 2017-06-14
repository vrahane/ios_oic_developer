//
//  DetailViewController.h
//  iotivity_sample
//
//  Created by Pooja Gosavi on 5/24/17.
//  Copyright © 2017 Marko Kiiskila. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Peripheral.h"

@interface DetailViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextView *displayTextView;
@property (weak, nonatomic) IBOutlet UIButton *getButton;
@property (weak, nonatomic) IBOutlet UIButton *putButton;
@property (weak, nonatomic) IBOutlet UIButton *observerButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *backButton;
@property (weak, nonatomic) IBOutlet UINavigationItem *navigationBar;

@property (strong, nonatomic) NSString *navigationTitle;
@property (strong, nonatomic) Peripheral *peripheral;
@end
