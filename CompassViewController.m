//
//  CompassViewController.m
//  iotivity_sample
//
//  Created by Pooja Gosavi on 6/26/17.
//  Copyright © 2017 Marko Kiiskila. All rights reserved.
//

#import "CompassViewController.h"
#import "CompassTableViewCell.h"
#import "iotivity_itf.h"

@interface CompassViewController () <ChartViewDelegate>
@property (strong, nonatomic) NSMutableArray *chartXValues;
@property (strong, nonatomic) NSMutableArray *chartYValues;
@property (strong, nonatomic) NSMutableArray *chartZValues;
@end

float e = -1.0;

@implementation CompassViewController

@synthesize mTableView;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    int64_t x[3];
    for (PeripheralResource *res in self.peripheral.resources) {
        NSLog(@"%@",res.resourceName);
        for (int i = 0; i < [res.resourceArrayValue count]; i++) {
            x[i] = [res.resourceArrayValue[i] unsignedLongLongValue];
            NSString *str = [NSString stringWithFormat:@"%lld",x[i]];
            NSLog(@"%@",str);
        }
        
    }
    
    UINib *nib;
    nib = [UINib nibWithNibName:@"CompassTableViewCell" bundle:nil];
    [self.mTableView registerNib:nib
            forCellReuseIdentifier:@"CompassTableViewCell"];
    self.navigationItem.title = self.uri;
}

-(void) viewWillAppear:(BOOL)animated {
#pragma mark - Chart view initializations
    _chartXValues = [[NSMutableArray alloc] init];
    _chartYValues = [[NSMutableArray alloc] init];
    _chartZValues = [[NSMutableArray alloc] init];
    _chartView.delegate = self;
    
    _chartView.chartDescription.enabled = NO;
    
    _chartView.dragEnabled = YES;
    [_chartView setScaleEnabled:YES];
    _chartView.pinchZoomEnabled = YES;
    _chartView.drawGridBackgroundEnabled = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - table view
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CompassTableViewCell *cell = (CompassTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"CompassTableViewCell"];
    int64_t x[3];
    PeripheralResource *res = _peripheral.resources[0];
    x[indexPath.row] = [res.resourceArrayValue[indexPath.row] unsignedLongLongValue];
    cell.mValueLbl.text = [NSString stringWithFormat:@"%lld",x[indexPath.row]];
    if (indexPath.row == 0) {
       cell.mTypeLbl.text = @"X";
         [_chartXValues addObject:[[ChartDataEntry alloc] initWithX:++e y:x[indexPath.row] icon: [UIImage imageNamed:@"icon"]]];
    }else if(indexPath.row == 1) {
       cell.mTypeLbl.text = @"Y";
        [_chartYValues addObject:[[ChartDataEntry alloc] initWithX:e y:x[indexPath.row] icon: [UIImage imageNamed:@"icon"]]];

    } else if(indexPath.row == 2) {
        cell.mTypeLbl.text = @"Z";
        [_chartZValues addObject:[[ChartDataEntry alloc] initWithX:e y:x[indexPath.row] icon: [UIImage imageNamed:@"icon"]]];

    }
    
    [self updateChartValues];
    return cell;
}

#pragma mark - Observe
- (IBAction)mSwitchMethod:(id)sender {
    
    if ([self.mSwitch isOn]) {
        [[iotivity_itf shared] observe:self andURI:@"/compass" andDevAddr:self.peripheral.devAddr];
    }else {
        [[iotivity_itf shared] cancel_observer:self andURI:@"/compass" andDevAddr:_peripheral.devAddr andHandle:_peripheral.handle];
    }
}

-(void) listUpdated {
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
        [mTableView reloadData];
    }];
    
}
- (IBAction)backBtnAction:(id)sender {

    [self.navigationController popViewControllerAnimated:true];
}

- (void) updateChartValues {
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
        set1.values = _chartXValues;
        
        set2 = (LineChartDataSet *)_chartView.data.dataSets[1];
        set2.values = _chartYValues;
        
        set3 = (LineChartDataSet *)_chartView.data.dataSets[2];
        set3.values = _chartZValues;
        
        [_chartView.data notifyDataChanged];
        [_chartView notifyDataSetChanged];
    }
    else
    {
        set1 = [[LineChartDataSet alloc] initWithValues:_chartXValues label:@"X"];
        
        set1.drawIconsEnabled = NO;
        
        [set1 setColor:UIColor.blueColor];
        [set1 setCircleColor:UIColor.clearColor];
        set1.lineWidth = 1.0;
        set1.circleRadius = 0.0;
        set1.drawCircleHoleEnabled = NO;
        set1.valueFont = [UIFont systemFontOfSize:9.f];
        
        set1.formSize = 15.0;
        
        
        set2 = [[LineChartDataSet alloc] initWithValues:_chartYValues label:@"Y"];
        
        set2.drawIconsEnabled = NO;
        
        [set2 setColor:UIColor.greenColor];
        [set2 setCircleColor:UIColor.clearColor];
        set2.lineWidth = 1.0;
        set2.circleRadius = 0.0;
        set2.drawCircleHoleEnabled = NO;
        set2.valueFont = [UIFont systemFontOfSize:9.f];
        
        set2.formSize = 15.0;
        
        
        set3 = [[LineChartDataSet alloc] initWithValues:_chartZValues label:@"Z"];
        
        set3.drawIconsEnabled = NO;
        
        [set3 setColor:UIColor.redColor];
        [set3 setCircleColor:UIColor.clearColor];
        set3.lineWidth = 1.0;
        set3.circleRadius = 0.0;
        set3.drawCircleHoleEnabled = NO;
        set3.valueFont = [UIFont systemFontOfSize:9.f];
        set3.formSize = 15.0;
        
        set1.fillAlpha = 1.f;
        
        set1.drawFilledEnabled = NO;
        
        set2.fillAlpha = 1.f;
        
        set2.drawFilledEnabled = NO;
        
        set3.fillAlpha = 1.f;
        
        set3.drawFilledEnabled = NO;
        
        NSMutableArray *dataSets = [[NSMutableArray alloc] init];
        [dataSets addObject:set1];
        [dataSets addObject:set2];
        [dataSets addObject:set3];
        
        
        LineChartData *data = [[LineChartData alloc] initWithDataSets:dataSets];
        
        _chartView.data = data;
        _chartView.chartDescription.text = @"";
    }
    
    ChartXAxis *xAxis = _chartView.xAxis;
    [xAxis removeAllLimitLines];
    
    xAxis.drawGridLinesEnabled = NO;
    
    ChartYAxis *leftAxis = _chartView.leftAxis;
    [leftAxis removeAllLimitLines];
    
    leftAxis.axisMaximum = _chartView.data.yMax + 1.0;
    leftAxis.axisMinimum = _chartView.data.yMin - 1.0;
    
    
    leftAxis.drawZeroLineEnabled = NO;
    leftAxis.drawLimitLinesBehindDataEnabled = NO;
    leftAxis.drawGridLinesEnabled = NO;
    
    [self.chartView setVisibleXRangeMaximum:5];
    _chartView.rightAxis.enabled = NO;
    _chartView.legend.form = ChartLegendFormLine;
    
    [_chartView animateWithXAxisDuration:0.1];
    [_chartView moveViewToX:_chartView.data.xMax];
    
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
