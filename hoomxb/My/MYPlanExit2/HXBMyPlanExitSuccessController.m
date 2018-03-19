//
//  HXBMyPlanExitSuccessController.m
//  hoomxb
//
//  Created by lxz on 2018/3/13.
//Copyright © 2018年 hoomsun-miniX. All rights reserved.
//

#import "HXBMyPlanExitSuccessController.h"
#import "HXBMY_PlanList_DetailViewController.h"

@interface HXBMyPlanExitSuccessController ()

@end

@implementation HXBMyPlanExitSuccessController

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"红利计划退出";
    [self setUI];  
}

#pragma mark - UI

- (void)setUI {
    self.isRedColorWithNavigationBar = YES;
    
    UIImageView *iconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"successful"]];
    iconView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:iconView];
    
    UILabel *resultLabel = [[UILabel alloc] init];
    resultLabel.textColor = kHXBFountColor_333333_100;
    resultLabel.font = kHXBFont_36;
    resultLabel.text = self.titleString;
    [self.view addSubview:resultLabel];
    
    UILabel *descLabel = [UILabel new];
    descLabel.numberOfLines = 0;
    descLabel.font = kHXBFont_26;
    descLabel.textColor = kHXBFountColor_666666_100;
    descLabel.text = self.descString;
    [self.view addSubview:descLabel];
    
    UIButton *btn = [UIButton new];
    btn.layer.cornerRadius = 4;
    btn.layer.masksToBounds = YES;
    [btn setTitle:@"完成" forState:UIControlStateNormal];
    [btn setTitleColor:kHXBFountColor_White_FFFFFF_100 forState:UIControlStateNormal];
    btn.backgroundColor = kHXBColor_F55151_100;
    [btn addTarget:self action:@selector(confirm) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    [iconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(@(72));
        make.top.equalTo(@(45 + HXBStatusBarAndNavigationBarHeight));
        make.centerX.equalTo(self.view);
    }];
    
    [resultLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(iconView.mas_bottom).offset(31);
        make.centerX.equalTo(self.view);
    }];
    
    [descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(resultLabel.mas_bottom).offset(20);
        make.left.equalTo(@20);
        make.right.equalTo(@-20);
    }];
    
    [btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(descLabel.mas_bottom).offset(39);
        make.left.right.equalTo(descLabel);
        make.height.equalTo(@41);
    }];
}

#pragma mark - Action
- (void)confirm {
    __block UIViewController *vc = nil;
    [self.navigationController.childViewControllers enumerateObjectsUsingBlock:^(__kindof UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[HXBMY_PlanList_DetailViewController class]]) {
            vc = obj;
            *stop = YES;
        }
    }];
    if (vc) {
        [self.navigationController popToViewController:vc animated:YES];
    }
}


- (void)leftBackBtnClick {
    [self confirm];
}

@end