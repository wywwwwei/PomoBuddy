//
//  PBSettingViewController.m
//  PomoBuddy
//
//  Created by Wu Yongwei on 2024/4/14.
//

#import "PBSettingViewController.h"
#import "PBSettingGroup.h"
#import "PBSettingManager.h"

#import <Masonry/Masonry.h>
#import <BlocksKit/UIControl+BlocksKit.h>

@interface PBSettingViewController ()

@property (nonatomic, strong) NSArray<PBSettingGroup *> *settingGroups;

@property (nonatomic, strong) UIView *navigationView;
@property (nonatomic, strong) UITableView *settingsView;

@end

@implementation PBSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.settingGroups = [PBSettingManager loadSettings];
    [self setupViews];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO];
}

- (void)setupViews {
    self.view.backgroundColor = [UIColor clearColor];
    [self createNavigationView];
    [self createSettingsView];
}

- (void)createNavigationView {
    if (self.navigationView) {
        return;
    }
    self.navigationView = [[UIView alloc] init];
    self.navigationView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.navigationView];
    [self.navigationView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(self.view);
        make.height.mas_equalTo([PBCommonUtils safeAreaInsets].top + 40.f);
        make.top.left.mas_equalTo(0);
    }];
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setImage:[UIImage imageNamed:@"menu"] forState:UIControlStateNormal];
    WEAK_REF(self);
    [backButton bk_addEventHandler:^(id sender) {
        STRONG_REF(self);
        [self.navigationController popViewControllerAnimated:YES];
    } forControlEvents:UIControlEventTouchUpInside];
    [self.navigationView addSubview:backButton];
    [backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(20);
        make.left.mas_equalTo(20);
        make.bottom.mas_equalTo(-15);
    }];
    
    UILabel *label = [[UILabel alloc] init];
    label.text = @"Settings";
    label.textAlignment = NSTextAlignmentCenter;
    [self.navigationView addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.navigationView);
        make.centerY.mas_equalTo(backButton);
        make.bottom.mas_equalTo(10);
    }];
}

- (void)createSettingsView {
    if (self.settingsView) {
        return;
    }
}

// 状态栏颜色为白色
- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

@end
