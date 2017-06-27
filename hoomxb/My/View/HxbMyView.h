//
//  HxbMyView.h
//  hoomxb
//
//  Created by HXB-C on 2017/5/3.
//  Copyright © 2017年 hoomsun-miniX. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol MyViewDelegate
- (void)didLeftHeadBtnClick:(UIButton *_Nullable)sender;
- (void)didClickTopUpBtn:(UIButton *_Nullable)sender;
- (void)didClickWithdrawBtn:(UIButton *_Nullable)sender;
@end
@interface HxbMyView : UIView
@property (nonatomic, strong) HXBRequestUserInfoViewModel * _Nonnull userInfoViewModel;
@property (nonatomic,weak,nullable) id<MyViewDelegate>delegate;
///点击了 总资产
- (void)clickAllFinanceButtonWithBlock: (void(^_Nullable)(UILabel * _Nullable button))clickAllFinanceButtonBlock;
@end
