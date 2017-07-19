//
//  PressureViewController.m
//  iotivity_sample
//
//  Created by Pooja Gosavi on 7/7/17.
//  Copyright © 2017 Marko Kiiskila. All rights reserved.
//

#import "PressureViewController.h"
#import "SmartDeviceTableViewCell.h"
#import "iotivity_itf.h"
#import <Charts/Charts.h>

@interface PressureViewController () <ChartViewDelegate>

@property (strong, nonatomic) NSMutableArray *chartValues;

@end

double j = 0;

@implementation PressureViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UINib *nib;
    nib = [UINib nibWithNibName:@"SmartDeviceTableViewCell" bundle:nil];
    [_mSmartDeviceList registerNib:nib forCellReuseIdentifier:@"SmartDeviceTableViewCell"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated {
    _chartValues = [[NSMutableArray alloc] init];
    
    _chartView.delegate = self;
    
    _chartView.chartDescription.enabled = NO;
    
    _chartView.dragEnabled = YES;
    [_chartView setScaleEnabled:YES];
    _chartView.pinchZoomEnabled = YES;
    _chartView.drawGridBackgroundEnabled = NO;
    
    ChartXAxis *xAxis = _chartView.xAxis;
    [xAxis removeAllLimitLines];
    
    ChartYAxis *leftAxis = _chartView.leftAxis;
    [leftAxis removeAllLimitLines];
    
    leftAxis.axisMaximum = 102.0;
    leftAxis.axisMinimum = 101.0;
    leftAxis.drawZeroLineEnabled = YES;
    leftAxis.drawLimitLinesBehindDataEnabled = YES;
    [self.chartView setVisibleXRangeMaximum:5];
    _chartView.rightAxis.enabled = NO;
    _chartView.legend.form = ChartLegendFormLine;
    
    [_chartView animateWithYAxisDuration:1.0];
}

- (IBAction)backAction:(id)sender {
    
    [self.navigationController popViewControllerAnimated:true];
}

#pragma mark - Tableview Methods

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.peripheral.resources count];
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    SmartDeviceTableViewCell *cell = (SmartDeviceTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"SmartDeviceTableViewCell"];
    PeripheralResource *pr = _peripheral.resources[indexPath.row];
    cell.mDataTypeLbl.text = pr.resourceName;
    if(pr.type == OCREP_PROP_DOUBLE) {
        cell.mValueLbl.text = [[NSNumber numberWithDouble:pr.resourceDoubleValue] stringValue];
        if([pr.resourceName containsString:@"press"]) {
            [_chartValues addObject:[[ChartDataEntry alloc] initWithX:j++ y:(pr.resourceDoubleValue/1000) icon: [UIImage imageNamed:@"icon"]]];
        }
    } else if(pr.type == OCREP_PROP_STRING) {
        cell.mValueLbl.text = pr.resourceStringValue;
    }else if(pr.type == OCREP_PROP_INT){
        cell.mValueLbl.text = [[NSNumber numberWithLongLong:pr.resourceIntegerValue] stringValue];
    }else if(pr.type == OCREP_PROP_BOOL){
        NSString *booleanString = pr.resourceBoolValue ? @"true" : @"false";
        cell.mValueLbl.text = booleanString;
    }
    [self updateChartData];
    return cell;

}

- (IBAction)mSwitchChanged:(id)sender {
    
    if ([self.mSwitch isOn]) {
        [[iotivity_itf shared] observe_light:self andURI:self.uri andDevAddr:self.peripheral.devAddr];
    }else {
        [[iotivity_itf shared] cancel_observer:self andURI:self.uri andDevAddr:_peripheral.devAddr andHandle:_peripheral.handle];
    }
    
}

-(void) getResourceDetails {
    [self receiveData];
}

-(void) receiveData {
    Peripheral *pr;
    pr = [[iotivity_itf shared] resourceDetails];
    
    for (PeripheralResource *resource in pr.resources) {
        NSLog(@"%@",resource.resourceName);
    }
    
    self.peripheral = pr;
    _peripheral.devAddr = pr.devAddr;
    _peripheral.handle = pr.handle;
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self.mSmartDeviceList reloadData];
    }];
    
}

- (void)updateChartData
{
    [self setDataCount:_chartValues];
}

- (void)setDataCount:(NSMutableArray *)chartValues
{
    
    LineChartDataSet *set1 = nil;
    if (_chartView.data.dataSetCount > 0)
    {
        set1 = (LineChartDataSet *)_chartView.data.dataSets[0];
        set1.values = chartValues;
        [_chartView.data notifyDataChanged];
        [_chartView notifyDataSetChanged];
    }
    else
    {
        set1 = [[LineChartDataSet alloc] initWithValues:chartValues label:@"DataSet 1"];
        
        set1.drawIconsEnabled = NO;
        
        [set1 setColor:UIColor.redColor];
        [set1 setCircleColor:UIColor.clearColor];
        set1.lineWidth = 1.0;
        set1.circleRadius = 0.0;
        set1.drawCircleHoleEnabled = NO;
        set1.valueFont = [UIFont systemFontOfSize:9.f];
        
        set1.formSize = 15.0;
        
        set1.fillAlpha = 1.f;
        
        set1.drawFilledEnabled = NO;
        NSMutableArray *dataSets = [[NSMutableArray alloc] init];
        [dataSets addObject:set1];
        
        LineChartData *data = [[LineChartData alloc] initWithDataSets:dataSets];
        
        _chartView.data = data;
        _chartView.chartDescription.text = @"";
    }
    set1.drawValuesEnabled = false;
}

#pragma mark - Actions

- (IBAction)slidersValueChanged:(id)sender
{
    [self updateChartData];
}

#pragma mark - ChartViewDelegate

- (void)chartValueSelected:(ChartViewBase * __nonnull)chartView entry:(ChartDataEntry * __nonnull)entry highlight:(ChartHighlight * __nonnull)highlight
{
    NSLog(@"chartValueSelected");
}

- (void)chartValueNothingSelected:(ChartViewBase * __nonnull)chartView
{
    NSLog(@"chartValueNothingSelected");
}

@end
