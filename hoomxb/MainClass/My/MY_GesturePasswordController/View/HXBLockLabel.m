//
//  HXBLockLabel.m
//  hoomxb
//
//  Created by HXB-C on 2017/6/20.
//  Copyright © 2017年 hoomsun-miniX. All rights reserved.
//

#import "HXBLockLabel.h"
#import "HXBCircleViewConst.h"
#import "CALayer+Anim.h"

@implementation HXBLockLabel

-(instancetype)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    
    if(self){
        
        //视图初始化
        [self viewPrepare];
    }
    
    return self;
}



-(id)initWithCoder:(NSCoder *)aDecoder{
    
    self=[super initWithCoder:aDecoder];
    
    if(self){
        
        //视图初始化
        [self viewPrepare];
    }
    
    return self;
}


/*
 *  视图初始化
 */
-(void)viewPrepare{
    
    [self setFont:[UIFont systemFontOfSize:14.0f]];
    [self setTextAlignment:NSTextAlignmentCenter];
}


/*
 *  普通提示信息
 */
-(void)showNormalMsg:(NSString *)msg{
    
    [self setText:msg];
    [self setTextColor:textColorNormalState];
}

/*
 *  警示信息
 */
-(void)showWarnMsg:(NSString *)msg{
    
    [self setText:msg];
    [self setTextColor:textColorWarningState];
}

/*
 *  警示信息(shake)
 */
-(void)showWarnMsgAndShake:(NSString *)msg{
    
    [self setText:msg];
    [self setTextColor:textColorWarningState];
    
    //添加一个shake动画
    [self.layer shake];
}

@end
