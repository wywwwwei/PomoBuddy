//
//  PBNavigationBar.m
//  PomoBuddy
//
//  Created by Wu Yongwei on 2024/4/17.
//

#import "PBNavigationBar.h"
#import <Masonry/Masonry.h>
#import <BlocksKit/UIControl+BlocksKit.h>

@interface PBNavigationBar ()

@property (nonatomic, strong) NSString *title;

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *backButton;

@end

@implementation PBNavigationBar

- (instancetype)initWithTitle:(NSString *)title {
    if (self = [super init]) {
        _title = title;
        [self setupViews];
    }
    return self;
}

- (void)setupViews {
    self.backgroundColor = [UIColor clearColor];
    [self createTitleLabel];
    [self createBackButton];
}

- (void)createTitleLabel {
    if (self.titleLabel) {
        return;
    }
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.text = self.title;
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.font = [UIFont boldSystemFontOfSize:22.0];
    [self addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self);
        make.bottom.mas_equalTo(-10);
    }];
}

- (void)createBackButton {
    if (self.backButton) {
        return;
    }
    self.backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.backButton setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    WEAK_REF(self);
    [self.backButton bk_addEventHandler:^(id sender) {
        STRONG_REF(self);
        [self.parentViewController.navigationController popViewControllerAnimated:YES];
    } forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.backButton];
    [self.backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(25);
        make.left.mas_equalTo(20);
        make.centerY.mas_equalTo(self.titleLabel);
    }];
}

@end
