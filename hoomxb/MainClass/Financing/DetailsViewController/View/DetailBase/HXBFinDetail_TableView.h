//
//  HXBFinDetail_TableView.h
//  hoomxb
//
//  Created by HXB on 2017/5/8.
//  Copyright © 2017年 hoomsun-miniX. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface HXBFinDetail_TableViewCellModel: NSObject
+ (instancetype)finDetail_TableViewCellModelWithImageName: (NSString *)imageName andOptionIitle: (NSString *)optionTitle;
- (instancetype)initWithImageName: (NSString *)imageName andOptionIitle: (NSString *)optionTitle;
@property (nonatomic,copy) NSString *imageName;
@property (nonatomic,copy) NSString *optionTitle;
@end


@class HXBFinDetail_TableViewCellModel;
///理财详情页的tableView  cell里面有一个图片一个title
@interface HXBFinDetail_TableView : UITableView
@property (nonatomic,strong) NSArray <HXBFinDetail_TableViewCellModel *>*tableViewCellModelArray;

///一个cell只有一个字符串的
@property (nonatomic,strong) NSArray <NSString *>*strArray;

///点击了 详情页底部的tableView的cell
- (void)clickBottomTableViewCellBloakFunc: (void(^)(NSIndexPath *index, HXBFinDetail_TableViewCellModel *model))clickBottomTabelViewCellBlock;
@end



@interface HXBFinDetail_TableViewCell : UITableViewCell
@property (nonatomic,strong) HXBFinDetail_TableViewCellModel *model;
@property (nonatomic,strong) UILabel *optionLabel;
///一个cell只有一个字符串的
@property (nonatomic,strong) NSArray <NSString *>*strArray;
@property (nonatomic,assign) BOOL isHiddenLastCellBottomLine;
@end

