//
//  RootViewController.m
//  Demo
//
//  Created by n369 on 16/8/31.
//  Copyright © 2016年 https://github.com/poos. All rights reserved.
//

#import "RootViewController.h"
#import "SXRichViewEdit.h"

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createView];
}

- (void)createView {
    static NSString * htmlString = nil;
    
    SXRichViewEdit *editView = [[SXRichViewEdit alloc] initWithFrame:CGRectMake(0, 20, 375, 600) andSelfCon:self];
    [self.view addSubview:editView];
    editView.doneButtonBlock = ^(){
        NSLog(@"点击了确定按钮,做一些事情,例如上传图片等");
        
        //假设图片传完了.得到了urlArr,传入url得到html字符串
        htmlString = [editView retureHtmlStrWithImageArr:@[@"http://image1.png"]];
        
        NSLog(@"%@", htmlString);
    };
}

@end
