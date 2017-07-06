//
//  HxbMyTopUpViewController.m
//  hoomxb
//
//  Created by HXB-C on 2017/5/8.
//  Copyright © 2017年 hoomsun-miniX. All rights reserved.
//

#import "HxbMyTopUpViewController.h"
#import "HxbSecurityCertificationViewController.h"
#import "HxbBindCardViewController.h"
#import "HXBMyTopUpBankView.h"
@interface HxbMyTopUpViewController ()
@property (nonatomic, strong) UITextField *amountTextField;
@property (nonatomic, strong) UIButton *nextButton;
@property (nonatomic, strong) HXBMyTopUpBankView *mybankView;
@end

@implementation HxbMyTopUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"充值";
    [self.view addSubview:self.mybankView];
    [self.view addSubview:self.amountTextField];
    [self.view addSubview:self.nextButton];
    [self setCardViewFrame];
}
- (void)setCardViewFrame{
    [KeyChain isBindCardWithBlock:^(NSString *isBindCard) {
        if (![isBindCard isEqualToString:@"1"]) {
            _mybankView.hidden = YES;
            [_amountTextField setY:64];
            [_nextButton setY:CGRectGetMaxY(_amountTextField.frame) + 20];
        }
    }];
    
}

- (void)nextButtonClick:(UIButton *)sender{
    if ([_amountTextField.text doubleValue] < 1) {
        [HxbHUDProgress showTextWithMessage:@"金额不能小于1"];
        return;
    }
//实名认证
    [HXBRequestUserInfo downLoadUserInfoWithSeccessBlock:^(HXBRequestUserInfoViewModel *viewModel) {
        //是否实名
        if (!viewModel.userInfoModel.userInfo.isAllPassed.integerValue) {
            HxbSecurityCertificationViewController *securityCertificationVC = [[HxbSecurityCertificationViewController alloc]init];
            [self.navigationController pushViewController:securityCertificationVC animated:YES];
            return;
        }
        //是否绑卡
        if (!viewModel.userInfoModel.userInfo.hasBindCard.integerValue) {
            HxbBindCardViewController *bindCardViewController = [[HxbBindCardViewController alloc]init];
            [self.navigationController pushViewController:bindCardViewController animated:YES];
            return;
        }
    } andFailure:^(NSError *error) {
        
    }];
    
   
}

- (HXBMyTopUpBankView *)mybankView{
    if (!_mybankView) {
        _mybankView = [[HXBMyTopUpBankView alloc]initWithFrame:CGRectMake(0, 84, SCREEN_WIDTH, 80)];
        _mybankView.backgroundColor = COR12;
    }
    return _mybankView;
}
- (UITextField *)amountTextField{
    if (!_amountTextField) {
        _amountTextField = [UITextField hxb_lineTextFieldWithFrame:CGRectMake(20, CGRectGetMaxY(_mybankView.frame), SCREEN_WIDTH - 40, 44)];
        _amountTextField.placeholder = @"请输入充值金额";

    }
    return _amountTextField;
}

- (UIButton *)nextButton{
    if (!_nextButton) {
        _nextButton = [UIButton btnwithTitle:@"下一步" andTarget:self andAction:@selector(nextButtonClick:) andFrameByCategory:  CGRectMake(20,CGRectGetMaxY(_amountTextField.frame) + 20, SCREEN_WIDTH - 40,44)];
    }
    return _nextButton;
}


@end


