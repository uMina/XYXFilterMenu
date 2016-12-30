# XYXFilterMenu
一个超流畅的菜单筛选项，支持tableView和collectionView以及自定义输入范围模式，可以根据你的需要设定显示方式。

An amazing filter menu with smooth animations, supports tableView/collectionView mode, and can mix user-define inputView in the way you want.

![XYXFilterMenu](http://img.blog.csdn.net/20161230173730682?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvYTE0ODQ=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)

###**🔧使用：**
**初始化**

  首先令你的ViewController遵从两个协议`XYXFilterMenuDataSource`和`XYXFilterMenuDelegate`，然后初始化并添加到适当的位置：
```
XYXFilterMenu *menu = [[XYXFilterMenu alloc]initWithOrigin:CGPointMake(0,64) height:44];
[self.view addSubview: menu];
menu.dataSource = self;
menu.delegate = self;
```
**实现适当的委托方法**

  这部分可以直接参考demo。

###**🚀特性：**

- 提供了`menu:tapIndex`和`menu:statisticWithStatisticModel`方法，可以方便的对用户点击进行统计，详细使用方法请参考Demo。

###**⚠️注意：**

- `XYXFilterMenuDataSource`中有三个必须实现的方法。

- `XYXFilterMenu` 的基础属性都有默认值，如果需要重新设置，需要在给'datasource'属性赋值之前设置，而功能性属性应该在'datasource'属性赋值之后设置。详情请参考Demo。
  

###**💩待完成：**

- 笔者太懒，并没有提供对tableView、collectionView、annexView的颜色、文字大小等的设置接口，相关基础数据设置请自己到`XYXFilterMenuMacro.h`文件里去修改。
