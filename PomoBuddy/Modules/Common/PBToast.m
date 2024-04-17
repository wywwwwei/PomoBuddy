//
//  PBToast.m
//  PomoBuddy
//
//  Created by Wu Yongwei on 2024/4/18.
//

#import "PBToast.h"
#import <Masonry/Masonry.h>

@implementation PBToast

+ (void)showToastTitle:(NSString *)title duration:(NSTimeInterval)duration {
    UILabel *label = [[UILabel alloc] init];
    label.text = title;
    label.textColor = [[UIColor blackColor] colorWithAlphaComponent:0.7];
    
    UIView *toastView = [[UIView alloc] init];
    toastView.layer.cornerRadius = 14.f;
    toastView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.7];
    [toastView addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(toastView);
        make.top.mas_equalTo(10);
        make.left.mas_equalTo(15);
        make.right.mas_equalTo(-15);
        make.bottom.mas_equalTo(-10);
    }];
    
    UIView *parentView = [PBCommonUtils keyWindow];
    [parentView addSubview:toastView];
    [toastView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(parentView);
    }];
    
    toastView.alpha = 0;
    [UIView animateWithDuration:0.3 animations:^{
        toastView.alpha = 1;
    }];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, duration * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.3 animations:^{
            toastView.alpha = 0;
        } completion:^(BOOL finished) {
            [toastView removeFromSuperview];
        }];
    });
}

@end
