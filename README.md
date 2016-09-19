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

>这里有几点有必要说明一下！

1.k线图功能比较完整，稍微的改动已能够满足用户的需求。


2.在使用的过程中有什么不明白的地方可以给我提 **Issues**

3.我相信看完整个demo以后，可能会很大一部分开发者都觉得疑惑或者吐槽，这个传值也隐藏的太深了吧，然而传值过程怎么不是一个Entity。（如果需要换成Entity模式，可以自行修改就可以了）

第三小点不明白为什么不用model，而是用extern key方式，可以看一看大神 **casatwy** 博客的两篇文章：
 **《model化和数据对象》** 🔗<http://casatwy.com/OOP_nomodel.html>、
 **《iOS应用架构谈 网络层设计方案》**:
🔗<http://casatwy.com/iosying-yong-jia-gou-tan-wang-luo-ceng-she-ji-fang-an.html>

3.`GNetworking`<https://github.com/DerClown/GNetworking>这个网络请求，是我借鉴 **YTK**和**casatwy** 写的一个高性能的网络框架。在这里非常感谢**猿题库团队**和**casatwy**做出的贡献。

	
