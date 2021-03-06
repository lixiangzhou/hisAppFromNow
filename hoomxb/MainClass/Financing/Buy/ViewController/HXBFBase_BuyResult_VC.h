//
//  HXBFin_BuySeccess_LoanTruansferVC.h
//  hoomxb
//
//  Created by HXB on 2017/7/20.
//  Copyright © 2017年 hoomsun-miniX. All rights reserved.
//

#import "HXBBaseViewController.h"

@interface HXBFBase_BuyResult_VC : HXBBaseViewController
/**
 image的名字
 */
@property (nonatomic,copy) NSString *imageName;
/**
 massage
 */
@property (nonatomic,copy) NSString * buy_title;
/**
 上下lable的View 有几层
 */
@property (nonatomic,assign) NSInteger buy_massageCount;
/**
 description
 */
@property (nonatomic,copy) NSString * buy_description;
/**
 button title
 */
@property (nonatomic,copy) NSString * buy_ButtonTitle;

/**
 左边的string Array
 */
@property (nonatomic,copy) NSArray *massage_Left_StrArray;
/**
 右边的string Array
 */
@property (nonatomic,copy) NSArray *massage_Right_StrArray;
/**
 邀请好友按钮文案
 */
@property (nonatomic, copy) NSString *inviteButtonTitle;
/**
 是否显示邀请好友按钮
 */
@property (nonatomic,  assign) BOOL isShowInviteBtn;
/**
 (可能没有，在button的顶部 100的地方)
 居中的label
 */
@property (nonatomic,copy) NSString *midStr;


- (void)clickButtonWithBlock:(void(^)())clickButtonBlock;
@end
