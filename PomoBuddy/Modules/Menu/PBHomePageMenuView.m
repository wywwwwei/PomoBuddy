//
//  PBHomePageMenuView.m
//  PomoBuddy
//
//  Created by Wu Yongwei on 2024/4/14.
//

#import "PBHomePageMenuView.h"
#import <Masonry/Masonry.h>
#import <BlocksKit/NSArray+BlocksKit.h>
#import <BlocksKit/UIGestureRecognizer+BlocksKit.h>

static const CGFloat PBHomePageMenuLogoWidth = 60.f;

@implementation PBHomePageMenuItem

@end

@interface PBHomePageMenuView ()

@property (nonatomic, strong) UIImageView *appLogoView;
@property (nonatomic, strong) UILabel *appDescLabel;

@property (nonatomic, strong) NSArray<PBHomePageMenuItem *> *menuItems;
@property (nonatomic, strong) UIStackView *buttonsView;

@property (nonatomic, strong) UIVisualEffectView *effectView;
@end

@implementation PBHomePageMenuView

- (instancetype)initWithMenuItems:(NSArray<PBHomePageMenuItem *> *)menuItems {
    if (self = [super init]) {
        _menuItems = menuItems;
        self.backgroundColor = [UIColor colorWithWhite:1 alpha:0.3];
        [self setupSubviews];
    }
    return self;
}

- (void)setupSubviews {
    [self createLogoView];
    [self createDescLabel];
    [self createButtonsView];
    [self createEffectView];
}

- (void)createEffectView {
    if (self.effectView) {
        return;
    }
    UIVisualEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    self.effectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    [self addSubview:self.effectView];
    [self sendSubviewToBack:self.effectView];
    [self.effectView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self);
    }];
}

- (void)createLogoView {
    if (self.appLogoView) {
        return;
    }
    self.appLogoView = [[UIImageView alloc] init];
    self.appLogoView.backgroundColor = [UIColor greenColor];
    self.appLogoView.image = [UIImage imageNamed:@"avatar"];
    self.appLogoView.layer.cornerRadius = self.appLogoView.frame.size.width / 2;
    self.appLogoView.clipsToBounds = YES;
    self.appLogoView.layer.cornerRadius = PBHomePageMenuLogoWidth / 2;
    [self addSubview:self.appLogoView];
    [self.appLogoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(PBHomePageMenuLogoWidth);
        make.centerX.mas_equalTo(self);
        make.top.mas_equalTo(100.f);
    }];
}

- (void)createDescLabel {
    if (self.appDescLabel) {
        return;
    }
    self.appDescLabel = [[UILabel alloc] init];
    self.appDescLabel.text = @"PomoBuddy";
    self.appDescLabel.font = [UIFont boldSystemFontOfSize:20.0];
    self.appDescLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:self.appDescLabel];
    [self.appDescLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.appLogoView.mas_bottom).offset(20);
        make.centerX.mas_equalTo(self.appLogoView);
    }];
}

- (void)createButtonsView {
    if (self.buttonsView) {
        return;
    }
    self.buttonsView = [[UIStackView alloc] initWithFrame:CGRectZero];
    self.buttonsView.axis = UILayoutConstraintAxisVertical;
    [self addSubview:self.buttonsView];
    [self.menuItems bk_each:^(PBHomePageMenuItem *obj) {
        UIView *itemView = [self itemViewForMenuItem:obj];
        [self.buttonsView addArrangedSubview:itemView];
        [itemView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(self);
            make.height.mas_equalTo(60);
        }];
    }];
    [self.buttonsView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.appDescLabel.mas_bottom).offset(40);
    }];
}

- (UIView *)itemViewForMenuItem:(PBHomePageMenuItem *)item {
    UIView *containerView = [[UIView alloc] init];
    
    UIImageView *iconView = [[UIImageView alloc] initWithImage:item.icon];
    [containerView addSubview:iconView];
    [iconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(20);
        make.centerY.mas_equalTo(containerView);
        make.left.mas_equalTo(30);
    }];
    
    UILabel *label = [[UILabel alloc] init];
    label.text = item.title;
    label.font = [UIFont boldSystemFontOfSize:16.0];
    [containerView addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(containerView);
        make.left.mas_equalTo(iconView.mas_right).offset(15);
    }];
    
    UIView *splitLine = [[UIView alloc] init];
    splitLine.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.5];
    [containerView addSubview:splitLine];
    [splitLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(containerView).offset(-20);
        make.height.mas_equalTo(0.5f);
        make.bottom.mas_equalTo(containerView);
        make.centerX.mas_equalTo(containerView);
    }];
    
    WEAK_REF(self);
    UITapGestureRecognizer *tapGesture = [UITapGestureRecognizer bk_recognizerWithHandler:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
        if (item.handler) {
            item.handler();
        }
        STRONG_REF(self);
        if (self.dismissBlock) {
            self.dismissBlock(NO);
        }
    }];
    [containerView addGestureRecognizer:tapGesture];
    
    return containerView;
}

@end
