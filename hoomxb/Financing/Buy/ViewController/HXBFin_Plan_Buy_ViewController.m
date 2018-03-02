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
#import "HXBModifyTransactionPasswordViewController.h"
#import "HxbWithdrawCardViewController.h"
#import "HXBFin_LoanTruansfer_BuyResoutViewModel.h"
#import "HXBChooseDiscountCouponViewController.h"
#import "HXBChooseCouponViewModel.h"
#import "HXBCouponModel.h"
#import "HXBTransactionPasswordView.h"
#import "HXBRootVCManager.h"
static NSString *const bankString = @"绑定银行卡";

@interface HXBFin_Plan_Buy_ViewController ()<UITableViewDelegate, UITableViewDataSource, HXBChooseDiscountCouponViewControllerDelegate>
@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic, strong) HXBTransactionPasswordView *passwordView;
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
/** 投资金额 */
@property (nonatomic, copy) NSString *inputMoneyStr;
/** 可用余额 */
@property (nonatomic, copy) NSString *balanceMoneyStr;
/** 预期收益 */
@property (nonatomic, copy) NSString *profitMoneyStr;
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
// 是否是从上个页面带入的金额，是的话不校验金额，不是的话，校验金额
@property (nonatomic, assign) BOOL hasInvestMoney;
// 当前输入框的金额
@property (nonatomic, assign) double curruntInvestMoney;
// 展示HUD
@property (nonatomic, strong) HxbHUDProgress *hud;
// 是否超出投资限制
@property (nonatomic, assign) BOOL isExceedLimitInvest;
// 是否选中同意选项
@property (nonatomic, assign) BOOL isSelectLimit;
// 是否符合标的等级购买规则
//@property (nonatomic, assign) BOOL isMatchBuy;
@property (nonatomic, strong) HXBFin_Buy_ViewModel *viewModel;
@end

@implementation HXBFin_Plan_Buy_ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.isColourGradientNavigationBar = YES;
    
    _couponTitle = @"优惠券";
    _discountTitle = @"";
    _balanceTitle = @"可用余额";
    _hud = [[HxbHUDProgress alloc] init];
    
    
//    _isMatchBuy = [self.userInfoViewModel.userInfoModel.userAssets.userRisk containsObject:self.riskType]; // 2.5.0版本暂时取消风险等级判断
    _balanceMoneyStr = self.userInfoViewModel.userInfoModel.userAssets.availablePoint;
    
    [self buildUI];
    [self unavailableMoney];
    [self hasBestCouponRequest];
    [self isMatchToBuyWithMoney:@"0"];
    self.bottomView.addBtnIsUseable = _inputMoneyStr.length;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    self.isSelectLimit = NO;
    [self getBankCardLimit];
}

- (void)buildUI {
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, HXBStatusBarAndNavigationBarHeight, kScreenWidth, kScreenHeight - HXBStatusBarAndNavigationBarHeight) style:(UITableViewStylePlain)];

    self.tableView.backgroundColor = kHXBColor_BackGround;
    self.tableView.hidden = YES;
    self.tableView.tableFooterView = [self footTableView];
    self.tableView.tableHeaderView = self.topView;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = kScrAdaptationH750(110.5);
    [self.view addSubview:self.tableView];
    [self.tableView reloadData];
    
    if (self.isNewPlan) {
        UIFont *font = kHXBFont_PINGFANGSC_REGULAR_750(24);
        NSMutableAttributedString *attrText = [[NSMutableAttributedString alloc] initWithString:@"温馨提示：" attributes:@{NSForegroundColorAttributeName: RGB(115, 173, 255)}];
        [attrText appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"新手产品每人加入上限%@元", self.NewPlanJoinLimit] attributes:@{NSForegroundColorAttributeName: COR8}]];
        CGFloat tipHeigt = ceil([font lineHeight]);
        CGRect rect = CGRectMake(15, self.tableView.height - tipHeigt - 40 - HXBBottomAdditionHeight, kScreenW - 15 * 2, tipHeigt);
        UILabel * tipLabel = [[UILabel alloc] initWithFrame:rect];
        tipLabel.font = font;
        tipLabel.attributedText = attrText;
        [self.tableView addSubview:tipLabel];
    }
}


// 根据金额改变按钮文案
- (void)changeItemWithInvestMoney:(NSString *)investMoney {
    self.topView.hiddenMoneyLabel = !self.cardModel.bankType;
    _inputMoneyStr = investMoney;
    [self isMatchToBuyWithMoney:investMoney];
    double rechargeMoney = investMoney.doubleValue - _balanceMoneyStr.doubleValue - _discountMoney;
    if (rechargeMoney > 0.00) { // 余额不足的情况
        if ([self.userInfoViewModel.userInfoModel.userInfo.hasBindCard isEqualToString:@"1"]) {
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
    
    [self checkIfNeedNewPlanDatas:investMoney];
    
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
        [weakSelf getBestCouponFailWithMoney:@"0" cell:nil];
        weakSelf.discountTitle = @"暂无可用优惠券";
    }];
}

// 购买红利计划
- (void)requestForPlan {
    if (_availablePoint.integerValue == 0) {
        self.topView.totalMoney = @"";
        self.topView.profitStr = @"预期收益0.00元";
        
        if (self.isNewPlan) {
            [self.topView setProfitStr:@"0.00" andSubsidy:@"0.00"];
        }
        
        _inputMoneyStr = @"";
        [self setUpArray];
        [HxbHUDProgress showTextWithMessage:@"已超可加入金额"];
        return;
    }
    
    if (_inputMoneyStr.length == 0) {
        [HxbHUDProgress showTextWithMessage:@"请输入投资金额"];
    } else if (_inputMoneyStr.floatValue > _availablePoint.floatValue && !_hasInvestMoney) { // 超过可加入金额是，只check，不用强制到最大可加入金额
        [HxbHUDProgress showTextWithMessage:@"已超可加入金额"];
    }  else if (_inputMoneyStr.floatValue < _minRegisterAmount.floatValue && !_hasInvestMoney && _isFirstBuy) {
        _topView.totalMoney = [NSString stringWithFormat:@"%ld", (long)_minRegisterAmount.integerValue];
        _inputMoneyStr = _minRegisterAmount;
        _profitMoneyStr = [NSString stringWithFormat:@"%.2f", _minRegisterAmount.floatValue*self.totalInterest.floatValue/100.0];
        _curruntInvestMoney =_inputMoneyStr.doubleValue;
        [self getBESTCouponWithMoney:_inputMoneyStr];
        _topView.profitStr = [NSString stringWithFormat:@"预期收益%@元", _profitMoneyStr];
        
        [self checkIfNeedNewPlanDatas:_inputMoneyStr];
        
        [HxbHUDProgress showTextWithMessage:@"投资金额不足起投金额"];
    } else if (_inputMoneyStr.floatValue < _registerMultipleAmount.floatValue && !_hasInvestMoney && !_isFirstBuy) {
        _topView.totalMoney = [NSString stringWithFormat:@"%ld", (long)_registerMultipleAmount.integerValue];
        _inputMoneyStr = _registerMultipleAmount;
        _profitMoneyStr = [NSString stringWithFormat:@"%.2f", _registerMultipleAmount.floatValue*self.totalInterest.floatValue/100.0];
        _curruntInvestMoney = _inputMoneyStr.floatValue;
        [self getBESTCouponWithMoney:_inputMoneyStr];
        _topView.profitStr = [NSString stringWithFormat:@"预期收益%@元", _profitMoneyStr];
        [self checkIfNeedNewPlanDatas:_inputMoneyStr];
        [HxbHUDProgress showTextWithMessage:@"投资金额不足递增金额"];
    } else {
        BOOL isFitToBuy;
        if (_isFirstBuy) {
            isFitToBuy = ((_inputMoneyStr.integerValue - _minRegisterAmount.integerValue) % _registerMultipleAmount.integerValue) ? NO : YES;
        } else {
            isFitToBuy = _inputMoneyStr.integerValue % _registerMultipleAmount.integerValue ? NO : YES;
        }
        if (_hasInvestMoney) {
            if (self.isExceedLimitInvest && !_isSelectLimit) {
                [HxbHUDProgress showTextWithMessage:@"请勾选同意风险提示"];
                return;
            }
            [self chooseBuyTypeWithSting:_btnLabelText];
        } else {
            if (isFitToBuy) {
                if (self.isExceedLimitInvest &&!_isSelectLimit) {
                    [HxbHUDProgress showTextWithMessage:@"请勾选同意风险提示"];
                    return;
                }
                [self chooseBuyTypeWithSting:_btnLabelText];
            } else {
                [HxbHUDProgress showTextWithMessage:[NSString stringWithFormat:@"金额需为%@的整数倍", self.registerMultipleAmount]];
            }
        }
    }
}

- (void)checkIfNeedNewPlanDatas:(NSString *)baseMoney {
    if (self.isNewPlan) {
        CGFloat subsidy = baseMoney.floatValue * self.expectedSubsidyInterestAmount.floatValue * 0.01;
        NSString *subsidyString = [NSString stringWithFormat:@"%.2f", subsidy];
        _profitMoneyStr = [NSString stringWithFormat:@"%.2f", baseMoney.floatValue*self.totalInterest.floatValue/100.0 + subsidy];
        [_topView setProfitStr:_profitMoneyStr andSubsidy:subsidyString];
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

- (void)fullAddtionFunc {
    kWeakSelf
    double topupMoney = [_inputMoneyStr doubleValue] - [_balanceMoneyStr doubleValue] - _discountMoney;
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

- (void)sendSmsCodeWithMoney:(double)topupMoney {
    kWeakSelf
    if (self.cardModel.securyMobile.length) {
        [self alertSmsCodeWithMoney:topupMoney];
    } else {
        [HXBFin_Buy_ViewModel requestForBankCardSuccessBlock:^(HXBBankCardModel *model) {
            weakSelf.tableView.tableHeaderView = nil;
            weakSelf.cardModel = model;
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
            weakSelf.tableView.tableHeaderView = weakSelf.topView;
            [weakSelf.tableView reloadData];
        }];
    }
}

- (void)alertSmsCodeWithMoney:(double)topupMoney {
    kWeakSelf
    [self.viewModel getVerifyCodeRequesWithRechargeAmount:[NSString stringWithFormat:@"%.2f", topupMoney] andWithType:@"sms" andWithAction:@"buy" andCallbackBlock:^(BOOL isSuccess, NSError *error) {
        if (isSuccess) {
            weakSelf.alertVC.subTitle = [NSString stringWithFormat:@"已发送到%@上，请查收", [weakSelf.cardModel.securyMobile replaceStringWithStartLocation:3 lenght:4]];
            [weakSelf showRechargeAlertVC];
            [weakSelf.alertVC.verificationCodeAlertView disEnabledBtns];
        }
        else {
           [weakSelf.alertVC.verificationCodeAlertView enabledBtns];
        }
    }];
}

- (void)showRechargeAlertVC {
    if (!self.presentedViewController) {
        self.alertVC = [[HXBVerificationCodeAlertVC alloc] init];
        self.alertVC.isCleanPassword = YES;
        double rechargeMoney = [_inputMoneyStr doubleValue] - [_balanceMoneyStr doubleValue] - _discountMoney;
        self.alertVC.messageTitle = @"请输入短信验证码";
        _buyType = @"recharge"; // 弹出短验，都是充值购买
        self.alertVC.subTitle = [NSString stringWithFormat:@"已发送到%@上，请查收", [self.cardModel.securyMobile replaceStringWithStartLocation:3 lenght:4]];
        kWeakSelf
        self.alertVC.sureBtnClick = ^(NSString *pwd) {
            [weakSelf.alertVC.view endEditing:YES];
            NSDictionary *dic = nil;
            dic = @{@"amount": weakSelf.inputMoneyStr,
                    @"cashType": weakSelf.cashType,
                    @"buyType": weakSelf.buyType,
                    @"balanceAmount": weakSelf.balanceMoneyStr,
                    @"smsCode": pwd,
                    @"willingToBuy": [NSString stringWithFormat:@"%d", _isSelectLimit],
                    @"couponId": weakSelf.couponid
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
                @"willingToBuy": [NSString stringWithFormat:@"%d", _isSelectLimit],
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
        // 投资成功，返回是否展示邀请好友按钮
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
        chooseDiscountVC.couponid = self.isNewPlan ? @"0" : _couponid;
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
    self.bottomView.addBtnIsUseable = YES;
    [self changeItemWithInvestMoney:_inputMoneyStr];
    [self setUpArray];
}

// 获取银行限额
static const NSInteger topView_bank_high = 370;
static const NSInteger topView_high = 300;
- (void)getBankCardLimit {
    if ([self.hasBindCard isEqualToString:@"1"]) {
        self.topView.height = kScrAdaptationH750(topView_bank_high);
        kWeakSelf
        [HXBFin_Buy_ViewModel requestForBankCardSuccessBlock:^(HXBBankCardModel *model) {
            weakSelf.cardModel = model;
            if (!weakSelf.cardModel) {
                weakSelf.topView.cardStr = @"--限额：单笔-- 单日--";
            } else {
                weakSelf.topView.cardStr = [NSString stringWithFormat:@"%@%@", weakSelf.cardModel.bankType, weakSelf.cardModel.quota];
            }
            [weakSelf changeItemWithInvestMoney:weakSelf.inputMoneyStr];
            weakSelf.tableView.hidden = NO;
            weakSelf.topView.hasBank = YES;
            weakSelf.tableView.tableHeaderView = weakSelf.topView;
            [weakSelf setUpArray];
            [weakSelf.tableView reloadData];
        }];
    } else {
        self.topView.height = kScrAdaptationH750(topView_high);
        self.topView.hasBank = NO;
        self.tableView.tableHeaderView = self.topView;
        [self changeItemWithInvestMoney:_inputMoneyStr];
        [self setUpArray];
        self.tableView.hidden = NO;
        [self.tableView reloadData];
    }
}

// 匹配最优优惠券
- (void)getBESTCouponWithMoney:(NSString *)money {
    NSDictionary *dic_post = @{
                               @"id": _loanId,
                               @"amount": money,
                               @"type": @"plan"
                               };
    HXBFin_creditorChange_TableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    cell.isStartAnimation = YES;
    _hasGetCoupon = YES;
    self.bottomView.addBtnIsUseable = NO;
    kWeakSelf
    [HXBChooseCouponViewModel requestBestCouponWithParams:dic_post andSuccessBlock:^(HXBBestCouponModel *model) {
        cell.isStartAnimation = NO;
        if (_curruntInvestMoney == money.doubleValue) {
            [weakSelf requestSuccessWithModel:model cell:cell money:money ];
        }
    } andFailureBlock:^(NSError *error) {
        [weakSelf getBestCouponFailWithMoney:money cell:cell];
        weakSelf.discountTitle = @"请选择优惠券";
        [weakSelf changeItemWithInvestMoney:money];
    }];
}

// 获取用户信息
- (void)getNewUserInfo {
    kWeakSelf
    [self.viewModel downLoadUserInfo:NO resultBlock:^(BOOL isSuccess) {
        if(isSuccess) {
            weakSelf.userInfoViewModel = weakSelf.viewModel.userInfoModel;
            weakSelf.balanceMoneyStr = weakSelf.userInfoViewModel.userInfoModel.userAssets.availablePoint;
            [weakSelf.tableView reloadData];
            [weakSelf changeItemWithInvestMoney:weakSelf.inputMoneyStr];
        }
        else {
            [weakSelf changeItemWithInvestMoney:weakSelf.inputMoneyStr];
        }
    }];
}

// 未匹配到优惠券调用方法
- (void)getBestCouponFailWithMoney:(NSString *)money cell:(HXBFin_creditorChange_TableViewCell *)cell {
    self.hasBestCoupon = NO;
    self.hasGetCoupon = NO;
    cell.isStartAnimation = NO;
    self.bottomView.addBtnIsUseable = YES;
    self.couponTitle = @"优惠券";
    self.discountMoney = 0;
    self.handleDetailTitle = money;
}

- (void)requestSuccessWithModel:(HXBBestCouponModel *)model cell:(HXBFin_creditorChange_TableViewCell *)cell money: (NSString *)money {
    
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
            _hasInvestMoney = YES;
            _curruntInvestMoney = _inputMoneyStr.doubleValue;
            [self getBESTCouponWithMoney:_inputMoneyStr];
        } else {
            _hasInvestMoney = NO;
            _topView.disableKeyBorad = NO;
        }
    } else {
        if (self.availablePoint.doubleValue < self.registerMultipleAmount.doubleValue) {
            _topView.totalMoney = [NSString stringWithFormat:@"%.lf", self.availablePoint.doubleValue];
            _inputMoneyStr = [NSString stringWithFormat:@"%.lf", self.availablePoint.doubleValue];
            _topView.disableKeyBorad = YES;
            _hasInvestMoney = YES;
            _curruntInvestMoney = _inputMoneyStr.doubleValue;
            [self getBESTCouponWithMoney:_inputMoneyStr];
        } else {
            _hasInvestMoney = NO;
            _topView.disableKeyBorad = NO;
        }
    }
}

- (void)setUpArray {
    _profitMoneyStr = _profitMoneyStr ? _profitMoneyStr : @"";
    self.titleArray = @[_couponTitle, @"支付金额", _balanceTitle];
    if (self.isNewPlan) {
        _discountTitle = @"暂无可用优惠券";
    }
    self.detailArray = @[_discountTitle,  [NSString hxb_getPerMilWithDouble: _handleDetailTitle.doubleValue],  [NSString hxb_getPerMilWithDouble: _balanceMoneyStr.doubleValue]];
    [self.tableView reloadData];
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
        _topView.profitType = _featuredSlogan;
        // 输入框值变化
        _topView.changeBlock = ^(NSString *text) {
            [weakSelf investMoneyTextFieldText:text];
        };
        // 点击一键购买执行的方法
        _topView.block = ^{
        };
        
        _topView.isNewPlan = self.isNewPlan;
        if (self.isNewPlan) {
            _topView.creditorMoney = [NSString stringWithFormat:@"新手产品剩余可购买金额%@", [NSString hxb_getPerMilWithIntegetNumber:_availablePoint.doubleValue]];
            _topView.alertTipBlock = ^{
                HXBXYAlertViewController *alertVC = [[HXBXYAlertViewController alloc] initWithTitle:@"温馨提示" Massage:@"加息收益将在计划退出时发放至您的账户" force:2 andLeftButtonMassage:nil andRightButtonMassage:@"确定"];
                alertVC.isHIddenLeftBtn = YES;
                alertVC.isCenterShow = YES;
                [weakSelf presentViewController:alertVC animated:YES completion:nil];
                
            };
            
            [_topView setProfitStr:@"0.00" andSubsidy:@"0.00"];
        }
        _topView.creditorMoney = [NSString stringWithFormat:@"本期剩余加入上限%@", [NSString hxb_getPerMilWithIntegetNumber:_availablePoint.doubleValue]];
        _topView.placeholderStr = _placeholderStr;
    }
    
    
    return _topView;
}

- (void)investMoneyTextFieldText:(NSString *)text {
    self.curruntInvestMoney = text.doubleValue;
    self.bottomView.addBtnIsUseable = text.length;
    BOOL isFitToBuy = NO;
    if (self.isFirstBuy) {
        isFitToBuy = ((text.integerValue - self.minRegisterAmount.integerValue) % self.registerMultipleAmount.integerValue) ? NO : YES;
    } else {
        isFitToBuy = (text.integerValue) % self.registerMultipleAmount.integerValue ? NO : YES;
    }

    // 判断是否符合购买条件
    if (text.length && text.doubleValue <= self.availablePoint.doubleValue && isFitToBuy) {
        // 判断是否超出风险
        self.couponTitle = @"优惠券";
        [self getBESTCouponWithMoney:text];
    } else {
        self.discountTitle = @"未使用";
        self.couponid = @" ";
        self.hasBestCoupon = NO;
        self.couponTitle = @"优惠券";
        self.discountMoney = 0;
        self.handleDetailTitle = text;
        [self changeItemWithInvestMoney:text];
        [self setUpArray];
    }
}

// 根据金额匹配是否展示风险协议
- (void)isMatchToBuyWithMoney:(NSString *)money {
    self.isSelectLimit = NO;
    self.bottomView.isShowRiskView = (money.doubleValue > self.userInfoViewModel.userInfoModel.userAssets.userRiskAmount.doubleValue - self.userInfoViewModel.userInfoModel.userAssets.holdingAmount);
    self.isExceedLimitInvest = (money.doubleValue > self.userInfoViewModel.userInfoModel.userAssets.userRiskAmount.doubleValue - self.userInfoViewModel.userInfoModel.userAssets.holdingAmount);
}

- (UIView *)footTableView {
    kWeakSelf
    _bottomView = [[HXBCreditorChangeBottomView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScrAdaptationH(200))];
    _bottomView.delegateLabelText = @"红利计划服务协议》,《网络借贷协议书";
    _bottomView.delegateBlock = ^(NSInteger index) {
        if (index == 1) {
            NSString *negotiate = [weakSelf.cashType isEqualToString:@"HXB"] ? [NSString splicingH5hostWithURL:kHXB_Negotiate_ServePlanMonthURL] : [NSString splicingH5hostWithURL:kHXB_Negotiate_ServePlanURL];
            [HXBBaseWKWebViewController pushWithPageUrl:negotiate fromController:weakSelf];
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
        [weakSelf requestForPlan];
    };
    return _bottomView;
}

- (HXBFin_Buy_ViewModel *)viewModel {
    if (!_viewModel) {
        kWeakSelf
        _viewModel = [[HXBFin_Buy_ViewModel alloc] initWithBlock:^UIView *{
            if (weakSelf.presentedViewController) {
                return weakSelf.presentedViewController.view;
            }
            else {
                return weakSelf.view;
            }
        }];
    }
    return _viewModel;
}

@end