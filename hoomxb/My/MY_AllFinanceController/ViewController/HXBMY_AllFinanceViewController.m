//
//  HXBMY_AllFinanceViewController.m
//  hoomxb
//
//  Created by HXB on 2017/6/27.
//  Copyright © 2017年 hoomsun-miniX. All rights reserved.
//

#import "HXBMY_AllFinanceViewController.h"
#import "HXBMY_AllFinanceView.h"
#import "HXBAccumulatedIncomeView.h"
#import "HXBBaseViewModel+KEYCHAIN.h"

@interface HXBMY_AllFinanceViewController ()
@property (nonatomic,strong) HXBMY_AllFinanceView *allFinanceView;
@property (nonatomic, strong) HXBAccumulatedIncomeView *accumulatedIncomeView;
@property (nonatomic, strong) HXBBaseViewModel *viewModel;
@end

@implementation HXBMY_AllFinanceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isColourGradientNavigationBar = YES;
    self.title = @"资产统计";
    kWeakSelf
    _viewModel = [[HXBBaseViewModel alloc] initWithBlock:^UIView *{
        return weakSelf.view;
    }];
    self.view.backgroundColor = BACKGROUNDCOLOR;
    [self.view addSubview:self.allFinanceView];
    [self.view addSubview:self.accumulatedIncomeView];
    [self loadData_userInfo];
}
/**
 再次获取网络数据
 */
- (void)getNetworkAgain
{
    [self loadData_userInfo];
}

- (void)loadData_userInfo
{
    kWeakSelf
    [_viewModel downLoadUserInfo:YES resultBlock:^(BOOL isSuccess) {
        if (isSuccess) {
            weakSelf.allFinanceView.viewModel = weakSelf.viewModel.userInfoModel;
            weakSelf.accumulatedIncomeView.viewModel = weakSelf.viewModel.userInfoModel;
        }
    }];
}

#pragma mark - 懒加载

- (HXBAccumulatedIncomeView *)accumulatedIncomeView
{
    if (!_accumulatedIncomeView) {
        // 高度改为屏幕高度减去上半部分的高度
        _accumulatedIncomeView = [[HXBAccumulatedIncomeView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.allFinanceView.frame) + kScrAdaptationH(10), kScreenWidth, kScrAdaptationH(291))];
    }
    return _accumulatedIncomeView;
}

- (HXBMY_AllFinanceView *)allFinanceView {
    if (!_allFinanceView) {
        _allFinanceView = [[HXBMY_AllFinanceView alloc]initWithFrame:CGRectMake(0, HXBStatusBarAndNavigationBarHeight + kScrAdaptationH(10), kScreenWidth, kScrAdaptationH(242))];
    }
    return _allFinanceView;
}

@end
