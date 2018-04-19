//
//  HXBFin_Loan_Buy_ViewController.m
//  hoomxb
//
//  Created by 肖扬 on 2017/11/13.
//  Copyright © 2017年 hoomsun-miniX. All rights reserved.
// 散标

#import "HXBFin_Loan_Buy_ViewController.h"
#import "HXBCreditorChangeTopView.h"
#import "HXBCreditorChangeBottomView.h"
#import "HXBFin_creditorChange_TableViewCell.h"
#import "HXBFBase_BuyResult_VC.h"
#import "HxbMyTopUpViewController.h"
#import "HXBVerificationCodeAlertVC.h"
#import "HXBModifyTransactionPasswordViewController.h"
#import "HxbWithdrawCardViewController.h"
#import "HXBChooseDiscountCouponViewController.h"
#import "HXBTransactionPasswordView.h"
#import "HXBRootVCManager.h"
#import "HXBFinLoanBuyViewModel.h"

static NSString *const bankString = @"绑定银行卡";

@interface HXBFin_Loan_Buy_ViewController ()<UITableViewDelegate, UITableViewDataSource, HXBChooseDiscountCouponViewControllerDelegate>
/** topView */
@property (nonatomic, strong) HXBCreditorChangeTopView *topView;
/** bottomView*/
@property (nonatomic, strong) HXBCreditorChangeBottomView *bottomView;
/** 短验弹框 */
@property (nonatomic, strong) HXBVerificationCodeAlertVC *alertVC;
// 银行卡信息
@property (nonatomic, strong) HXBBankCardModel *cardModel;
/** titleArray */
@property (nonatomic, strong) NSArray *titleArray;
/** titleArray */
@property (nonatomic, strong) NSArray *detailArray;
/** 充值金额 */
@property (nonatomic, copy) NSString *inputMoneyStr;
/** 可用余额 */
@property (nonatomic, copy) NSString *balanceMoneyStr;
/** 点击按钮的文案 */
@property (nonatomic, copy) NSString * btnLabelText;
/** 购买类型 */
@property (nonatomic, copy) NSString *buyType; // balance recharge
/** 优惠券金额 */
@property (nonatomic, copy) NSString *discountTitle;
/** 应付金额detailLabel */
@property (nonatomic, copy) NSString *handleDetailTitle;
/** 可用余额TextLabel */
@property (nonatomic, copy) NSString *balanceTitle;
/** 可用余额detailLabel */
@property (nonatomic, copy) NSString *balanceDetailTitle;
// 是否符合标的等级购买规则
@property (nonatomic, assign) BOOL isMatchBuy;
// 是否选中同意选项
@property (nonatomic, assign) BOOL isSelectLimit;
// 是否超出投资限制
@property (nonatomic, assign) BOOL isExceedLimitInvest;
@property (nonatomic,strong) UITableView *hxbBaseVCScrollView;
@property (nonatomic,copy) void(^trackingScrollViewBlock)(UIScrollView *scrollView);
@property (nonatomic, strong) HXBTransactionPasswordView *passwordView;

@property (nonatomic, strong) HXBFinLoanBuyViewModel *viewModel;

@end

@implementation HXBFin_Loan_Buy_ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isColourGradientNavigationBar = YES;
    _discountTitle = @"暂无可用优惠券";
    _balanceTitle = @"可用余额";
    kWeakSelf
    _viewModel = [[HXBFinLoanBuyViewModel alloc] initWithBlock:^UIView *{
        if (weakSelf.presentedViewController) {
            return weakSelf.presentedViewController.view;
        } else {
            return weakSelf.view;
        }
    }];
    _isMatchBuy = [self.userInfoViewModel.userInfoModel.userAssets.userRisk containsObject:self.riskType];
    _balanceMoneyStr = self.userInfoViewModel.userInfoModel.userAssets.availablePoint;
    
    [self buildUI];
    [self changeItemWithInvestMoney:_inputMoneyStr];
    self.bottomView.addBtnIsUseable = _inputMoneyStr.length;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    self.isSelectLimit = NO;
    [self getBankCardLimit];
    
}

- (void)dealloc {
    [self.hxbBaseVCScrollView.panGestureRecognizer removeObserver: self forKeyPath:@"state"];
    NSLog(@"✅被销毁 %@",self);
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    
    if ([keyPath isEqualToString:@"state"]) {
        NSNumber *tracking = change[NSKeyValueChangeNewKey];
        if (tracking.integerValue == UIGestureRecognizerStateBegan && self.trackingScrollViewBlock) {
            self.trackingScrollViewBlock(self.hxbBaseVCScrollView);
        }
        return;
    }
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:nil];
}

- (void)buildUI {
    self.hxbBaseVCScrollView = [[UITableView alloc] initWithFrame:CGRectMake(0, HXBStatusBarAndNavigationBarHeight, kScreenWidth, kScreenHeight - HXBStatusBarAndNavigationBarHeight) style:(UITableViewStylePlain)];

    self.hxbBaseVCScrollView.backgroundColor = kHXBColor_BackGround;
    self.hxbBaseVCScrollView.tableFooterView = [self footTableView];
    self.hxbBaseVCScrollView.tableHeaderView = self.topView;
    self.hxbBaseVCScrollView.hidden = YES;
    self.hxbBaseVCScrollView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.hxbBaseVCScrollView.panGestureRecognizer addObserver:self forKeyPath:@"state" options:NSKeyValueObservingOptionNew context:nil];
    self.hxbBaseVCScrollView.delegate = self;
    self.hxbBaseVCScrollView.dataSource = self;
    self.hxbBaseVCScrollView.rowHeight = kScrAdaptationH750(110.5);
    [self.view addSubview:self.hxbBaseVCScrollView];
    [self.hxbBaseVCScrollView reloadData];
}

- (void)changeItemWithInvestMoney:(NSString *)investMoney {
    [self isMatchToBuyWithMoney:investMoney];
    self.topView.hiddenMoneyLabel = !self.cardModel.bankType;
    _handleDetailTitle = [NSString stringWithFormat:@"%.2f", investMoney.doubleValue];
    _inputMoneyStr = investMoney;
    double rechargeMoney = investMoney.doubleValue - _balanceMoneyStr.doubleValue;
    if (rechargeMoney > 0.00) { // 余额不足的情况
        if ([self.userInfoViewModel.userInfoModel.userInfo.hasBindCard isEqualToString:@"1"]) {
            self.bottomView.clickBtnStr = [NSString stringWithFormat:@"充值%.2f元并出借", rechargeMoney];
        } else {
            self.bottomView.clickBtnStr = bankString;
        }
        _balanceTitle = @"可用余额（余额不足）";
    } else {
        self.bottomView.clickBtnStr = @"立即出借";
        _balanceTitle = @"可用余额";
    }
    [self setUpArray];
}

// 购买散标
- (void)requestForLoan {
    if (_availablePoint.integerValue == 0) {
        self.topView.totalMoney = @"";
        _inputMoneyStr = @"";
        [self setUpArray];
        if (self.isExceedLimitInvest && !_isSelectLimit) {
            [HxbHUDProgress showTextWithMessage:@"请勾选同意风险提示"];
            return;
        }
        [HxbHUDProgress showTextWithMessage:@"已超可加入金额"];
        return;
    }
    if (_inputMoneyStr.length == 0) {
        [HxbHUDProgress showTextWithMessage:@"请输入出借金额"];
    } else if (_inputMoneyStr.floatValue > _availablePoint.floatValue) {
        self.topView.totalMoney = [NSString stringWithFormat:@"%.lf", _availablePoint.doubleValue];
        _inputMoneyStr = [NSString stringWithFormat:@"%.lf", _availablePoint.doubleValue];
        [self changeItemWithInvestMoney:_inputMoneyStr];
        [self setUpArray];
        [HxbHUDProgress showTextWithMessage:@"已超过剩余金额"];
    } else if (_inputMoneyStr.floatValue < _minRegisterAmount.floatValue) {
        _topView.totalMoney = [NSString stringWithFormat:@"%ld", (long)_minRegisterAmount.integerValue];
        _inputMoneyStr = _minRegisterAmount;
        [self changeItemWithInvestMoney:_inputMoneyStr];
        [self setUpArray];
        [HxbHUDProgress showTextWithMessage:@"出借金额不足起投金额"];
    } else {
        BOOL isFitToBuy = ((_inputMoneyStr.integerValue - _minRegisterAmount.integerValue) % _registerMultipleAmount.integerValue) ? NO : YES;
        if (isFitToBuy) {
            if (self.isExceedLimitInvest && !_isSelectLimit) {
                [HxbHUDProgress showTextWithMessage:@"请勾选同意风险提示"];
                return;
            }
            [self chooseBuyTypeWithSting:_btnLabelText];
        } else {
            [HxbHUDProgress showTextWithMessage:[NSString stringWithFormat:@"金额需为%@的整数倍", self.registerMultipleAmount]];
        }
    }
}

// 判断是什么投资类型（充值购买，余额购买、未绑卡）
- (void)chooseBuyTypeWithSting:(NSString *)buyType {
    kWeakSelf
    if ([buyType containsString:@"充值"]) {
        [self fullAddtionFunc];
    } else if ([buyType isEqualToString:bankString]) {
        HxbWithdrawCardViewController *withdrawCardViewController = [[HxbWithdrawCardViewController alloc] init];
        withdrawCardViewController.block = ^(BOOL isBlindSuccess) {
            if (isBlindSuccess) {
                weakSelf.hasBindCard = @"1";
                [weakSelf getNewUserInfo];
            } else {
                weakSelf.hasBindCard = @"0";
            }
        };
        withdrawCardViewController.title = @"绑卡";
        withdrawCardViewController.type = HXBRechargeAndWithdrawalsLogicalJudgment_Other;
        [self.navigationController pushViewController:withdrawCardViewController animated:YES];
    } else {
        [self alertPassWord];
    }
}

// 获取用户信息
- (void)getNewUserInfo {
    kWeakSelf
    [self.viewModel downLoadUserInfo:NO resultBlock:^(BOOL isSuccess) {
        if(isSuccess) {
            weakSelf.userInfoViewModel = weakSelf.viewModel.userInfoModel;
            weakSelf.balanceMoneyStr = weakSelf.userInfoViewModel.userInfoModel.userAssets.availablePoint;
            [weakSelf.hxbBaseVCScrollView reloadData];
            [weakSelf changeItemWithInvestMoney:weakSelf.inputMoneyStr];
        }
        else {
            [weakSelf changeItemWithInvestMoney:weakSelf.inputMoneyStr];
        }
    }];
}

- (void)fullAddtionFunc {
    kWeakSelf
    double topupMoney = [_inputMoneyStr doubleValue] - [_balanceMoneyStr doubleValue];
    NSString *rechargeMoney =_userInfoViewModel.userInfoModel.userInfo.minChargeAmount_new;
    if (topupMoney < _userInfoViewModel.userInfoModel.userInfo.minChargeAmount) {
        HXBGeneralAlertVC *alertVC = [[HXBGeneralAlertVC alloc] initWithMessageTitle:@"" andSubTitle:[NSString stringWithFormat:@"单笔充值最低金额%@元，\n是否确认充值？", rechargeMoney] andLeftBtnName:@"取消" andRightBtnName:@"确认充值" isHideCancelBtn:YES isClickedBackgroundDiss:NO];
        alertVC.isCenterShow = YES;
        [alertVC setRightBtnBlock:^{
            [weakSelf sendSmsCodeWithMoney:weakSelf.userInfoViewModel.userInfoModel.userInfo.minChargeAmount];
        }];
        [self presentViewController:alertVC animated:NO completion:nil];
    } else {
        [self sendSmsCodeWithMoney:topupMoney];
    }
}

- (void)alertSmsCode {
    if (!self.presentedViewController) {
        self.alertVC = [[HXBVerificationCodeAlertVC alloc] init];
        self.alertVC.isCleanPassword = YES;
        double rechargeMoney = [_inputMoneyStr doubleValue] - [_balanceMoneyStr doubleValue];
        self.alertVC.messageTitle = @"请输入短信验证码";
        _buyType = @"recharge"; // 弹出短验，都是充值购买
        self.alertVC.subTitle = [NSString stringWithFormat:@"已发送到%@上，请查收", [self.cardModel.securyMobile replaceStringWithStartLocation:3 lenght:4]];
        kWeakSelf
        self.alertVC.sureBtnClick = ^(NSString *pwd) {
            [weakSelf.alertVC.view endEditing:YES];
            NSDictionary *dic = nil;
            dic = @{@"amount": [NSString stringWithFormat:@"%.lf", weakSelf.inputMoneyStr.doubleValue], // 强转成整数类型
                    @"buyType": weakSelf.buyType,
                    @"balanceAmount": weakSelf.balanceMoneyStr,
                    @"willingToBuy": [NSString stringWithFormat:@"%d", _isSelectLimit],
                    @"smsCode": pwd};
            [weakSelf buyLoanWithDic:dic];
        };
        self.alertVC.getVerificationCodeBlock = ^{
            [weakSelf.alertVC.verificationCodeAlertView enabledBtns];
            [weakSelf sendSmsCodeWithMoney:rechargeMoney];
        };
        self.alertVC.getSpeechVerificationCodeBlock = ^{
            [weakSelf.alertVC.verificationCodeAlertView enabledBtns];
            //获取语音验证码 注意参数
            [weakSelf sendSmsCodeWithMoney:rechargeMoney];
        };
        self.alertVC.cancelBtnClickBlock = ^{
        };
        [self presentViewController:_alertVC animated:NO completion:nil];
    }
}

- (void)sendSmsCodeWithMoney:(double)topupMoney {
    if (self.cardModel.securyMobile.length) {
        [self alertSmsCodeWithMoney:topupMoney];
    } else {
        kWeakSelf
        [_viewModel getBankCardWithHud:YES resultBlock:^(BOOL isSuccess) {
            weakSelf.hxbBaseVCScrollView.tableHeaderView = nil;
            weakSelf.cardModel = weakSelf.viewModel.bankCardModel;
            if ([weakSelf.hasBindCard isEqualToString:@"1"]) {
                weakSelf.topView.height = kScrAdaptationH750(topView_bank_high);
                if (!weakSelf.cardModel) {
                    weakSelf.topView.cardStr = @"--限额：单笔-- 单日--";
                } else {
                    weakSelf.topView.cardStr = [NSString stringWithFormat:@"%@%@", weakSelf.cardModel.bankType, weakSelf.cardModel.quota];
                    [weakSelf alertSmsCodeWithMoney:topupMoney];
                }
                weakSelf.topView.hasBank = YES;
            } else {
                weakSelf.topView.height = kScrAdaptationH750(topView_high);
                weakSelf.topView.hasBank = NO;
            }
            weakSelf.hxbBaseVCScrollView.tableHeaderView = weakSelf.topView;
            [weakSelf.hxbBaseVCScrollView reloadData];
        }];
    }
}

- (void)alertSmsCodeWithMoney:(double)topupMoney {
    kWeakSelf
    [self.viewModel getVerifyCodeRequesWithRechargeAmount:[NSString stringWithFormat:@"%.2f", topupMoney] andWithType:@"sms" andWithAction:@"buy" andCallbackBlock:^(BOOL isSuccess, NSError *error) {
        if (isSuccess) {
            weakSelf.alertVC.subTitle = [NSString stringWithFormat:@"已发送到%@上，请查收", [weakSelf.cardModel.securyMobile replaceStringWithStartLocation:3 lenght:4]];
            [weakSelf alertSmsCode];
            [weakSelf.alertVC.verificationCodeAlertView disEnabledBtns];
        }
        else {
            [weakSelf.alertVC.verificationCodeAlertView enabledBtns];
        }
    }];
}

- (void)alertPassWord {
    kWeakSelf
    _buyType = @"balance"; // 弹出密码，都是余额购买
    self.passwordView = [[HXBTransactionPasswordView alloc] init];
    [self.passwordView showInView:self.view];
    self.passwordView.getTransactionPasswordBlock = ^(NSString *password) {
        NSDictionary *dic = nil;
        dic = @{@"amount": weakSelf.inputMoneyStr,
                @"buyType": weakSelf.buyType,
                @"tradPassword": password,
                @"willingToBuy": [NSString stringWithFormat:@"%d", _isSelectLimit]
                };
        [weakSelf buyLoanWithDic:dic];
    };
}

- (void)buyLoanWithDic:(NSDictionary *)dic {
    kWeakSelf
    [_viewModel loanBuyReslutWithLoanID:self.loanId parameter:dic resultBlock:^(BOOL isSuccess) {
        if (isSuccess) {
            HXBFBase_BuyResult_VC *loanBuySuccessVC = [[HXBFBase_BuyResult_VC alloc]init];
            loanBuySuccessVC.title = @"购买成功";
            loanBuySuccessVC.inviteButtonTitle = weakSelf.viewModel.resultModel.inviteActivityDesc;
            loanBuySuccessVC.isShowInviteBtn = weakSelf.viewModel.resultModel.isInviteActivityShow;
            loanBuySuccessVC.imageName = @"successful";
            loanBuySuccessVC.buy_title = @"投标成功";
            loanBuySuccessVC.buy_description = @"放款前系统将会冻结您的出借金额，放款成功后开始计息";
            loanBuySuccessVC.buy_ButtonTitle = @"查看我的出借";
            [loanBuySuccessVC clickButtonWithBlock:^{
                [[NSNotificationCenter defaultCenter] postNotificationName:kHXBNotification_ShowMYVC_LoanList object:nil];
                [weakSelf.navigationController popToRootViewControllerAnimated:YES];
            }];
            [weakSelf.alertVC dismissViewControllerAnimated:NO completion:nil];
            [weakSelf.navigationController pushViewController:loanBuySuccessVC animated:YES];
        } else {
            HXBFBase_BuyResult_VC *failViewController = [[HXBFBase_BuyResult_VC alloc] init];
            failViewController.title = @"出借失败";
            switch (weakSelf.viewModel.errorCode) {
                case kBuy_Result:
                    failViewController.imageName = @"failure";
                    failViewController.buy_title = @"出借失败";
                    failViewController.buy_description = weakSelf.viewModel.errorMessage;
                    failViewController.buy_ButtonTitle = @"重新出借";
                    break;
                    
                case kBuy_Processing:
                    failViewController.imageName = @"outOffTime";
                    failViewController.buy_title = @"处理中";
                    failViewController.buy_description = weakSelf.viewModel.errorMessage;
                    failViewController.buy_ButtonTitle = @"重新出借";
                    break;
                    
                default:
                    [weakSelf.passwordView clearUpPassword];
                    return;
            }
            [failViewController clickButtonWithBlock:^{
                [weakSelf.navigationController popToRootViewControllerAnimated:YES];  //跳回理财页面
            }];
            [weakSelf.alertVC dismissViewControllerAnimated:NO completion:nil];
            [weakSelf.navigationController pushViewController:failViewController animated:YES];
        }
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _titleArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *const identifier = @"identifer";
    HXBFin_creditorChange_TableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[HXBFin_creditorChange_TableViewCell alloc] initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.hasBestCoupon = NO;
    cell.isStartAnimation = NO;
    if (indexPath.row == 0) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.isDiscountRow = YES;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.isDiscountRow = NO;
    }
    cell.titleStr = _titleArray[indexPath.row];
    cell.detailStr = _detailArray[indexPath.row];
    if (indexPath.row == _titleArray.count - 1) {
        cell.isHeddenHine = YES;
    } else {
        cell.isHeddenHine = NO;
        if (_titleArray.count == 1) {
            cell.isHeddenHine  = YES;
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 0) {
        HXBChooseDiscountCouponViewController *chooseDiscountVC = [[HXBChooseDiscountCouponViewController alloc] init];
        chooseDiscountVC.delegate = self;
        chooseDiscountVC.planid = @"";
        chooseDiscountVC.investMoney = _inputMoneyStr ? _inputMoneyStr : @"";
        chooseDiscountVC.type = @"plan";
        chooseDiscountVC.couponid = @"";
        [self.navigationController pushViewController:chooseDiscountVC animated:YES];
    }
}

- (void)chooseDiscountCouponViewController:(HXBChooseDiscountCouponViewController *)chooseDiscountCouponViewController didSendModel:(HXBCouponModel *)model {
}

// 获取银行限额
static const NSInteger topView_bank_high = 300;
static const NSInteger topView_high = 230;
- (void)getBankCardLimit {
    if ([self.hasBindCard isEqualToString:@"1"]) {
        self.topView.height = kScrAdaptationH750(topView_bank_high);
        kWeakSelf
        [_viewModel getBankCardWithHud:YES resultBlock:^(BOOL isSuccess) {
            if (isSuccess) {
                weakSelf.cardModel = weakSelf.viewModel.bankCardModel;
                if (!weakSelf.cardModel) {
                    weakSelf.topView.cardStr = @"--限额：单笔-- 单日--";
                } else {
                    weakSelf.topView.cardStr = [NSString stringWithFormat:@"%@%@", weakSelf.cardModel.bankType, weakSelf.cardModel.quota];
                }
                [weakSelf changeItemWithInvestMoney:weakSelf.inputMoneyStr];
                [weakSelf setUpArray];
                weakSelf.topView.hasBank = YES;
                weakSelf.hxbBaseVCScrollView.tableHeaderView = weakSelf.topView;
                [weakSelf.hxbBaseVCScrollView reloadData];
                weakSelf.hxbBaseVCScrollView.hidden = NO;
            }
        }];
    } else {
        self.topView.height = kScrAdaptationH750(topView_high);
        self.topView.hasBank = NO;
        self.hxbBaseVCScrollView.tableHeaderView = self.topView;
        [self changeItemWithInvestMoney:_inputMoneyStr];
        [self setUpArray];
        [self.hxbBaseVCScrollView reloadData];
        self.hxbBaseVCScrollView.hidden = NO;
    }
}

- (void)setUpArray {
    self.titleArray = @[@"优惠券", @"支付金额", _balanceTitle];
    self.detailArray = @[_discountTitle,  [NSString hxb_getPerMilWithDouble: _handleDetailTitle.doubleValue],  [NSString hxb_getPerMilWithDouble: _balanceMoneyStr.doubleValue]];
    [self.hxbBaseVCScrollView reloadData];
}



- (NSArray *)titleArray {
    if (!_titleArray) {
        _titleArray = [NSArray array];
    }
    return _titleArray;
}

- (NSArray *)detailArray {
    if (!_detailArray) {
        _detailArray = [NSArray array];
    }
    return _detailArray;
}

- (UIView *)topView {
    kWeakSelf
    if (!_topView) {
        _topView = [[HXBCreditorChangeTopView alloc] initWithFrame:CGRectZero];
        _topView.isHiddenBtn = NO;
        _topView.hiddenProfitLabel = YES;
        _topView.keyboardType = UIKeyboardTypeNumberPad;
        _topView.creditorMoney = [NSString stringWithFormat:@"散标剩余金额%@", [NSString hxb_getPerMilWithIntegetNumber:_availablePoint.doubleValue]];
        _topView.placeholderStr = _placeholderStr;
        
        // 输入框值变化
        _topView.changeBlock = ^(NSString *text) {
            [weakSelf investMoneyTextFieldText:text];
        };
        // 点击一键购买执行的方法
        _topView.block = ^{
            if (weakSelf.availablePoint.doubleValue == 0) {
                [HxbHUDProgress showTextWithMessage:@"投标金额已达上限"];
                weakSelf.topView.disableKeyBorad = YES;
            } else {
                NSString *topupStr = weakSelf.availablePoint;
                weakSelf.topView.totalMoney = [NSString stringWithFormat:@"%.lf", topupStr.floatValue];
                weakSelf.inputMoneyStr = topupStr;
                weakSelf.handleDetailTitle = topupStr;
                weakSelf.bottomView.addBtnIsUseable = topupStr.length;
                [weakSelf changeItemWithInvestMoney:topupStr];
                [weakSelf setUpArray];
            }
        };
    }
    return _topView;
}

- (void)investMoneyTextFieldText:(NSString *)text {
    self.bottomView.addBtnIsUseable = text.length;
    BOOL isFitToBuy = ((text.integerValue - self.minRegisterAmount.integerValue) % self.registerMultipleAmount.integerValue) ? NO : YES;
    if (text.doubleValue >= self.minRegisterAmount.doubleValue && text.doubleValue <= self.availablePoint.doubleValue && isFitToBuy) {
        [self changeItemWithInvestMoney:text];
        [self setUpArray];
    } else {
        self.discountTitle = @"未使用";
        self.handleDetailTitle = text;
        [self changeItemWithInvestMoney:text];
        [self setUpArray];
    }
}

// 根据金额匹配是否展示风险协议
- (void)isMatchToBuyWithMoney:(NSString *)money {
    self.isSelectLimit = NO;
    if (_isMatchBuy) {
        self.bottomView.isShowRiskView = (money.doubleValue > self.userInfoViewModel.userInfoModel.userAssets.userRiskAmount.doubleValue - self.userInfoViewModel.userInfoModel.userAssets.holdingAmount);
        self.isExceedLimitInvest = (money.doubleValue > self.userInfoViewModel.userInfoModel.userAssets.userRiskAmount.doubleValue - self.userInfoViewModel.userInfoModel.userAssets.holdingAmount);
    } else {
        self.bottomView.isShowRiskView = YES;
        self.isExceedLimitInvest = YES;
    }
}


- (UIView *)footTableView {
    kWeakSelf
    _bottomView = [[HXBCreditorChangeBottomView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScrAdaptationH(200))];
    _bottomView.delegateLabelText = @"借款合同》,《网络借贷协议书";
    _bottomView.delegateBlock = ^(NSInteger index) {
        if (index == 1) {
            [HXBBaseWKWebViewController pushWithPageUrl:[NSString splicingH5hostWithURL:kHXB_Negotiate_ServeLoanURL] fromController:weakSelf];
        } else {
            [HXBBaseWKWebViewController pushWithPageUrl:[NSString splicingH5hostWithURL:kHXB_Agreement_Hint] fromController:weakSelf];
        }
    };
    _bottomView.riskBlock = ^(BOOL selectStatus) {
        weakSelf.isSelectLimit = selectStatus;
    };
    _bottomView.addBlock = ^(NSString *investMoney) {
        weakSelf.btnLabelText = investMoney;
        [weakSelf.topView endEditing:YES];
        [weakSelf requestForLoan];
    };
    return _bottomView;
}

@end