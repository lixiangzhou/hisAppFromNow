//
//  HxbHUDProgress.m
//  hoomxb
//
//  Created by HXB-C on 2017/4/18.
//  Copyright © 2017年 hoomsun-miniX. All rights reserved.
//

#import "HxbHUDProgress.h"
@interface HxbHUDProgress () <MBProgressHUDDelegate>
@property (strong, nonatomic) MBProgressHUD *HUD;
@property (assign, nonatomic)int  mTime;
//@property (nonatomic, strong) ToastAnimationView *animtionView;
@end


@implementation HxbHUDProgress
{
    NSTimer *timer;
}

+ (void)errorWithErrorCode:(NSInteger)errorCode{
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    MBProgressHUD *HUD = [[MBProgressHUD alloc]initWithWindow:keyWindow];
    [keyWindow addSubview:HUD];
    if (errorCode == 401) {
        NSString *text = @"验证失效,请您重新刷新";
        HUD.detailsLabelText = text;
        HUD.detailsLabelFont = [UIFont systemFontOfSize:16];
        HUD.mode = MBProgressHUDModeText;
        
        int sec = text.length > 6? 2:1;
        
        [HUD showAnimated:YES whileExecutingBlock:^{
            sleep(sec);
        } completionBlock:^{
            [HUD removeFromSuperview];
        }];
    }
}

+ (void)errorWithErrorCode:(int )errorCode message:(NSString *)message{
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    MBProgressHUD *HUD = [[MBProgressHUD alloc]initWithWindow:keyWindow];
    [keyWindow addSubview:HUD];
        NSString *text = message;
        HUD.detailsLabelText = text;
        HUD.detailsLabelFont = [UIFont systemFontOfSize:16];
        HUD.mode = MBProgressHUDModeText;
        
        int sec = text.length > 6? 2:1;
        
        [HUD showAnimated:YES whileExecutingBlock:^{
            sleep(sec);
        } completionBlock:^{
            [HUD removeFromSuperview];
        }];
 
}

- (void)showAnimationWithText:(NSString *)text
{
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    _HUD = [[MBProgressHUD alloc]initWithWindow:keyWindow];
    
    [keyWindow addSubview:_HUD];
    _HUD.labelText = text;
    _HUD.delegate = self;//添加代理
    
    [_HUD show:YES];
    self.mTime =0;
    timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerFired:) userInfo:nil repeats:30];
    timer.fireDate = [NSDate distantPast];
    
}

-(void)timerFired:(NSTimer *)time{
    
    self.mTime++;
    
    if (self.mTime >= 12) {
        timer.fireDate = [NSDate distantFuture];
        [self hide];
    }
}

-(void)hide
{
    [_HUD hide:YES];
    if (timer) {
        timer.fireDate = [NSDate distantFuture];
    }
    
}

#pragma mark MBProgressHUD代理方法
-(void)hudWasHidden:(MBProgressHUD *)hud
{
    [_HUD removeFromSuperview];
    if (_HUD != nil) {
        _HUD = nil;
    }
}
@end