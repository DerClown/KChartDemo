# 股票k线图 

![Mou icon](https://github.com/DongZai/KChartDemo/blob/master/ChartDemo1.png)
![Mou icon](https://github.com/DongZai/KChartDemo/blob/master/ChartDemo2.png) 
![Mou icon](https://github.com/DongZai/KChartDemo/blob/master/ChartDemo3.png)


# 使用

```
1.	k线图 
		_kLineChartView = [[KLineChartView alloc] initWithFrame:CGRectMake(20, 50, self.view.frame.size.width - 40.0f, 300.0f)];
    	_kLineChartView.backgroundColor = [UIColor whiteColor];      		_kLineChartView.topMargin = 20.0f;
    	_kLineChartView.rightMargin = 1.0;
    	_kLineChartView.bottomMargin = 80.0f;
    	// YES表示：Y坐标的值根据视图中呈现的k线图的最大值最小值变化而变化；NO表示：Y坐标是所有数据中的最大值最小值，不管k线图呈现如何都不会变化。默认YES
    	//_kLineChartView.yAxisTitleIsChange = NO;
        
    	// 及时更新k线图
    	//_kLineChartView.dynamicUpdateIsNew = YES;
        
    	//是否支持手势
  	    //_kLineChartView.supportGesture = NO;

2. 分时图
		_tLineChartView = [[TLineChartView alloc] initWithFrame:CGRectMake(20, 380.0f, self.view.frame.size.width - 40.0f, 180.0f)];
        _tLineChartView.backgroundColor = [UIColor whiteColor];
        _tLineChartView.topMargin = 5.0f;
        _tLineChartView.leftMargin = 50.0;
        _tLineChartView.bottomMargin = 0.5;
        _tLineChartView.rightMargin = 1.0;
        _tLineChartView.pointPadding = 1.6;
        _tLineChartView.flashPoint = YES;
        // 圆滑的曲线
        //_tLineChartView.smoothPath = NO;
```


**注意⚠️：** 

1. 其他参数设置可以查看`KLineChartView.h` & `TLineChartView.h` 头文件。
2. 网络请求查看 `KLineListManager.m` 文件。
3. 数据处理查看 `KLineListTransformer.m` 文件。

>其他

1.k线图功能比较完整，如有不同需求，可以自行改动就能满足需求。

2.在使用的过程中有什么不明白的地方可以给我提 **Issues**

3.为什么不适用pod管理的原因，希望能够提供让更多的人参与自行修改，能够定制自己的k线图。

4.`GNetworking`<https://github.com/DerClown/GNetworking>这个网络请求，是我借鉴 **YTK**和**casatwy** 写的一个高性能的网络框架。在这里非常感谢**猿题库团队**和**casatwy**做出的贡献。

	
