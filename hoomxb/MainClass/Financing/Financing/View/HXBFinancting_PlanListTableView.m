//
//  HXBFinancting_PlanListVIew.m
//  hoomxb
//
//  Created by HXB on 2017/5/3.
//  Copyright © 2017年 hoomsun-miniX. All rights reserved.
//



#define kPlanListCellHasCouponHeight         kScrAdaptationH750(279)
#define kPlanListCellNoHasCouponHeight       kScrAdaptationH750(219)
#define kPlanListCellSpacing                 kScrAdaptationH750(20)
#define kNodataViewTopSpacing                kScrAdaptationH(100)
#define kNodataViewHeight                    kScrAdaptationH(184)
#define kNodataViewImageName                 @"Fin_NotData"
#define kNoDataMassage                       @"暂无数据"


#import "HXBFinancting_PlanListTableView.h"
#import "HXBFinancting_PlanListTableViewCell.h"
#import "HXBFinHomePageViewModel_PlanList.h"//viewmodel
#import "HXBFinHomePageViewModel_LoanList.h"
#import "HXBFinHomePageModel_PlanList.h"
#import "HXBFinHomePageModel_LoanList.h"
//#import "HXBFinance_MouthType_tableView.h"


@interface HXBFinancting_PlanListTableView () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic,strong) HXBNoDataView *nodataView;

@end

@implementation HXBFinancting_PlanListTableView

static NSString *CELLID = @"CELLID";

- (void)setPlanListViewModelArray:(NSArray<HXBFinHomePageViewModel_PlanList *> *)planListViewModelArray {
    _planListViewModelArray = planListViewModelArray;
    self.nodataView.hidden = planListViewModelArray.count;
    [self reloadData];
}


- (instancetype) initWithFrame:(CGRect)frame style:(UITableViewStyle)style {
    if (self = [super initWithFrame:frame style:style]) {
        [self setup];
    }
    return self;
}


- (void)setup {
    self.delegate = self;
    self.dataSource = self;
    self.backgroundColor = kHXBColor_BackGround;
    [self registerClass:[HXBFinancting_PlanListTableViewCell class] forCellReuseIdentifier:CELLID];
    self.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.backgroundColor = kHXBColor_BackGround;
    self.nodataView.hidden = NO;
}

#pragma mark - datesource

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.planListViewModelArray.count;
}

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//    return self.planListViewModelArray.count;
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HXBFinancting_PlanListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CELLID forIndexPath:indexPath];
    cell.finPlanListViewModel = self.planListViewModelArray[indexPath.row];
    return cell;
}

#pragma mark - delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //拿到cell的model
    HXBFinancting_PlanListTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    //点击后的block回调给了HomePageView
    if (self.clickPlanListCellBlock) {
        self.clickPlanListCellBlock(indexPath, cell.finPlanListViewModel);
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    HXBFinHomePageViewModel_PlanList *model = self.planListViewModelArray[indexPath.row];
    
    CGFloat happyHeight = 33;
    if (model.planType == planType_newComer) {
        return model.hasHappyThing ? 98 + happyHeight : 98;
    } else {
        return model.hasHappyThing ? 132 + happyHeight : 132;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headView = [[UIView alloc] init];
    headView.backgroundColor = [UIColor whiteColor];
    
    UILabel *titleLabel = [UILabel new];
    titleLabel.text = @"新手专享";
    titleLabel.font = [UIFont boldSystemFontOfSize:kScrAdaptationW(17)];
    titleLabel.textColor = kHXBColor_333333_100;
    [headView addSubview:titleLabel];
    
    UILabel *descLabel = [UILabel new];
    descLabel.text = @"灵活高收益";
    descLabel.font = kHXBFont_24;
    descLabel.textColor = kHXBColor_333333_100;
    [headView addSubview:descLabel];
    
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@15);
        make.bottom.equalTo(headView);
    }];
    
    [descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(@-15);
        make.bottom.equalTo(headView);
    }];
    
    return headView;
}


- (HXBNoDataView *)nodataView {
    if (!_nodataView) {
        _nodataView = [[HXBNoDataView alloc]initWithFrame:CGRectZero];
        [self addSubview:_nodataView];
        _nodataView.imageName = kNodataViewImageName;
        _nodataView.noDataMassage = kNoDataMassage;
        [_nodataView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self).offset(kNodataViewTopSpacing);
            make.height.width.offset(kNodataViewHeight);
            make.centerX.equalTo(self);
        }];
    }
    return _nodataView;
}

@end
