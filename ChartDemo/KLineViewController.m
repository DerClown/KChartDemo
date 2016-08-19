//
//  ViewController.m
//  ChartDemo
//
//  Created by xdliu on 16/8/12.
//  Copyright © 2016年 taiya. All rights reserved.
//

#import "KLineViewController.h"
#import "TYKLineChartView.h"
#import "KLineListManager.h"
#import "KLineListTransformer.h"

@interface KLineViewController ()<GAPIBaseManagerRequestCallBackDelegate>

@property (nonatomic, strong) KLineListManager *chartApi;
@property (nonatomic, strong) KLineListTransformer *lineListTransformer;
@property (nonatomic, strong) TYKLineChartView *kLineChartView;

@end

@implementation KLineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.kLineChartView];
    
    //发起请求
    self.chartApi.dateType = @"d";
    self.chartApi.kLineID = @"601888.SS";
    [self.chartApi startRequest];
}

#pragma mark - GAPIBaseManagerRequestCallBackDelegate

- (void)managerApiCallBackDidSuccess:(__kindof GApiBaseManager *)manager {
    NSDictionary *lineData = [self.chartApi fetchDataWithTransformer:self.lineListTransformer];
    [self.kLineChartView drawChartWithData:lineData];
}

- (void)managerApiCallBackDidFailed:(__kindof GApiBaseManager *)manager {
    
}

#pragma mark - getters

- (TYKLineChartView *)kLineChartView {
    if (!_kLineChartView) {
        _kLineChartView = [[TYKLineChartView alloc] initWithFrame:CGRectMake(20, 50, self.view.frame.size.width - 40.0f, 350.0f)];
        _kLineChartView.backgroundColor = [UIColor whiteColor];
        _kLineChartView.topMargin = 20.0f;
        _kLineChartView.leftMargin = 50.0f;
        _kLineChartView.rightMargin = 1.0;
        _kLineChartView.bottomMargin = 100.0f;
        _kLineChartView.yAxisTitleIsChange = NO;
    }
    return _kLineChartView;
}

- (KLineListManager *)chartApi {
    if (!_chartApi) {
        _chartApi = [KLineListManager new];
        _chartApi.delegate = self;
    }
    return _chartApi;
}

- (KLineListTransformer *)lineListTransformer {
    if (!_lineListTransformer) {
        _lineListTransformer = [KLineListTransformer new];
    }
    return _lineListTransformer;
}

#pragma mark - memory manager

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
