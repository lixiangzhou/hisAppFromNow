//
//  HXBMy_Withdraw_notifitionView.m
//  hoomxb
//
//  Created by 肖扬 on 2017/9/21.
//  Copyright © 2017年 hoomsun-miniX. All rights reserved.
//

#import "HXBMy_Withdraw_notifitionView.h"

@interface HXBMy_Withdraw_notifitionView ()

/** 小喇叭 */
@property (nonatomic, strong)  UIImageView *messageImage;
/** 文案 */
@property (nonatomic, strong)  UILabel *messageLabel;

@end


@implementation HXBMy_Withdraw_notifitionView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self buildUI];
    }
    return self;
}

- (void)buildUI {
    self.backgroundColor = COR32;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickMessageView)];
    [self addGestureRecognizer:tap];
    UIView *shadowView = [[UIView alloc] initWithFrame:CGRectMake(0, kScrAdaptationH750(69.5), kScreenWidth, kScrAdaptationH750(0.5))];
    shadowView.backgroundColor = COR32;
    shadowView.layer.shadowColor = [UIColor blackColor].CGColor;//shadowColor阴影颜色
    shadowView.layer.shadowOffset = CGSizeMake(2, 2);//shadowOffset阴影偏移,x向右偏移4，y向下偏移4，默认(0, -3),这个跟shadowRadius配合使用
    shadowView.layer.shadowOpacity = 0.8;//阴影透明度，默认0
    shadowView.layer.shadowRadius = 2;//阴影半径，默认3
    [self addSubview:shadowView];
    
    [self addSubview:self.messageImage];
    [self addSubview:self.messageLabel];
    
    _messageImage.image = [UIImage imageNamed:@"hxb_my_message"];
    
    [_messageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_messageImage);
        make.centerX.equalTo(self).offset(kScrAdaptationW(13));
        make.height.offset(kScrAdaptationH750(30));
    }];
    [_messageImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(_messageLabel.mas_left).offset(-kScrAdaptationW(10));
        make.top.equalTo(@kScrAdaptationH750(21));
        make.width.offset(kScrAdaptationW750(26));
        make.height.offset(kScrAdaptationH750(27.7));
    }];
}

- (void)clickMessageView {
    self.block();
}

- (void)setMessageCount:(NSString *)messageCount {
    _messageCount = messageCount;
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:messageCount];
    _messageLabel.attributedText = str;
}

- (UIImageView *)messageImage {
    if (!_messageImage) {
        _messageImage = [[UIImageView alloc] init];
        _messageLabel.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _messageImage;
}

- (UILabel *)messageLabel {
    if (!_messageLabel) {
        _messageLabel = [[UILabel alloc] init];
        _messageLabel.textColor = COR10;
        _messageLabel.font = kHXBFont_PINGFANGSC_REGULAR(12);
    }
    return _messageLabel;
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
