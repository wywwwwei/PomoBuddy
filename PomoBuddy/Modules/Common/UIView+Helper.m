//
//  UIView+Helper.m
//  PomoBuddy
//
//  Created by Wu Yongwei on 2024/4/15.
//

#import "UIView+Helper.h"

@implementation UIView (Helper)

- (CGFloat)x {
    return self.frame.origin.x;
}

- (void)setX:(CGFloat)x {
    CGRect f = self.frame;
    f.origin.x = x;
    self.frame = f;
}

- (CGFloat)y {
    return self.frame.origin.y;
}

- (void)setY:(CGFloat)y {
    CGRect f = self.frame;
    f.origin.y = y;
    self.frame = f;
}

- (CGFloat)width {
    return self.frame.size.width;
}

- (void)setWidth:(CGFloat)width {
    CGRect f = self.frame;
    f.size.width = width;
    self.frame = f;
}

- (CGFloat)height {
    return self.frame.size.height;
}

- (void)setHeight:(CGFloat)height {
    CGRect f = self.frame;
    f.size.height = height;
    self.frame = f;
}

- (CGPoint)origin {
    return self.frame.origin;
}

- (void)setOrigin:(CGPoint)origin {
    CGRect f = self.frame;
    f.origin = origin;
    self.frame = f;
}

- (CGSize)size {
    return self.frame.size;
}

- (void)setSize:(CGSize)size {
    CGRect f = self.frame;
    f.size = size;
    self.frame = f;
}

- (CGFloat)centerX {
    return self.center.x;
}

- (void)setCenterX:(CGFloat)centerX {
    CGPoint c = self.center;
    c.x = centerX;
    self.center = c;
}

- (CGFloat)centerY {
    return self.center.y;
}

- (void)setCenterY:(CGFloat)centerY {
    CGPoint c = self.center;
    c.y = centerY;
    self.center = c;
}

- (CGFloat)left {
    return self.x;
}

- (void)setLeft:(CGFloat)left {
    self.x = left;
}

- (CGFloat)top {
    return self.y;
}

- (void)setTop:(CGFloat)top {
    self.y = top;
}

- (CGFloat)right {
    return self.x + self.width;
}

- (void)setRight:(CGFloat)right {
    self.x = right - self.width;
}

- (CGFloat)bottom {
    return self.y + self.height;
}

- (void)setBottom:(CGFloat)bottom {
    self.y = bottom - self.height;
}

@end
