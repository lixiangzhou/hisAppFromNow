//
//  HXBFinancing_LoanListAPI.h
//  hoomxb
//
//  Created by HXB on 2017/5/8.
//  Copyright © 2017年 hoomsun-miniX. All rights reserved.
//

#import "NYBaseRequest.h"

@interface HXBFinancing_LoanListAPI : NYBaseRequest
///是否为上拉刷新
@property (nonatomic,assign) BOOL isUPData;
@end
