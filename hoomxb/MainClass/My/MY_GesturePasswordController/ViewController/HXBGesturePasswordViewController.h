//
//  HXBGesturePasswordViewController.h
//  hoomxb
//
//  Created by HXB-C on 2017/6/20.
//  Copyright © 2017年 hoomsun-miniX. All rights reserved.
//

#import "HXBBaseViewController.h"
#import "HXBCheckLoginPasswordViewController.h"

typedef enum{
    GestureViewControllerTypeSetting = 1,
    GestureViewControllerTypeLogin
}GestureViewControllerType;

typedef enum{
    buttonTagReset = 1,
    buttonTagManager,
    buttonTagForget
    
}buttonTag;


@interface HXBGesturePasswordViewController : HXBBaseViewController

/**
 *  控制器来源类型
 */
@property (nonatomic, assign) GestureViewControllerType type;
/// 手势密码开关
@property (nonatomic, assign) HXBAccountSecureSwitchType switchType;

@property (nonatomic, strong) void (^dismissBlock)(BOOL delay, BOOL toActivity, BOOL popRightNow);

- (void)checkAlertSkipSetting;
@end
