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

#define IMAGE_MAX_SIZE 365
#define DefaultFont (16)
#define MaxLength (1000) //最大选中删除字符数
#define RICHTEXT_IMAGE (@"[UIImageView]")
#define ImageButtonFrame CGRectMake(self.frame.size.width - 120, self.frame.size.height - 40, 50, 40)
#define DoneButtonFrame CGRectMake(self.frame.size.width - 60, self.frame.size.height - 40, 50, 40)

@interface SXRichViewEdit () <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextViewDelegate>

@property (nonatomic, weak) UIViewController *selfController;
@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) UILabel *placeholderLabel; //默认提示字
@property (nonatomic, assign) NSRange newRange;          //记录最新内容的range
@property (nonatomic, strong) NSString *newstr;          //记录最新内容的字符串
@property (nonatomic, assign) NSUInteger location;       //纪录变化的起始位置
@property (nonatomic, strong) NSMutableArray *imageArr;         //记录添加的图片

@property (nonatomic, strong) NSMutableAttributedString *locationStr; //纪录变化时的内容，即是
@property (nonatomic, assign) CGFloat lineSapce;                      //行间距
@property (nonatomic, assign) BOOL isDelete;                          //是否是回删
@property (nonatomic, assign) CGRect selfFrame;                       //默认位置
@property (nonatomic, assign) CGRect selfNewFrame;                    //弹起键盘的位置

@property (nonatomic, strong) UIButton *imgButton;
@property (nonatomic, strong) UIButton *doneButton;


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
    _imageArr = [[NSMutableArray alloc] initWithCapacity:0];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onKeyboardNotification:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onKeyboardNotification:) name:UIKeyboardWillShowNotification object:nil];
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
    if (_hideButton) {
        _imgButton.hidden = YES;
        _doneButton.hidden = YES;
    }
}

#pragma mark 设置内容，二次编辑
//*****设置内容，二次编辑传入htmlString
- (void)setRichTextViewHtmlStr:(NSString *)htmlStr andImageArr:(NSArray <UIImage *>*)imageArr {
    NSAttributedString * contentStr = [[NSAttributedString alloc] initWithString:@""];
    NSMutableString * totalHtmlstring = [[NSMutableString alloc] initWithString:[contentStr toHtmlString]];
    [totalHtmlstring replaceCharactersInRange:[totalHtmlstring rangeOfString:@"<body>\n</body>"] withString:htmlStr];
    
    [self setRichTextViewTotalHtmlStr:totalHtmlstring andImageArr:imageArr];
}

- (void)setRichTextViewTotalHtmlStr:(NSString *)htmlStr andImageArr:(NSArray<UIImage *> *)imageArr {
    [_imageArr removeAllObjects];
    [_imageArr addObjectsFromArray:imageArr];
    static NSInteger i = 0;
    _textView.attributedText = [htmlStr toAttributedString];
    NSMutableAttributedString *contentStr = [[NSMutableAttributedString alloc] initWithAttributedString:[htmlStr toAttributedString]];
    [contentStr enumerateAttribute:NSAttachmentAttributeName
                           inRange:NSMakeRange(0, contentStr.length)
                           options:0
                        usingBlock:^(id value, NSRange range, BOOL *stop) {
                            if (value && [value isKindOfClass:[NSTextAttachment class]]) {
                                //                NSTextAttachment * imageAttach = value;
                                //                NSLog(@"%@.....%@",imageAttach.image,imageAttach);
                                //                if (imageAttach.image) {
                                //                    [self setImageText:imageAttach withRange:range appenReturn:NO];
                                //                }
                                //                //设置图片
                                [self setImageText:imageArr[i] withRange:range appenReturn:NO];
                                i = i + 1;
                            }
                        }];
    if (_textView.attributedText.length > 0) {
        self.placeholderLabel.hidden = YES;
        }
    
    _textView.font = [UIFont systemFontOfSize:DefaultFont];
}

#pragma mark ----------------编辑完成button-----------------

- (void)doneButtonAction {
    if (self.doneButtonBlock) {
        self.doneButtonBlock(_imageArr);
    }
//    NSArray *arr = [_textView.attributedText getImgaeArray];
//    [self setRichTextViewHtmlStr:@"tttttttt"];
//    NSLog(@"%@", [self retureHtmlStrWithImageArr:@[@"http://pic32.nipic.com/20130829/12906030_124355855000_2.png"]]);
//    [self setRichTextViewHtmlStr:[self retureHtmlStrWithImageArr:@[@"<img src=\"http://pic32.nipic.com/20130829/12906030_124355855000_2.png\"/>"]] andImageArr:@[_imageTEMP]];
}

//*必须****传入imageUrlArr得到HtmlString
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
    
    [contentStr enumerateAttribute:NSAttachmentAttributeName inRange:NSMakeRange(0, contentStr.length)
                           options:0
                        usingBlock:^(id value, NSRange range, BOOL *stop) {
                            if (value && [value isKindOfClass:[ImageTextAttachment class]]) {
                                
                                [contentStr replaceCharactersInRange:range withString:RICHTEXT_IMAGE];
                                
                            }
                        }];
    
    NSMutableString * mutableStr=[[NSMutableString alloc]initWithString:[contentStr toHtmlString]];
    
    //这里是把字符串分割成数组，
    NSArray * strArr=[mutableStr  componentsSeparatedByString:RICHTEXT_IMAGE];
    NSString * newContent=@"";
    for (int i=0; i<strArr.count; i++) {
        
        NSString * imgTag=@"";
        if (i<picArr.count) {
                imgTag=picArr[i];
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
    
    __weak typeof(self) weakSelf = self;
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"选择照片" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertVC addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *_Nonnull action) {
        [weakSelf selectedImage];
    }]];
    [alertVC addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    
    [_selfController presentViewController:alertVC animated:YES completion:nil];
}
- (void)selectedImage {
    
    NSUInteger sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.delegate = self;
    imagePickerController.allowsEditing = NO;
    imagePickerController.sourceType = sourceType;
    [_selfController presentViewController:imagePickerController animated:YES completion:nil];
}

#pragma mark - image picker delegte
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    if (self.textView.textStorage.length > 0) {
        [self appenReturn];
    }
//    _imageTEMP = image;
    //图片添加后 自动换行
    [self setImageText:image withRange:self.textView.selectedRange appenReturn:YES];
    
    [self.textView becomeFirstResponder];
}
//设置图片
- (void)setImageText:(UIImage *)img withRange:(NSRange)range appenReturn:(BOOL)appen {
    [_imageArr addObject:img];
    UIImage *image = img;
    
    if (image == nil) {
        return;
    }
    
    if (![image isKindOfClass:[UIImage class]]) // UIImage资源
    {
        
        return;
    }
    
    CGFloat ImgeHeight = image.size.height * IMAGE_MAX_SIZE / image.size.width;
    if (ImgeHeight > IMAGE_MAX_SIZE * 2) {
        ImgeHeight = IMAGE_MAX_SIZE * 2;
    }
    
    ImageTextAttachment *imageTextAttachment = [ImageTextAttachment new];
    
    // Set tag and image
    imageTextAttachment.imageTag = RICHTEXT_IMAGE;
    imageTextAttachment.image = image;
    
    // Set image size
    imageTextAttachment.imageSize = CGSizeMake(IMAGE_MAX_SIZE, ImgeHeight);
    
    if (appen) {
        // Insert image image
        [_textView.textStorage
         insertAttributedString:
         [NSAttributedString attributedStringWithAttachment:imageTextAttachment] atIndex:range.location];
    } else {
        if (_textView.textStorage.length > 0) {
            
            // Insert image image
            [_textView.textStorage
             replaceCharactersInRange:range
             withAttributedString:
             [NSAttributedString
              attributedStringWithAttachment:imageTextAttachment]];
        }
    }
    
    // Move selection location
    _textView.selectedRange = NSMakeRange(range.location + 1, range.length);
    
    //设置locationStr的设置
    [self setInitLocation];
    if (appen) {
        [self appenReturn];
    }
    [self.textView setSelectedRange:NSMakeRange(self.textView.attributedText.length, 0)];
}

- (void)setInitLocation {
    
    self.locationStr = nil;
    self.locationStr = [[NSMutableAttributedString alloc]
                        initWithAttributedString:self.textView.attributedText];
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

#pragma mark ---------------------textViewDelegate--------------------
/**
 *  点击图片触发代理事件
 */
- (BOOL)textView:(UITextView *)textView shouldInteractWithTextAttachment:(NSTextAttachment *)textAttachment inRange:(NSRange)characterRange {
    NSLog(@"%@", textAttachment);
    return NO;
}

/**
 *  点击链接，触发代理事件
 */
- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange {
    [[UIApplication sharedApplication] openURL:URL];
    return YES;
}
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    //    textview 改变字体的行间距
    
    return YES;
}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if (range.length == 1) // 回删
    {
        
        return YES;
    } else {
        
        // 超过长度限制
        if ([textView.text length] >= MaxLength + 3) {
            
            return NO;
        }
    }
    
    return YES;
}
//- (void)textViewDidChangeSelection:(UITextView *)textView;
//{
//    NSLog(@"焦点改变");
//}
- (void)textViewDidChange:(UITextView *)textView {
    
    if (self.textView.attributedText.length > 0) {
        self.placeholderLabel.hidden = YES;
    } else {
        self.placeholderLabel.hidden = NO;
    }
//    NSInteger len = textView.attributedText.length - self.locationStr.length;
//    if (len > 0) {
//        
//        self.isDelete = NO;
//        self.newRange =
//        NSMakeRange(self.textView.selectedRange.location - len, len);
//        self.newstr = [textView.text substringWithRange:self.newRange];
//    } else {
//        self.isDelete = YES;
//    }
//    //# warning  如果出现输入问题，检查这里
//    bool isChinese; //判断当前输入法是否是中文
//    
//    if ([[[textView textInputMode] primaryLanguage] isEqualToString:@"en-US"]) {
//        isChinese = false;
//    } else {
//        isChinese = true;
//    }
//    NSString *str =
//    [[self.textView text] stringByReplacingOccurrencesOfString:@"?"
//                                                    withString:@""];
//    if (isChinese) { //中文输入法下
//        UITextRange *selectedRange = [self.textView markedTextRange];
//        //获取高亮部分
//        UITextPosition *position =
//        [self.textView positionFromPosition:selectedRange.start offset:0];
//        // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
//        if (!position) {
//            //            NSLog(@"汉字");
//            //            [self setStyle];
//            if (str.length >= MaxLength) {
//                NSString *strNew = [NSString stringWithString:str];
//                [self.textView setText:[strNew substringToIndex:MaxLength]];
//            }
//        } else {
//            //            NSLog(@"没有转化--%@",str);
//            if ([str length] >= MaxLength + 10) {
//                NSString *strNew = [NSString stringWithString:str];
//                [self.textView setText:[strNew substringToIndex:MaxLength + 10]];
//            }
//        }
//    } else {
//        //        NSLog(@"英文");
//        
//        //        [self setStyle];
//        if ([str length] >= MaxLength) {
//            NSString *strNew = [NSString stringWithString:str];
//            [self.textView setText:[strNew substringToIndex:MaxLength]];
//        }
//    }
    
//    NSLog(@"%@", textView.attributedText);
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    
    
}

#pragma mark - Keyboard notification

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
        CGFloat hideHeight = keyboardFrame.size.height -([UIScreen mainScreen].bounds.size.height - 20 - self.frame.origin.y - self.frame.size.height);
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
