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
#import "PBCountdownCell.h"
#import "RecordsStatViewController.h"

#import <Masonry/Masonry.h>
#import <BlocksKit/UIGestureRecognizer+BlocksKit.h>
#import <BlocksKit/UIControl+BlocksKit.h>

static const CGFloat PBHomePageButtonWidth = 120.f;
static const CGFloat PBHomePageButtonHeight = 44.f;

@interface PBHomePageController () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UIImageView *backgroundView;

// display different style countdown timer
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSArray<PBCountdownModel *> *countdownModels;

// Container view for animation assistance
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UIButton *menuButton;
@property (nonatomic, strong) UIButton *startButton;
@property (nonatomic, strong) UIButton *pauseButton;
@property (nonatomic, strong) UIButton *resumeButton;
@property (nonatomic, strong) UIButton *exitButton;
@property (nonatomic, strong) UISlider *slider;
@property (nonatomic, strong) UILabel *durationLabel;

@property (nonatomic, strong, nullable) UIView *menuMaskView;
@property (nonatomic, strong, nullable) PBHomePageMenuView *menuView;
@property (nonatomic, strong) NSArray<PBHomePageMenuItem *> *menuItems;

// preset countdown time
@property (nonatomic, assign) NSInteger originDuration;
// the remain countdown time
@property (nonatomic, assign) NSInteger currentDuration;
@property (nonatomic, strong, nullable) NSTimer *countdownTimer;

@property (nonatomic, weak) PBCountdownCell *currentCell;

@end

@implementation PBHomePageController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadDefaultDuration];
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
    [self createCollectionView];
    [self createContainerView];
    [self createMenuButton];
    [self createStartButton];
    [self createSlider];
    [self createDurationLabel];
}

- (NSArray<PBCountdownModel *> *)countdownModels {
    if (!_countdownModels) {
        _countdownModels = @[
            [PBCountdownModel countdownModelWithTitle:@"Afternoon" backgroundColor:RGBACOLOR(139, 69, 19, 0.3)],
            [PBCountdownModel countdownModelWithTitle:@"Rain" backgroundColor:RGBACOLOR(70, 84, 92, 0.4)],
            [PBCountdownModel countdownModelWithTitle:@"Forest" backgroundColor:RGBACOLOR(85, 107, 47, 0.3)],
            [PBCountdownModel countdownModelWithTitle:@"Beach" backgroundColor:RGBACOLOR(100, 149, 237, 0.3)],
            [PBCountdownModel countdownModelWithTitle:@"Night" backgroundColor:RGBACOLOR(25, 25, 122, 0.65)],
        ];
    }
    return _countdownModels;
}

#pragma mark - Timer

- (void)setOriginDuration:(NSInteger)originDuration {
    _originDuration = originDuration;
    [self updateDurationLabel];
    [[NSUserDefaults standardUserDefaults] setInteger:originDuration forKey:@"settings_duration"];
}

- (void)setCurrentDuration:(NSInteger)currentDuration {
    _currentDuration = currentDuration;
    [self.currentCell updateCurrentDuration:currentDuration];
}

- (void)loadDefaultDuration {
    NSInteger recordDuration = [[NSUserDefaults standardUserDefaults] integerForKey:@"settings_duration"];
    _originDuration = recordDuration > 0 ? recordDuration : 30;
}

- (void)startTimer {
    self.currentDuration = self.originDuration;
    [self resumeTimer];
}

- (void)pauseTimer {
    [self destroyTimer];
}

- (void)resumeTimer {
    WEAK_REF(self);
    self.countdownTimer = [NSTimer scheduledTimerWithTimeInterval:1 repeats:YES block:^(NSTimer * _Nonnull timer) {
        STRONG_REF(self);
        self.currentDuration -= 1;
        if (self.currentDuration == 0) {
            [self destroyTimer];
        }
    }];
}

- (void)destroyTimer {
    [self.countdownTimer invalidate];
    self.countdownTimer = nil;
}

#pragma mark - Event

- (void)onMenuButtonClick {
    [self showMenu];
}

- (void)onStartButtonClick {
    self.collectionView.scrollEnabled = NO;
    [self hideSlider];
    
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
        [self startTimer];
    }];
    [self.currentCell showCountdownView];
    [self.currentCell startAnimation];
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
    [self pauseTimer];
    [self.currentCell stopAnimation];
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
        [self resumeTimer];
    }];
    [self.currentCell startAnimation];
}

- (void)onExitButtonClick {
    self.collectionView.scrollEnabled = YES;
    [self showSlider];
    
    [UIView animateWithDuration:0.3 animations:^{
        self.resumeButton.frame = self.containerView.frame;
        self.exitButton.frame = self.containerView.frame;
        self.containerView.alpha = 1;
        self.startButton.alpha = 1;
        self.resumeButton.alpha = 0;
        self.exitButton.alpha = 0;
    } completion:^(BOOL finished) {
        
    }];
    [self.currentCell showInformationView];
    [self.currentCell stopAnimation];
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
            RecordsStatViewController *recordsVC = [[RecordsStatViewController alloc] init];
            [self.navigationController pushViewController:recordsVC animated:YES];
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

#pragma mark - UICollectionViewDelegate

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        [self updateCurrentCell];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self updateCurrentCell];
}

- (PBCountdownCell *)currentCell {
    if (!_currentCell) {
        [self updateCurrentCell];
    }
    return _currentCell;
}

- (void)updateCurrentCell {
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:[self.collectionView convertPoint:CGPointMake(self.view.width / 2, self.view.height / 2) fromView:self.view]];
    self.currentCell = (PBCountdownCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return collectionView.size;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    return self.countdownModels.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                           cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PBCountdownCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass(PBCountdownCell.class) forIndexPath:indexPath];
    cell.model = self.countdownModels[indexPath.row];
    return cell;
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
        make.width.mas_equalTo(40);
        make.height.mas_equalTo(35);
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
        make.bottom.mas_equalTo(-80);
    }];
}

- (void)createStartButton {
    if (self.startButton) {
        return;
    }
    self.startButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.startButton.backgroundColor = RGBACOLOR(0, 0, 0, 0.7);
    [self.startButton setTitle:@"Start" forState:UIControlStateNormal];
    [self.startButton setTitleColor:[[UIColor whiteColor]colorWithAlphaComponent:0.9] forState:UIControlStateNormal];
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
    [self.pauseButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    self.pauseButton.layer.cornerRadius = PBHomePageButtonHeight / 2;
    self.pauseButton.layer.borderWidth = 1;
    self.pauseButton.layer.borderColor = [UIColor blackColor].CGColor;
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
    self.resumeButton.backgroundColor = RGBACOLOR(0, 0, 0, 0.7);
    [self.resumeButton setTitle:@"Resume" forState:UIControlStateNormal];
    [self.resumeButton setTitleColor:[[UIColor whiteColor]colorWithAlphaComponent:0.9] forState:UIControlStateNormal];
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
    [self.exitButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    self.exitButton.layer.cornerRadius = PBHomePageButtonHeight / 2;
    self.exitButton.layer.borderWidth = 1;
    self.exitButton.layer.borderColor = [UIColor blackColor].CGColor;
    [self.exitButton addTarget:self action:@selector(onExitButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.exitButton];
}

- (void)createCollectionView {
    if (self.collectionView) {
        return;
    }
    UICollectionViewFlowLayout * collectionLayout = [[UICollectionViewFlowLayout alloc] init];
    collectionLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    collectionLayout.minimumLineSpacing = 0;
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:collectionLayout];
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.pagingEnabled = YES;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.bounces = NO;
    [self.collectionView registerClass:PBCountdownCell.class forCellWithReuseIdentifier:NSStringFromClass(PBCountdownCell.class)];
    [self.view addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view);
    }];
}

- (void)createSlider {
    if (self.slider) {
        return;
    }
    self.slider = [[UISlider alloc] init];
    self.slider.minimumTrackTintColor = [[UIColor blackColor] colorWithAlphaComponent:0.7];
    self.slider.maximumTrackTintColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
    self.slider.thumbTintColor = [[UIColor blackColor] colorWithAlphaComponent:0.7];
    WEAK_REF(self);
    [self.slider bk_addEventHandler:^(UISlider *sender) {
        STRONG_REF(self);
        // from 5 to 300
        self.originDuration = 5 + (sender.value * 295);
    } forControlEvents:UIControlEventValueChanged];
    self.slider.value = (self.originDuration - 5) / 295.f;
    [self.view addSubview:self.slider];
    [self.slider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(self.view).multipliedBy(0.7);
        make.centerX.mas_equalTo(self.view);
        make.bottom.mas_equalTo(self.containerView.mas_top).offset(-235);
    }];
}

- (void)createDurationLabel {
    if (self.durationLabel) {
        return;
    }
    self.durationLabel = [[UILabel alloc] init];
    self.durationLabel.textColor = [[UIColor blackColor] colorWithAlphaComponent:0.8];
    [self updateDurationLabel];
    [self.view addSubview:self.durationLabel];
    [self.durationLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view);
        make.top.mas_equalTo(self.slider.mas_bottom).mas_offset(10);
    }];
}

- (void)updateDurationLabel {
    self.durationLabel.text = [NSString stringWithFormat:@"Countdown: %ld s", self.originDuration];
    [self.durationLabel sizeToFit];
}

- (void)showSlider {
    [UIView animateWithDuration:0.5 animations:^{
        self.slider.alpha = 1;
        self.durationLabel.alpha = 1;
    }];
}

- (void)hideSlider {
    [UIView animateWithDuration:0.5 animations:^{
        self.slider.alpha = 0;
        self.durationLabel.alpha = 0;
    }];
}

// 状态栏颜色为白色
- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleDarkContent;
}

@end
