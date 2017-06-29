//
//  HXBMY_Plan_Capital_ViewController.m
//  hoomxb
//
//  Created by HXB on 2017/6/28.
//  Copyright © 2017年 hoomsun-miniX. All rights reserved.
//

#import "HXBMY_Plan_Capital_ViewController.h"
#import "HXBFinanctingRequest.h"
#import "HXBMYRequest.h"
#import "HXBMY_PlanViewModel_LoanRecordViewModel.h"
static NSString *const cellID = @"cellID";
@interface HXBMY_Plan_Capital_ViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,strong) UITableView *planCapitalTableView;

@property (nonatomic,strong) NSMutableArray<HXBMY_PlanViewModel_LoanRecordViewModel *> *dataArray;
@property (nonatomic,strong) HXBMY_Plan_Capital_Cell *topView;

@end

@implementation HXBMY_Plan_Capital_ViewController
- (void)setDataArray:(NSMutableArray *)dataArray {
    _dataArray = dataArray;
    [self.planCapitalTableView reloadData];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.topView = [[HXBMY_Plan_Capital_Cell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    [self.view addSubview: self.topView];
    self.topView.ID = @"标的ID";
    self.topView.loanAoumt = @"投资金额(元)";
    self.topView.time = @"时间";
    self.topView.type = @"状态";
    
    [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.view).offset(64);
        make.height.equalTo(@(kScrAdaptationH(64)));
    }];
    
    self.planCapitalTableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
    [self.view addSubview:self.planCapitalTableView];
    
    [self.planCapitalTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.top.equalTo(self.topView.mas_bottom);
    }];
    
    self.planCapitalTableView.delegate = self;
    self.planCapitalTableView.dataSource = self;
    
    [self.planCapitalTableView registerClass:[HXBMY_Plan_Capital_Cell class] forCellReuseIdentifier:cellID];
    [self downLoadWithIsUPLoad: true];
}

- (void)downLoadWithIsUPLoad: (BOOL)isUPLoad {
    HXBMYRequest *request = [[HXBMYRequest alloc]init];
    [request loanRecord_my_Plan_WithIsUPData: isUPLoad andPlanID:self.planID andSuccessBlock:^(NSArray<HXBMY_PlanViewModel_LoanRecordViewModel *> *viewModelArray) {
        [self.dataArray addObjectsFromArray:viewModelArray];
        self.dataArray = self.dataArray;
    } andFailureBlock:^(NSError *error) {
        
        
    }];
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HXBMY_Plan_Capital_Cell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        cell.ID = _dataArray[indexPath.row].loanId;
        cell.loanAoumt = _dataArray[indexPath.row].amount;
        cell.time = _dataArray[indexPath.row].lendTime;
        cell.type = _dataArray[indexPath.row].status;
    return cell;
}






- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




@end
@interface HXBMY_Plan_Capital_Cell ()
/**
 标的id
 */
@property (nonatomic,strong) UILabel *planIDLabel;
/**
 投资金额（元）
 */
@property (nonatomic,strong) UILabel *amountLabel;
/**
 时间
 */
@property (nonatomic,strong) UILabel *timeLabel;
/**
 状态
 */
@property (nonatomic,strong) UILabel *typeLabel;
@end

@implementation HXBMY_Plan_Capital_Cell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:cellID]) {
        [self setUPViews];
    }
    return self;
}
- (void)setUPViews {
    self.planIDLabel = [[UILabel alloc]init];
    self.amountLabel = [[UILabel alloc]init];
    self.timeLabel = [[UILabel alloc]init];
    self.typeLabel = [[UILabel alloc]init];
    
    
    [self.contentView addSubview:self.planIDLabel];
    [self.contentView addSubview:self.amountLabel];
    [self.contentView addSubview:self.timeLabel];
    [self.contentView addSubview:self.typeLabel];
    NSArray *viewArray = @[
                          self.planIDLabel,self.amountLabel,self.timeLabel,self.typeLabel
                           ];
    
    [viewArray mas_distributeViewsAlongAxis:MASAxisTypeHorizontal withFixedSpacing:0 leadSpacing:0 tailSpacing:0];
    [viewArray mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(self.contentView);
    }];
//    [self.planIDLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.bottom.top.equalTo(self.contentView);
//        make.left.equalTo(self.contentView);
//        make.width.equalTo(self).multipliedBy(1 / 4);
//    }];
//    [self.amountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.bottom.top.equalTo(self.contentView);
//        make.left.equalTo(self.planIDLabel.mas_right);
//        make.width.equalTo(self).multipliedBy(1 / 4);
//    }];
//    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.bottom.top.equalTo(self.contentView);
//        make.left.equalTo(self.amountLabel.mas_right);
//        make.width.equalTo(self).multipliedBy(1 / 4);
//    }];
//    [self.typeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.bottom.top.equalTo(self.contentView);
//        make.left.equalTo(self.timeLabel.mas_right);
//        make.width.equalTo(self).multipliedBy(1 / 4);
//    }];
}

- (void) setTime:(NSString *)time {
    _time = time;
    self.timeLabel.text = time;
}
- (void) setType:(NSString *)type {
    _type = type;
    self.typeLabel.text = type;
}
- (void)setLoanAoumt:(NSString *)loanAoumt {
    _loanAoumt = loanAoumt;
    self.amountLabel.text = loanAoumt;
}
- (void)setID:(NSString *)ID {
    _ID = ID;
    self.planIDLabel.text = ID;
}
@end

