//
//  HXBMY_Plan_Capital_ViewController.h
//  hoomxb
//
//  Created by HXB on 2017/6/28.
//  Copyright © 2017年 hoomsun-miniX. All rights reserved.
//

#import "HXBBaseViewController.h"
///投资记录的b
@interface HXBMY_Plan_Capital_ViewController : HXBBaseViewController
@property (nonatomic,copy) NSString *planID;
@end





@interface HXBMY_Plan_Capital_Cell : UITableViewCell
@property (nonatomic,copy) NSString *ID;
@property (nonatomic,copy) NSString *loanAoumt;
@property (nonatomic,copy) NSString *time;
@property (nonatomic,copy) NSString *type;
@end