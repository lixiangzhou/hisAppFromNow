//
//  HXBFinanctingRequest.m
//  hoomxb
//
//  Created by HXB on 2017/5/3.
//  Copyright © 2017年 hoomsun-miniX. All rights reserved.
//

#import "HXBFinanctingRequest.h"
#import "HXBBaseRequest.h"///网络数据请求

//MARK: - 列表页
#import "HXBFinHomePageViewModel_PlanList.h"//红利计划的的ViewModel
#import "HXBFinHomePageViewModel_LoanList.h"//散标列表的ViewModel
#import "HXBFinHomePageModel_PlanList.h"//红利计划列表页的Model
#import "HXBFinHomePageModel_LoanList.h"//散标列表的model


//MARK: - 详情页
#import "HXBFinDetailViewModel_PlanDetail.h"//红利计划详情的ViewModel
#import "HXBFinDetailModel_PlanDetail.h"//红利计划详情页Model

#import "HXBFinDetailViewModel_LoanDetail.h"//散标详情ViewModel
#import "HXBFinDatailModel_LoanDetail.h"//散标Model

//MARK: - 加入记录
#import "HXBFinModel_AddRecortdModel_Plan.h"//加入记录的model


@interface HXBFinanctingRequest ()
#pragma mark - Plan
///红利计划 列表API
@property (nonatomic,strong) HXBBaseRequest *planListAPI;
///红利计划 详情API
@property (nonatomic,strong) HXBBaseRequest *planDetaileAPI;
///红利计划 加入记录API
@property (nonatomic,strong) HXBBaseRequest *planAddRecortdAPI;


#pragma mark - Loan
///散标 列表的API
@property (nonatomic,strong) HXBBaseRequest *loanListAPI;
///散标 详情的API
@property (nonatomic,strong) HXBBaseRequest *loanDetaileAPI;

//红利计划列表的数据数组
@property (nonatomic,strong) NSMutableArray <HXBFinHomePageViewModel_PlanList *>*planListViewModelArray;
@property (nonatomic,strong) NSMutableArray <HXBFinHomePageViewModel_LoanList *>*loanListViewModelArray;
@end


@implementation HXBFinanctingRequest


- (HXBBaseRequest *) planListAPI {
    if (!_planListAPI) {
        _planListAPI = [[HXBBaseRequest alloc]init];
    }
    return _planListAPI;
}
- (HXBBaseRequest *) planDetaileAPI {
    if (!_planDetaileAPI) {
        _planDetaileAPI = [[HXBBaseRequest alloc]init];
    }
    return _planDetaileAPI;
}

- (HXBBaseRequest *) planAddRecortdAPI {
    if (!_planAddRecortdAPI) {
        _planAddRecortdAPI = [[HXBBaseRequest alloc]init];
    }
    return _planAddRecortdAPI;
}

- (HXBBaseRequest *) loanListAPI {
    if (!_loanListAPI) {
        _loanListAPI = [[HXBBaseRequest alloc]init];
    }
    return _loanListAPI;
}
- (HXBBaseRequest *) loanDetaileAPI {
    if (!_loanDetaileAPI) {
        _loanDetaileAPI = [[HXBBaseRequest alloc]init];
    }
    return _loanDetaileAPI;
}


- (instancetype)init {
    if (self = [super init]){
        self.planListViewModelArray = [[NSMutableArray alloc]init];
        self.loanListViewModelArray = [[NSMutableArray alloc]init];
    }
    return self;
}

+ (instancetype)sharedFinanctingRequest {
    static dispatch_once_t onceToken;
    static id _instanceType;
    dispatch_once(&onceToken, ^{
        _instanceType = [[self alloc]init];
    });
    return _instanceType;
}


#pragma mark - setter

#pragma mark - homePage reaquest

//MARK: 红利计划列表api
- (void)planBuyListWithIsUpData: (BOOL)isUPData andSuccessBlock: (void(^)(NSArray<HXBFinHomePageViewModel_PlanList *>* viewModelArray))successDateBlock andFailureBlock: (void(^)(NSError *error))failureBlock {
    //是否为上拉刷新
    self.planListAPI.requestUrl = kHXBFinanc_PlanLisetURL(self.planListAPI.dataPage);
    self.planListAPI.isUPReloadData = isUPData;
    self.planListAPI.requestMethod = NYRequestMethodGet;
    [self.planListAPI startWithSuccess:^(HXBBaseRequest *request, id responseObject) {
        ///数据是否出错
        kHXBResponsShowHUD
        
        NSArray <NSDictionary *>* dataList = responseObject[@"data"][@"dataList"];
        NSMutableArray <HXBFinHomePageViewModel_PlanList *>*planListViewModelArray = [[NSMutableArray alloc]init];
        
        [dataList enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
           HXBFinHomePageModel_PlanList *financtingPlanListModel = [[HXBFinHomePageModel_PlanList alloc]init];
            //创建viewModel
            HXBFinHomePageViewModel_PlanList *financtingPlanListViewModel = [[HXBFinHomePageViewModel_PlanList alloc]init];
            //字典转模型
            [financtingPlanListModel yy_modelSetWithDictionary:obj];
            //给viewModel赋值MODEL
            financtingPlanListViewModel.planListModel = financtingPlanListModel;
            [planListViewModelArray addObject:financtingPlanListViewModel];
        }];
        //数据的处理
        [self plan_handleDataWithIsUPData:request.isUPReloadData andData:planListViewModelArray];
        
        if(!self.planListViewModelArray.count) {
            kNetWorkError(@"计划列表 没有数据");
            if(failureBlock) failureBlock(nil);
            return;
        }
        if (successDateBlock) successDateBlock(self.planListViewModelArray);
        
    } failure:^(NYBaseRequest *request, NSError *error) {
        if (error && failureBlock) {
            kNetWorkError(@"");
            failureBlock(error);
        }
    }];
}
///数据的处理
- (void)plan_handleDataWithIsUPData: (BOOL)isUPData andData: (NSArray<HXBFinHomePageViewModel_PlanList *>*)viewModelArray {
    if (isUPData) {
        [self.planListViewModelArray removeAllObjects];
    }
    //是否为重复数据
    __block BOOL isErrorData = false;
    //遍历，看是请求的数据为一样的数据
    [self.planListViewModelArray enumerateObjectsUsingBlock:^(HXBFinHomePageViewModel_PlanList * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([viewModelArray.firstObject.planListModel.ID isEqualToString:obj.planListModel.ID]) {
            kNetWorkError(@"红利计划列表页的 追加数据出现重复数据, 已经返回");
            isErrorData = true;
            *stop = true;
        }
    }];
    //如果是重复数据，那么就return
    if (isErrorData) return;
    [self.planListViewModelArray addObjectsFromArray:viewModelArray];
}

//MARK: 散标列表api
- (void)loanBuyListWithIsUpData: (BOOL)isUPData andSuccessBlock: (void(^)(NSArray<HXBFinHomePageViewModel_LoanList *>* viewModelArray))successDateBlock andFailureBlock: (void(^)(NSError *error))failureBlock {
    self.loanListAPI.isUPReloadData = isUPData;
    self.loanListAPI.requestUrl =  kHXBFinanc_LoanListURL(self.loanListAPI.dataPage);
    self.loanListAPI.requestMethod = NYRequestMethodGet;

    [self.loanListAPI startWithSuccess:^(NYBaseRequest *request, id responseObject) {
        kHXBResponsShowHUD
        //数据
        NSArray <NSDictionary *>* dataList = responseObject[@"data"][@"dataList"];
        
        if (!responseObject || !dataList.count) {
            NSLog(@"✘散标列表请求没有数据");
        }
        NSMutableArray <HXBFinHomePageViewModel_LoanList *>*loanDataListModelArray = [[NSMutableArray alloc]init];
        
        [dataList enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            HXBFinHomePageModel_LoanList *financtingLoanListModel = [[HXBFinHomePageModel_LoanList alloc]init];
            //创建viewModel
            HXBFinHomePageViewModel_LoanList *financtingLoanListViewModel = [[HXBFinHomePageViewModel_LoanList alloc]init];
            //字典转模型
            [financtingLoanListModel yy_modelSetWithDictionary:obj];
            //给viewModel赋值MODEL
            financtingLoanListViewModel.loanListModel = financtingLoanListModel;
            [loanDataListModelArray addObject:financtingLoanListViewModel];
        }];
        //回调
        [self loan_handleDataWithIsUPData:self.loanListAPI.isUPReloadData andViewModel:loanDataListModelArray];
        
        ///没有数据的话，也算出错
        if (!self.loanListViewModelArray.count) {
            kNetWorkError(@"散标列表 没有数据");
            if(failureBlock) failureBlock(nil);
            return;
        }
        ///请求成功
        if (successDateBlock) successDateBlock(self.loanListViewModelArray);
        
    } failure:^(NYBaseRequest *request, NSError *error) {
        if (error && failureBlock) {
             NSLog(@"✘散标购买请求没有数据");
            failureBlock(error);
        }
    }];
}

- (void)loan_handleDataWithIsUPData: (BOOL)isUPData andViewModel: (NSArray <HXBFinHomePageViewModel_LoanList *>*)loan_viewModelArray {
    if (isUPData) {
        [self.loanListViewModelArray removeAllObjects];
    }
    __block BOOL isErrorData = false;
    [self.loanListViewModelArray enumerateObjectsUsingBlock:^(HXBFinHomePageViewModel_LoanList * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([loan_viewModelArray.firstObject.loanListModel.loanId isEqualToString:obj.loanListModel.loanId]) {
            kNetWorkError(@"理财 - loan列表页的 追加数据出现重复数据, 已经返回");
            isErrorData = true;
            *stop = true;
        }
    }];
    if(isErrorData) return;
    if (loan_viewModelArray.count) {
        [self.loanListViewModelArray addObjectsFromArray:loan_viewModelArray];
    }
}

#define kHXBFinanc_PlanDetaileURL(planID) [NSString stringWithFormat:@"/plan/%ld",(planID)]
#pragma mark - 详情页 数据请求
- (void)planDetaileWithPlanID: (NSString *)financePlanId andSuccessBlock: (void(^)(HXBFinDetailViewModel_PlanDetail* viewModel))successDateBlock andFailureBlock: (void(^)(NSError *error))failureBlock{
    
    self.planDetaileAPI.requestUrl = kHXBFinanc_PlanDetaileURL(financePlanId.integerValue);
    self.planDetaileAPI.requestMethod = NYRequestMethodGet;
    
    [self.planDetaileAPI startWithSuccess:^(NYBaseRequest *request, id responseObject) {
        ///数据是否出错
        NSString *status = responseObject[kResponseStatus];
        if (status.integerValue) {
            kNetWorkError(@"计划详情页 没有数据");
            if(failureBlock) failureBlock(nil);
            return;
        }
        NSDictionary *planDetaileDic = [responseObject valueForKey:@"data"];
        HXBFinDetailModel_PlanDetail *planDetaileModel = [[HXBFinDetailModel_PlanDetail alloc]init];
        [planDetaileModel yy_modelSetWithDictionary:planDetaileDic];
        HXBFinDetailViewModel_PlanDetail *planDetailViewModel = [[HXBFinDetailViewModel_PlanDetail alloc]init];
        planDetailViewModel.planDetailModel = planDetaileModel;
        ///回调
        if (successDateBlock) successDateBlock(planDetailViewModel);
    } failure:^(NYBaseRequest *request, NSError *error) {
        if (error && failureBlock) {
            kNetWorkError(@"红利计划详情")
            failureBlock(error);
        }
    }];
}

///标的详情页
- (void)loanDetaileWithLoanID: (NSString *)financeLoanId andSuccessBlock: (void(^)(HXBFinDetailViewModel_LoanDetail* viewModel))successDateBlock andFailureBlock: (void(^)(NSError *error))failureBlock{
    
    self.loanDetaileAPI.requestUrl = kHXBFinanc_LoanDetaileURL(financeLoanId.integerValue);
    self.loanDetaileAPI.requestMethod = NYRequestMethodGet;
    
    [self.loanDetaileAPI startWithSuccess:^(NYBaseRequest *request, id responseObject) {
        
        ///数据是否出错
        NSString *status = responseObject[kResponseStatus];
        if (status.integerValue) {
            kNetWorkError(@"计划详情页 没有数据");
            if(failureBlock) failureBlock(nil);
            return;
        }
        
        NSDictionary *planDetaileDic = [responseObject valueForKey:@"data"];
        HXBFinDatailModel_LoanDetail *loanDetaileModel = [[HXBFinDatailModel_LoanDetail alloc]init];
        [loanDetaileModel yy_modelSetWithDictionary:planDetaileDic];
        HXBFinDetailViewModel_LoanDetail *loanDetailViewModel = [[HXBFinDetailViewModel_LoanDetail alloc]init];
        loanDetailViewModel.loanDetailModel = loanDetaileModel;
        if (!loanDetailViewModel.loanDetailModel) {
            kNetWorkError(@"散标详情 没有数据");
            if(failureBlock) failureBlock(nil);
            return;
        }
        if (successDateBlock) {
            successDateBlock(loanDetailViewModel);
        }
    } failure:^(NYBaseRequest *request, NSError *error) {
        if (error && failureBlock) {
            kNetWorkError(@"✘散标计划详情 - 请求没有数据")
            failureBlock(error);
        }
    }];
}


#pragma mark - 红利计划详情页 - 加入记录
- (void)planAddRecortdWithISUPLoad: (BOOL)isUPLoad andFinancePlanId: (NSString *)financePlanId andOrder: (NSString *)order andSuccessBlock: (void(^)(HXBFinModel_AddRecortdModel_Plan * model))successDateBlock andFailureBlock: (void(^)(NSError *error))failureBlock {

    self.planAddRecortdAPI.requestMethod = NYRequestMethodGet;
    self.planAddRecortdAPI.requestUrl = kHXBFinanc_Plan_AddRecortdURL(financePlanId);
    
    [self.planAddRecortdAPI startWithSuccess:^(NYBaseRequest *request, id responseObject) {
        kHXBResponsShowHUD
        HXBFinModel_AddRecortdModel_Plan *planAddRecortdModel = [[HXBFinModel_AddRecortdModel_Plan alloc]init];
        NSDictionary *dataDic = [responseObject valueForKey:@"data"];
        [planAddRecortdModel yy_modelSetWithDictionary:dataDic];
        if (successDateBlock) {
            successDateBlock(planAddRecortdModel);
        }
    } failure:^(NYBaseRequest *request, NSError *error) {
        NSLog(@"✘ 红利计划的详情页 - 加入计划 - 网络请求失败");
        if (error) {
            failureBlock(error);
        }
    }];
}
@end
