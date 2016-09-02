//
//  SXRichViewEdit.h
//  Demo
//
//  Created  on 16/8/31.
//  github地址:https://github.com/poos/SXRichViewEdit
//  图文编辑上传 任何问题可以前往留言
//
//  推荐轮播图:https://github.com/poos/SXCycleView
//  Copyright © 2016年 https://github.com/poos All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^DoneButtonBlock)(NSArray *imageArr);
typedef void(^DownloadImageBlock)(NSArray *imageUrlArr);

@interface SXRichViewEdit : UIView


//- (void)setDoneButton

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

@end
