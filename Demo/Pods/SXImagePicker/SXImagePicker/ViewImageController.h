//
//  ViewImageController.h
//  ads
//
//  Created on 16/7/16.
//  Created by xiaoR
//  github地址:https://github.com/poos/SXImagePicker
//  图片选择器 任何问题可以前往留言
//
//  推荐轮播图:https://github.com/poos/SXCycleView

//选取图片后的展示图片页面
#import <UIKit/UIKit.h>

typedef void(^pickImageDoneBlock)();

@interface ViewImageController : UIViewController
@property (nonatomic, copy) pickImageDoneBlock block;

- (instancetype)initWithImage:(UIImage *)image block:(pickImageDoneBlock)block haveLeftBarButtonItem:(BOOL)isHave;
@end
