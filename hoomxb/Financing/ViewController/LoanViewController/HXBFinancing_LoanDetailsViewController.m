//
//  HXBFinancing_LoanDetailsViewController.m
//  hoomxb
//
//  Created by HXB on 2017/5/4.
//  Copyright © 2017年 hoomsun-miniX. All rights reserved.
//

#import "HXBFinancing_LoanDetailsViewController.h"
#import "HXBFinDetail_TableView.h"
#import "HXBFin_DetailsView_LoanDetailsView.h"
#import "HXBFinanctingRequest.h"
#import "HXBFinDetailViewModel_LoanDetail.h"
//#import "HXBFinDetailView"

@interface HXBFinancing_LoanDetailsViewController ()

@property(nonatomic,strong) HXBFin_DetailsView_LoanDetailsView *loanDetailsView;

@property (nonatomic,strong) NSArray <HXBFinDetail_TableViewCellModel *>*tableViewModelArray;
///tableView的tatile
@property (nonatomic,strong) NSArray <NSString *>* tableViewTitleArray;
///详情底部的tableView的图片数组
@property (nonatomic,strong) NSArray <NSString *>* tableViewImageArray;
@end

@implementation HXBFinancing_LoanDetailsViewController
///给self. tableViewarray赋值
- (void) setupTableViewArray {
    self.tableViewImageArray = @[
                                 @"1",
                                 @"1",
                                 @"1",
                                 ];
    self.tableViewTitleArray = @[
                                 @"借款信息",
                                 @"投标记录",
                                 @"借款合同"
                                 ];
}
- (NSArray<HXBFinDetail_TableViewCellModel *> *)tableViewModelArray {
    if (!_tableViewModelArray) {
        [self setupTableViewArray];
        NSMutableArray *tableViewModelArrayM = [[NSMutableArray alloc]init];
        for (int i = 0; i < self.tableViewImageArray.count; i++) {
            NSString *imageName = self.tableViewImageArray[i];
            NSString *title = self.tableViewTitleArray[i];
            HXBFinDetail_TableViewCellModel *model = [[HXBFinDetail_TableViewCellModel alloc]initWithImageName:imageName andOptionIitle:title];
            [tableViewModelArrayM addObject:model];
        }
        _tableViewModelArray = tableViewModelArrayM.copy;
    }
    return _tableViewModelArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
}

//MARK: ------ setup -------
- (void)setup {
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.loanDetailsView = [[HXBFin_DetailsView_LoanDetailsView alloc]initWithFrame:self.view.frame];
    [self.view addSubview:self.loanDetailsView];
    //是否为计划界面
    self.loanDetailsView.isPlan = false;
    self.loanDetailsView.isFlowChart = true;
    [self downLoadData];
    //    [self.planDetailsView show];
    
}

//MARK: 网络数据请求
- (void)downLoadData {
    [[HXBFinanctingRequest sharedFinanctingRequest] loanDetaileWithSuccessBlock:^(HXBFinDetailViewModel_LoanDetail *viewModel) {
        self.loanDetailsView.loanDetailViewModel = viewModel;
        self.loanDetailsView.modelArray = self.tableViewModelArray;
    } andFailureBlock:^(NSError *error) {
        
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
