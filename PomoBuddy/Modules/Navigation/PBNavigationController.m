//
//  PBNavigationController.m
//  PomoBuddy
//
//  Created by Wu Yongwei on 2024/4/16.
//

#import "PBNavigationController.h"
#import <Masonry/Masonry.h>

@implementation PBNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupViews];
}

- (void)setupViews {
    self.view.backgroundColor = [UIColor clearColor];
    
    UIVisualEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    UIVisualEffectView *visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    [self.view addSubview:visualEffectView];
    [self.view sendSubviewToBack:visualEffectView];
    [visualEffectView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view);
    }];
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated {
    if (self.childViewControllers.count == 1) {
        if (self.presentingViewController) {
            [self dismissViewControllerAnimated:animated completion:nil];
            return nil;
        }
    }
    return [super popViewControllerAnimated:animated];
}

@end
