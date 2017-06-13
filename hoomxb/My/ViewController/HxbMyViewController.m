//
//  HxbMyViewController.m
//  hoomxb
//
//  Created by HXB-C on 2017/4/19.
//  Copyright © 2017年 hoomsun-miniX. All rights reserved.
//

#import "HxbMyViewController.h"
#import "AppDelegate.h"
#import "HxbMyView.h"
#import "HxbAccountInfoViewController.h"
#import "HxbMyTopUpViewController.h"
#import "HxbWithdrawViewController.h"

@interface HxbMyViewController ()<MyViewDelegate>
@property (nonatomic,copy) NSString *imageName;
@end

@implementation HxbMyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.imageName = @"1";
    //防止跳转的时候，tableView向上或者向下移动
    if ([self respondsToSelector:@selector(automaticallyAdjustsScrollViewInsets)]) {
        self.automaticallyAdjustsScrollViewInsets = true;
    };
    //登录的测试

//    对controllerView进行布局
    [self setupSubView];
    //对controllerView进行布局
    //    [self setupSubView];

    
//    //散标列表 红利计划的Button
//    [self setupBUTTON];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

//MARK: 对controllerView进行布局
- (void)setupSubView {
    [self setupMyView];
}

- (void)setupMyView{
    HxbMyView *myView = [[HxbMyView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    myView.delegate = self;
    myView.userInteractionEnabled = YES;
    [self.view addSubview:myView];
}



- (void)didLeftHeadBtnClick:(UIButton *)sender{
    HxbAccountInfoViewController *accountInfoVC = [[HxbAccountInfoViewController alloc]init];
    [self.navigationController pushViewController:accountInfoVC animated:YES];
}
/// 提现
- (void)didClickTopUpBtn:(UIButton *)sender{
    HxbMyTopUpViewController *hxbMyTopUpViewController = [[HxbMyTopUpViewController alloc]init];
    [self.navigationController pushViewController:hxbMyTopUpViewController animated:YES];
}

- (void)didClickWithdrawBtn:(UIButton *)sender{
    HxbWithdrawViewController *withdrawViewController = [[HxbWithdrawViewController alloc]init];
    [self.navigationController pushViewController:withdrawViewController animated:YES];
}
- (void)clickBarButtonItem {
    NSLog(@"点击了返回按钮");
}

- (void)clickMyLoanButton: (UIButton *)button {
    NSLog(@"%@ - 散标被点击",self.class);
}
@end
