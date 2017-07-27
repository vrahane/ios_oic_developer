//
//  SensorViewController.m
//  iotivity_sample
//
//  Created by Pooja Gosavi on 7/17/17.
//  Copyright © 2017 Marko Kiiskila. All rights reserved.
//

#import "SensorViewController.h"
#import "SensorTableViewCell.h"

@interface SensorViewController () <ChartViewDelegate>
@property (strong, nonatomic) NSArray *keyArray;
@property (strong, nonatomic) NSMutableArray *chartXValues;
@property (strong, nonatomic) NSMutableArray *chartYValues;
@property (strong, nonatomic) NSMutableArray *chartZValues;
@property (strong, nonatomic) NSMutableArray *chartKValues;
@end

float d = -1.0;

@implementation SensorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    UINib *nib = [UINib nibWithNibName:@"SensorTableViewCell" bundle:nil];
    [self.sensorData registerNib:nib forCellReuseIdentifier:@"SensorTableViewCell"];
    self.navigationItem.title = self.uri;
}

- (void) viewWillAppear:(BOOL)animated {
    _keyArray = [[NSMutableArray alloc] initWithArray:[_dict allKeys]];
    _isObserving = true;
    _observeButton.title = @"Observe";
    
#pragma mark - Chart view initializations
    _chartXValues = [[NSMutableArray alloc] init];
    _chartYValues = [[NSMutableArray alloc] init];
    _chartZValues = [[NSMutableArray alloc] init];
    _chartKValues = [[NSMutableArray alloc] init];
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_dict count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    SensorTableViewCell *cell = (SensorTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"SensorTableViewCell"];
    NSString *key = _keyArray[indexPath.row];
    cell.titleLabel.text = key;
    NSNumber *number = [_dict valueForKey:key];
    cell.valueLabel.text = [number stringValue];
    if ([_dict count] == 1) {
        [_chartXValues addObject:[[ChartDataEntry alloc] initWithX:++d y:[number doubleValue] icon: [UIImage imageNamed:@"icon"]]];
    }
    
    else if ([_dict count] == 2) {
        if([key isEqualToString:@"x"] || [key isEqualToString:@"y"]) {
        [_chartXValues addObject:[[ChartDataEntry alloc] initWithX:++d y:[[_dict valueForKey:@"x"] doubleValue] icon: [UIImage imageNamed:@"icon"]]];
        [_chartYValues addObject:[[ChartDataEntry alloc] initWithX:d y:[[_dict valueForKey:@"y"] doubleValue]icon: [UIImage imageNamed:@"icon"]]];
        } else if ([key isEqualToString:@"r"] || [key isEqualToString:@"g"]) {
            [_chartXValues addObject:[[ChartDataEntry alloc] initWithX:++d y:[[_dict valueForKey:@"r"] doubleValue] icon: [UIImage imageNamed:@"icon"]]];
            [_chartYValues addObject:[[ChartDataEntry alloc] initWithX:d y:[[_dict valueForKey:@"g"] doubleValue]icon: [UIImage imageNamed:@"icon"]]];
            
        }
    }
    else if ([_dict count] > 2) {
   
        if([key isEqualToString:@"x"] || [key isEqualToString:@"y"] || [key isEqualToString:@"z"]) {

        [_chartXValues addObject:[[ChartDataEntry alloc] initWithX:++d y:[[_dict valueForKey:@"x"] doubleValue] icon: [UIImage imageNamed:@"icon"]]];
        [_chartYValues addObject:[[ChartDataEntry alloc] initWithX:d y:[[_dict valueForKey:@"y"] doubleValue]icon: [UIImage imageNamed:@"icon"]]];

            [_chartZValues addObject:[[ChartDataEntry alloc] initWithX:d y:[[_dict valueForKey:@"z"] doubleValue] icon: [UIImage imageNamed:@"icon"]]];
        } else if([key isEqualToString:@"r"] || [key isEqualToString:@"g"] || [key isEqualToString:@"b"]) {
            [_chartXValues addObject:[[ChartDataEntry alloc] initWithX:++d y:[[_dict valueForKey:@"r"] doubleValue] icon: [UIImage imageNamed:@"icon"]]];
            [_chartYValues addObject:[[ChartDataEntry alloc] initWithX:d y:[[_dict valueForKey:@"g"] doubleValue]icon: [UIImage imageNamed:@"icon"]]];
            
            [_chartZValues addObject:[[ChartDataEntry alloc] initWithX:d y:[[_dict valueForKey:@"b"] doubleValue] icon: [UIImage imageNamed:@"icon"]]];
            
        } else if([key isEqualToString:@"ir"] || [key isEqualToString:@"full"] || [key isEqualToString:@"lux"]) {
            [_chartXValues addObject:[[ChartDataEntry alloc] initWithX:++d y:[[_dict valueForKey:@"ir"] doubleValue] icon: [UIImage imageNamed:@"icon"]]];
            [_chartYValues addObject:[[ChartDataEntry alloc] initWithX:d y:[[_dict valueForKey:@"full"] doubleValue]icon: [UIImage imageNamed:@"icon"]]];
            
            [_chartZValues addObject:[[ChartDataEntry alloc] initWithX:d y:[[_dict valueForKey:@"lux"] doubleValue] icon: [UIImage imageNamed:@"icon"]]];
            
        }
    }
    [self updateChartValues];
    
    return cell;
}

- (IBAction)observeAction:(id)sender {
    
    if (_isObserving == true) {
        [[iotivity_itf shared] observe:self andURI:_uri andDevAddr:_peripheral.devAddr];
        _observeButton.title = @"Stop";
        _isObserving = false;
    } else {
        d = -1.0;
        _observeButton.title = @"Observe";
        _isObserving = true;
        [[iotivity_itf shared] cancel_observer:self andURI:_uri andDevAddr:_peripheral.devAddr andHandle:_peripheral.handle];
    }
    
}

- (IBAction)backAction:(id)sender {
    [[iotivity_itf shared] cancel_observer:self andURI:self.uri andDevAddr:_peripheral.devAddr andHandle:_peripheral.handle];
    [self.navigationController popViewControllerAnimated:true];
}

- (void) listUpdated {
    Peripheral *pr = [[iotivity_itf shared] resourceDetails];
    if (pr != nil) {
        self.peripheral = pr ;
        _peripheral.devAddr = pr.devAddr;
        _peripheral.handle = pr.handle;
        _dict = [self sortPeripheralsForSensors:pr.resources andType:self.uri];
        _keyArray = [_dict allKeys];
    }

    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [_sensorData reloadData];
    }];

}


- (NSMutableDictionary *) sortPeripheralsForSensors:(NSMutableArray *)resources andType: (NSString *) resourceURI{
    
    NSMutableDictionary *resourceDictionary = [[NSMutableDictionary alloc] init];
    
    if([resourceURI containsString:@"acc"]) {
        for (PeripheralResource *pr in resources) {
            NSString *uri = pr.resourceName;
            if([uri isEqualToString:@"x"]) {
                [resourceDictionary setObject:[NSNumber numberWithDouble:pr.resourceDoubleValue] forKey:uri];
            }
            if([uri isEqualToString:@"y"]) {
                [resourceDictionary setObject:[NSNumber numberWithDouble:pr.resourceDoubleValue] forKey:uri];
            }
            if([uri isEqualToString:@"z"]) {
                [resourceDictionary setObject:[NSNumber numberWithDouble:pr.resourceDoubleValue] forKey:uri];
            }
        }
    } else if([resourceURI containsString:@"mag"]) {
        for (PeripheralResource *pr in resources) {
            NSString *uri = pr.resourceName;
            if([uri isEqualToString:@"x"]) {
                [resourceDictionary setObject:[NSNumber numberWithDouble:pr.resourceDoubleValue] forKey:uri];
            }
            if([uri isEqualToString:@"y"]) {
                [resourceDictionary setObject:[NSNumber numberWithDouble:pr.resourceDoubleValue] forKey:uri];
            }
            if([uri isEqualToString:@"z"]) {
                [resourceDictionary setObject:[NSNumber numberWithDouble:pr.resourceDoubleValue] forKey:uri];
            }
        }

    }else if([resourceURI containsString:@"tmp"] || [resourceURI containsString:@"temp"] ) {
        for (PeripheralResource *pr in resources) {
            NSString *uri = pr.resourceName;
            if([uri isEqualToString:@"temp"]) {
                [resourceDictionary setObject:[NSNumber numberWithDouble:pr.resourceDoubleValue] forKey:uri];
            }
        }
    }else if([resourceURI containsString:@"hmty"] || [resourceURI containsString:@"humid"]) {
        for (PeripheralResource *pr in resources) {
            NSString *uri = pr.resourceName;
            if([uri isEqualToString:@"humid"]) {
                [resourceDictionary setObject:[NSNumber numberWithDouble:pr.resourceDoubleValue] forKey:uri];
            }
        }
    } else if([resourceURI containsString:@"psr"]) {
        for (PeripheralResource *pr in resources) {
            NSString *uri = pr.resourceName;
            if([uri isEqualToString:@"press"]) {
                [resourceDictionary setObject:[NSNumber numberWithDouble:pr.resourceDoubleValue] forKey:uri];
            }
        }
        
    } else if([resourceURI containsString:@"col"]) {
        for (PeripheralResource *pr in resources) {
            NSString *uri = pr.resourceName;
            if([uri isEqualToString:@"r"]) {
                [resourceDictionary setObject:[NSNumber numberWithDouble:pr.resourceDoubleValue] forKey:uri];
            }
            if([uri isEqualToString:@"g"]) {
                [resourceDictionary setObject:[NSNumber numberWithDouble:pr.resourceDoubleValue] forKey:uri];
            }
            if([uri isEqualToString:@"b"]) {
                [resourceDictionary setObject:[NSNumber numberWithDouble:pr.resourceDoubleValue] forKey:uri];
            }
            if([uri isEqualToString:@"lux"]) {
                [resourceDictionary setObject:[NSNumber numberWithDouble:pr.resourceDoubleValue] forKey:uri];
            }
        }
    } else if([resourceURI containsString:@"gyr"]) {
        for (PeripheralResource *pr in resources) {
            NSString *uri = pr.resourceName;
            if([uri isEqualToString:@"x"]) {
                [resourceDictionary setObject:[NSNumber numberWithDouble:pr.resourceDoubleValue] forKey:uri];
            }
            if([uri isEqualToString:@"y"]) {
                [resourceDictionary setObject:[NSNumber numberWithDouble:pr.resourceDoubleValue] forKey:uri];
            }
            if([uri isEqualToString:@"z"]) {
                [resourceDictionary setObject:[NSNumber numberWithDouble:pr.resourceDoubleValue] forKey:uri];
            }
        }

    }else if([resourceURI containsString:@"eul"]) {
        for (PeripheralResource *pr in resources) {
            NSString *uri = pr.resourceName;
            if([uri isEqualToString:@"h"]) {
                [resourceDictionary setObject:[NSNumber numberWithDouble:pr.resourceDoubleValue] forKey:uri];
            }
            if([uri isEqualToString:@"r"]) {
                [resourceDictionary setObject:[NSNumber numberWithDouble:pr.resourceDoubleValue] forKey:uri];
            }
            if([uri isEqualToString:@"p"]) {
                [resourceDictionary setObject:[NSNumber numberWithDouble:pr.resourceDoubleValue] forKey:uri];
            }
        }

    }else if([resourceURI containsString:@"quat"]) {
        for (PeripheralResource *pr in resources) {
            NSString *uri = pr.resourceName;
            if([uri isEqualToString:@"x"]) {
                [resourceDictionary setObject:[NSNumber numberWithDouble:pr.resourceDoubleValue] forKey:uri];
            }
            if([uri isEqualToString:@"y"]) {
                [resourceDictionary setObject:[NSNumber numberWithDouble:pr.resourceDoubleValue] forKey:uri];
            }
            if([uri isEqualToString:@"z"]) {
                [resourceDictionary setObject:[NSNumber numberWithDouble:pr.resourceDoubleValue] forKey:uri];
            }
            if([uri isEqualToString:@"w"]) {
                [resourceDictionary setObject:[NSNumber numberWithDouble:pr.resourceDoubleValue] forKey:uri];
            }

        }

    }else if([resourceURI containsString:@"grav"]) {
        for (PeripheralResource *pr in resources) {
            NSString *uri = pr.resourceName;
            if([uri isEqualToString:@"x"]) {
                [resourceDictionary setObject:[NSNumber numberWithDouble:pr.resourceDoubleValue] forKey:uri];
            }
            if([uri isEqualToString:@"y"]) {
                [resourceDictionary setObject:[NSNumber numberWithDouble:pr.resourceDoubleValue] forKey:uri];
            }
            if([uri isEqualToString:@"z"]) {
                [resourceDictionary setObject:[NSNumber numberWithDouble:pr.resourceDoubleValue] forKey:uri];
            }
        }

    } else if([resourceURI containsString:@"lt"]) {
        for (PeripheralResource *pr in resources) {
            NSString *uri = pr.resourceName;
            if([uri isEqualToString:@"ir"]) {
                [resourceDictionary setObject:[NSNumber numberWithDouble:pr.resourceDoubleValue] forKey:uri];
            }
            if([uri isEqualToString:@"full"]) {
                [resourceDictionary setObject:[NSNumber numberWithDouble:pr.resourceDoubleValue] forKey:uri];
            }
            if([uri isEqualToString:@"lux"]) {
                [resourceDictionary setObject:[NSNumber numberWithDouble:pr.resourceDoubleValue] forKey:uri];
            }
        }
        
    }
    
    return resourceDictionary;
}

- (void) updateChartValues {
    [self setDataCount];
}

- (void)setDataCount
{
    
    LineChartDataSet *set1 = nil;
    LineChartDataSet *set2 = nil;
    LineChartDataSet *set3 = nil;
    LineChartDataSet *set4 = nil;
    
    if (_chartView.data.dataSetCount > 0)
    {
        set1 = (LineChartDataSet *)_chartView.data.dataSets[0];
        set1.values = _chartXValues;
        
        set2 = (LineChartDataSet *)_chartView.data.dataSets[1];
        set2.values = _chartYValues;
        
        set3 = (LineChartDataSet *)_chartView.data.dataSets[2];
        set3.values = _chartZValues;
        
        set4 = (LineChartDataSet *)_chartView.data.dataSets[3];
        set4.values = _chartKValues;
        
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

        set4 = [[LineChartDataSet alloc] initWithValues:_chartZValues label:@"K"];
        
        set4.drawIconsEnabled = NO;
        
        [set4 setColor:UIColor.orangeColor];
        [set4 setCircleColor:UIColor.clearColor];
        set4.lineWidth = 1.0;
        set4.circleRadius = 0.0;
        set4.drawCircleHoleEnabled = NO;
        set4.valueFont = [UIFont systemFontOfSize:9.f];
        set4.formSize = 15.0;
        
        set1.fillAlpha = 1.f;
        
        set1.drawFilledEnabled = NO;
        
        set2.fillAlpha = 1.f;
        
        set2.drawFilledEnabled = NO;
        
        set3.fillAlpha = 1.f;
        
        set3.drawFilledEnabled = NO;

        set4.fillAlpha = 1.f;
        
        set4.drawFilledEnabled = NO;

        NSMutableArray *dataSets = [[NSMutableArray alloc] init];
        [dataSets addObject:set1];
        [dataSets addObject:set2];
        [dataSets addObject:set3];
        [dataSets addObject:set4];
        
        
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
