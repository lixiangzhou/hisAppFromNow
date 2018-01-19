//
//  HxbHomePageViewModel.h
//  hoomxb
//
//  Created by HXB-C on 2017/5/17.
//  Copyright © 2017年 hoomsun-miniX. All rights reserved.
//

#import <Foundation/Foundation.h>
@class HxbHomePageModel,HXBHomeBaseModel,HxbHomePageModel_DataList;

@interface HxbHomePageViewModel : NSObject
@property (nonatomic,strong)HxbHomePageModel *homePageModel;
@property (nonatomic,strong) NSString *assetsTotal;

@property (nonatomic, strong) HXBHomeBaseModel *homeBaseModel;

@property (nonatomic, strong) NSMutableArray <HxbHomePageModel_DataList *>*homeDataList;
@end
