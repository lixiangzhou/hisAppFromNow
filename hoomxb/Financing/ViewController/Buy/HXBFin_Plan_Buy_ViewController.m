//
//  HXBFin_Plan_Buy_ViewController.m
//  hoomxb
//
//  Created by 肖扬 on 2017/11/13.
//  Copyright © 2017年 hoomsun-miniX. All rights reserved.
//

#import "HXBFin_Plan_Buy_ViewController.h"
#import "HXBCreditorChangeTopView.h"
#import "HXBCreditorChangeBottomView.h"
#import "HXBFin_creditorChange_TableViewCell.h"
#import "HXBFinanctingRequest.h"
#import "HXBFBase_BuyResult_VC.h"
#import "HXBFin_Plan_BuyViewModel.h"
#import "HxbMyTopUpViewController.h"
#import "HXBFin_Buy_ViewModel.h"
#import "HXBVerificationCodeAlertVC.h"
#import "HXBOpenDepositAccountRequest.h"
#import "HXBModifyTransactionPasswordViewController.h"
#import "HxbWithdrawCardViewController.h"
#import "HXBFin_LoanTruansfer_BuyResoutViewModel.h"
#import "HXBChooseDiscountCouponViewController.h"
#import "HXBChooseCouponViewModel.h"
#import "HXBCouponModel.h"
#import "HXBTransactionPasswordView.h"

static NSString *const bankString = @"绑定银行卡";

@interface HXBFin_Plan_Buy_ViewController ()<UITableViewDelegate, UITableViewDataSource, HXBChooseDiscountCouponViewControllerDelegate>
/** topView */
@property (nonatomic, strong) HXBCreditorChangeTopView *topView;
/** bottomView*/
@property (nonatomic, strong) HXBCreditorChangeBottomView *bottomView;
// 我的信息
@property (nonatomic, strong) HXBRequestUserInfoViewModel *viewModel;
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
/** 预期收益 */
@property (nonatomic, copy) NSString *profitMoneyStr;
/** 还需金额 */
@property (nonatomic, copy) NSString *needMoneyStr;
/** 交易密码 */
@property (nonatomic, copy) NSString *exchangePasswordStr;
/** 短信验证码 */
@property (nonatomic, copy) NSString *smsCodeStr;
/** 点击按钮的文案 */
@property (nonatomic, copy) NSString * btnLabelText;
/** 购买类型 */
@property (nonatomic, copy) NSString *buyType; // balance recharge
/** 优惠券Title */
@property (nonatomic, copy) NSString *couponTitle;
/** 优惠券金额 */
@property (nonatomic, copy) NSString *discountTitle;
/** 应付金额detailLabel */
@property (nonatomic, copy) NSString *handleDetailTitle;
/** 可用余额TextLabel */
@property (nonatomic, copy) NSString *balanceTitle;
/** 可用余额detailLabel */
@property (nonatomic, copy) NSString *balanceDetailTitle;
/** 最优优惠券model */
@property (nonatomic, strong) HXBBestCouponModel *model;
/** 选择的优惠券model */
@property (nonatomic, strong) HXBCouponModel *chooseCoupon;
/** 是否有优惠券 */
@property (nonatomic, assign) BOOL hasCoupon;
/** 是否匹配优惠券 */
@property (nonatomic, assign) BOOL hasBestCoupon;
/** 优惠的金额 */
@property (nonatomic, assign) double discountMoney;
/** 优惠券id */
@property (nonatomic, copy) NSString *couponid;
/** 是否获取到优惠券 */
@property (nonatomic, assign) BOOL hasGetCoupon;
@property (nonatomic,strong) UITableView *hxbBaseVCScrollView;
@property (nonatomic,copy) void(^trackingScrollViewBlock)(UIScrollView *scrollView);
@property (nonatomic, strong) HXBTransactionPasswordView *passwordView;
@end

@implementation HXBFin_Plan_Buy_ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isColourGradientNavigationBar = YES;
    _couponTitle = @"优惠券";
    _discountTitle = @"";
    _balanceTitle = @"可用余额";
    [self buildUI];
    [self getBankCardLimit];
    [self hasBestCouponRequest];
    [self changeItemWithInvestMoney:_inputMoneyStr];
    self.bottomView.addBtnIsUseable = _inputMoneyStr.length;
    [self unavailableMoney];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    [self getBankCardLimit];
    [self getNewUserInfo];
}

- (void)dealloc {
    [self.hxbBaseVCScrollView.panGestureRecognizer removeObserver: self forKeyPath:@"state"];
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

static const NSInteger topView_bank_high = 370;
static const NSInteger topView_high = 300;
// 获取银行限额
- (void)getBankCardLimit {
    kWeakSelf
    [HXBFin_Buy_ViewModel requestForBankCardSuccessBlock:^(HXBBankCardModel *model) {
        weakSelf.hxbBaseVCScrollView.tableHeaderView = nil;
        weakSelf.cardModel = model;
        if (weakSelf.cardModel.bankType) {
            weakSelf.topView.height = kScrAdaptationH750(topView_bank_high);
        } else {
            weakSelf.topView.height = kScrAdaptationH750(topView_high);
        }
        weakSelf.topView.cardStr = [NSString stringWithFormat:@"%@%@", weakSelf.cardModel.bankType, weakSelf.cardModel.quota];
        weakSelf.topView.hasBank = weakSelf.cardModel.bankType ? YES : NO;
        weakSelf.hxbBaseVCScrollView.tableHeaderView = weakSelf.topView;
    }];
}

// 根据金额改变按钮文案
- (void)changeItemWithInvestMoney:(NSString *)investMoney {
    self.topView.hiddenMoneyLabel = !self.cardModel.bankType;
    _inputMoneyStr = investMoney;
    double rechargeMoney = investMoney.doubleValue - _balanceMoneyStr.doubleValue - _discountMoney;
    if (rechargeMoney > 0.00) { // 余额不足的情况
        if ([self.viewModel.userInfoModel.userInfo.hasBindCard isEqualToString:@"1"]) {
            self.bottomView.clickBtnStr = [NSString stringWithFormat:@"充值%.2f元并投资", rechargeMoney];
        } else {
            self.bottomView.clickBtnStr = bankString;
        }
        _balanceTitle = @"可用余额（余额不足）";
    } else {
        self.bottomView.clickBtnStr = @"立即加入";
        _balanceTitle = @"可用余额";
    }
    self.topView.profitStr = [NSString stringWithFormat:@"预期收益%@", [NSString hxb_getPerMilWithDouble:investMoney.floatValue*self.totalInterest.floatValue/100.0]];
    [self setUpArray];
}

- (void)hasBestCouponRequest {
    NSDictionary *dic_post = @{
                               @"id": _loanId,
                               @"amount": @"0",
                               @"type": @"plan"
                               };
    kWeakSelf
    [HXBChooseCouponViewModel requestBestCouponWithParams:dic_post andSuccessBlock:^(HXBBestCouponModel *model) {
        weakSelf.hxbBaseVCScrollView.hidden = NO;
        weakSelf.discountTitle = nil;
        weakSelf.model = model;
        weakSelf.hasCoupon = model.hasCoupon;
        if (model.hasCoupon) {
            weakSelf.discountTitle = @"请选择优惠券";
        } else {
            weakSelf.discountTitle = @"暂无可用优惠券";
        }
        [weakSelf setUpArray];
    } andFailureBlock:^(NSError *error) {
        weakSelf.discountTitle = @"暂无可用优惠券";
    }];
}

// 购买红利计划
- (void)requestForPlan {
    if (_availablePoint.integerValue == 0) {
        self.topView.totalMoney = @"";
        self.topView.profitStr = @"预期收益0.00元";
        _inputMoneyStr = @"";
        [self setUpArray];
        [HxbHUDProgress showTextWithMessage:@"已超可加入金额"];
        return;
    }
    if (_inputMoneyStr.length == 0) {
        [HxbHUDProgress showTextWithMessage:@"请输入投资金额"];
    } else if (_inputMoneyStr.floatValue > _availablePoint.floatValue) {
        self.topView.totalMoney = [NSString stringWithFormat:@"%.lf", _availablePoint.doubleValue];
        _inputMoneyStr = [NSString stringWithFormat:@"%.lf", _availablePoint.doubleValue];
        _profitMoneyStr = [NSString stringWithFormat:@"%.2f", _availablePoint.floatValue*self.totalInterest.floatValue/100.0];
        [self getBESTCouponWithMoney:_inputMoneyStr];
        _topView.profitStr = [NSString stringWithFormat:@"预期收益%@元", _profitMoneyStr];
        [HxbHUDProgress showTextWithMessage:@"已超可加入金额"];
    }  else if (_inputMoneyStr.floatValue < _minRegisterAmount.floatValue && _availablePoint.doubleValue > _minRegisterAmount.doubleValue) {
        _topView.totalMoney = [NSString stringWithFormat:@"%ld", (long)_minRegisterAmount.integerValue];
        _inputMoneyStr = _minRegisterAmount;
        _profitMoneyStr = [NSString stringWithFormat:@"%.2f", _minRegisterAmount.floatValue*self.totalInterest.floatValue/100.0];
        [self getBESTCouponWithMoney:_inputMoneyStr];
        _topView.profitStr = [NSString stringWithFormat:@"预期收益%@元", _profitMoneyStr];
        [HxbHUDProgress showTextWithMessage:@"投资金额不足起投金额"];
    } else {
        BOOL isFitToBuy = ((_inputMoneyStr.integerValue - _minRegisterAmount.integerValue) % _registerMultipleAmount.integerValue) ? NO : YES;
        if (isFitToBuy) {
            [self chooseBuyTypeWithSting:_btnLabelText];
        } else {
            [HxbHUDProgress showTextWithMessage:[NSString stringWithFormat:@"金额需为%@的整数倍", self.registerMultipleAmount]];
        }
    }
}

// 判断是什么投资类型（充值购买，余额购买、未绑卡）
- (void)chooseBuyTypeWithSting:(NSString *)buyType {
    if ([buyType containsString:@"充值"]) {
        [self fullAddtionFunc];
    } else if ([buyType isEqualToString:bankString]) {
        HxbWithdrawCardViewController *withdrawCardViewController = [[HxbWithdrawCardViewController alloc]init];
        withdrawCardViewController.title = @"绑卡";
        withdrawCardViewController.type = HXBRechargeAndWithdrawalsLogicalJudgment_Other;
        [self.navigationController pushViewController:withdrawCardViewController animated:YES];
    } else {
        [self alertPassWord];
    }
}

- (void)fullAddtionFunc {
    kWeakSelf
    double topupMoney = [_inputMoneyStr doubleValue] - [_balanceMoneyStr doubleValue] - _discountMoney;
    NSString *rechargeMoney =_viewModel.userInfoModel.userInfo.minChargeAmount_new;
    if (topupMoney < _viewModel.userInfoModel.userInfo.minChargeAmount) {
        HXBXYAlertViewController *alertVC = [[HXBXYAlertViewController alloc] initWithTitle:nil Massage:[NSString stringWithFormat:@"单笔充值最低金额%@元，\n是否确认充值？", rechargeMoney] force:2 andLeftButtonMassage:@"取消" andRightButtonMassage:@"确认充值"];
        alertVC.isCenterShow = YES;
        [alertVC setClickXYRightButtonBlock:^{
            [weakSelf sendSmsCodeWithMoney:weakSelf.viewModel.userInfoModel.userInfo.minChargeAmount];
        }];
        [self presentViewController:alertVC animated:YES completion:nil];
    } else {
        [self sendSmsCodeWithMoney:topupMoney];
    }
}

- (void)sendSmsCodeWithMoney:(double)topupMoney {
    kWeakSelf
    HXBOpenDepositAccountRequest *accountRequest = [[HXBOpenDepositAccountRequest alloc] init];
    [accountRequest accountRechargeRequestWithRechargeAmount:[NSString stringWithFormat:@"%.2f", topupMoney] andWithType:@"sms" andWithAction:@"buy" andSuccessBlock:^(id responseObject) {
        weakSelf.alertVC.subTitle = [NSString stringWithFormat:@"已发送到%@上，请查收", [weakSelf.cardModel.securyMobile replaceStringWithStartLocation:3 lenght:4]];
        [weakSelf alertSmsCode];
        [weakSelf.alertVC.verificationCodeAlertView disEnabledBtns];
    } andFailureBlock:^(NSError *error) {
        NSInteger errorCode = 0;
        if ([error isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dic = (NSDictionary *)error;
            errorCode = [dic[@"status"] integerValue];
        }else{
            errorCode = error.code;
        }
        if (errorCode != kHXBCode_Success) {
            [weakSelf.alertVC.verificationCodeAlertView enabledBtns];
        }
    }];
}

- (void)alertSmsCode {
    if (!self.presentedViewController) {
        self.alertVC = [[HXBVerificationCodeAlertVC alloc] init];
        self.alertVC.isCleanPassword = YES;
        double rechargeMoney = [_inputMoneyStr doubleValue] - [_balanceMoneyStr doubleValue] - _discountMoney;
        self.alertVC.messageTitle = @"请输入验证码";
        _buyType = @"recharge"; // 弹出短验，都是充值购买
        self.alertVC.subTitle = [NSString stringWithFormat:@"已发送到%@上，请查收", [self.cardModel.securyMobile replaceStringWithStartLocation:3 lenght:4]];
        kWeakSelf
        self.alertVC.sureBtnClick = ^(NSString *pwd) {
            [weakSelf.alertVC.view endEditing:YES];
            NSDictionary *dic = nil;
            dic = @{@"amount": _inputMoneyStr,
                    @"cashType": _cashType,
                    @"buyType": _buyType,
                    @"balanceAmount": _balanceMoneyStr,
                    @"smsCode": pwd,
                    @"couponId": _couponid
                    };
            [weakSelf buyPlanWithDic:dic];
        };
        self.alertVC.getVerificationCodeBlock = ^{
            [weakSelf.alertVC.verificationCodeAlertView enabledBtns];
            [weakSelf sendSmsCodeWithMoney:rechargeMoney];
        };
        self.alertVC.getSpeechVerificationCodeBlock = ^{
            [weakSelf.alertVC.verificationCodeAlertView enabledBtns];
            [weakSelf sendSmsCodeWithMoney:rechargeMoney];
        };
        self.alertVC.cancelBtnClickBlock = ^{
        };
        [self presentViewController:self.alertVC animated:NO completion:nil];
    }
}

- (void)alertPassWord {
    kWeakSelf
    _buyType = @"balance"; // 弹出密码，都是余额购买
    self.passwordView = [[HXBTransactionPasswordView alloc] init];
    [self.passwordView showInView:self.view];
    self.passwordView.getTransactionPasswordBlock = ^(NSString *password) {
        NSDictionary *dic = nil;
        dic = @{@"amount": weakSelf.inputMoneyStr,
                @"cashType": weakSelf.cashType,
                @"buyType": weakSelf.buyType,
                @"tradPassword": password,
                @"couponId": weakSelf.couponid
                };
        [weakSelf buyPlanWithDic:dic];
    };
}

// 购买计划
- (void)buyPlanWithDic:(NSDictionary *)dic {
    kWeakSelf
    [[HXBFinanctingRequest sharedFinanctingRequest] plan_buyReslutWithPlanID:self.loanId parameter:dic andSuccessBlock:^(HXBFinModel_BuyResoult_PlanModel *model) {
        HXBFBase_BuyResult_VC *planBuySuccessVC = [[HXBFBase_BuyResult_VC alloc]init];
        planBuySuccessVC.inviteButtonTitle = model.inviteActivityDesc;
        planBuySuccessVC.isShowInviteBtn = model.isInviteActivityShow;
        planBuySuccessVC.imageName = @"successful";
        planBuySuccessVC.buy_title = @"加入成功";
        planBuySuccessVC.buy_description =model.lockStart;
        planBuySuccessVC.buy_ButtonTitle = @"查看我的投资";
        planBuySuccessVC.title = @"投资成功";
        [planBuySuccessVC clickButtonWithBlock:^{
            [[NSNotificationCenter defaultCenter] postNotificationName:kHXBNotification_ShowMYVC_PlanList object:nil];
            [weakSelf.navigationController popToRootViewControllerAnimated:YES];
        }];
        [weakSelf.alertVC dismissViewControllerAnimated:NO completion:nil];
        [weakSelf.navigationController pushViewController:planBuySuccessVC animated:YES];
    } andFailureBlock:^(NSString *errorMessage, NSInteger status) {
        HXBFBase_BuyResult_VC *failViewController = [[HXBFBase_BuyResult_VC alloc]init];
        failViewController.title = @"投资结果";
        switch (status) {
            case kBuy_Result:
                failViewController.imageName = @"failure";
                failViewController.buy_title = @"加入失败";
                failViewController.buy_description = errorMessage;
                failViewController.buy_ButtonTitle = @"重新投资";
                
                break;

            case kBuy_Processing:
                failViewController.imageName = @"outOffTime";
                failViewController.buy_title = @"处理中";
                failViewController.buy_description = errorMessage;
                failViewController.buy_ButtonTitle = @"重新投资";
                break;
                
                // 弹toast（3014：交易密码错误， 3015：短验错误， 3413：产品购买过于频繁）
            default:
                [weakSelf.passwordView clearUpPassword];
                return;
        }
        [failViewController clickButtonWithBlock:^{
            [weakSelf.navigationController popToRootViewControllerAnimated:YES];  //跳回理财页面
        }];
        [weakSelf.alertVC dismissViewControllerAnimated:NO completion:nil];
        [weakSelf.navigationController pushViewController:failViewController animated:YES];
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
    cell.hasBestCoupon = _hasBestCoupon;
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
    if (indexPath.row == 0 && !_hasGetCoupon) {
        HXBChooseDiscountCouponViewController *chooseDiscountVC = [[HXBChooseDiscountCouponViewController alloc] init];
        chooseDiscountVC.delegate = self;
        chooseDiscountVC.planid = _loanId;
        chooseDiscountVC.investMoney = _inputMoneyStr ? _inputMoneyStr : @"";
        chooseDiscountVC.type = @"plan";
        chooseDiscountVC.couponid = _couponid;
        [self.navigationController pushViewController:chooseDiscountVC animated:YES];
    }
}

- (void)chooseDiscountCouponViewController:(HXBChooseDiscountCouponViewController *)chooseDiscountCouponViewController didSendModel:(HXBCouponModel *)model {
    if (model) {
        _discountMoney = model.valueActual.doubleValue;
        double handleMoney = _inputMoneyStr.doubleValue - model.valueActual.doubleValue;
        _discountTitle = [NSString stringWithFormat:@"-%@", [NSString hxb_getPerMilWithDouble:model.valueActual.doubleValue]];
        _handleDetailTitle = [NSString stringWithFormat:@"%.2f", handleMoney];
        _couponTitle = [NSString stringWithFormat:@"优惠券（使用%@）", model.summaryTitle];
        _hasBestCoupon = YES;
        _chooseCoupon = model;
        _couponid = model.ID;
    } else {
        _discountMoney = 0.0;
        _hasBestCoupon = NO;
        _handleDetailTitle = [NSString stringWithFormat:@"%.2f", _inputMoneyStr.doubleValue];
        _couponTitle = @"优惠券";
        _discountTitle = @"不使用优惠券";
        _couponid = @"不使用优惠券";
    }
    [self changeItemWithInvestMoney:_inputMoneyStr];
    [self setUpArray];
}



// 获取用户信息
- (void)getNewUserInfo {
    kWeakSelf
    [KeyChain downLoadUserInfoNoHUDWithSeccessBlock:^(HXBRequestUserInfoViewModel *viewModel) {
        weakSelf.hxbBaseVCScrollView.hidden = NO;
        weakSelf.viewModel = viewModel;
        weakSelf.balanceMoneyStr = weakSelf.viewModel.userInfoModel.userAssets.availablePoint;
        [weakSelf changeItemWithInvestMoney:weakSelf.inputMoneyStr];
        [weakSelf setUpArray];
        [weakSelf.hxbBaseVCScrollView reloadData];
    } andFailure:^(NSError *error) {
        [weakSelf changeItemWithInvestMoney:weakSelf.inputMoneyStr];
    }];
}

// 匹配最优优惠券
- (void)getBESTCouponWithMoney:(NSString *)money {
    NSDictionary *dic_post = @{
                               @"id": _loanId,
                               @"amount": money,
                               @"type": @"plan"
                               };
    NSIndexPath *indexpath = [NSIndexPath indexPathForRow:0 inSection:0];
    HXBFin_creditorChange_TableViewCell *cell = [self.hxbBaseVCScrollView cellForRowAtIndexPath:indexpath];
    cell.isStartAnimation = YES;
    _hasGetCoupon = YES;
    self.bottomView.addBtnIsUseable = NO;
    kWeakSelf
    [HXBChooseCouponViewModel requestBestCouponWithParams:dic_post andSuccessBlock:^(HXBBestCouponModel *model) {
        [weakSelf requestSuccessWithModel:model cell:cell money:money];
    } andFailureBlock:^(NSError *error) {
        weakSelf.hasBestCoupon = NO;
        cell.isStartAnimation = NO;
        weakSelf.discountTitle = @"请选择优惠券";
        [weakSelf setUpArray];
        [weakSelf changeItemWithInvestMoney:money];
    }];
    
}

- (void)requestSuccessWithModel:(HXBBestCouponModel *)model cell:(HXBFin_creditorChange_TableViewCell *)cell money: (NSString *)money {
    cell.isStartAnimation = NO;
    self.hasGetCoupon = NO;
    self.bottomView.addBtnIsUseable = YES;
    self.discountTitle = nil;
    self.model = model;
    if (model.hasCoupon && model.bestCoupon) { // 只有有优惠券hasCoupon都返回1，没有匹配到bestCoupon为空，所有有优惠券，且匹配到了，就抵扣或者满减
        _discountMoney = model.bestCoupon.valueActual.doubleValue;
        double handleMoney = money.doubleValue - model.bestCoupon.valueActual.doubleValue;
        _discountTitle = [NSString stringWithFormat:@"-%@", [NSString hxb_getPerMilWithDouble:model.bestCoupon.valueActual.doubleValue]];
        _handleDetailTitle = [NSString stringWithFormat:@"%.2f", handleMoney];
        _couponTitle = [NSString stringWithFormat:@"优惠券（使用%@）", model.bestCoupon.summaryTitle];
        _hasBestCoupon = YES;
        _couponid = model.bestCoupon.ID;
    } else {
        _hasBestCoupon = NO;
        _discountMoney = 0.0;
        _handleDetailTitle = money;
        _discountTitle = @"请选择优惠券";
        _couponTitle = @"优惠券";
        _couponid = @" ";
        if (!model.hasCoupon) {
            _discountTitle = @"暂无可用优惠券";
        }
    }
    [self setUpArray];
    [self changeItemWithInvestMoney:money];
}

- (void)unavailableMoney {
    // 小于最小投资金额时，输入框不可以编辑
    if (self.isFirstBuy) {
        if (self.availablePoint.doubleValue < self.minRegisterAmount.doubleValue) {
            _topView.totalMoney = [NSString stringWithFormat:@"%.lf", self.availablePoint.doubleValue];
            _inputMoneyStr = [NSString stringWithFormat:@"%.lf", self.availablePoint.doubleValue];
            _topView.disableKeyBorad = YES;
            [self getBESTCouponWithMoney:_inputMoneyStr];
        } else {
            _topView.disableKeyBorad = NO;
        }
    } else {
        if (self.availablePoint.doubleValue < self.registerMultipleAmount.doubleValue) {
            _topView.totalMoney = [NSString stringWithFormat:@"%.lf", self.availablePoint.doubleValue];
            _inputMoneyStr = [NSString stringWithFormat:@"%.lf", self.availablePoint.doubleValue];
            _topView.disableKeyBorad = YES;
            [self getBESTCouponWithMoney:_inputMoneyStr];
        } else {
            _topView.disableKeyBorad = NO;
        }
    }
}

- (void)setUpArray {
    _profitMoneyStr = _profitMoneyStr ? _profitMoneyStr : @"";
    self.titleArray = @[_couponTitle, @"支付金额", _balanceTitle];
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

- (HXBBestCouponModel *)model {
    if (!_model) {
        _model = [[HXBBestCouponModel alloc] init];
    }
    return _model;
}

- (UIView *)topView {
    kWeakSelf
    if (!_topView) {
        _topView = [[HXBCreditorChangeTopView alloc] initWithFrame:CGRectZero];
        _topView.isHiddenBtn = YES;
        _topView.profitStr = @"预期收益0.00元";
        _topView.hiddenProfitLabel = NO;
        _topView.keyboardType = UIKeyboardTypeNumberPad;
        
        _topView.changeBlock = ^(NSString *text) { // 检测输入框输入的信息
            weakSelf.bottomView.addBtnIsUseable = text.length;
            BOOL isFitToBuy = ((text.integerValue - weakSelf.minRegisterAmount.integerValue) % weakSelf.registerMultipleAmount.integerValue) ? NO : YES;
            // 判断是否符合购买条件
            if (text.doubleValue >= weakSelf.minRegisterAmount.doubleValue && text.doubleValue <= weakSelf.availablePoint.doubleValue && isFitToBuy) {
                weakSelf.couponTitle = @"优惠券";
                [weakSelf getBESTCouponWithMoney:text];
            } else {
                weakSelf.discountTitle = @"未使用";
                weakSelf.couponid = @" ";
                weakSelf.hasBestCoupon = NO;
                weakSelf.couponTitle = @"优惠券";
                weakSelf.handleDetailTitle = text;
                [weakSelf changeItemWithInvestMoney:text];
                [weakSelf setUpArray];
            }
        };
        _topView.creditorMoney = [NSString stringWithFormat:@"本期剩余加入上限%@", [NSString hxb_getPerMilWithIntegetNumber:_availablePoint.doubleValue]];
        _topView.placeholderStr = _placeholderStr;
        _topView.block = ^{ // 点击一键购买执行的方法
        };
    }
    _topView.creditorMoney = [NSString stringWithFormat:@"本期剩余加入上限%@", [NSString hxb_getPerMilWithIntegetNumber:_availablePoint.doubleValue]];
    _topView.placeholderStr = _placeholderStr;
    return _topView;
}

- (UIView *)footTableView {
    kWeakSelf
    _bottomView = [[HXBCreditorChangeBottomView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScrAdaptationH(200))];
    _bottomView.delegateLabelText = @"红利计划服务协议》,《网络借贷协议书";
    
    _bottomView.delegateBlock = ^(NSInteger index) {
        if (index == 1) {
            [HXBBaseWKWebViewController pushWithPageUrl:[NSString splicingH5hostWithURL:kHXB_Negotiate_ServePlanURL] fromController:weakSelf];
        } else {
            [HXBBaseWKWebViewController pushWithPageUrl:[NSString splicingH5hostWithURL:kHXB_Agreement_Hint] fromController:weakSelf];
        }
    };
    
    _bottomView.addBlock = ^(NSString *investMoney) {
        weakSelf.btnLabelText = investMoney;
        [weakSelf.topView endEditing:YES];
        [weakSelf requestForPlan];
    };
    return _bottomView;
}


@end
