//
//  PBSettingViewController.m
//  PomoBuddy
//
//  Created by Wu Yongwei on 2024/4/14.
//

#import "PBSettingViewController.h"
#import "PBSettingGroup.h"
#import "PBSettingManager.h"
#import "PBSettingSwitchCell.h"
#import "PBNavigationBar.h"

#import <Masonry/Masonry.h>
#import <BlocksKit/UIControl+BlocksKit.h>

@interface PBSettingViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSArray<PBSettingGroup *> *settingGroups;

@property (nonatomic, strong) PBNavigationBar *navigationView;
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

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.settingGroups.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.settingGroups[section].items.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    PBSettingGroup *group = self.settingGroups[section];
    UIView *headerView = [[UIView alloc] init];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, tableView.width, 0)];
    label.text = group.title;
    label.font = [UIFont boldSystemFontOfSize:20.0]; // 设置字体为20号加粗
    [headerView addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.centerY.mas_equalTo(headerView);
    }];
    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PBSettingSwitchCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(PBSettingSwitchCell.class)];
    if (!cell) {
        cell = [[PBSettingSwitchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NSStringFromClass(PBSettingSwitchCell.class)];
    }
    PBSettingSwitchItem *item = self.settingGroups[indexPath.section].items[indexPath.row];
    cell.item = item;
    return cell;
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
    self.navigationView = [[PBNavigationBar alloc] initWithTitle:@"Settings"];
    [self.view addSubview:self.navigationView];
    [self.navigationView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(self.view);
        make.height.mas_equalTo(NAVIGATION_BAR_HEIGHT);
        make.top.left.mas_equalTo(0);
    }];
}

- (void)createSettingsView {
    if (self.settingsView) {
        return;
    }
    self.settingsView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    self.settingsView.dataSource = self;
    self.settingsView.delegate = self;
    self.settingsView.backgroundColor = [UIColor clearColor];
    self.settingsView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.settingsView.rowHeight = 50;
    [self.view addSubview:self.settingsView];
    [self.settingsView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(self.view);
        make.centerX.mas_equalTo(self.view);
        make.top.mas_equalTo(self.navigationView.mas_bottom);
        make.bottom.mas_equalTo(self.view);
    }];
}

// 状态栏颜色为白色
- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

@end
