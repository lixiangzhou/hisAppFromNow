//
//  HXBHomePopViewRequest.m
//  hoomxb
//
//  Created by hxb on 2017/12/13.
//  Copyright © 2017年 hoomsun-miniX. All rights reserved.
//

#import "HXBHomePopViewRequest.h"
#import "HXBBaseRequest.h"///网络数据的请求

@implementation HXBHomePopViewRequest

#pragma mark -  数据请求

+ (void)homePopViewRequestSuccessBlock: (void(^)(id responseObject))successDateBlock andFailureBlock: (void(^)(NSError *error))failureBlock
{
    NYBaseRequest *versionUpdateAPI = [[NYBaseRequest alloc] init];
    versionUpdateAPI.requestUrl = kHXBHome_PopView;
    versionUpdateAPI.requestMethod = NYRequestMethodGet;
//    versionUpdateAPI.requestArgument = @{
//                                         @"versionCode" : versionCode
//                                         };
    [versionUpdateAPI startWithSuccess:^(NYBaseRequest *request, id responseObject) {
        NSInteger status =  [responseObject[@"status"] integerValue];
        
        if (status) {
            kHXBResponsShowHUD
        }
        
        if (successDateBlock) {
            successDateBlock(responseObject);
        }
    } failure:^(NYBaseRequest *request, NSError *error) {
        if (failureBlock) {
            failureBlock(error);
        }
    }];
}



@end
