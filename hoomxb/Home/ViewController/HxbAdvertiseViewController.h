//
//  HxbAdvertiseViewController.h
//  hoomxb
//
//  Created by HXB-C on 2017/4/19.
//  Copyright © 2017年 hoomsun-miniX. All rights reserved.
//

#import <UIKit/UIKit.h>
///广告的VC
@interface HxbAdvertiseViewController : UIViewController

@property (nonatomic, copy) NSString *adUrl;
///dismiss
- (void) dismissAdvertiseViewControllerFunc: (void(^)())dismissAdvertiseViewControllerBlock;
@end
