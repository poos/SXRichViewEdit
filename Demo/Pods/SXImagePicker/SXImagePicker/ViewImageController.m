//
//  ViewImageController.m
//  ads
//
//  Created on 16/7/16.
//  Created by xiaoR
//  github地址:https://github.com/poos/SXImagePicker
//  图片选择器 任何问题可以前往留言
//
//  推荐轮播图:https://github.com/poos/SXCycleView

#import "ViewImageController.h"

@interface ViewImageController () {
    UIImageView *_imageView;
    BOOL _haveLeftBarButtonItem;
}
@end

@implementation ViewImageController

- (instancetype)initWithImage:(UIImage *)image block:(pickImageDoneBlock)block haveLeftBarButtonItem:(BOOL)isHave
{
    self = [super init];
    if (self) {
        _haveLeftBarButtonItem = isHave;
        self.view.backgroundColor = [UIColor blackColor];
        _imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
        _imageView.image = image;
        self.block = block;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [self.view addSubview:_imageView];
    [self.navigationController setNavigationBarHidden:NO];
}

- (void)haveLeftBarButtonItem:(BOOL)isHave {
    _haveLeftBarButtonItem = isHave;
}

- (void)viewDidLoad {
    UIBarButtonItem *right = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:self action:@selector(pickImageDone)];
    if (_haveLeftBarButtonItem) {
        self.navigationItem.leftBarButtonItem = right;
    }
    self.navigationItem.rightBarButtonItem = right;
    self.title = @"预览照片";
}

- (void)pickImageDone {
    self.block();
}

@end
