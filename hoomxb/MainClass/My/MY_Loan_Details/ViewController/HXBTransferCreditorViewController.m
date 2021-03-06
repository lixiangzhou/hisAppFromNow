//
//  HXBTransferCreditorViewController.m
//  hoomxb
//
//  Created by HXB-C on 2017/9/21.
//  Copyright © 2017年 hoomsun-miniX. All rights reserved.
//

#import "HXBTransferCreditorViewController.h"
#import "HXBTransferCreditorTopView.h"
#import "HXBTransferCreditorBottomView.h"
#import "HXBModifyTransactionPasswordViewController.h"
#import "HXBFBase_BuyResult_VC.h"
#import "HXBMY_LoanListViewController.h"
#import "HXBTransferConfirmModel.h"
#import "HXBTransactionPasswordView.h"
#import "HXBMyLoanDetailsViewModel.h"
#import "HXBLazyCatAccountWebViewController.h"

@interface HXBTransferCreditorViewController ()

@property (nonatomic, strong) HXBTransferCreditorTopView *topView;

@property (nonatomic, strong) HXBTransferCreditorBottomView *bottomView;

@property (nonatomic, strong) HXBFinBaseNegotiateView *agreementView;

@property (nonatomic, strong) UIButton *sureBtn;

@property (nonatomic, strong) HXBTransactionPasswordView *passwordView;

@property (nonatomic, strong) HXBTransferConfirmModel *transferConfirmModel;

@property (nonatomic, strong) HXBMyLoanDetailsViewModel *viewModel;

@end

@implementation HXBTransferCreditorViewController



#pragma mark - life生命周期
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"确认转让债权";
    self.view.backgroundColor = BACKGROUNDCOLOR;
    self.isRedColorWithNavigationBar = YES;
    kWeakSelf
    self.viewModel = [[HXBMyLoanDetailsViewModel alloc] initWithBlock:^UIView *{
        return weakSelf.view;
    }];
    [self.view addSubview:self.topView];
    [self.view addSubview:self.bottomView];
    [self.view addSubview:self.agreementView];
    [self.view addSubview:self.sureBtn];
    [self setupFrame];
    [self loadAccountLoanTransferInfo];
}

- (void)setupFrame
{
    [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(HXBStatusBarAndNavigationBarHeight);
        make.right.left.equalTo(self.view);
        make.height.offset(kScrAdaptationH750(270));
    }];
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.topView.mas_bottom);
        make.right.left.equalTo(self.view);
        make.height.offset(kScrAdaptationH750(262));
    }];
    [self.agreementView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.bottomView.mas_bottom).offset(kScrAdaptationH750(21));
        make.left.equalTo(self.view);
        make.height.offset(kScrAdaptationH750(26));
        make.right.equalTo(self.view);
    }];
    [self.sureBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(kScrAdaptationW750(40));
        make.right.equalTo(self.view).offset(kScrAdaptationW750(-40));
        make.height.offset(kScrAdaptationH750(82));
        make.top.equalTo(self.bottomView.mas_bottom).offset(kScrAdaptationH750(147));
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)loadAccountLoanTransferInfo {
    kWeakSelf
    [_viewModel accountLoanTransferRequestWithTransferID:self.creditorID resultBlock:^(BOOL isSuccess) {
        if (isSuccess) {
            weakSelf.topView.transferConfirmModel = weakSelf.viewModel.transferConfirmModel;
            weakSelf.bottomView.transferConfirmModel = weakSelf.viewModel.transferConfirmModel;
            weakSelf.transferConfirmModel = weakSelf.viewModel.transferConfirmModel;
        }
    }];
}

#pragma mark - Event事件
- (void)sureBtnClick {
    kWeakSelf
    NSDictionary *dic_post = @{
                               @"loanId": self.creditorID,
                               @"currentTransferValue": self.transferConfirmModel.currentTransValue?:@""
                               };
    [_viewModel accountLoanTransferRequestResultWithParams:dic_post resultBlock:^(BOOL isSuccess) {
        if (isSuccess) {
            HXBLazyCatAccountWebViewController *HFVC = [[HXBLazyCatAccountWebViewController alloc] init];
            HFVC.requestModel = weakSelf.viewModel.resultModel;
            [weakSelf.navigationController pushViewController:HFVC animated:YES];
        }
    }];
}

#pragma mark - getter(懒加载)
- (HXBFinBaseNegotiateView *)agreementView
{
    if (!_agreementView) {
        _agreementView = [[HXBFinBaseNegotiateView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScrAdaptationH(200))];
        _agreementView.negotiateStr = @"债权转让及受让协议";
        kWeakSelf
        [_agreementView clickNegotiateWithBlock:^{
            [HXBBaseWKWebViewController pushWithPageUrl:[NSString splicingH5hostWithURL:kHXB_Negotiate_LoanTruansferURL] fromController:weakSelf];
        }];
        [_agreementView clickCheckMarkWithBlock:^(BOOL isSelected) {
            if (isSelected) {
                weakSelf.sureBtn.userInteractionEnabled = YES;
                [weakSelf.sureBtn setBackgroundColor:COR29];
            }else
            {
                weakSelf.sureBtn.userInteractionEnabled = NO;
                [weakSelf.sureBtn setBackgroundColor:COR26];
            }
        }];
    }
    return _agreementView;
}

- (HXBTransferCreditorTopView *)topView
{
    if (!_topView) {
        _topView = [[HXBTransferCreditorTopView alloc] initWithFrame:CGRectZero];
        _topView.backgroundColor = [UIColor whiteColor];
    }
    return _topView;
}

- (HXBTransferCreditorBottomView *)bottomView
{
    if (!_bottomView) {
        _bottomView = [[HXBTransferCreditorBottomView alloc] init];
        _bottomView.backgroundColor = [UIColor whiteColor];
    }
    return _bottomView;
}
- (UIButton *)sureBtn
{
    if (!_sureBtn) {
        _sureBtn = [UIButton btnwithTitle:@"确定" andTarget:self andAction:@selector(sureBtnClick) andFrameByCategory:CGRectZero];
    }
    return _sureBtn;
}
@end
