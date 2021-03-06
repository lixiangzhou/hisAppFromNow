//
//  HXBAccount_AlterLoginPassword_View.m
//  hoomxb
//
//  Created by HXB on 2017/6/8.
//  Copyright © 2017年 hoomsun-miniX. All rights reserved.
//

#import "HXBAccount_AlterLoginPassword_View.h"
#import "HXBCustomTextField.h"///密码的View
#import "SVGKit/SVGKImage.h"
@interface HXBAccount_AlterLoginPassword_View ()<UITextFieldDelegate>
///原始的密码的textField
@property (nonatomic,strong) HXBCustomTextField *password_Original;
///新密码的textField
//@property (nonatomic,strong) HXBBasePasswordView *password_New;
@property (nonatomic, strong) HXBCustomTextField *password_New;
///确认修改密码
@property (nonatomic,strong) UIButton *alterButton;

////点击了确认修改密码
@property (nonatomic,copy) void(^clickAlterButtonBlock)(NSString *password_Original, NSString *password_New);
@end

@implementation HXBAccount_AlterLoginPassword_View
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setUPView];
    }
    return self;
}

///设置UI
- (void)setUPView {
    kWeakSelf
    self.alterButton = [UIButton btnwithTitle:@"确认修改" andTarget:self andAction:@selector(clickAlterButton:) andFrameByCategory:CGRectZero];
    self.alterButton.backgroundColor = COR12;
    self.alterButton.userInteractionEnabled = NO;
    
    [self addSubview: self.password_Original];
    [self addSubview:self.password_New];
    [self addSubview:self.alterButton];
    [self.password_Original mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(kScrAdaptationH(28));
        make.left.equalTo(self);
        make.right.equalTo(self);
        make.height.equalTo(@(kScrAdaptationH(60)));
    }];
    [self.password_New mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.password_Original.mas_bottom);
        make.left.equalTo(self);
        make.right.equalTo(self);
        make.height.offset(kScrAdaptationH(60));
    }];
    [self.alterButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.password_New.mas_bottom).offset(kScrAdaptationH(50));
        make.left.equalTo(self).offset(kScrAdaptationW(20));
        make.right.equalTo(self).offset(kScrAdaptationW(-20));
        make.height.equalTo(@(kScrAdaptationH(41)));
    }];
}
///点击了确认修改按钮
- (void)clickAlterButton: (UIButton *)button {
    NSLog(@"点击了确认修改按钮");
    if (self.clickAlterButtonBlock) self.clickAlterButtonBlock(self.password_Original.text,self.password_New.text);
}
- (void)clickAlterButtonWithBlock:(void (^)(NSString *password_Original, NSString *password_New))clickAlterButtonBlock {
    self.clickAlterButtonBlock = clickAlterButtonBlock;
}
#pragma mark - 懒加载

- (HXBCustomTextField *)password_New
{
    if (!_password_New) {
        _password_New = [[HXBCustomTextField alloc] init];
        _password_New.leftImage = [UIImage imageNamed:@"password"];
        _password_New.delegate = self;
        _password_New.placeholder = @"请设置8-20位数字和字母组合的密码";
        _password_New.secureTextEntry = YES;
        _password_New.block = ^(NSString *text) {
            if (text.length > 0 && _password_Original.text.length > 0) {
                _alterButton.backgroundColor = COR29;
                _alterButton.userInteractionEnabled = YES;
            } else {
                _alterButton.backgroundColor = COR12;
                _alterButton.userInteractionEnabled = NO;
            }
        };
    }
    return _password_New;
}

- (HXBCustomTextField *)password_Original
{
    if (!_password_Original) {
        _password_Original = [[HXBCustomTextField alloc] init];
        _password_Original.leftImage = [UIImage imageNamed:@"password"];
        _password_Original.delegate = self;
        _password_Original.placeholder = @"原登录密码";
        _password_Original.secureTextEntry = YES;
        _password_Original.block = ^(NSString *text) {
            if (text.length > 0 && _password_New.text.length > 0) {
                _alterButton.backgroundColor = COR29;
                _alterButton.userInteractionEnabled = YES;
            } else {
                _alterButton.backgroundColor = COR12;
                _alterButton.userInteractionEnabled = NO;
            }
        };
    }
    return _password_Original;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    self.alterButton.backgroundColor = COR12;
    self.alterButton.userInteractionEnabled = NO;
    return YES;
}

@end
