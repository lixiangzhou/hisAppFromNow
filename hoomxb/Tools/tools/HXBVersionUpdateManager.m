//
//  HXBVersionUpdateManager.m
//  hoomxb
//
//  Created by HXB-C on 2017/12/13.
//Copyright © 2017年 hoomsun-miniX. All rights reserved.
//

#import "HXBVersionUpdateManager.h"
#import "HXBVersionUpdateModel.h"
#import "HXBRootVCManager.h"
#import "HXBHomePopViewManager.h"

@interface HXBVersionUpdateManager ()

/**
 是否展示过升级弹框
 */
@property (nonatomic, assign) BOOL isShow;
//只在appdelegate里面使用
@property (nonatomic, strong) HXBVersionUpdateModel *versionUpdateModel;

@end


@implementation HXBVersionUpdateManager

+ (instancetype)sharedInstance {
    static HXBVersionUpdateManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[HXBVersionUpdateManager alloc] initWithBlock:^UIView *{
            return [HXBRootVCManager manager].topVC.view;
        }];
    });
    return manager;
}

- (void)checkVersionUpdate {
    kWeakSelf
    NSString *version = [[[NSBundle mainBundle]infoDictionary]objectForKey:@"CFBundleShortVersionString"];
    
    NYBaseRequest *versionUpdateAPI = [[NYBaseRequest alloc] initWithDelegate:self];
    versionUpdateAPI.requestUrl = kHXBMY_VersionUpdateURL;
    versionUpdateAPI.requestMethod = NYRequestMethodPost;
    versionUpdateAPI.requestArgument = @{
                                         @"versionCode" : version
                                         };
    [versionUpdateAPI loadData:^(NYBaseRequest *request, id responseObject) {
        NSLog(@"%@",responseObject);
        NSInteger status =  [responseObject[@"status"] integerValue];
        if (status != 0) {
            
            weakSelf.isShow = YES;
            [[HXBHomePopViewManager sharedInstance] popHomeViewfromController:[HXBRootVCManager manager].topVC];//展示首页弹窗
            
        }
        else {
            
            weakSelf.versionUpdateModel = [HXBVersionUpdateModel yy_modelWithDictionary:responseObject[@"data"]];
            
            if ([KeyWindow.rootViewController isKindOfClass:NSClassFromString(@"HXBBaseTabBarController")]) {
                //获取顶部控制器
                if (![[HXBRootVCManager manager].topVC isKindOfClass:NSClassFromString(@"HXBGesturePasswordViewController")]) {
                    [weakSelf show];
                }
            }
        }
    } failure:^(NYBaseRequest *request, NSError *error) {
        weakSelf.isShow = YES;
        [[HXBHomePopViewManager sharedInstance] popHomeViewfromController:[HXBRootVCManager manager].topVC];//展示首页弹窗
    }];
}

- (void)show {
    if (self.versionUpdateModel && (!self.isShow)) {
        self.isShow = YES;
        [HXBAlertManager checkversionUpdateWith:self.versionUpdateModel];
    }
}


@end
