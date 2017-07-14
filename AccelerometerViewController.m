//
//  AccelerometerViewController.m
//  iotivity_sample
//
//  Created by Pooja Gosavi on 7/7/17.
//  Copyright © 2017 Marko Kiiskila. All rights reserved.
//

#import "AccelerometerViewController.h"
#import "SmartDeviceTableViewCell.h"
#import <Charts/Charts.h>

@interface AccelerometerViewController () <ChartViewDelegate>
//@property (strong, nonatomic) NSMutableDictionary *chartValues;
@property (strong, nonatomic) NSMutableArray *chartValues;
@property (strong, nonatomic) NSMutableArray *chartYValues;
@property (strong, nonatomic) NSMutableArray *chartZValues;

@end

double f = -1.0;

@implementation AccelerometerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    UINib *nib = [UINib nibWithNibName:@"SmartDeviceTableViewCell" bundle:nil];
    [_mSmartDeviceList registerNib:nib forCellReuseIdentifier:@"SmartDeviceTableViewCell"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)backAction:(id)sender {
    [self.navigationController popViewControllerAnimated:true];
}

- (void) viewWillAppear:(BOOL)animated {
   // _chartValues = [[NSMutableDictionary alloc] init];
    _chartValues = [[NSMutableArray alloc] init];
    _chartYValues = [[NSMutableArray alloc] init];
    _chartZValues = [[NSMutableArray alloc] init];
    
    
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
    
    leftAxis.axisMaximum = 10;
    leftAxis.axisMinimum = -10;
    leftAxis.gridLineDashLengths = @[@5.f, @5.f];
    leftAxis.drawZeroLineEnabled = YES;
    leftAxis.drawLimitLinesBehindDataEnabled = YES;
    [self.chartView setVisibleXRangeMaximum:5];
    _chartView.rightAxis.enabled = NO;
    _chartView.legend.form = ChartLegendFormLine;
    
    [_chartView animateWithYAxisDuration:1.0];
}

#pragma mark - TableView methods

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.peripheral.resources count];
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SmartDeviceTableViewCell *cell = (SmartDeviceTableViewCell *) [tableView dequeueReusableCellWithIdentifier:@"SmartDeviceTableViewCell"];
    PeripheralResource *pr = self.peripheral.resources[indexPath.row];
    cell.mDataTypeLbl.text = pr.resourceName;
    if(pr.type == OCREP_PROP_DOUBLE) {
        cell.mValueLbl.text = [[NSNumber numberWithDouble:pr.resourceDoubleValue] stringValue];
        if([pr.resourceName containsString:@"x"]) {
            //[_chartValues setValue:[[ChartDataEntry alloc] initWithX:++f y:pr.resourceDoubleValue] forKey:@"x"];
            [_chartValues addObject:[[ChartDataEntry alloc] initWithX:++f y:pr.resourceDoubleValue]];
        }
        if([pr.resourceName containsString:@"y"]) {
            [_chartYValues addObject:[[ChartDataEntry alloc] initWithX:f y:pr.resourceDoubleValue]];
        }
        if([pr.resourceName containsString:@"z"]) {
            [_chartYValues addObject:[[ChartDataEntry alloc] initWithX:f y:pr.resourceDoubleValue]];
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
    [self setDataCount];
}
- (void)setDataCount
{
    
    LineChartDataSet *set1 = nil;
    LineChartDataSet *set2 = nil;
    LineChartDataSet *set3 = nil;
    
    if (_chartView.data.dataSetCount > 0)
    {
        set1 = (LineChartDataSet *)_chartView.data.dataSets[0];
        set1.values = _chartValues;
        
        set2 = (LineChartDataSet *)_chartView.data.dataSets[1];
        set2.values = _chartYValues;
        
        set3 = (LineChartDataSet *)_chartView.data.dataSets[2];
        set3.values = _chartZValues;
        
        [_chartView.data notifyDataChanged];
        [_chartView notifyDataSetChanged];
    }
    else
    {
        set1 = [[LineChartDataSet alloc] initWithValues:_chartValues label:@"DataSet 1"];
        
        set1.drawIconsEnabled = NO;
        
        set1.lineDashLengths = @[@5.f, @2.5f];
        set1.highlightLineDashLengths = @[@5.f, @2.5f];
        [set1 setColor:UIColor.blackColor];
        [set1 setCircleColor:UIColor.clearColor];
        set1.lineWidth = 1.0;
        set1.circleRadius = 3.0;
        set1.drawCircleHoleEnabled = NO;
        set1.valueFont = [UIFont systemFontOfSize:9.f];
        set1.formLineDashLengths = @[@5.f, @2.5f];
        set1.formLineWidth = 1.0;
        set1.formSize = 15.0;
        
        
        set2 = [[LineChartDataSet alloc] initWithValues:_chartValues label:@"DataSet 2"];
        
        set2.drawIconsEnabled = NO;
        
        set2.lineDashLengths = @[@1.0f, @3.5f];
        set2.highlightLineDashLengths = @[@1.0f, @3.5f];
        [set2 setColor:UIColor.blackColor];
        [set2 setCircleColor:UIColor.clearColor];
        set2.lineWidth = 1.0;
        set2.circleRadius = 3.0;
        set2.drawCircleHoleEnabled = NO;
        set2.valueFont = [UIFont systemFontOfSize:9.f];
        set2.formLineDashLengths = @[@5.f, @2.5f];
        set2.formLineWidth = 1.0;
        set2.formSize = 15.0;
      
        
        set3 = [[LineChartDataSet alloc] initWithValues:_chartValues label:@"DataSet 3"];
        
        set3.drawIconsEnabled = NO;
        
        set3.lineDashLengths = @[@2.0f, @4.5f];
        set3.highlightLineDashLengths = @[@2.0f, @4.5f];
        [set3 setColor:UIColor.blackColor];
        [set3 setCircleColor:UIColor.clearColor];
        set3.lineWidth = 1.0;
        set3.circleRadius = 3.0;
        set3.drawCircleHoleEnabled = NO;
        set3.valueFont = [UIFont systemFontOfSize:9.f];
        set3.formLineDashLengths = @[@5.f, @2.5f];
        set3.formLineWidth = 1.0;
        set3.formSize = 15.0;

        
        NSArray *gradientColors = @[
                                    (id)[ChartColorTemplates colorFromString:@"#00ff0000"].CGColor,
                                    (id)[ChartColorTemplates colorFromString:@"#ffff0000"].CGColor
                                    ];
        CGGradientRef gradient = CGGradientCreateWithColors(nil, (CFArrayRef)gradientColors, nil);
        
        set1.fillAlpha = 1.f;
        set1.fill = [ChartFill fillWithLinearGradient:gradient angle:90.f];
        set1.drawFilledEnabled = YES;
        
        set2.fillAlpha = 1.f;
        set2.fill = [ChartFill fillWithLinearGradient:gradient angle:90.f];
        set2.drawFilledEnabled = YES;
       
        set3.fillAlpha = 1.f;
        set3.fill = [ChartFill fillWithLinearGradient:gradient angle:90.f];
        set3.drawFilledEnabled = YES;
        
        CGGradientRelease(gradient);
        
        NSMutableArray *dataSets = [[NSMutableArray alloc] init];
        [dataSets addObject:set1];
        [dataSets addObject:set2];
        [dataSets addObject:set3];

        
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
