# SXRichViewEdit
show richView and edit 

##特点:
1,支持html导入自动网上下载图片,加载,可继续编辑
2,编辑完成block,在block中上传图片服务器,服务器拿到url,拼接html
3,图片自适应宽度,布局键盘自适应等

##导入方法

pod 'SXRichViewEdit'

##调用
头文件#import "SXRichViewEdit.h"
```
//*必须*****初始化方法
- (instancetype)initWithFrame:(CGRect)frame andSelfCon:(UIViewController *)selfCon;

//*必须*****点击确定时候调用,应在block中发起网络请求,请求图片url
- (void)setDoneButtonBlock:(DoneButtonBlock)doneButtonBlock;

//*必须*****传入imageUrlArr得到HtmlString
- (NSString *)retureHtmlStrWithImageArr:(NSArray <NSString *> *)imageUrlArr;

//*****设置内容，二次编辑传入htmlString, !!!!<downloadImageBlock建议传为空,自动网上下载设置图片,不为空block中返回图片url网址>
- (void)setRichTextViewHtmlStr:(NSString *)htmlStr andDownloadImageBlock:(DownloadImageBlock)downloadImageBlock ;

//**设置内容,二次编辑的图片,downloadImageBlock中下载完成调用
- (void)setRichTextViewImageArr:(NSArray<UIImage *> *)imageArr;


/****
    以下定制方法
    隐藏button在外部调用
 */
//是否显示 '添加图片button' 和 '完成button' ,默认NO
@property (nonatomic, assign) BOOL hideButton;
//添加图片按钮被点击
- (void)imageButtonAction;
//完成按钮被点击
- (void)doneButtonAction;
```

###.调用示例:例子调用生成了html代码,然后加载了另一段html代码
```
- (void)createView {
    
    SXRichViewEdit *editView = [[SXRichViewEdit alloc] initWithFrame:CGRectMake(0, 20, 375, 600) andSelfCon:self];
    [self.view addSubview:editView];
    self.editView = editView;
    
    editView.doneButtonBlock = ^(NSArray *imageArr){
        
        //点击了确定按钮,做一些事情,例如上传图片等
        //假设图片传完了.得到了urlArr,传入url得到html字符串
        NSString *htmlString = [self.editView retureHtmlStrWithImageArr:@[@"http://image1.png"]];
        NSLog(@"%@", htmlString);
        
        
//        加载 test---------------------------------
        [self testEdit];
//        加载 test---------------------------------
    };
}

- (void)testEdit {
    NSString * htmlStr = @" <body> <p class=\"p1\"><span class=\"s1\">不可置否，新的广告载体出现，通常都意味着一定的流量红利。业内分析称，对广告主来说，短视频广告投放显然正处在这短暂的红利期。</span></p> <p class=\"p2\"><span class=\"s2\"><img src=\"http://img2.donews.com/2016/0831/39971464.jpg.450.jpg\"></span></p> <p class=\"p1\"><span class=\"s1\">据今日头条官方数据显示，截至2016年8月，平台内累计激活用户数达5.3亿，仅app的日活跃用户超过5500万。头条视频目前每日10亿次播放，单日播放时长超2800万小时，每日逾3万支优质视频内容上传</span></p><img src=\"http://img2.donews.com/2016/0831/39971464.jpg.450.jpg\"></span></p><p class=\"p1\"><span class=\"s1\">结果已经打印结果已经打印</span></p><p class=\"p1\"><span class=\"s1\">结果已经打印结果已经打印</span></p><p class=\"p1\"><span class=\"s1\">结果已经打印结果已经打印</span></p> </body>";
//    [self.editView setRichTextViewHtmlStr:htmlStr andDownloadImageBlock:^(NSArray *imageUrlArr){
//        
//        //在此downloadImage,会提取html代码中的image的urls数组
//        sleep(1);
//        //download完成设置图片
//        [self.editView setRichTextViewImageArr:@[[UIImage imageNamed:@"123.jpg"],[UIImage imageNamed:@"123.jpg"]]];
//    }];
    [self.editView setRichTextViewHtmlStr:htmlStr andDownloadImageBlock:nil];
}
```

 ###示例效果图

![img](https://github.com/poos/SXRichViewEdit/blob/master/Untitled.gif)

