//
//  PBNavigationBar.h
//  PomoBuddy
//
//  Created by Wu Yongwei on 2024/4/17.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PBNavigationBar : UIView

@property (readonly) UILabel *titleLabel;
@property (readonly) UIButton *backButton;

- (instancetype)initWithTitle:(NSString *)title;

@end

NS_ASSUME_NONNULL_END
