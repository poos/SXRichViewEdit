//
//  RootViewController.m
//  Demo
//
//  Created by n369 on 16/8/31.
//  Copyright © 2016年 https://github.com/poos. All rights reserved.
//

#import "RootViewController.h"
#import "SXRichViewEdit.h"
@interface RootViewController ()

@property (nonatomic, weak) SXRichViewEdit *editView;
@end

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createView];
}

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

@end
