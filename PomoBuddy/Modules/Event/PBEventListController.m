//
//  PBEventListController.m
//  PomoBuddy
//
//  Created by Wu Yongwei on 2024/4/17.
//

#import "PBEventListController.h"
#import "PBNavigationBar.h"
#import "PBEventListCell.h"

#import <Masonry/Masonry.h>
#import <BlocksKit/UIControl+BlocksKit.h>

@interface PBEventListController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) PBNavigationBar *navigationView;
@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray<PBEvent *> *dataSource;
@property (nonatomic, strong) UIButton *addButton;

@end

@implementation PBEventListController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadData];
    [self setupViews];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
}

- (void)loadData {
    self.dataSource = [[NSUserDefaults standardUserDefaults] arrayForKey:@"saveList"];
    if (!self.dataSource) {
        self.dataSource = @[
            [PBEvent eventWithTitle:@"每周读一本好书" spendTime:200 totalTime:600],
            [PBEvent eventWithTitle:@"跑步锻炼" spendTime:100 totalTime:500],
            [PBEvent eventWithTitle:@"考研英语模拟" spendTime:60 totalTime:400],
            [PBEvent eventWithTitle:@"每日阅读" spendTime:80 totalTime:300],
        ];
    }
}

- (void)showAddEventAlert {
    
}

#pragma mark - <UITableViewDataSource>

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSource.count;
}

#pragma mark - <UITableViewDelegate>
- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PBEventListCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(PBEventListCell.class)];
    if (!cell) {
        cell = [[PBEventListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NSStringFromClass(PBEventListCell.class)];
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    cell.event = self.dataSource[indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 95;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ApplyEvent" object:nil userInfo:@{
        @"event": self.dataSource[indexPath.row]
    }];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UI

- (void)setupViews {
    [self createNavigationView];
    [self createTableView];
    [self createAddButton];
}

- (void)createNavigationView {
    if (self.navigationView) {
        return;
    }
    self.navigationView = [[PBNavigationBar alloc] initWithTitle:@"Events"];
    self.navigationView.backgroundColor = RGBCOLOR(94, 163, 223);
    [self.view addSubview:self.navigationView];
    [self.navigationView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(self.view);
        make.height.mas_equalTo(NAVIGATION_BAR_HEIGHT);
        make.top.left.mas_equalTo(0);
    }];
}

- (void)createTableView {
    if (self.tableView) {
        return;
    }
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:PBEventListCell.class forCellReuseIdentifier:NSStringFromClass(PBEventListCell.class)];
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.navigationView.mas_bottom);
        make.left.right.bottom.equalTo(self.view);
    }];
}

- (void)createAddButton {
    if (self.addButton) {
        return;
    }
    self.addButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.addButton setImage:[UIImage imageNamed:@"add"] forState:UIControlStateNormal];
    WEAK_REF(self);
    [self.addButton bk_addEventHandler:^(id sender) {
        STRONG_REF(self);
        [self showAddEventAlert];
    } forControlEvents:UIControlEventTouchUpInside];
    [self.navigationView addSubview:self.addButton];
    [self.addButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.centerY.mas_equalTo(self.navigationView.backButton);
        make.right.mas_equalTo(-20);
    }];
}

@end
