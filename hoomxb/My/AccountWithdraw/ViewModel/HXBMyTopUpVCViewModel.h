//
//  HXBMyTopUpVCViewModel.h
//  hoomxb
//
//  Created by HXB-C on 2018/2/7.
//  Copyright © 2018年 hoomsun-miniX. All rights reserved.
//

#import "HXBBaseViewModel.h"
#import "HXBBaseViewModel+KEYCHAIN.h"

@interface HXBMyTopUpVCViewModel : HXBBaseViewModel

/**
 快捷充值确认
 
 @param smscode 短信验证码
 @param amount 充值金额
 */
- (void)accountRechargeResultRequestWithSmscode:(NSString *)smscode andWithQuickpayAmount:(NSString *)amount andCallBackBlock:(void(^)(BOOL isSuccess))callBackBlock;

@end
