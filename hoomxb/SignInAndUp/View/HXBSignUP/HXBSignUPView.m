//
//  HXBSignUPView.m
//  hoomxb
//
//  Created by HXB on 2017/6/2.
//  Copyright © 2017年 hoomsun-miniX. All rights reserved.
//

#import "HXBSignUPView.h"
#import "HxbSignUpViewController.h"

static NSString *const kNextButtonTitle = @"下一步";
static NSString *const kHavedAccountTitle = @"已有账户，去登录";
static NSString *const kPhoneTitle = @"手机号";
@interface HXBSignUPView()  <
UITextFieldDelegate
>
///已有账户的button
@property (nonatomic, strong) UIButton *havedAccountButton;
///手机号
@property (nonatomic, strong) UITextField *phoneTextField;
@property (nonatomic, strong) UILabel *checkMobileLabel;
///手机号
@property (nonatomic, strong) UILabel *phoneLabel;
///下一步button
@property (nonatomic, strong) UIButton *nextButton;
///点击了下一步的button
@property (nonatomic, copy) void(^clickNextButtonBlock)();
///请求 手机好校验
@property (nonatomic, copy) void(^checkMobileBlock)(NSString *mobile);
///点击了已有账号，去登陆按钮
@property (nonatomic, copy) void(^clickHaveAccountButtonBlock)();
@end

@implementation HXBSignUPView

#pragma mark - setter 
- (void)setCheckMobileStr:(NSString *)checkMobileStr {
    _checkMobileStr = checkMobileStr;
    self.checkMobileLabel.text = checkMobileStr;
}

#pragma mark - getter 
- (UITextField *)phoneTextField{
    if (!_phoneTextField) {
        _phoneTextField = [[UITextField alloc]init];
        _phoneTextField.keyboardType = UIKeyboardTypeNumberPad;
        _phoneTextField.delegate = self;
    }
    return _phoneTextField;
}
- (UILabel *)phoneLabel {
    if (!_phoneLabel) {
        _phoneLabel = [[UILabel alloc]init];
        _phoneLabel.textColor = COR1;
        _phoneLabel.text = kPhoneTitle;
    }
    return _phoneLabel;
}

- (UIButton *)nextButton{
    if (!_nextButton) {
        _nextButton = [[UIButton alloc]init];
        [_nextButton setTitle:kNextButtonTitle forState:UIControlStateNormal];
        [_nextButton addTarget:self action:@selector(clickNextButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _nextButton;
}
- (UIButton *)havedAccountButton {
    if (!_havedAccountButton) {
        _havedAccountButton = [[UIButton alloc]init];
        [_havedAccountButton setTitle:kHavedAccountTitle forState:UIControlStateNormal];
        [_havedAccountButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [_havedAccountButton addTarget:self action:@selector(clickHavedAccountButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _havedAccountButton;
}
- (UILabel *)checkMobileLabel {
    if (!_checkMobileLabel) {
        _checkMobileLabel = [[UILabel alloc]init];
        _checkMobileLabel.textColor = [UIColor blueColor];
    }
    return _checkMobileLabel;
}
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setUP];
    }
    return self;
}

- (void) setUP {
    [self addSubview:self.phoneLabel];
    [self addSubview:self.phoneTextField];
    [self addSubview:self.nextButton];
    [self addSubview:self.havedAccountButton];
    [self addSubview:self.checkMobileLabel];
    
    kWeakSelf
    [self.phoneLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf).offset(kScrAdaptationH(80));
        make.left.equalTo(weakSelf).offset(kScrAdaptationW(20));
        make.height.equalTo(@(kScrAdaptationW(50)));
        make.width.equalTo(@(kScrAdaptationH(80)));
    }];
    [self.phoneTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(weakSelf.phoneLabel);
        make.left.equalTo(weakSelf.phoneLabel.mas_right).offset(kScrAdaptationW(0));
        make.right.equalTo(weakSelf).offset(kScrAdaptationW(-20));
        make.height.equalTo(weakSelf.phoneLabel);
    }];
    [self.checkMobileLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.phoneTextField.mas_bottom).offset(kScrAdaptationH(10));
        make.height.offset(kScrAdaptationH(20));
        make.left.right.equalTo(weakSelf.phoneTextField);
    }];
    [self.havedAccountButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(weakSelf).offset(kScrAdaptationH(-50));
        make.right.equalTo(weakSelf).offset(kScrAdaptationW(-20));
        make.left.equalTo(weakSelf).offset(kScrAdaptationW(20));
    }];
    [self.nextButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(weakSelf.havedAccountButton.mas_top).offset(kScrAdaptationH(-20));
        make.right.left.height.equalTo(weakSelf.havedAccountButton);
    }];
    self.phoneLabel.backgroundColor = [UIColor hxb_randomColor];
    self.phoneTextField.backgroundColor = [UIColor hxb_randomColor];
    self.havedAccountButton.backgroundColor = [UIColor hxb_randomColor];
    self.nextButton.backgroundColor = [UIColor hxb_randomColor];
    self.checkMobileLabel.backgroundColor = [UIColor hxb_randomColor];
}

#pragma mark - textfield delegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (![self.phoneTextField isEqual:textField]) return true;
    
    //删除按钮
    self.phoneTextField.clearButtonMode = textField.text.length > 0? UITextFieldViewModeAlways : UITextFieldViewModeNever;
    
    //如果到达11 个字符就请求数据
    NSString *str = nil;
    if (string.length) {
        str = [NSString stringWithFormat:@"%@%@",self.phoneTextField.text,string];
    }else {
        NSInteger length = self.phoneTextField.text.length;
        NSRange range = NSMakeRange(length - 1, 1);
        NSMutableString *strM = self.phoneTextField.text.mutableCopy;
        [strM deleteCharactersInRange:range];
        str = strM.copy;
    }
    
    if (str.length == 11) {
        if (self.checkMobileBlock) {
            self.checkMobileBlock(str);
        }
    }
    if (str.length != 11) {
        self.checkMobileLabel.text = @"";
    }
    UITextFieldViewMode model = str.length > 0? UITextFieldViewModeAlways : UITextFieldViewModeNever;
    self.phoneTextField.clearButtonMode = model;
    return str.length <= 11;
}
- (void)textFieldDidChange1:(UITextField *)textField{
   
   
}

///点击了nextButton
- (void)clickNextButton:(UIButton *)sender{
    //判断是否为手机号，不是不让图验
    if (![NSString isMobileNumber: self.phoneTextField.text]) {
        self.checkMobileLabel.text = @"手机号不正确";
        return;
    }
    if (self.clickNextButtonBlock) self.clickNextButtonBlock();
}
///点击了已有账号登录按钮
- (void)clickHavedAccountButton: (UIButton *)button {
    if (self.clickHaveAccountButtonBlock) {
        self.clickHaveAccountButtonBlock();
    }
}

//事件的传递
- (void)signUPClickNextButtonFunc:(void (^)())clickNextButtonBlock {
    self.clickNextButtonBlock = clickNextButtonBlock;
}
//手机号校验
- (void)checkMobileWithBlockFunc:(void (^)(NSString *mobile))checkMobileBlock {
    self.checkMobileBlock = checkMobileBlock;
}
///点击了已有账号按钮
- (void)clickHaveAccountButtonFunc:(void (^)())clickHaveAccountButtonBlock {
    self.clickHaveAccountButtonBlock = clickHaveAccountButtonBlock;
}
@end