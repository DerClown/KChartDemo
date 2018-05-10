//
//  ViewController.m
//  ChartDemo
//
//  Created by xdliu on 16/8/12.
//  Copyright © 2016年 yoyo. All rights reserved.
//

#import "KLineViewController.h"
#import "CandlestickChartsView.h"
#import "TimeShareChartView.h"
#import "KLineListManager.h"
#import "KLineListTransformer.h"
#import "StatusView.h"

@interface KLineViewController ()<GAPIBaseManagerRequestCallBackDelegate>

@property (nonatomic, strong) KLineListManager *chartApi;
@property (nonatomic, strong) KLineListTransformer *lineListTransformer;
@property (nonatomic, strong) CandlestickChartsView *kLineChartView;
@property (nonatomic, strong) TimeShareChartView *tLineChartView;

@property (nonatomic, strong) StatusView *kStatusView;

/**
 *  (模拟)实时测试
 */
@property (nonatomic, strong) NSArray *data;
@property (nonatomic, strong) NSTimer *timer;

@end

@implementation KLineViewController

#pragma mark - life cycle

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.kLineChartView];
    [self.view addSubview:self.tLineChartView];
    
    // 绘制均线
    
    self.kLineChartView.Mas = @[@5, @10, @30];
    
    [self drawChart];
    /*[self.kLineChartView addSubview:self.kStatusView];
    
    __block typeof(self) weakSelf = self;
    self.kStatusView.reloadBlock = ^(){
        [weakSelf.chartApi startRequest];
    };
    
    //发起请求
    self.chartApi.dateType = @"d";
    self.chartApi.kLineID = @"601888.SS";
    [self.chartApi startRequest];*/
    
    // 动态更新数据
//    [self performSelector:@selector(startTimer) withObject:nil afterDelay:10];
}

- (void)drawChart {
    NSString * path =[[NSBundle mainBundle]pathForResource:@"data.plist" ofType:nil];
    NSArray * sourceArray = [[NSDictionary dictionaryWithContentsOfFile:path] objectForKey:@"data"];
    
    self.data = [self.lineListTransformer manager:nil transformData:sourceArray];
    [self.kLineChartView drawChartWithData:self.data];
    [self.tLineChartView drawChartWithData:self.data];
}

#pragma mark - GAPIBaseManagerRequestCallBackDelegate

- (void)managerApiCallBackDidSuccess:(__kindof GApiBaseManager *)manager {
    self.data = [[self.chartApi fetchDataWithTransformer:self.lineListTransformer] mutableCopy];
    
    [self.kLineChartView drawChartWithData:self.data];
    [self.tLineChartView drawChartWithData:self.data];
    
    self.kStatusView.status = StatusStyleSuccess;
    self.kStatusView.hidden = YES;
    
    //动态数据测试
    //[self startTimer];
}

- (void)managerApiCallBackDidFailed:(__kindof GApiBaseManager *)manager {
    self.kStatusView.hidden = NO;
    switch (manager.requestHandleType) {
        case GAPIManagerRequestHandlerTypeDefault:
        case GAPIManagerRequestHandlerTypeFailure:
        case GAPIManagerRequestHandlerTypeParamsError:
        case GAPIManagerRequestHandlerTypeNoContent:
        case GAPIManagerRequestHandlerTypeTimeout: {
            self.kStatusView.status = StatusStyleFailed;
            break;
        }
        case GAPIManagerRequestHandlerTypeNoNetWork: {
            self.kStatusView.status = StatusStyleNoNetWork;
            break;
        }
        default:break;
    }
}

#pragma mark - getters

- (CandlestickChartsView *)kLineChartView {
    if (!_kLineChartView) {
        _kLineChartView = [[CandlestickChartsView alloc] initWithFrame:CGRectMake(20, 50, self.view.frame.size.width - 40.0f, 300.0f)];
        _kLineChartView.backgroundColor = [UIColor whiteColor];
        _kLineChartView.topMargin = 20.0f;
        _kLineChartView.rightMargin = 1.0;
        _kLineChartView.bottomMargin = 80.0f;
        _kLineChartView.leftMargin = 25.0f;
        _kLineChartView.isVisiableViewerExtremeValue = YES;
        // YES表示：Y坐标的值根据视图中呈现的k线图的最大值最小值变化而变化；NO表示：Y坐标是所有数据中的最大值最小值，不管k线图呈现如何都不会变化。默认YES
        //_kLineChartView.yAxisTitleIsChange = NO;
        
        // 及时更新k线图
        //_kLineChartView.dynamicUpdateIsNew = YES;
        
        //是否支持手势
        //_kLineChartView.supportGesture = NO;
    }
    return _kLineChartView;
}

- (TimeShareChartView *)tLineChartView {
    if (!_tLineChartView) {
//        _tLineChartView = [[TLineChartView alloc] initWithFrame:CGRectMake(20, 380.0f, self.view.frame.size.width - 40.0f, 180.0f)];
//        _tLineChartView.backgroundColor = [UIColor whiteColor];
//        _tLineChartView.topMargin = 5.0f;
//        _tLineChartView.leftMargin = 50.0;
//        _tLineChartView.bottomMargin = 0.5;
//        _tLineChartView.rightMargin = 1.0;
//        _tLineChartView.pointPadding = 30.0f;
//        _tLineChartView.separatorNum = 4;
//        _tLineChartView.flashPoint = YES;
        //_tLineChartView.smoothPath = NO;
    }
    return _tLineChartView;
}

- (StatusView *)kStatusView {
    if (!_kStatusView) {
        _kStatusView = [[StatusView alloc] initWithFrame:_kLineChartView.bounds];
    }
    return _kStatusView;
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
