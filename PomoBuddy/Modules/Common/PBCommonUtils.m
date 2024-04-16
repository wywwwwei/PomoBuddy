//
//  PBCommonUtils.m
//  PomoBuddy
//
//  Created by Wu Yongwei on 2024/4/14.
//

#import "PBCommonUtils.h"
#import "PBCommonMacro.h"

@implementation PBCommonUtils

+ (UIWindow *)keyWindow {
    __block UIScene *scene = nil;
    [[[UIApplication sharedApplication] connectedScenes] enumerateObjectsUsingBlock:^(UIScene * _Nonnull obj, BOOL * _Nonnull stop) {
        if (obj.activationState == UISceneActivationStateForegroundActive) {
            scene = obj;
            *stop = YES;
        }
    }];
    if (!scene) {
        scene = [[UIApplication sharedApplication] connectedScenes].allObjects.firstObject;
    }
    UIWindowScene *windowScene = PBSAFE_CAST(scene, UIWindowScene);
    UIWindow *window = nil;
    if (@available(iOS 15.0, *)) {
        window =  windowScene.keyWindow;
    }
    return window ?: windowScene.windows.firstObject;
}

+ (UIEdgeInsets)safeAreaInsets {
    return [self keyWindow].safeAreaInsets;
}

@end
