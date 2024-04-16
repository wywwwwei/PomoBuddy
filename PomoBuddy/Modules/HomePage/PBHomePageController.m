//
//  PBHomePageController.m
//  PomoBuddy
//
//  Created by Wu Yongwei on 2024/4/14.
//

#import "PBHomePageController.h"
#import "PBHomePageMenuView.h"
#import "PBSettingViewController.h"
#import "PBNavigationController.h"

#import <Masonry/Masonry.h>
#import <BlocksKit/UIGestureRecognizer+BlocksKit.h>

static const CGFloat PBHomePageButtonWidth = 120.f;
static const CGFloat PBHomePageButtonHeight = 44.f;

@interface PBHomePageController ()

@property (nonatomic, strong) UIImageView *backgroundView;

// 不同样式的倒计时
@property (nonatomic, strong) UICollectionView *collectionView;

// 用于动画辅助的容器view
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UIButton *menuButton;
@property (nonatomic, strong) UIButton *startButton;
@property (nonatomic, strong) UIButton *pauseButton;
@property (nonatomic, strong) UIButton *resumeButton;
@property (nonatomic, strong) UIButton *exitButton;

@property (nonatomic, strong, nullable) UIView *menuMaskView;
@property (nonatomic, strong, nullable) PBHomePageMenuView *menuView;
@property (nonatomic, strong) NSArray<PBHomePageMenuItem *> *menuItems;

@end

@implementation PBHomePageController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupSubviews];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO];
}

- (void)setupSubviews {
    [self createBackgroundView];
    [self createContainerView];
    [self createMenuButton];
    [self createStartButton];
}

#pragma mark - Event

- (void)onMenuButtonClick {
    [self showMenu];
}

- (void)onStartButtonClick {
    self.collectionView.scrollEnabled = NO;
    
    [self createPauseButton];
    self.pauseButton.alpha = 0;
    [UIView transitionWithView:self.containerView
                      duration:0.3
                       options:UIViewAnimationOptionTransitionCurlUp
                    animations:^{
        self.startButton.alpha = 0;
        self.pauseButton.alpha = 1;
    }
                    completion:^(BOOL finished) {
        
    }];
}

- (void)onPauseButtonClick {
    [self createResumeButton];
    [self createExitButton];
    self.resumeButton.alpha = 0;
    self.exitButton.alpha = 0;
    self.resumeButton.frame = self.containerView.frame;
    self.exitButton.frame = self.containerView.frame;
    [UIView animateWithDuration:0.1 animations:^{
        self.containerView.alpha = 0;
        self.pauseButton.alpha = 0;
        self.resumeButton.alpha = 1;
        self.exitButton.alpha = 1;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3 animations:^{
            self.resumeButton.centerX -= 68;
            self.exitButton.centerX += 68;
        }];
    }];
}

- (void)onResumeButtonClick {
    [UIView animateWithDuration:0.3 animations:^{
        self.resumeButton.frame = self.containerView.frame;
        self.exitButton.frame = self.containerView.frame;
        self.containerView.alpha = 1;
        self.pauseButton.alpha = 1;
        self.resumeButton.alpha = 0;
        self.exitButton.alpha = 0;
    } completion:^(BOOL finished) {
    }];
}

- (void)onExitButtonClick {
    [UIView animateWithDuration:0.3 animations:^{
        self.resumeButton.frame = self.containerView.frame;
        self.exitButton.frame = self.containerView.frame;
        self.containerView.alpha = 1;
        self.startButton.alpha = 1;
        self.resumeButton.alpha = 0;
        self.exitButton.alpha = 0;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)showMenu {
    self.menuMaskView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.menuMaskView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
    WEAK_REF(self);
    UITapGestureRecognizer *tapGesture = [UITapGestureRecognizer bk_recognizerWithHandler:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
        STRONG_REF(self);
        // 点击到菜单不隐藏
        if (CGRectContainsPoint(self.menuView.frame, location)) {
            return;
        }
        [self dismissMenuAnimated:YES];
    }];
    [self.menuMaskView addGestureRecognizer:tapGesture];
    [self.view addSubview:self.menuMaskView];
    
    CGFloat width = 200.f, height = CGRectGetHeight(self.view.bounds);
    self.menuView = [[PBHomePageMenuView alloc] initWithMenuItems:self.menuItems];
    self.menuView.frame = CGRectMake(-width, 0, width, height);
    self.menuView.userInteractionEnabled = YES;
    self.menuView.dismissBlock = ^(BOOL animated) {
        STRONG_REF(self);
        [self dismissMenuAnimated:animated];
    };
    [self.menuMaskView addSubview:self.menuView];
    
    CGRect targetFrame = CGRectMake(0, 0, width, height);
    [UIView animateWithDuration:0.3f animations:^{
        self.menuView.frame = targetFrame;
    }];
}

- (NSArray<PBHomePageMenuItem *> *)menuItems {
    if (!_menuItems) {
        NSMutableArray *items = [NSMutableArray array];
        
        PBHomePageMenuItem *settingItem = [[PBHomePageMenuItem alloc] init];
        settingItem.icon = [UIImage imageNamed:@"setting"];
        settingItem.title = @"Settings";
        WEAK_REF(self);
        settingItem.handler = ^{
            STRONG_REF(self);
            // 打开设置页
            PBSettingViewController *settingVC = [[PBSettingViewController alloc] init];
            PBNavigationController *nav = [[PBNavigationController alloc] initWithRootViewController:settingVC];
            nav.modalPresentationStyle = UIModalPresentationOverCurrentContext;
            nav.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
            [self presentViewController:nav animated:YES completion:nil];
        };
        [items addObject:settingItem];
        
        PBHomePageMenuItem *statisticItem = [[PBHomePageMenuItem alloc] init];
        statisticItem.icon = [UIImage imageNamed:@"setting"];
        statisticItem.title = @"Statistics";
        statisticItem.handler = ^{
            STRONG_REF(self);
            // 打开历史统计页
            PBSettingViewController *settingVC = [[PBSettingViewController alloc] init];
            [self.navigationController pushViewController:settingVC animated:YES];
        };
        [items addObject:statisticItem];
        
        PBHomePageMenuItem *eventItem = [[PBHomePageMenuItem alloc] init];
        eventItem.icon = [UIImage imageNamed:@"setting"];
        eventItem.title = @"Events";
        eventItem.handler = ^{
            // 打开事件页面
            PBSettingViewController *settingVC = [[PBSettingViewController alloc] init];
            [self.navigationController pushViewController:settingVC animated:YES];
        };
        [items addObject:eventItem];
        _menuItems = [items copy];
    }
    return _menuItems;
}

- (void)dismissMenuAnimated:(BOOL)animated {
    CGFloat animateTime = animated ? 0.3f : 0;
    CGRect currentFrame = self.menuView.frame;
    currentFrame.origin.x = -CGRectGetWidth(currentFrame);
    [UIView animateWithDuration:animateTime animations:^{
        self.menuView.frame = currentFrame;
    } completion:^(BOOL finished) {
        [self.menuView removeFromSuperview];
        [self.menuMaskView removeFromSuperview];
        self.menuView = nil;
        self.menuMaskView = nil;
    }];
}

#pragma mark - UI

- (void)createBackgroundView {
    if (self.backgroundView) {
        return;
    }
    self.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background_image"]];
    [self.view addSubview:self.backgroundView];
    [self.backgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view);
    }];
}

- (void)createMenuButton {
    if (self.menuButton) {
        return;
    }
    self.menuButton = [[UIButton alloc] init];
    self.menuButton.backgroundColor = [UIColor clearColor];
    [self.menuButton setImage:[UIImage imageNamed:@"menu"] forState:UIControlStateNormal];
    [self.menuButton addTarget:self action:@selector(onMenuButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.menuButton];
    [self.menuButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(50);
        make.left.mas_equalTo(10);
        make.top.mas_equalTo([PBCommonUtils safeAreaInsets].top);
    }];
}

- (void)createContainerView {
    if (self.containerView) {
        return;
    }
    self.containerView = [[UIView alloc] init];
    self.containerView.backgroundColor = [UIColor clearColor];
    self.containerView.layer.cornerRadius = PBHomePageButtonHeight / 2;
    self.containerView.layer.masksToBounds = YES;
    [self.view addSubview:self.containerView];
    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(PBHomePageButtonWidth);
        make.height.mas_equalTo(PBHomePageButtonHeight);
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.bottom.mas_equalTo(-100);
    }];
}

- (void)createStartButton {
    if (self.startButton) {
        return;
    }
    self.startButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.startButton.backgroundColor = RGBCOLOR(255, 84, 84);
    [self.startButton setTitle:@"Start" forState:UIControlStateNormal];
    [self.startButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.startButton.layer.cornerRadius = PBHomePageButtonHeight / 2;
    [self.startButton addTarget:self action:@selector(onStartButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.containerView addSubview:self.startButton];
    [self.startButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.containerView);
    }];
}

- (void)createPauseButton {
    if (self.pauseButton) {
        return;
    }
    self.pauseButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.pauseButton.backgroundColor = [UIColor clearColor];
    [self.pauseButton setTitle:@"Pause" forState:UIControlStateNormal];
    [self.pauseButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.pauseButton.layer.cornerRadius = PBHomePageButtonHeight / 2;
    self.pauseButton.layer.borderWidth = 1;
    self.pauseButton.layer.borderColor = [UIColor whiteColor].CGColor;
    [self.pauseButton addTarget:self action:@selector(onPauseButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.containerView addSubview:self.pauseButton];
    [self.pauseButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.startButton);
    }];
}

- (void)createResumeButton {
    if (self.resumeButton) {
        return;
    }
    self.resumeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.resumeButton.backgroundColor = RGBCOLOR(83, 186, 156);
    [self.resumeButton setTitle:@"Resume" forState:UIControlStateNormal];
    [self.resumeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.resumeButton.layer.cornerRadius = PBHomePageButtonHeight / 2;
    [self.resumeButton addTarget:self action:@selector(onResumeButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.resumeButton];
}

- (void)createExitButton {
    if (self.exitButton) {
        return;
    }
    self.exitButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.exitButton.backgroundColor = [UIColor clearColor];
    [self.exitButton setTitle:@"Exit" forState:UIControlStateNormal];
    [self.exitButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.exitButton.layer.cornerRadius = PBHomePageButtonHeight / 2;
    self.exitButton.layer.borderWidth = 1;
    self.exitButton.layer.borderColor = [UIColor whiteColor].CGColor;
    [self.exitButton addTarget:self action:@selector(onExitButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.exitButton];
}

// 状态栏颜色为白色
- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

@end
