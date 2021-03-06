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
#import "HXBFBase_BuyResult_VC.h"
#import "HxbMyTopUpViewController.h"
#import "HXBModifyTransactionPasswordViewController.h"
#import "HxbWithdrawCardViewController.h"
#import "HXBChooseDiscountCouponViewController.h"
#import "HXBTransactionPasswordView.h"
#import "HXBRootVCManager.h"
#import "HXBFinPlanBuyViewModel.h"
#import "HXBLazyCatAccountWebViewController.h"
#import "HXBPlanBuyResultViewController.h"


@interface HXBFin_Plan_Buy_ViewController ()<UITableViewDelegate, UITableViewDataSource, HXBChooseDiscountCouponViewControllerDelegate, HXBRemoteUpdateInterface>
@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic, strong) HXBTransactionPasswordView *passwordView;
/** topView */
@property (nonatomic, strong) HXBCreditorChangeTopView *topView;
/** bottomView*/
@property (nonatomic, strong) HXBCreditorChangeBottomView *bottomView;
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
/** 购买类型 */
@property (nonatomic, copy) NSString *buyType; // balance recharge
/** 优惠券Title */
@property (nonatomic, copy) NSString *couponTitle;
/** 优惠券金额 */
@property (nonatomic, copy) NSString *discountTitle;
/** 可用余额TextLabel */
@property (nonatomic, copy) NSString *balanceTitle;
/** 可用余额detailLabel */
@property (nonatomic, copy) NSString *balanceDetailTitle;
/** 应付金额detailLabel */
@property (nonatomic, copy) NSString *handleDetailTitle;
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
/** 是否勾选优惠券 */
@property (nonatomic, assign) BOOL isSelectCoupon;
/** 是否获取到优惠券 */
@property (nonatomic, assign) BOOL hasGetCoupon;
// 当前输入框的金额
@property (nonatomic, assign) double curruntInvestMoney;
// 实际支付金额
@property (nonatomic, assign) double afterDiscountMoney;
// 是否超出投资限制
@property (nonatomic, assign) BOOL isExceedLimitInvest;
// 是否选中同意选项
@property (nonatomic, assign) BOOL isSelectLimit;

// 是否符合标的等级购买规则
//@property (nonatomic, assign) BOOL isMatchBuy;

@property (nonatomic, strong) HXBFinPlanBuyViewModel *viewModel;

// 是否显示 退出方式
@property (nonatomic, assign) BOOL showQuitWay;
/// 判断购买类型
@property (nonatomic, assign) HXBBuyType hxbBuyType;
/// 银行卡名称
@property (nonatomic, copy) NSString *bankImageName;

@end

@implementation HXBFin_Plan_Buy_ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.isColourGradientNavigationBar = YES;
    
    _couponTitle = @"优惠券";
    _discountTitle = @"";
    _balanceTitle = @"可用余额";
    _isSelectCoupon = NO;
    kWeakSelf
    _viewModel = [[HXBFinPlanBuyViewModel alloc] initWithBlock:^UIView *{
        if (weakSelf.presentedViewController) {
            return weakSelf.presentedViewController.view;
        } else {
            return weakSelf.view;
        }
    }];
    
    self.showQuitWay = !(self.quitWay == nil || self.quitWay.length == 0 || [self.quitWay isEqualToString:@"null"]);
//    _isMatchBuy = [self.userInfoViewModel.userInfoModel.userAssets.userRisk containsObject:self.riskType]; // 2.5.0版本暂时取消风险等级判断
    _balanceMoneyStr = self.userInfoViewModel.userInfoModel.userAssets.availablePoint;

    [self buildUI];
    [self hasBestCouponRequest];
    [self isMatchToBuyWithMoney:@"0"];
    self.bottomView.addBtnIsUseable = _inputMoneyStr.length;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    self.isSelectLimit = NO;
    [self getBankCardLimit];
    [self hasBuyType];
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
        NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
        attachment.image = [UIImage imageNamed:@"lightblue_tip"];
        attachment.bounds = CGRectMake(0, -2, 14, 14);
        
        NSMutableAttributedString *attrText = [NSMutableAttributedString new];
        [attrText appendAttributedString:[NSAttributedString attributedStringWithAttachment:attachment]];
        [attrText appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" 新手产品每人加入上限%@元", [NSString hxb_getPerMilWithDoubleNum:[self.NewPlanJoinLimit integerValue]]] attributes:@{NSForegroundColorAttributeName: COR8}]];
        
        UIFont *font = kHXBFont_PINGFANGSC_REGULAR_750(24);
        
        CGFloat tipHeigt = ceil([font lineHeight]);
        CGRect rect = CGRectMake(15, self.tableView.height - tipHeigt - 40 - HXBBottomAdditionHeight, kScreenW - 15 * 2, tipHeigt);
        
        UILabel * tipLabel = [[UILabel alloc] initWithFrame:rect];
        tipLabel.font = font;
        tipLabel.attributedText = attrText;
        [self.tableView addSubview:tipLabel];
    }
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
        cell.bankImageName = @"";
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.isDiscountRow = NO;
        cell.bankImageName = _bankImageName;
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
        chooseDiscountVC.isSelectCoupon = _isSelectCoupon;
        chooseDiscountVC.couponid = self.isNewPlan ? @"0" : _couponid;
        [self.navigationController pushViewController:chooseDiscountVC animated:YES];
    }
}

/// 判断购买类型
- (void)hasBuyType {
    /// 进入界面判断是否绑卡及账户余额是否比起投金额高
    if ((_balanceMoneyStr.floatValue > self.minRegisterAmount.floatValue ?: self.registerMultipleAmount.floatValue) && _balanceMoneyStr.floatValue >= self.afterDiscountMoney) { // 余额够
        [self changeCellWithBuyType:HXBBuyTypeBalance];
        _hxbBuyType = HXBBuyTypeBalance;
    } else {
        if ([self.hasBindCard isEqualToString:@"1"]) {
            [self changeCellWithBuyType:HXBBuyTypeBankBuy];
            _hxbBuyType = HXBBuyTypeBankBuy;
        } else {
            [self changeCellWithBuyType:HXBBuyTypeNoBankCard];
            _hxbBuyType = HXBBuyTypeNoBankCard;
        }
    }
}

/// 根据购买类型判断cell展示
- (void)changeCellWithBuyType:(HXBBuyType)buyType {
    if (buyType == HXBBuyTypeBalance) {
        _balanceTitle = [NSString stringWithFormat:@"账户余额（%@）", [NSString hxb_getPerMilWithDouble: self.balanceMoneyStr.doubleValue]];
        _bankImageName = @"";
        _bottomView.clickBtnStr = @"立即加入";
    } else if (buyType == HXBBuyTypeNoBankCard) {
        _balanceTitle = @"需绑定银行卡";
        _bankImageName = @"";
        _bottomView.clickBtnStr = @"立即绑卡";
    } else if (buyType == HXBBuyTypeBankBuy) {
        _balanceTitle = [NSString stringWithFormat:@"%@（%@）", self.cardModel.bankType, [NSString getHiddenBankNum:self.cardModel.cardId]];
        _bankImageName = self.cardModel.bankCode;
        _bottomView.clickBtnStr = @"立即加入";
    }
    [self setUpArray];
}

// 根据金额改变按钮文案
- (void)changeItemWithInvestMoney:(NSString *)investMoney {
    self.topView.hiddenMoneyLabel = !self.cardModel.bankType;
    _inputMoneyStr = investMoney;
    [self isMatchToBuyWithMoney:investMoney];
    self.topView.profitStr = [NSString stringWithFormat:@"预期收益%@", [NSString hxb_getPerMilWithDouble:investMoney.floatValue*self.totalInterest.floatValue/100.0]];
    [self checkIfNeedNewPlanDatas:investMoney];
    [self hasBuyType];
}

- (void)hasBestCouponRequest {
    NSDictionary *dic_post = @{
                               @"id": _loanId,
                               @"amount": @"0",
                               @"type": @"plan"
                               };
    kWeakSelf
    [_viewModel bestCouponListWithParams:dic_post resultBlock:^(BOOL isSuccess) {
        if (isSuccess) {
            weakSelf.discountTitle = nil;
            weakSelf.model = weakSelf.viewModel.bestCouponModel;
            weakSelf.hasCoupon = weakSelf.model.hasCoupon;
            if (weakSelf.model.hasCoupon) {
                weakSelf.discountTitle = @"请选择优惠券";
            } else {
                weakSelf.discountTitle = @"暂无可用优惠券";
            }
            [weakSelf setUpArray];
        } else {
            [weakSelf getBestCouponFailWithMoney:@"0" cell:nil];
            weakSelf.discountTitle = @"暂无可用优惠券";
        }
    }];
}

// 购买红利计划
- (void)requestForPlan {
    if (_inputMoneyStr.length == 0) {
        [HxbHUDProgress showTextWithMessage:@"请输入出借金额"];
    } else if (_inputMoneyStr.floatValue > _availablePoint.floatValue) { // 超过可加入金额是，只check，不用强制到最大可加入金额
        [HxbHUDProgress showTextWithMessage:@"已超可加入金额"];
    }  else if (_inputMoneyStr.floatValue < _minRegisterAmount.floatValue && _isFirstBuy) {
        _topView.totalMoney = [NSString stringWithFormat:@"%ld", (long)_minRegisterAmount.integerValue];
        _inputMoneyStr = _minRegisterAmount;
        _profitMoneyStr = [NSString stringWithFormat:@"%.2f", _minRegisterAmount.floatValue*self.totalInterest.floatValue/100.0];
        _curruntInvestMoney =_inputMoneyStr.doubleValue;
        [self getBESTCouponWithMoney:_inputMoneyStr];
        _topView.profitStr = [NSString stringWithFormat:@"预期收益%@元", _profitMoneyStr];
        [self checkIfNeedNewPlanDatas:_inputMoneyStr];
        [self hasBuyType];
        [HxbHUDProgress showTextWithMessage:@"出借金额不足起投金额"];
    } else if (_inputMoneyStr.floatValue < _registerMultipleAmount.floatValue && !_isFirstBuy) {
        _topView.totalMoney = [NSString stringWithFormat:@"%ld", (long)_registerMultipleAmount.integerValue];
        _inputMoneyStr = _registerMultipleAmount;
        _profitMoneyStr = [NSString stringWithFormat:@"%.2f", _registerMultipleAmount.floatValue*self.totalInterest.floatValue/100.0];
        _curruntInvestMoney = _inputMoneyStr.floatValue;
        [self getBESTCouponWithMoney:_inputMoneyStr];
        _topView.profitStr = [NSString stringWithFormat:@"预期收益%@元", _profitMoneyStr];
        [self checkIfNeedNewPlanDatas:_inputMoneyStr];
        [self hasBuyType];
        [HxbHUDProgress showTextWithMessage:@"出借金额不足递增金额"];
    } else {
        BOOL isFitToBuy;
        if (_isFirstBuy) {
            isFitToBuy = ((_inputMoneyStr.integerValue - _minRegisterAmount.integerValue) % _registerMultipleAmount.integerValue) ? NO : YES;
        } else {
            isFitToBuy = _inputMoneyStr.integerValue % _registerMultipleAmount.integerValue ? NO : YES;
        }
        if (isFitToBuy) {
            if (self.isExceedLimitInvest &&!_isSelectLimit) {
                [HxbHUDProgress showTextWithMessage:@"请勾选同意风险提示"];
                return;
            }
            [self chooseBuyTypeWithbuyType:_hxbBuyType];
        } else {
            [HxbHUDProgress showTextWithMessage:[NSString stringWithFormat:@"金额需为%@的整数倍", self.registerMultipleAmount]];
        }
    }
}

- (void)checkIfNeedNewPlanDatas:(NSString *)baseMoney {
    if (self.isNewPlan) {
        /// 贴息收益
        CGFloat subsidy = baseMoney.floatValue * self.expectedSubsidyInterestAmount.floatValue * 0.01;
        float total = baseMoney.floatValue*self.totalInterest.floatValue/100.0 + subsidy;
        NSString* priceStr = [NSString stringWithFormat:@"%.4f", total];
        /// 总收益
        _profitMoneyStr = [NSString stringWithFormat:@"%@", [priceStr notRounding:2]];
        [_topView setProfitString:_profitMoneyStr];
    }
}

// 判断是什么投资类型（充值购买，余额购买、未绑卡）
- (void)chooseBuyTypeWithbuyType:(HXBBuyType)buyType {
    NSDictionary *dic = nil;
    if (buyType == HXBBuyTypeNoBankCard) {  /// 去绑卡
        HxbWithdrawCardViewController *withdrawCardViewController = [[HxbWithdrawCardViewController alloc] init];
        withdrawCardViewController.title = @"绑卡";
        withdrawCardViewController.type = HXBRechargeAndWithdrawalsLogicalJudgment_Other;
        [self.navigationController pushViewController:withdrawCardViewController animated:YES];
    } else if (buyType == HXBBuyTypeBankBuy) {
        dic = @{@"financePlanId": self.loanId,
                @"amount": self.inputMoneyStr,
                @"cashType": self.cashType,
                @"buyType": @"recharge",
                @"willingToBuy": [NSString stringWithFormat:@"%d", _isSelectLimit],
                @"couponId": self.couponid
                };
        [self buyPlanWithDic:dic];
    } else if (buyType == HXBBuyTypeBalance) {
        
        dic = @{@"financePlanId": self.loanId,
                @"amount": self.inputMoneyStr,
                @"cashType": self.cashType,
                @"buyType": @"balance",
                @"willingToBuy": [NSString stringWithFormat:@"%d", _isSelectLimit],
                @"couponId": self.couponid
                };
        [self buyPlanWithDic:dic];
    }
}

// 购买计划
- (void)buyPlanWithDic:(NSDictionary *)dic {
    kWeakSelf
    [_viewModel planBuyReslutWithParameter:dic resultBlock:^(BOOL isSuccess) {
        if (isSuccess) { /// 跳转恒丰webView
            HXBLazyCatAccountWebViewController *HFVC = [[HXBLazyCatAccountWebViewController alloc] init];
            HFVC.requestModel = weakSelf.viewModel.resultModel;
            [weakSelf.navigationController pushViewController:HFVC animated:YES];
        } else {
            HXBPlanBuyResultViewController *failViewController = [[HXBPlanBuyResultViewController alloc]init];
            switch (weakSelf.viewModel.errorCode) {
                case kBuy_Result:
                    failViewController.errorMessage = weakSelf.viewModel.errorMessage;
                    break;
                    
                default:
                    return;
            }

            [weakSelf.navigationController pushViewController:failViewController animated:YES];
        
        }
    }];
    
}

- (void)chooseDiscountCouponViewController:(HXBChooseDiscountCouponViewController *)chooseDiscountCouponViewController didSendModel:(HXBCouponModel *)model {
    if (model) {
        _discountMoney = model.valueActual.doubleValue;
        _afterDiscountMoney = _inputMoneyStr.doubleValue - model.valueActual.doubleValue;
        _discountTitle = [NSString stringWithFormat:@"-%@", [NSString hxb_getPerMilWithDouble:model.valueActual.doubleValue]];
        _couponTitle = [NSString stringWithFormat:@"优惠券（使用%@）", model.summaryTitle];
        _hasBestCoupon = YES;
        _chooseCoupon = model;
        _couponid = model.ID;
        _isSelectCoupon = NO;
    } else {
        _discountMoney = 0.0;
        _hasBestCoupon = NO;
        _afterDiscountMoney = _inputMoneyStr.doubleValue;
        _couponTitle = @"优惠券";
        _discountTitle = @"不使用优惠券";
        _couponid = @"";
        _isSelectCoupon = YES;
    }
    self.bottomView.addBtnIsUseable = YES;
    [self changeItemWithInvestMoney:_inputMoneyStr];
}

// 获取银行限额
- (void)getBankCardLimit {
    if ([self.hasBindCard isEqualToString:@"1"]) {
        self.topView.height = kScrAdaptationH750(370) + self.topQuitWayAdditionalHeight;
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
                weakSelf.tableView.hidden = NO;
                weakSelf.topView.hasBank = YES;
                weakSelf.tableView.tableHeaderView = weakSelf.topView;
                [weakSelf hasBuyType];
                [weakSelf.tableView reloadData];
            }
        }];
        
    } else {
        self.topView.height = kScrAdaptationH750(300) + self.topQuitWayAdditionalHeight;
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
    [_viewModel bestCouponListWithParams:dic_post resultBlock:^(BOOL isSuccess) {
        if (isSuccess) {
            cell.isStartAnimation = NO;
            if (weakSelf.curruntInvestMoney == money.doubleValue) {
                [weakSelf requestSuccessWithModel:weakSelf.viewModel.bestCouponModel cell:cell money:money ];
            }
        } else {
            [weakSelf getBestCouponFailWithMoney:money cell:cell];
            weakSelf.discountTitle = @"请选择优惠券";
            weakSelf.isSelectCoupon = NO;
            [weakSelf changeItemWithInvestMoney:money];
        }
    }];
}

// 获取用户信息
- (void)getNewUserInfo {
    kWeakSelf
    [self.viewModel downLoadUserInfo:NO resultBlock:^(BOOL isSuccess) {
        if(isSuccess) {
            weakSelf.userInfoViewModel = weakSelf.viewModel.userInfoModel;
            weakSelf.balanceMoneyStr = weakSelf.userInfoViewModel.userInfoModel.userAssets.availablePoint;
            weakSelf.hasBindCard = weakSelf.userInfoViewModel.userInfoModel.userInfo.hasBindCard;
            [weakSelf changeItemWithInvestMoney:weakSelf.inputMoneyStr];
            if (!weakSelf.cardModel.bankCode) {
                [weakSelf getBankCardLimit];
            }
            [weakSelf hasBuyType];
            [weakSelf.tableView reloadData];
        } else {
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
    self.afterDiscountMoney = money.floatValue;
}

- (void)updateNetWorkData {
    [self getNewUserInfo];
}

- (void)requestSuccessWithModel:(HXBBestCouponModel *)model cell:(HXBFin_creditorChange_TableViewCell *)cell money: (NSString *)money {
    
    self.hasGetCoupon = NO;
    self.bottomView.addBtnIsUseable = YES;
    self.discountTitle = nil;
    self.model = model;
    if (model.hasCoupon && model.bestCoupon) { // 只有有优惠券hasCoupon都返回1，没有匹配到bestCoupon为空，所有有优惠券，且匹配到了，就抵扣或者满减
        _discountMoney = model.bestCoupon.valueActual.doubleValue;
        _afterDiscountMoney = money.doubleValue - model.bestCoupon.valueActual.doubleValue;
        _discountTitle = [NSString stringWithFormat:@"-%@", [NSString hxb_getPerMilWithDouble:model.bestCoupon.valueActual.doubleValue]];
        _couponTitle = [NSString stringWithFormat:@"优惠券（使用%@）", model.bestCoupon.summaryTitle];
        _hasBestCoupon = YES;
        _couponid = model.bestCoupon.ID;
        _isSelectCoupon = NO;
    } else {
        _hasBestCoupon = NO;
        _afterDiscountMoney = money.doubleValue;
        _discountTitle = @"请选择优惠券";
        _couponTitle = @"优惠券";
        _couponid = @"";
        _isSelectCoupon = NO;
        if (!model.hasCoupon) {
            _discountTitle = @"暂无可用优惠券";
        }
    }
    
    [self changeItemWithInvestMoney:money];
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
        if (self.showQuitWay) {
            _topView.quitWay = self.quitWay;
        } else {
            _topView.quitWay = nil;
        }
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
                float price = _inputMoneyStr.floatValue * self.expectedSubsidyInterestAmount.floatValue * 0.01;
                NSString* priceStr = [NSString stringWithFormat:@"%.4f", price];
                HXBXYAlertViewController *alertVC = [[HXBXYAlertViewController alloc] initWithTitle:@"温馨提示" Massage:[NSString stringWithFormat:@"新手加息收益%@元将在计划退出时发放至您的账户", [priceStr notRounding:2]] force:2 andLeftButtonMassage:nil andRightButtonMassage:@"确定"];
                alertVC.isHIddenLeftBtn = YES;
                alertVC.isCenterShow = YES;
                [weakSelf presentViewController:alertVC animated:YES completion:nil];
                
            };
            
            [_topView setProfitString:@"0.00"];
        }
        else {
           _topView.creditorMoney = [NSString stringWithFormat:@"本期剩余加入上限%@", [NSString hxb_getPerMilWithIntegetNumber:_availablePoint.doubleValue]];
        }
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
        self.couponid = @"";
        self.isSelectCoupon = NO;
        self.hasBestCoupon = NO;
        self.couponTitle = @"优惠券";
        self.afterDiscountMoney = text.doubleValue;
        [self changeItemWithInvestMoney:text];
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
    _bottomView.delegateLabelText = @"红利智投服务协议》,《网络借贷协议书";
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
        [weakSelf.topView endEditing:YES];
        [weakSelf requestForPlan];
    };
    return _bottomView;
}

- (CGFloat)topQuitWayAdditionalHeight {
    return self.showQuitWay ? 27 : 0;
}
@end
