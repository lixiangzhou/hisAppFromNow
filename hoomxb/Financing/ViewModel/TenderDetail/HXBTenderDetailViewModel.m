//
//  HXBTenderDetailViewModel.m
//  hoomxb
//
//  Created by lxz on 2018/1/19.
//Copyright © 2018年 hoomsun-miniX. All rights reserved.
//

#import "HXBTenderDetailViewModel.h"

@implementation HXBTenderDetailViewModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.totalCount = @"0";
        self.pageSize = @"20";
    }
    return self;
}

- (NSMutableArray *)dataSource {
    if (_dataSource == nil) {
        _dataSource = [NSMutableArray array];
    }
    return _dataSource;
}

- (void)getData:(BOOL)isNew completion:(void (^)(BOOL))completion {
    NSInteger currentPage = ceil(self.dataSource.count * 1.0 / self.pageSize.integerValue);
    NSInteger page = 1;
    if (isNew == NO) {
        page = currentPage + 1;
    }

    NYBaseRequest *req = [NYBaseRequest new];
    req.requestUrl = kHXBFinanc_PlanInvestList;
    req.requestArgument = @{@"pageSize": self.pageSize,
                            @"page": @(page)};
    kWeakSelf
    [req startWithSuccess:^(NYBaseRequest *request, NSDictionary *responseObject) {
        NSInteger statusCode = [responseObject[kResponseStatus] integerValue];
        if (statusCode != kHXBCode_Success) {
            NSString *message = responseObject[kResponseMessage];
            [HxbHUDProgress showMessageCenter:message inView:weakSelf.view];
            completion(NO);
        } else {
            NSArray *temp = responseObject[kResponseData][@"dataList"];
            if (temp.count) {
                NSMutableArray *tempModels = [NSMutableArray new];
                for (NSInteger i = 0; i < temp.count; i++) {
                    [tempModels addObject:[HXBTenderDetailModel yy_modelWithDictionary:temp[i]]];
                }
                
                if (isNew) {
                    [self.dataSource removeAllObjects];
                    [self.dataSource addObjectsFromArray:tempModels];
                } else {
                    [self.dataSource addObjectsFromArray:tempModels];
                }
            }
            self.totalCount = responseObject[kResponseData][@"totalCount"];
            
            self.showNoMoreData = self.dataSource.count >= self.totalCount.integerValue;
            self.showPullup = self.totalCount.integerValue > self.pageSize.integerValue;
            completion(YES);
        }
    } failure:^(NYBaseRequest *request, NSError *error) {
        completion(NO);
    }];
}

@end
