//
//  HXBMyPlanDetailsViewModel.h
//  hoomxb
//
//  Created by HXB-xiaoYang on 2018/2/7.
//Copyright © 2018年 hoomsun-miniX. All rights reserved.
//

#import "HXBBaseViewModel.h"
@class HXBMYViewModel_PlanDetailViewModel;
@class HXBMYModel_PlanDetailModel;

@interface HXBMyPlanDetailsViewModel : HXBBaseViewModel
// 计划列表详情数据源
@property (nonatomic, readonly, strong) HXBMYViewModel_PlanDetailViewModel *planDetailsViewModel;

/**
 * 计划列表详情接口
 * @param planID 计划id
 */
- (void)accountPlanListDetailsRequestWithPlanID: (NSString *)planID
                                    resultBlock: (void(^)(BOOL isSuccess))resultBlock;
@end