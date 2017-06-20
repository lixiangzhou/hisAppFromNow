//
//  HXBPlan_JoinImmediatelyViewController.m
//  hoomxb
//
//  Created by HXB on 2017/6/14.
//  Copyright © 2017年 hoomsun-miniX. All rights reserved.
//

#import "HXBFin_Plan_BuyViewController.h"
#import "HXBJoinImmediateView.h"
#import "HXBFinModel_Buy_Plan.h"
#import "HXBFinanctingRequest.h"
#import "HXBFinDetailViewModel_PlanDetail.h"
#import "HXBFinDetailModel_PlanDetail.h"
@interface HXBFin_Plan_BuyViewController ()
@property (nonatomic,strong) HXBRequestUserInfoViewModel *userInfoViewModel;
@property (nonatomic,strong) HXBJoinImmediateView *joinimmediateView;
@end

@implementation HXBFin_Plan_BuyViewController

- (void)setIsPlan:(BOOL)isPlan {
    _isPlan = isPlan;
    self.joinimmediateView.isPlan = isPlan;
}

- (void)viewDidLoad {
    kWeakSelf
    [self.hxbBaseVCScrollView hxb_HeaderWithHeaderRefreshCallBack:^{
        [weakSelf.hxbBaseVCScrollView endRefresh];
    } andSetUpGifHeaderBlock:^(MJRefreshNormalHeader *header) {
    }];
    
    [super viewDidLoad];
    //判断是否登录
    [self isLogin];

    ///UI的搭建
    [self setUPViews];
    
    //传递值
    [self setValue];
    
    //事件的传递
    [self registerEvent];
}

///判断是否登录
- (void)isLogin {
    if (!KeyChain.isLogin) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kHXBNotification_ShowLoginVC object:nil];
    }
}

///UI搭建
- (void)setUPViews {
    kWeakSelf
    self.joinimmediateView = [[HXBJoinImmediateView alloc] init];
    [self.hxbBaseVCScrollView addSubview:self.joinimmediateView];
    
    [self trackingScrollViewBlock:^(UIScrollView *scrollView) {
        weakSelf.joinimmediateView.isEndEditing = true;
    }];
    
    self.joinimmediateView.frame = self.view.frame;
    
}

 - (void) registerEvent {
     __weak typeof(self) weakSelf = self;
     ///点击了充值
     [self.joinimmediateView clickRechargeFunc:^{
         [HxbHUDProgress showTextWithMessage:@"余额不足，请先到官网充值后再进行投资"];
     }];
     ///点击了一键购买
     [self.joinimmediateView clickBuyButtonFunc:^(NSString *capitall, UITextField *textField) {
     }];
     ///点击了加入
     [self.joinimmediateView clickAddButtonFunc:^(NSString *capital) {
         // 先判断是否>=1000，再判断是否为1000的整数倍（追加时只需判断是否为1000的整数倍），错误，toast提示“起投金额1000元”或“投资金额应为1000的整数倍
         if (!(capital.floatValue >= 1000)) {
             NSLog(@"请输入大于等于1000");
             [HxbHUDProgress showTextWithMessage:@"起投金额1000元"];
             return;
         }
         if ((capital.integerValue % 1000) != 0) {
             NSLog(@"1000的整数倍");
             [HxbHUDProgress showTextWithMessage:@"投资金额应为1000的整数倍"];
             return;
         }
         //判断是否安全认证
         [HXBRequestUserInfo downLoadUserInfoWithSeccessBlock:^(HXBRequestUserInfoViewModel *viewModel) {
             if (!viewModel.userInfoModel.userInfo.isAllPassed.integerValue) {
                 [HxbHUDProgress showTextWithMessage:@"去安全认证"];
             }else {
                 [[HXBFinanctingRequest sharedFinanctingRequest] planBuyWithPlanID:@(weakSelf.ID).description andAmount:capital andSuccessBlock:^(HXBFinModel_Buy_Plan *model) {
                     
                 } andFailureBlock:^(NSError *error) {
                     
                 }];
                  }
         } andFailure:^(NSError *error) {
             [HxbHUDProgress showTextWithMessage:@"加入失败"];
         }];
     }];
     //点击了 服务协议
     [self.joinimmediateView clickNegotiateButtonFunc:^{
         
     }];
}

- (void)setValue {
    kWeakSelf
    [HXBRequestUserInfo downLoadUserInfoWithSeccessBlock:^(HXBRequestUserInfoViewModel *viewModel) {
        self.userInfoViewModel = viewModel;
        [self.joinimmediateView setUPValueWithModelBlock:^HXBJoinImmediateView_Model *(HXBJoinImmediateView_Model *model) {
            
            ///预计收益Const
            model.profitLabel_consttStr = @"预期收益";
            ///服务协议
            model.negotiateLabelStr = @"我已阅读并同意";
            ///余额 title
            model.balanceLabel_constStr = @"可用余额";
            ///充值的button str
            model.rechargeButtonStr = @"充值";
            ///一键购买的str
            model.buyButtonStr = @"一键购买";
            ///收益方式
            model.profitTypeLable_ConstStr = @"收益处理方式";
            ///加入上限
            model.upperLimitLabel_constStr = @"本期计划加入上限";
            
            ///收益方法
            model.profitTypeLabelStr = weakSelf.planViewModel.profitType;
            /// ￥1000起投，1000递增 placeholder
            model.rechargeViewTextField_placeholderStr = weakSelf.planViewModel.addCondition;
            
            ///余额展示
            model.balanceLabelStr = viewModel.availablePoint;
            
            ///预计收益 在 加入计划的 view 内部计算
            
            ///服务协议 button str
            model.negotiateButtonStr = weakSelf.planViewModel.contractName;
            model.totalInterest = weakSelf.planViewModel.totalInterest;
            ///加入上线
            model.upperLimitLabelStr = weakSelf.planViewModel.singleMaxRegisterAmount;
            ///确认加入的Buttonstr
            model.addButtonStr = @"确认加入";
            return model;
        }];

    
        [self.joinimmediateView setUPValueWithModelBlock:^HXBJoinImmediateView_Model *(HXBJoinImmediateView_Model *model) {
            
            ///预计收益Const
            model.profitLabel_consttStr = @"预期收益";
            ///服务协议
            model.negotiateLabelStr = @"我已阅读并同意";
            ///余额 title
            model.balanceLabel_constStr = @"可用余额";
            ///充值的button str
            model.rechargeButtonStr = @"充值";
            ///一键购买的str
            model.buyButtonStr = @"一键购买";
            ///收益方式
            model.profitTypeLable_ConstStr = @"收益处理方式";
            ///加入上限
            model.upperLimitLabel_constStr = @"本期计划加入上限";
            
            ///收益方法
            model.profitTypeLabelStr = weakSelf.planViewModel.profitType;
            /// ￥1000起投，1000递增 placeholder
            model.rechargeViewTextField_placeholderStr = weakSelf.planViewModel.addCondition;
            
            ///余额展示
            model.balanceLabelStr = viewModel.availablePoint;
            
            ///预计收益 在 加入计划的 view 内部计算
        
            ///服务协议 button str
            model.negotiateButtonStr = weakSelf.planViewModel.contractName;
            model.totalInterest = weakSelf.planViewModel.totalInterest;
            ///加入上线
            model.upperLimitLabelStr = weakSelf.planViewModel.singleMaxRegisterAmount;
            ///确认加入的Buttonstr
            model.addButtonStr = @"确认加入";
            return model;
        }];
    } andFailure:^(NSError *error) {
        
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end
