//
//  ViewController.m
//  ChartDemo
//
//  Created by xdliu on 16/8/12.
//  Copyright © 2016年 taiya. All rights reserved.
//

#import "KLineViewController.h"
#import "TYKLineChartView.h"
#import "TYTLineChartView.h"
#import "KLineListManager.h"
#import "KLineListTransformer.h"
#import "StatusView.h"

@interface KLineViewController ()<GAPIBaseManagerRequestCallBackDelegate>

@property (nonatomic, strong) KLineListManager *chartApi;
@property (nonatomic, strong) KLineListTransformer *lineListTransformer;
@property (nonatomic, strong) TYKLineChartView *kLineChartView;
@property (nonatomic, strong) TYTLineChartView *tLineChartView;

@property (nonatomic, strong) StatusView *kStatusView;

/**
 *  (模拟)实时测试
 */
@property (nonatomic, strong) NSMutableDictionary *data;
@property (nonatomic, copy) NSString *lastDate;
@property (nonatomic, strong) NSArray *lastItem;
@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, assign) NSInteger cutdown;

@end

@implementation KLineViewController

#pragma mark - life cycle

- (void)dealloc {
    [self stopDisplayLink];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)init {
    if (self = [super init]) {
        _cutdown = 20;
        [self registerObserver];
    }
    return self;
}

- (void)registerObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(kLineStartTouchNotification:) name:KLineKeyStartUserInterfaceNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(kLineEndOfTouchNotification:) name:KLineKeyEndOfUserInterfaceNotification object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.kLineChartView];
    [self.view addSubview:self.tLineChartView];
    [self.kLineChartView addSubview:self.kStatusView];
    
    //发起请求
    self.chartApi.dateType = @"d";
    self.chartApi.kLineID = @"601888.SS";
    [self.chartApi startRequest];
}

#pragma mark - private methods

- (void)startDisplayLink {
    [self stopDisplayLink];
    
    _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(realTimeData:)];
    [_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    _displayLink.frameInterval = 60.0;}

- (void)stopDisplayLink {
    if (_displayLink) {
        [_displayLink invalidate];
    }
    
    _displayLink = nil;
}

- (void)realTimeData:(id)timer {
    NSMutableArray *dates = [self.data[kCandlerstickChartsDate] mutableCopy];
    NSMutableArray *contexts = [self.data[kCandlerstickChartsContext] mutableCopy];
    
    [dates addObject:self.lastDate];
    [contexts addObject:self.lastItem];
    self.data[kCandlerstickChartsDate] = dates;
    self.data[kCandlerstickChartsContext] = contexts;
    
    [self.kLineChartView drawChartWithData:self.data];
    [self.tLineChartView drawChartWithData:self.data];
    _cutdown --;
    if (_cutdown == 0) {
        [self stopDisplayLink];
    }
}

#pragma mark - GAPIBaseManagerRequestCallBackDelegate

- (void)managerApiCallBackDidSuccess:(__kindof GApiBaseManager *)manager {
    self.data = [[self.chartApi fetchDataWithTransformer:self.lineListTransformer] mutableCopy];
    
    NSArray *dates = self.data[kCandlerstickChartsDate];
    NSArray *contexts = self.data[kCandlerstickChartsContext];
    
    self.lastDate = [dates lastObject];
    self.lastItem = [contexts lastObject];
    
    [self.kLineChartView drawChartWithData:self.data];
    [self.tLineChartView drawChartWithData:self.data];
    
    self.kStatusView.status = StatusStyleSuccess;
    self.kStatusView.hidden = YES;
    
    [self startDisplayLink];
}

- (void)managerApiCallBackDidFailed:(__kindof GApiBaseManager *)manager {
    switch (manager.requestHandleType) {
        case GAPIManagerRequestHandlerTypeSuccess: {
            break;
        }
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
    }
}

#pragma mark - notification events

- (void)kLineStartTouchNotification:(NSNotification *)notification {
    [self stopDisplayLink];
}

- (void)kLineEndOfTouchNotification:(NSNotification *)notificaiton {
    if (_cutdown != 0) {
        [self startDisplayLink];
    }
}

#pragma mark - getters

- (TYKLineChartView *)kLineChartView {
    if (!_kLineChartView) {
        _kLineChartView = [[TYKLineChartView alloc] initWithFrame:CGRectMake(20, 50, self.view.frame.size.width - 40.0f, 300.0f)];
        _kLineChartView.backgroundColor = [UIColor whiteColor];
        _kLineChartView.topMargin = 20.0f;
        _kLineChartView.leftMargin = 50.0f;
        _kLineChartView.rightMargin = 1.0;
        _kLineChartView.bottomMargin = 80.0f;
        //_kLineChartView.yAxisTitleIsChange = YES;
    }
    return _kLineChartView;
}

- (TYTLineChartView *)tLineChartView {
    if (!_tLineChartView) {
        _tLineChartView = [[TYTLineChartView alloc] initWithFrame:CGRectMake(20, 380.0f, self.view.frame.size.width - 40.0f, 180.0f)];
        _tLineChartView.backgroundColor = [UIColor whiteColor];
        _tLineChartView.topMargin = 5.0f;
        _tLineChartView.leftMargin = 50.0;
        _tLineChartView.bottomMargin = 0.5;
        _tLineChartView.rightMargin = 1.0;
        _tLineChartView.pointPadding = 3.0;
        _tLineChartView.flashPoint = YES;
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
