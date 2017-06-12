//
//  HxbSecurityCertificationViewController.m
//  hoomxb
//
//  Created by HXB-C on 2017/5/3.
//  Copyright © 2017年 hoomsun-miniX. All rights reserved.
//

#import "HxbSecurityCertificationViewController.h"
#import "HxbSecurityCertificationView.h"
#import "HxbBindCardViewController.h"

@interface HxbSecurityCertificationViewController ()

@end

@implementation HxbSecurityCertificationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"安全认证";
    HxbSecurityCertificationView *securityCertificationView = [[HxbSecurityCertificationView alloc]initWithFrame:self.view.frame];
    [self.view addSubview:securityCertificationView];
    
    ///点击了next
    [securityCertificationView clickNextButtonFuncWithBlock:^(NSString *name, NSString *idCard, NSString *transactionPassword) {
        
        [self dismissViewControllerAnimated:true completion:nil];
        //查看是否安全认证 （获取用户信息）
        [HXBRequestUserInfo downLoadUserInfoWithSeccessBlock:^(HXBRequestUserInfoViewModel *viewModel) {
           
        } andFailure:^(NSError *error) {
            
        }];
        
        if (![KeyChain hasBindBankcard]) {
            HxbBindCardViewController *bindCardVC = [[HxbBindCardViewController alloc]init];
            [self.navigationController pushViewController:bindCardVC animated:YES];
        }else {
          
        }
    }];
}

- (void)requestSecurityCertification {
    
}


- (void)didClickSecurityCertificationButton{
//    [HxbHUDProgress showTextWithMessage:@"点了"];
    
   
}

@end