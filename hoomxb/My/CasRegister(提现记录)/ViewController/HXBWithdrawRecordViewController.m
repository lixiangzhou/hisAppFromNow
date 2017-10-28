//
//  HXBWithdrawRecordViewController.m
//  hoomxb
//
//  Created by HXB-C on 2017/10/10.
//  Copyright © 2017年 hoomsun-miniX. All rights reserved.
//

#import "HXBWithdrawRecordViewController.h"
#import "HXBWithdrawRecordViewModel.h"
#import "HXBWithdrawRecordListModel.h"
#import "HXBWithdrawRecordCell.h"
@interface HXBWithdrawRecordViewController ()<UITableViewDelegate,UITableViewDataSource>

/**
 提现记录的ViewModel
 */
@property (nonatomic, strong) HXBWithdrawRecordViewModel *withdrawRecordViewModel;
/**
 提现进度列表
 */
@property (nonatomic, strong) UITableView *withdrawRecordTableView;

/**
 暂无数据接口
 */
@property (nonatomic, strong) HXBNoDataView *nodataView;
@end

@implementation HXBWithdrawRecordViewController
#pragma mark – Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"提现进度";
    self.isRedColorWithNavigationBar = YES;
    [self loadCashRegisterData];
    [self.view addSubview:self.withdrawRecordTableView];
    [self nodataView];
}
#pragma mark - Events
///无网状态的网络连接
- (void)getNetworkAgain {
    [self loadCashRegisterData];
}
#pragma mark – Private
//加载数据
- (void)loadCashRegisterData {
    kWeakSelf
    [self.withdrawRecordViewModel casRegisteRequestSuccessBlock:^(HXBWithdrawRecordListModel *withdrawRecordListModel) {
        [weakSelf isHaveData];
        [weakSelf.withdrawRecordTableView reloadData];
        [weakSelf endRefreshing];
    } andFailureBlock:^(NSError *error) {
        [weakSelf.withdrawRecordTableView reloadData];
        [weakSelf endRefreshing];
    }];
}
//结束刷新
- (void)endRefreshing {
    [self.withdrawRecordTableView.mj_header endRefreshing];
    [self.withdrawRecordTableView.mj_header endRefreshing];
}
//判断是否有数据
- (void)isHaveData {
    if (self.withdrawRecordViewModel.withdrawRecordListModel.dataList.count) {
        self.nodataView.hidden = YES;
    } else {
        self.nodataView.hidden = NO;
    }
}

#pragma mark - UITableViewDataSource
- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    static NSString *identifier = @"HXBNoticeViewControllerCell";
    HXBWithdrawRecordCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[HXBWithdrawRecordCell alloc] initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.withdrawRecordModel = self.withdrawRecordViewModel.withdrawRecordListModel.dataList[indexPath.row];
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.withdrawRecordViewModel.withdrawRecordListModel.dataList.count;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kScrAdaptationH750(200);
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return kScrAdaptationH750(20);
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headView = [[UIView alloc] init];
    headView.backgroundColor = BACKGROUNDCOLOR;
    return headView;
}

#pragma mark – Getters and Setters
- (UITableView *)withdrawRecordTableView {
    if (!_withdrawRecordTableView) {
        _withdrawRecordTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, kScreenWidth, kScreenHeight - 64) style:(UITableViewStylePlain)];
        [HXBMiddlekey AdaptationiOS11WithTableView:_withdrawRecordTableView];
        _withdrawRecordTableView.backgroundColor = BACKGROUNDCOLOR;
        _withdrawRecordTableView.delegate = self;
        _withdrawRecordTableView.dataSource = self;
        _withdrawRecordTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_withdrawRecordTableView hxb_GifHeaderWithIdleImages:nil andPullingImages:nil andFreshingImages:nil andRefreshDurations:nil andRefreshBlock:^{
            [self loadCashRegisterData];
        } andSetUpGifHeaderBlock:^(MJRefreshGifHeader *gifHeader) {
            
        }];
    }
    return _withdrawRecordTableView;
}
- (HXBWithdrawRecordViewModel *)withdrawRecordViewModel {
    if (!_withdrawRecordViewModel) {
        _withdrawRecordViewModel = [[HXBWithdrawRecordViewModel alloc] init];
    }
    return _withdrawRecordViewModel;
}

- (HXBNoDataView *)nodataView {
    if (!_nodataView) {
        _nodataView = [[HXBNoDataView alloc]initWithFrame:CGRectZero];
        [self.view addSubview:_nodataView];
        _nodataView.imageName = @"Fin_NotData";
        _nodataView.noDataMassage = @"暂无数据";
        _nodataView.userInteractionEnabled = NO;
        //        _nodataView.downPULLMassage = @"下拉进行刷新";
        [_nodataView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view).offset(kScrAdaptationH(100) + 64);
            make.height.width.equalTo(@(kScrAdaptationH(184)));
            make.centerX.equalTo(self.view);
        }];
    }
    return _nodataView;
}
@end
