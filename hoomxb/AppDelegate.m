//
//  AppDelegate.m
//  hoomxb
//
//  Created by HXB-C on 2017/4/11.
//  Copyright © 2017年 hoomsun-miniX. All rights reserved.
//

#import "AppDelegate.h"
#import "NYNetwork.h"//网络请求的kit
#import "HXBBaseTabBarController.h"//自定义的tabBarController
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    //配置网络
    [self setNetworkConfig];
    
    //创建根视图 并设置.
    [self creatRootViewController];
    return YES;
}

#pragma mark - 设置网路库的Config
- (void)setNetworkConfig
{
    NYNetworkConfig *config = [NYNetworkConfig sharedInstance];
    config.baseUrl = BASEURL;
    config.version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
}

#pragma mark - 创建并设置根视图控制器
- (void)creatRootViewController {
    _window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    HXBBaseTabBarController *tabBarController = [[HXBBaseTabBarController alloc]init];
    tabBarController.selectColor = [UIColor redColor];
    tabBarController.normalColor = [UIColor grayColor];
    //数据
    NSArray *controllerNameArray = @[@"ViewController",@"ViewController",@"ViewController"];
    NSArray *controllerTitleArray = @[@"首页",@"你的",@"我的"];
    NSArray *imageArray = @[@"1",@"1",@"1"];
    NSString *commonName = @"1";
    [tabBarController subViewControllerNames:controllerNameArray andNavigationControllerTitleArray:controllerTitleArray andImageNameArray:imageArray andSelectImageCommonName:commonName];
    
    _window.rootViewController = tabBarController;
    [_window makeKeyAndVisible];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
