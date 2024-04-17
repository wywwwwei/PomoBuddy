//
//  PBCountdownModel.h
//  PomoBuddy
//
//  Created by Wu Yongwei on 2024/4/16.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PBCountdownModel : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) UIColor *backgroundColor;

+ (instancetype)countdownModelWithTitle:(NSString *)title
                        backgroundColor:(UIColor *)backgroundColor;

@end

NS_ASSUME_NONNULL_END
