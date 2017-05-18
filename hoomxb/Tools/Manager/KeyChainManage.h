//
//  KeyChainManage.h
//  HongXiaoBao
//
//  Created by 牛严 on 16/6/16.
//  Copyright © 2016年 hongxb. All rights reserved.
//

#import <Foundation/Foundation.h>

#define KeyChain [KeyChainManage sharedInstance]

@interface KeyChainManage : NSObject

/**
 *  获取KeyChainManage单例
 */
+ (instancetype)sharedInstance;

@property (nonatomic, copy) NSString *token;
@property (nonatomic, copy) NSString *phone;
@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString *userName;
@property (nonatomic, copy) NSString *inviteCode;

@property (nonatomic, copy) NSString *loginPwd;
@property (nonatomic, copy) NSString *tradePwd;
@property (nonatomic, copy) NSString *gesturePwd;

@property (nonatomic, copy) NSString *realId;           //!< 身份证
@property (nonatomic, copy) NSString *realName;         //!<
@property (nonatomic, copy) NSString *defBankNum;

@property (nonatomic, copy) NSString *avatarImageURL;
@property (nonatomic, copy) NSData *localAvatarImageData;

@property (nonatomic, strong) NSArray *bankNumArr;

@property (nonatomic, assign, readonly) BOOL isLogin;

@property (nonatomic, strong) NSString *assetsTotal;

- (void)removePassword;     //!< 移除密码

- (void)removeToken;        //!< 移除token

- (BOOL)removeAllInfo;

- (BOOL)isSwitchOn;         //!<手势密码是否开启

- (BOOL)isVerify;           //!<是否已经实名

- (BOOL)hasBindBankcard;    //!<已经绑定了银行卡

- (void)printAllInfo;

- (BOOL)isInvest;
@end
