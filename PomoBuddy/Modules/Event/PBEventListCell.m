//
//  PBEventListCell.m
//  PomoBuddy
//
//  Created by Wu Yongwei on 2024/4/17.
//

#import "PBEventListCell.h"

#import <Masonry/Masonry.h>

@interface PBEventListCell ()

@property (nonatomic, strong) UIImageView *bgImageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *descLabel;

@end

@implementation PBEventListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setupViews];
    }
    return self;
}

- (void)setEvent:(PBEvent *)event {
    _event = event;
    self.titleLabel.text = event.title;
    [self.titleLabel sizeToFit];
    
    NSInteger min = event.spendTime / 60;
    NSInteger sec = event.spendTime % 60;
    NSString *desc = [NSString stringWithFormat:@"%@分钟    总学习", @(event.totalTime / 60)];
    if (min > 0) {
        desc = [desc stringByAppendingString:[NSString stringWithFormat:@"%@分",@(min)]];
    }
    if (sec > 0) {
        desc = [desc stringByAppendingString:[NSString stringWithFormat:@"%@秒",@(sec)]];
    }
    self.descLabel.text = desc;
    [self.descLabel sizeToFit];
    
    [self setNeedsLayout];
}

- (void)setupViews {
    [self createBgImageView];
    [self createTitleLabel];
    [self createDescLabel];
}

- (void)createBgImageView {
    if (self.bgImageView) {
        return;
    }
    self.bgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"event_bg2"]];
    self.bgImageView.layer.cornerRadius = 8;
    self.bgImageView.layer.masksToBounds = YES;
    [self.contentView addSubview:self.bgImageView];
    [self.bgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.mas_equalTo(self).offset(10);
        make.right.bottom.mas_equalTo(self).offset(-10);
    }];
}

- (void)createTitleLabel {
    if (self.titleLabel) {
        return;
    }
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.font = [UIFont systemFontOfSize:18];
    self.titleLabel.textColor = RGBCOLOR(236, 236, 236);
    [self.contentView addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.mas_equalTo(self.bgImageView).offset(10);
    }];
}

- (void)createDescLabel {
    if (self.descLabel) {
        return;
    }
    self.descLabel = [[UILabel alloc] init];
    self.descLabel.font = [UIFont systemFontOfSize:13];
    self.descLabel.textColor = RGBCOLOR(236, 236, 236);
    [self.contentView addSubview:self.descLabel];
    [self.descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.bgImageView).offset(10);
        make.bottom.mas_equalTo(self.bgImageView).offset(-10);
    }];
}


@end
