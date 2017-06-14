//
//  DetailViewController.m
//  iotivity_sample
//
//  Created by Pooja Gosavi on 5/24/17.
//  Copyright © 2017 Marko Kiiskila. All rights reserved.
//

#import "DetailViewController.h"
#import "iotivity_itf.h"

@interface DetailViewController ()

@end

@implementation DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.navigationBar.title = _navigationTitle;
    self.displayTextView.backgroundColor = [UIColor lightGrayColor];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)getAction:(id)sender {
    self.displayTextView.text = @"{status : true}";
    [[iotivity_itf shared] get_generic:self andURI:self.navigationTitle andDevAddr:self.peripheral.devAddr];
}
- (IBAction)putAction:(id)sender {
    NSString *myString = self.displayTextView.text;
    NSLog(@"%@", myString);
}

- (IBAction)observeAction:(id)sender {
    
}
- (IBAction)backAction:(id)sender {
    
    [self.navigationController popViewControllerAnimated:true];
}


@end
