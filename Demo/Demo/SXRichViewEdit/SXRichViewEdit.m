//
//  SXRichViewEdit.m
//  Demo
//
//  Createdon 16/8/31.
//  github地址:https://github.com/poos/SXRichViewEdit
//  图文编辑上传 任何问题可以前往留言
//
//  推荐轮播图:https://github.com/poos/SXCycleView
//  Copyright © 2016年 https://github.com/poos All rights reserved.
//

#import "SXRichViewEdit.h"
#import "SXRich.h"
#import "SDWebImageDownloader.h"
#import "TZImagePickerController.h"

#define ImageWidthSize self.frame.size.width-10
#define DefaultFont (16)
#define MaxLength (1000) //最大选中删除字符数
#define RichTextImage (@"[UIImageView]")
#define ImageButtonFrame CGRectMake(self.frame.size.width - 120, self.frame.size.height - 40, 50, 40)
#define DoneButtonFrame CGRectMake(self.frame.size.width - 60, self.frame.size.height - 40, 50, 40)

@interface SXRichViewEdit () <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextViewDelegate ,TZImagePickerControllerDelegate>

@property (nonatomic, weak  ) UIViewController          *selfController;
@property (nonatomic, strong) UITextView                *textView;
@property (nonatomic, assign) NSRange                   newRange;//记录最新内容的range
@property (nonatomic, assign) NSRange                   addImageRange;//记录最新内容的range

@property (nonatomic, strong) NSMutableAttributedString *locationStr;//纪录变化时的内容，即是
@property (nonatomic, assign) CGRect                    selfFrame;//默认位置
@property (nonatomic, assign) CGRect                    selfNewFrame;//弹起键盘的位置

@property (nonatomic, assign) NSInteger                 imageIndex;//加载的图片index
@property (nonatomic, assign) NSInteger                 iamgeDownloadAllCount;//下载图片所有个数
@property (nonatomic, strong) NSMutableDictionary       *imageDownloadDic;//加载的图片index

@property (nonatomic, strong) UIButton                  *imgButton;
@property (nonatomic, strong) UIButton                  *doneButton;
@property (nonatomic, copy  ) DoneButtonBlock           doneButtonBlock;

@end

@implementation SXRichViewEdit

- (instancetype)initWithFrame:(CGRect)frame
                   andSelfCon:(UIViewController *)selfCon {
    self = [super initWithFrame:frame];
    if (self) {
        _selfController = selfCon;
        _selfFrame = frame;
        _selfNewFrame = CGRectMake(0, 0, 0, 0);
        [self initData];
        [self createView];
    }
    return self;
}

- (void)initData {
    self.backgroundColor = [UIColor grayColor];
    _iamgeDownloadAllCount = -1;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onKeyboardNotification:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onKeyboardNotification:) name:UIKeyboardWillShowNotification object:nil];
}

- (void)setHideButton:(BOOL)hideButton {
    _hideButton = hideButton;
    if (hideButton) {
        _imgButton.hidden = YES;
        _doneButton.hidden = YES;
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)createView {
    _textView = [[UITextView alloc] initWithFrame:self.bounds];
    _textView.delegate = self;
    _textView.font = [UIFont systemFontOfSize:DefaultFont];
    [self addSubview:_textView];
    _placeholderLabel = [[UILabel alloc] initWithFrame:CGRectMake(7, 8, 300, 20)];
    _placeholderLabel.text = @"输入内容...";
    [_textView addSubview:_placeholderLabel];
    _imgButton = [[UIButton alloc] initWithFrame:ImageButtonFrame];
    [_imgButton setTitle:@"图片" forState:UIControlStateNormal];
    _imgButton.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
    [_imgButton addTarget:self action:@selector(imageButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_imgButton];
    _doneButton = [[UIButton alloc] initWithFrame:DoneButtonFrame];
    [_doneButton setTitle:@"完成" forState:UIControlStateNormal];
    _doneButton.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
    [_doneButton addTarget:self action:@selector(doneButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_doneButton];
    
}

#pragma mark ---------------设置内容，二次编辑-----------------
//*****设置内容，二次编辑传入htmlString
- (void)setRichTextViewHtmlStr:(NSString *)htmlStr andDownloadImageBlock:(DownloadImageBlock)downloadImageBlock {
    NSAttributedString * contentStr = [[NSAttributedString alloc] initWithString:@""];
    NSMutableString * totalHtmlstring = [[NSMutableString alloc] initWithString:[contentStr toHtmlString]];
    [totalHtmlstring replaceCharactersInRange:[totalHtmlstring rangeOfString:@"<body>\n</body>"] withString:htmlStr];
    [self setRichTextViewTotalHtmlStr:totalHtmlstring];
    if (downloadImageBlock) {
        downloadImageBlock([self getImageUrlsFromHtml:htmlStr]);
    } else {
        [self setLoadImages:[self getImageUrlsFromHtml:htmlStr]];
    }
}

- (void)setLoadImages:(NSArray *)urlArr {
    _iamgeDownloadAllCount = urlArr.count;
    _imageDownloadDic = [[NSMutableDictionary alloc] initWithCapacity:0];
    for (NSString * urlImage in urlArr) {
        [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL URLWithString:urlImage] options:0 progress:nil completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
            if (image) {
                UIImage *image1 = [UIImage imageWithData:data];
                [_imageDownloadDic setValue:image1 forKey:urlImage];
                [self refreshTextImageView:urlArr];
            }
        }];
    }
}

- (void)refreshTextImageView:(NSArray *)urlArr {
    if (_imageDownloadDic.count == urlArr.count) {
        NSMutableArray *arrImage = [[NSMutableArray alloc] initWithCapacity:0];
        for (NSString *imageUrl in urlArr) {
            [arrImage addObject:_imageDownloadDic[imageUrl]];
        }
        dispatch_sync(dispatch_get_main_queue(), ^{
            /* Do UI work here */
            [self setRichTextViewImageArr:arrImage];
        });
    }
}

- (NSArray *) getImageUrlsFromHtml:(NSString *)webString {
    NSMutableArray * imageurlArray = [NSMutableArray arrayWithCapacity:1];
    //标签匹配
    NSString *parten = @"<img(.*?)>";
    NSError* error = NULL;
    NSRegularExpression *reg = [NSRegularExpression regularExpressionWithPattern:parten options:0 error:&error];
    
    NSArray* match = [reg matchesInString:webString options:0 range:NSMakeRange(0, [webString length] - 1)];
    for (NSTextCheckingResult * result in match) {
        //过去数组中的标签
        NSRange range = [result range];
        NSString * subString = [webString substringWithRange:range];
        
        //从图片中的标签中提取ImageURL
        NSRegularExpression *subReg = [NSRegularExpression regularExpressionWithPattern:@"http://(.*?)\"" options:0 error:NULL];
        NSArray* match = [subReg matchesInString:subString options:0 range:NSMakeRange(0, [subString length] - 1)];
        NSTextCheckingResult *subRes = match[0];
        NSRange subRange = [subRes range];
        subRange.length = subRange.length - 1;
        NSString *imagekUrl = [subString substringWithRange:subRange];
        
        //将提取出的图片URL添加到图片数组中
        [imageurlArray addObject:imagekUrl];
    }
    return imageurlArray;
}

- (void)setRichTextViewTotalHtmlStr:(NSString *)htmlStr {
    _textView.attributedText = [htmlStr toAttributedString];
    if (_textView.attributedText.length > 0) {
        self.placeholderLabel.hidden = YES;
    }
    _textView.font = [UIFont systemFontOfSize:DefaultFont];
}

- (void)setRichTextViewImageArr:(NSArray<UIImage *> *)imageArr {
    _imageIndex = 0;
    NSMutableAttributedString *contentStr = [[NSMutableAttributedString alloc] initWithAttributedString:_textView.attributedText];
    [contentStr enumerateAttribute:NSAttachmentAttributeName inRange:NSMakeRange(0, contentStr.length) options:0 usingBlock:^(id value, NSRange range, BOOL *stop) {
        if (value && [value isKindOfClass:[NSTextAttachment class]]) {
            //设置图片
            [self setImageText:imageArr[_imageIndex] withRange:range appenReturn:NO];
            _imageIndex++;
        }
    }];
}

#pragma mark ----------------编辑完成button-----------------

- (void)doneButtonAction {
    NSMutableArray *imageArr = [[NSMutableArray alloc] initWithCapacity:0];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]initWithAttributedString:_textView.attributedText];
    [attributedString enumerateAttribute:NSAttachmentAttributeName inRange:NSMakeRange(0, attributedString.length) options:0 usingBlock:^(id value, NSRange range, BOOL *stop) {
        if (value && [value isKindOfClass:[ImageTextAttachment class]]) {
            ImageTextAttachment *imageAttach = (ImageTextAttachment *)value;
            UIImage * selImage = imageAttach.image;
            [imageArr addObject:selImage];
        }
    }];
    if (self.doneButtonBlock) {
        self.doneButtonBlock(imageArr);
    }
}

#pragma mark *必须****传入imageUrlArr得到HtmlString
- (NSString *)retureHtmlStrWithImageArr:(NSArray <NSString *> *)imageUrlArr {
    return [self returnBodyHtmlstringFromTotalHtmlString:[self replacetagWithImageUrlArray:imageUrlArr]];
}

- (NSString *)returnBodyHtmlstringFromTotalHtmlString:(NSString *)totalString {
    NSString * fromEnd = [totalString substringFromIndex:[totalString rangeOfString:@"<body>"].location];
    NSString * fromTo = [fromEnd substringToIndex:[fromEnd rangeOfString:@"</body>"].location+7];
    return fromTo;
}

//拼接图片地址,完整html
- (NSString *)replacetagWithImageUrlArray:(NSArray *)picArr {
    NSMutableAttributedString * contentStr=[[NSMutableAttributedString alloc]initWithAttributedString:_textView.attributedText];
    
    [contentStr enumerateAttribute:NSAttachmentAttributeName inRange:NSMakeRange(0, contentStr.length) options:0 usingBlock:^(id value, NSRange range, BOOL *stop) {
        if (value && [value isKindOfClass:[ImageTextAttachment class]]) {
            [contentStr replaceCharactersInRange:range withString:RichTextImage];
        }
    }];
    
    NSMutableString * mutableStr=[[NSMutableString alloc]initWithString:[contentStr toHtmlString]];
    //这里是把字符串分割成数组，
    NSArray * strArr=[mutableStr  componentsSeparatedByString:RichTextImage];
    NSString * newContent=@"";
    for (int i=0; i<strArr.count; i++) {
        
        NSString * imgTag=@"";
        if (i<picArr.count) {
            imgTag=[NSString stringWithFormat:@"<img src=\"%@\" />",picArr[i]];
        }
        //因为cutstr 可能是null
        NSString * cutStr=[strArr objectAtIndex:i];
        newContent=[NSString stringWithFormat:@"%@%@%@",newContent,cutStr,imgTag];
    }
    return newContent;
}

#pragma mark ----------------添加图片button-----------------
- (void)imageButtonAction {
    [self endEditing:YES];
    
    //    __weak typeof(self) weakSelf = self;
    //    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"选择照片" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    //    [alertVC addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *_Nonnull action) {
    //        [weakSelf selectedImage];
    //    }]];
    //    [alertVC addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    //
    //    [_selfController presentViewController:alertVC animated:YES completion:nil];
    
    [self selectedImage];
}
- (void)selectedImage {
    
    //    NSUInteger sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    //
    //    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    //    imagePickerController.delegate = self;
    //    imagePickerController.allowsEditing = NO;
    //    imagePickerController.sourceType = sourceType;
    //    [_selfController presentViewController:imagePickerController animated:YES completion:nil];
    _addImageRange = _newRange;
    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:9 delegate:self];
    imagePickerVc.allowPickingVideo = NO;
    imagePickerVc.sortAscendingByModificationDate = NO;
    // You can get the photos by block, the same as by delegate.
    // 你可以通过block或者代理，来得到用户选择的照片.
    [imagePickerVc setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
        if (self.textView.textStorage.length > 0) {
            [self appenReturn];
        }
        for (int i = 0; i < photos.count; i++) {
            NSRange range = NSMakeRange(_addImageRange.location+i, 1);
            [self setImageText:photos[i] withRange:range appenReturn:YES];
        }
        [self.textView becomeFirstResponder];
        [self.textView setSelectedRange:NSMakeRange(self.textView.attributedText.length, 0)];
    }];
    [_selfController presentViewController:imagePickerVc animated:YES completion:nil];
}

#pragma mark - image picker delegte
//- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
//    [picker dismissViewControllerAnimated:YES completion:nil];
//
//    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
//
//    if (self.textView.textStorage.length > 0) {
//        [self appenReturn];
//    }
//    //    _imageTEMP = image;
//    //图片添加后 自动换行
//    [self.textView becomeFirstResponder];
//    [self setImageText:image withRange:self.textView.selectedRange appenReturn:YES];
//}
//设置图片
- (void)setImageText:(UIImage *)img withRange:(NSRange)range appenReturn:(BOOL)appen {
    UIImage *image = img;
    if (image == nil) {
        return;
    }
    if (![image isKindOfClass:[UIImage class]]) {
        return;
    }
    CGFloat imgeWeight = ImageWidthSize;
    CGFloat imgeHeight = image.size.height * imgeWeight / image.size.width;
    //    if (ImgeHeight > ImageWidthSize * 2) {
    //        ImgeHeight = ImageWidthSize * 2;
    //    }
    
    ImageTextAttachment *imageTextAttachment = [ImageTextAttachment new];
    // Set tag and image
    imageTextAttachment.imageTag = RichTextImage;
    imageTextAttachment.image = image;
    
    // Set image size
    imageTextAttachment.imageSize = CGSizeMake(imgeWeight, imgeHeight);
    
    if (appen) {
        // Insert image image
        [_textView.textStorage insertAttributedString:[NSAttributedString attributedStringWithAttachment:imageTextAttachment] atIndex:range.location];
    } else {
        if (_textView.textStorage.length > 0) {
            [_textView.textStorage replaceCharactersInRange:range withAttributedString:[NSAttributedString attributedStringWithAttachment:imageTextAttachment]];
        }
    }
    
    //    // Move selection location
    //    _textView.selectedRange = NSMakeRange(range.location + 1, range.length);
    
    //设置locationStr的设置
    [self setInitLocation];
    //    if (appen) {
    //        [self appenReturn];
    //    }
    self.textView.font = [UIFont systemFontOfSize:DefaultFont];
}

- (void)setInitLocation {
    
    self.locationStr = nil;
    self.locationStr = [[NSMutableAttributedString alloc] initWithAttributedString:self.textView.attributedText];
    if (self.textView.textStorage.length > 0) {
        self.placeholderLabel.hidden = YES;
    }
}

- (void)appenReturn {
    NSAttributedString *returnStr = [[NSAttributedString alloc] initWithString:@"\n"];
    NSMutableAttributedString *att = [[NSMutableAttributedString alloc] initWithAttributedString:_textView.attributedText];
    [att appendAttributedString:returnStr];
    
    _textView.attributedText = att;
    _textView.font = [UIFont systemFontOfSize:DefaultFont];
}

#pragma mark ------------------textViewDelegate----------------
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if (range.length == 1) {
        return YES;
    } else {
        // 超过长度限制
        if ([textView.text length] >= MaxLength + 3) {
            return NO;
        }
    }
    
    return YES;
}

- (void)textViewDidChangeSelection:(UITextView *)textView {
    _newRange = textView.selectedRange;
}

- (void)textViewDidChange:(UITextView *)textView {
    //    CGFloat floatValue = textView.selectedRange;
    if (self.textView.attributedText.length > 0) {
        self.placeholderLabel.hidden = YES;
    } else {
        self.placeholderLabel.hidden = NO;
    }
}

#pragma mark ------------Keyboard notification(视图偏移)-------
- (void)onKeyboardNotification:(NSNotification *)notification {
    //Reset constraint constant by keyboard height
    if ([notification.name isEqualToString:UIKeyboardWillShowNotification]) {
        if (_selfNewFrame.size.height != 0) {
            [UIView animateWithDuration:0.8f animations:^{
                self.frame = _selfNewFrame;
                _textView.frame = self.bounds;
                _imgButton.frame = ImageButtonFrame;
                _doneButton.frame = DoneButtonFrame;
            }];
            return;
        }
        
        CGRect keyboardFrame = ((NSValue *) notification.userInfo[UIKeyboardFrameEndUserInfoKey]).CGRectValue;
        CGFloat hideHeight = 0;
        if (keyboardFrame.size.height != 0) {
            hideHeight = keyboardFrame.size.height -([UIScreen mainScreen].bounds.size.height - self.frame.origin.y - self.frame.size.height);
        } else {
            hideHeight = 0;
        }
        _selfNewFrame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.frame.size.height - hideHeight);
        [UIView animateWithDuration:0.8f animations:^{
            self.frame = _selfNewFrame;
            _textView.frame = self.bounds;
            _imgButton.frame = ImageButtonFrame;
            _doneButton.frame = DoneButtonFrame;
        }];
    } else if ([notification.name isEqualToString:UIKeyboardWillHideNotification]) {
        [UIView animateWithDuration:0.8f animations:^{
            self.frame = _selfFrame;
            _textView.frame = self.bounds;
            _imgButton.frame = ImageButtonFrame;
            _doneButton.frame = DoneButtonFrame;
        }];
    }
}

@end
