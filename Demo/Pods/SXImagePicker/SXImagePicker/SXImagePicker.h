//
//  SXImagePicker.h
//  Demo
//
//  Created on 16/7/16.
//  Created by xiaoR
//  github地址:https://github.com/poos/SXImagePicker
//  图片选择器 任何问题可以前往留言
//
//  推荐轮播图:https://github.com/poos/SXCycleView

#import <UIKit/UIKit.h>

typedef void(^ChooseImageBlock)(NSDictionary<NSString *,id> *info, UIImage *imageData);

@interface SXImagePicker : NSObject

+ (void)pickerCameraImageWithSelf:(UIViewController *)selfController done:(ChooseImageBlock)doneBlock;
+ (void)pickerPhotoLibraryImageWithSelf:(UIViewController *)selfController done:(ChooseImageBlock)doneBlock;

@end
