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
#import "PBRecordsStatViewController.h"
#import "PBEventListController.h"
#import "PBEvent.h"
#import "PBToast.h"
#import "PBSettingManager.h"

#import <Masonry/Masonry.h>
#import <BlocksKit/UIGestureRecognizer+BlocksKit.h>
#import <BlocksKit/UIControl+BlocksKit.h>
#import <AVFoundation/AVFoundation.h>

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

// preset countdown time, the unit is second
@property (nonatomic, assign) NSInteger originDuration;
// the remain countdown time, the unit is second
@property (nonatomic, assign) NSInteger currentDuration;
@property (nonatomic, strong, nullable) NSTimer *countdownTimer;

@property (nonatomic, weak) PBCountdownCell *currentCell;

@property (nonatomic, strong) AVAudioPlayer *audioPlayer;

@end

@implementation PBHomePageController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupNotification];
    [self loadDefaultDuration];
    [self setupSubviews];
    [self setupPlayer];
    [self setupDisableLockScreen];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO];
}

- (void)setupNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onApplyEventNotification:) name:@"ApplyEvent" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onSettingChangeNotification:) name:PBSettingItemChange object:nil];
}

- (void)onApplyEventNotification:(NSNotification *)notification {
    PBEvent *event = notification.userInfo[@"event"];
    if (event) {
        [PBToast showToastTitle:[NSString stringWithFormat:@"Apply event: %@", event.title] duration:3];
        _originDuration = event.spendTime;
        [self updateDurationLabel];
    }
}

- (void)onSettingChangeNotification:(NSNotification *)notification {
    PBSettingSwitchType switchType = [notification.userInfo[PBSettingItemTypeKey] integerValue];
    if (switchType == PBSettingSwitchTypeWhiteNoise || switchType == PBSettingSwitchTypeMusicFusion) {
        [self setupPlayer];
    } else if (switchType == PBSettingSwitchTypeDisableLockScreen) {
        [self setupDisableLockScreen];
    }
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
            [PBCountdownModel countdownModelWithTitle:@"Morning" backgroundColor:RGBACOLOR(139, 69, 19, 0.3)],
            [PBCountdownModel countdownModelWithTitle:@"Afternoon" backgroundColor:RGBACOLOR(241, 148, 138, 0.2)],
            [PBCountdownModel countdownModelWithTitle:@"Night" backgroundColor:RGBACOLOR(93, 121, 161, 0.4)],
            [PBCountdownModel countdownModelWithTitle:@"Sunny" backgroundColor:RGBACOLOR(247, 220, 111, 0.4)],
            [PBCountdownModel countdownModelWithTitle:@"Rainy" backgroundColor:RGBACOLOR(70, 84, 92, 0.4)],
            [PBCountdownModel countdownModelWithTitle:@"Ocean" backgroundColor:RGBACOLOR(100, 149, 237, 0.3)],
            [PBCountdownModel countdownModelWithTitle:@"Forest" backgroundColor:RGBACOLOR(85, 107, 47, 0.3)],
        ];
    }
    return _countdownModels;
}

#pragma mark - Timer

- (void)setOriginDuration:(NSInteger)originDuration {
    _originDuration = originDuration;
    [self updateDurationLabel];
    NSLog(@"OriginDuration set %ld", (long)originDuration);
}

- (void)setCurrentDuration:(NSInteger)currentDuration {
    _currentDuration = currentDuration;
    [self.currentCell updateCurrentDuration:currentDuration];
}

- (void)loadDefaultDuration {
    NSInteger recordDuration = [[NSUserDefaults standardUserDefaults] integerForKey:@"settings_duration"];
    _originDuration = recordDuration > 0 ? recordDuration : 30 * 60;
    NSLog(@"OriginDuration load %ld", (long)_originDuration);
}

- (void)saveDefaultDuration {
    NSLog(@"OriginDuration save %ld", (long)self.originDuration);
    [[NSUserDefaults standardUserDefaults] setInteger:self.originDuration forKey:@"settings_duration"];
    [[NSUserDefaults standardUserDefaults] synchronize];
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

#pragma mark - Lock

- (void)setupDisableLockScreen {
    [UIApplication sharedApplication].idleTimerDisabled = [PBSettingManager disbaleLockScreen];
}

#pragma mark - Audio

- (void)setupPlayer {
    NSURL *currentUrl = nil;
    if ([PBSettingManager enableWhiteNoise]) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"white_noise" ofType:@"mp3"];
        currentUrl = [NSURL fileURLWithPath:path];
    } else if ([PBSettingManager enableMusicFusion]) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"song" ofType:@"mp3"];
        currentUrl = [NSURL fileURLWithPath:path];
    }
    if (![self.audioPlayer.url.absoluteString isEqualToString:currentUrl.absoluteString]) {
        [self.audioPlayer stop];
        self.audioPlayer = nil;
    }
    if (!currentUrl) {
        return;
    }
    if (!self.audioPlayer) {
        NSError *error;
        self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:currentUrl error:&error];
        self.audioPlayer.numberOfLoops = -1;
        if (error) {
            [self.audioPlayer stop];
            self.audioPlayer = nil;
        }
    }
    [self.audioPlayer play];
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
        settingItem.icon = [UIImage imageNamed:@"settings"];
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
        statisticItem.icon = [UIImage imageNamed:@"statistics"];
        statisticItem.title = @"Statistics";
        statisticItem.handler = ^{
            STRONG_REF(self);
            // 打开历史统计页
            PBRecordsStatViewController *recordsVC = [[PBRecordsStatViewController alloc] init];
            PBNavigationController *nav = [[PBNavigationController alloc] initWithRootViewController:recordsVC];
            nav.modalPresentationStyle = UIModalPresentationOverCurrentContext;
            nav.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
            [self presentViewController:nav animated:YES completion:nil];
        };
        [items addObject:statisticItem];
        
        PBHomePageMenuItem *eventItem = [[PBHomePageMenuItem alloc] init];
        eventItem.icon = [UIImage imageNamed:@"events"];
        eventItem.title = @"Events";
        eventItem.handler = ^{
            // 打开事件页面
            PBEventListController *recordsVC = [[PBEventListController alloc] init];
            PBNavigationController *nav = [[PBNavigationController alloc] initWithRootViewController:recordsVC];
            nav.modalPresentationStyle = UIModalPresentationOverCurrentContext;
            nav.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
            [self presentViewController:nav animated:YES completion:nil];
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
    self.menuButton.contentEdgeInsets = UIEdgeInsetsMake(7.5, 7.5, 7.5, 7.5);
    [self.view addSubview:self.menuButton];
    [self.menuButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(45);
        make.left.mas_equalTo(15);
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
    const NSInteger minValue = 1, maxValue = 60;
    self.slider.value = (self.originDuration / 60 - minValue) * 1.f / (maxValue - minValue);
    WEAK_REF(self);
    [self.slider bk_addEventHandler:^(UISlider *sender) {
        STRONG_REF(self);
        // from 1 to 60 mins
        self.originDuration = @((minValue + (maxValue - minValue) * sender.value)).integerValue * 60;
    } forControlEvents:UIControlEventValueChanged];
    [self.slider bk_addEventHandler:^(UISlider *sender) {
        STRONG_REF(self);
        [self saveDefaultDuration];
    } forControlEvents:UIControlEventTouchUpInside];
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
    NSInteger minutes = self.originDuration / 60;
    NSInteger seconds = self.originDuration % 60;
    NSString *text = nil;
    if (seconds > 0) {
        text = [NSString stringWithFormat:@"Countdown: %ld m %ld s", minutes, seconds];
    } else {
        text = [NSString stringWithFormat:@"Countdown: %ld min%@", minutes, minutes > 1 ? @"s": @""];
    }
    self.durationLabel.text = text;
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
