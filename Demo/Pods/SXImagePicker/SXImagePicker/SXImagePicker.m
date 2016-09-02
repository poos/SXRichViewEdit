//
//  SXImagePicker.m
//  Demo
//
//  Created on 16/7/16.
//  Created by xiaoR
//  github地址:https://github.com/poos/SXImagePicker
//  图片选择器 任何问题可以前往留言
//
//  推荐轮播图:https://github.com/poos/SXCycleView

#import "SXImagePicker.h"
#import "ViewImageController.h"

@interface SXImagePicker () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, copy) ChooseImageBlock block;
@end

static SXImagePicker *imagePicker;
@implementation SXImagePicker

+ (void)pickerCameraImageWithSelf:(UIViewController *)selfController done:(ChooseImageBlock)doneBlock {
    imagePicker = [[SXImagePicker alloc] init];
    imagePicker.block = doneBlock;
    [imagePicker cameraButtonActionWith:selfController];
}
+ (void)pickerPhotoLibraryImageWithSelf:(UIViewController *)selfController done:(ChooseImageBlock)doneBlock{
    imagePicker = [[SXImagePicker alloc] init];
    imagePicker.block = doneBlock;
    [imagePicker picButtonActionWith:selfController];
}

- (void)cameraButtonActionWith:(UIViewController *)selfCon {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        //实例化一个对象
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        //设置资源类型
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        //设置代理
        imagePicker.delegate = self;
        //                imagePicker.allowsEditing  = YES;
        //进行模态跳转
        [selfCon presentViewController:imagePicker animated:YES completion:nil];
    }
}
- (void)picButtonActionWith:(UIViewController *)selfCon {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        UIImagePickerController *imagePicker =[[UIImagePickerController alloc]init];
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imagePicker.delegate = self;
        //                imagePicker.allowsEditing   = YES;
        [selfCon presentViewController:imagePicker animated:YES completion:nil];
    }
}

#pragma mark pickImageDelgegate
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
    
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    
    UIImage * image = [[UIImage alloc] init];
    image = info[@"UIImagePickerControllerOriginalImage"];
    BOOL isHaveLeftButton = (picker.sourceType == UIImagePickerControllerSourceTypeCamera);
//    __weak SXImagePicker *weakself = self;
    [picker pushViewController:[[ViewImageController alloc] initWithImage:image block:^{
        NSData * data = UIImagePNGRepresentation(image);
        UIImage * image = [UIImage imageWithData:data];
        if (self.block) {
            self.block(info,image);
        }
        [picker dismissViewControllerAnimated:YES completion:nil];
    } haveLeftBarButtonItem:isHaveLeftButton] animated:YES];
}

@end
