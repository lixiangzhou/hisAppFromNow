//
//  Animatr.m
//  PYTransitionAnimation
//
//  Created by 李鹏跃 on 17/3/13.
//  Copyright © 2017年 13lipengyue. All rights reserved.
//

#import "Animatr.h"
#import "AnimatedTransition.h"
#import "PYPresentationController.h"//非交互式

@interface Animatr ()
//MARK: ---------------------- dismiss & present ------------------------
/**dismiss动画*/
@property (nonatomic,copy) void(^dismissAnimaBlock)(UIViewController *toVC, UIViewController *fromeVC, UIView *toView, UIView *fromeView);

/**present动画*/
@property (nonatomic,copy) void(^presentAnimaBlock)(UIViewController *toVC, UIViewController *fromeVC, UIView *toView, UIView *fromeView);

/**containerView*/
@property (nonatomic,copy) void(^setupContainerViewBlock)(UIView *containerView);

/**非交互式 转场动画执行者*/
@property (nonatomic,strong) AnimatedTransition *animatedTransition;
@end



@implementation Animatr

+ (instancetype)animatrWithModalPresentationStyle: (UIModalPresentationStyle)modalPresentationStyle{
    return [[self alloc]initWithModalPresentationStyle:modalPresentationStyle];
}
- (instancetype)initWithModalPresentationStyle: (UIModalPresentationStyle)modalPresentationStyle{
    if (self = [super init]) {
        self.modalPresentationStyle = modalPresentationStyle;
    }
    return self;
}




- (void)setIsAccomplishAnima:(BOOL)isAccomplishAnima {
    _isAccomplishAnima = isAccomplishAnima;
    self.animatedTransition.isAccomplishAnima = isAccomplishAnima;
}
- (void)setModalPresentationStyle:(UIModalPresentationStyle)modalPresentationStyle {
    _modalPresentationStyle = modalPresentationStyle;
    self.animatedTransition.modalPresentationStyle = modalPresentationStyle;
}

//MARK: --------------- 懒加载 -----------------------
- (AnimatedTransition *)animatedTransition {
    if (!_animatedTransition) {
        _animatedTransition = [[AnimatedTransition alloc]init];
    }
    return _animatedTransition;
}



//MAKR: --------------- dismiss & present 方法实现 ------------------
- (void)presentAnimaWithBlock:(void (^)(UIViewController *, UIViewController *, UIView *, UIView *))presentAnimaBlock {
    self.presentAnimaBlock = presentAnimaBlock;
}

- (void)dismissAnimaWithBlock:(void (^)(UIViewController *, UIViewController *, UIView *, UIView *))dismissAnimaBlock {
    self.dismissAnimaBlock = dismissAnimaBlock;
}


//MARK: ---------------------- setupContainerView ------------------------
- (void)setupContainerViewWithBlock: (void(^)(UIView *containerView))setupContainerViewBlock{
    self.setupContainerViewBlock = setupContainerViewBlock;
}


//MARK: ----------------- presentationController --------------------------
//如果内部改变了toview的frame 那么在做动画的时候会出现问题
/////内部对fromVC与toVC进行了UI界面的布局 (1.先走这个方法)
- (UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented presentingViewController:(UIViewController *)presenting sourceViewController:(UIViewController *)source
{
    PYPresentationController * presentationController = [[PYPresentationController alloc]initWithPresentedViewController:presented presentingViewController:presenting];    
    return presentationController;
}


//MARK: ----------------- present --------------------------
///前两个方法是针对动画切换的，我们需要分别在呈现VC和解散VC时，给出一个实现了UIViewControllerAnimatedTransitioning接口的对象（其中包含切换时长和如何切换）。
- (id<UIViewControllerAnimatedTransitioning>) animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    //动画类型
    self.animatedTransition.animatedTransitionType = AnimatedTransitionType_Present;
    //动画时长
    self.animatedTransition.presentDuration = self.presentDuration;
    //容器视图
    [self.animatedTransition setupContainerViewWithBlock:^(UIView *containerView) {
        if (self.setupContainerViewBlock) {
            self.setupContainerViewBlock(containerView);
        }
    }];
    //动画传递
    [self.animatedTransition presentAnimaWithBlock:^(UIViewController *toVC, UIViewController *fromeVC, UIView *toView, UIView *fromeView) {
        if (self.presentAnimaBlock) {
            self.presentAnimaBlock(toVC,fromeVC,toView,fromeView);
        }
    }];
    return self.animatedTransition;
}


//MARK: ------------------- Dismissed -------------------
-(id< UIViewControllerAnimatedTransitioning >)animationControllerForDismissedController:(UIViewController *)dismissed{
    
    //动画类型
    self.animatedTransition.animatedTransitionType = AnimatedTransitionType_Dismiss;
    //动画时长
    self.animatedTransition.dismissDuration = self.dismissDuration;
    //容器视图
    [self.animatedTransition setupContainerViewWithBlock:^(UIView *containerView) {
        if (self.setupContainerViewBlock) {
            self.setupContainerViewBlock(containerView);
        }
    }];
    //动画传递
    [self.animatedTransition dismissAnimaWithBlock:^(UIViewController *toVC, UIViewController *fromeVC, UIView *toView, UIView *fromeView) {
        if (self.dismissAnimaBlock) {
            self.dismissAnimaBlock(toVC,fromeVC,toView,fromeView);
        }
    }];
    return self.animatedTransition;
}

////MARK: -------------------- 3 -------------------
////交互类型的动画
-(id< UIViewControllerInteractiveTransitioning >)interactionControllerForPresentation:(id < UIViewControllerAnimatedTransitioning >)animator{

    return nil;
}

-(id< UIViewControllerInteractiveTransitioning >)interactionControllerForDismissal:(id < UIViewControllerAnimatedTransitioning >)animator {
    return nil;
}

@end
