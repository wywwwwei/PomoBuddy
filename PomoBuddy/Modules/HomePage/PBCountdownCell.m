//
//  PBCountdownCell.m
//  PomoBuddy
//
//  Created by Wu Yongwei on 2024/4/16.
//

#import "PBCountdownCell.h"

#import <Masonry/Masonry.h>

@interface PBCountdownCell ()

@property (nonatomic, strong) UIView *circleView;
@property (nonatomic, strong, nullable) CALayer *circleAnimationLayer;

@property (nonatomic, strong) UIView *informationView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *dateLabel;

@property (nonatomic, strong) UIView *countdownView;
@property (nonatomic, strong) UILabel *countdownLabel;

@end

@implementation PBCountdownCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupViews];
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [self stopAnimation];
    self.informationView.alpha = 1;
    self.countdownView.alpha = 0;
}

- (void)setModel:(PBCountdownModel *)model {
    _model = model;
    
    self.titleLabel.text = model.title;
    [self.titleLabel sizeToFit];
    
    self.backgroundColor = model.backgroundColor;
    
    [self setNeedsLayout];
}

- (void)startAnimation {
    if (self.circleAnimationLayer) {
        return;
    }
    self.circleAnimationLayer = [CALayer layer];
    const NSInteger pulsingCount = 4;
    const NSInteger animationDuration = 6;
    for (NSInteger i = 0; i < pulsingCount; i++) {
        CALayer *pulsingLayer = [CALayer layer];
        pulsingLayer.frame = self.circleView.bounds;
        pulsingLayer.borderColor = RGBACOLOR(0, 0, 0, 0.6).CGColor;
        pulsingLayer.borderWidth = 1.5;
        pulsingLayer.cornerRadius = self.circleView.height / 2;
        
        CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        scaleAnimation.fromValue = @1.0;
        scaleAnimation.toValue = @1.15;
        
        CAKeyframeAnimation *opacityAnimation = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
        opacityAnimation.values = @[@0, @0.4, @0.4, @0.4, @0.4, @0.3, @0.3, @0.3, @0.2, @0.1, @0];
        opacityAnimation.keyTimes = @[@0, @0.1, @0.2, @0.3, @0.4, @0.5, @0.6, @0.7, @0.8, @0.9, @1];
        
        CAAnimationGroup * animationGroup = [CAAnimationGroup animation];
        animationGroup.fillMode = kCAFillModeBackwards;
        animationGroup.beginTime = CACurrentMediaTime() + i * animationDuration / pulsingCount;
        animationGroup.duration = animationDuration;
        animationGroup.repeatCount = INFINITY;
        animationGroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault];
        animationGroup.animations = @[scaleAnimation, opacityAnimation];
        
        [pulsingLayer addAnimation:animationGroup forKey:@"pulsing"];
        [self.circleAnimationLayer addSublayer:pulsingLayer];
    }
    [self.circleView.layer addSublayer:self.circleAnimationLayer];
}

- (void)stopAnimation {
    [self.circleAnimationLayer removeFromSuperlayer];
    self.circleAnimationLayer = nil;
}

- (void)showInformationView {
    [UIView transitionWithView:self.informationView duration:0.8 options:UIViewAnimationOptionTransitionFlipFromLeft animations:^{
        self.informationView.alpha = 1;
    } completion:nil];
    [UIView transitionWithView:self.countdownView duration:0.8 options:UIViewAnimationOptionTransitionFlipFromLeft animations:^{
        self.countdownView.alpha = 0;
    } completion:nil];
}

- (void)showCountdownView {
    [UIView transitionWithView:self.informationView duration:0.8 options:UIViewAnimationOptionTransitionFlipFromLeft animations:^{
        self.informationView.alpha = 0;
    } completion:nil];
    [UIView transitionWithView:self.countdownView duration:0.8 options:UIViewAnimationOptionTransitionFlipFromLeft animations:^{
        self.countdownView.alpha = 1;
    } completion:nil];
}

- (void)updateCurrentDuration:(NSInteger)duration {
    NSInteger hours = duration / (60 * 60);
    NSInteger mins = (duration % (60 * 60)) / 60;
    NSInteger seconds = duration % 60;
    NSString *display = nil;
    if (hours > 0) {
        display = [NSString stringWithFormat:@"%.2ld:%.2ld:%.2ld", (long)hours, (long)mins, (long)seconds];
    } else {
        display = [NSString stringWithFormat:@"%.2ld:%.2ld", (long)mins, (long)seconds];
    }
    self.countdownLabel.text = display;
    [self.countdownLabel sizeToFit];
}

#pragma mark - UI

- (void)setupViews {
    [self setupCircleView];
    [self setupInformationView];
    [self setupCountdownView];
    self.countdownView.alpha = 0;
}

- (NSString *)currentDateString {
    NSCalendar * calendar = [NSCalendar currentCalendar];
    NSDateComponents *comp = [calendar components:NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitWeekday|NSCalendarUnitYear fromDate:[NSDate date]];
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    fmt.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    fmt.dateFormat = @"MMM. dd EEE yyyy";
    NSDate *now = [calendar dateFromComponents:comp];
    return [fmt stringFromDate:now];
}

- (void)setupCircleView {
    if (self.circleView) {
        return;
    }
    CGFloat width = self.width * 0.6;
    self.circleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, width)];
    self.circleView.backgroundColor = [UIColor clearColor];
    self.circleView.layer.cornerRadius = width / 2;
//    self.circleView.layer.borderColor = [UIColor colorWithWhite:1 alpha:0.25].CGColor;
    self.circleView.layer.borderColor = [[UIColor blackColor] colorWithAlphaComponent:0.7].CGColor;
    self.circleView.layer.borderWidth = 3;
    [self.contentView addSubview:self.circleView];
    [self.circleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self);
        make.centerY.mas_equalTo(self).multipliedBy(0.7);
        make.width.height.mas_equalTo(width);
    }];
}

- (void)setupInformationView {
    if (self.informationView) {
        return;
    }
    self.informationView = [[UIView alloc] init];
    self.informationView.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:self.informationView];
    [self.informationView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.circleView);
    }];
    
    [self setupTitleLabel];
    [self setupDateLabel];
}

- (void)setupTitleLabel {
    if (self.titleLabel) {
        return;
    }
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.font = [UIFont systemFontOfSize:34];
    self.titleLabel.textColor = [[UIColor blackColor] colorWithAlphaComponent:0.8];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.informationView addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.informationView);
        make.centerY.mas_equalTo(self.informationView).offset(-30);
    }];
}

- (void)setupDateLabel {
    if (self.dateLabel) {
        return;
    }
    self.dateLabel = [[UILabel alloc] init];
    self.dateLabel.textAlignment = NSTextAlignmentCenter;
    self.dateLabel.textColor = [[UIColor blackColor] colorWithAlphaComponent:0.8];
    self.dateLabel.font = [UIFont systemFontOfSize:14];
    self.dateLabel.text = [self currentDateString];
    [self.informationView addSubview:self.dateLabel];
    [self.dateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.informationView);
        make.centerY.mas_equalTo(self.informationView).offset(30);
    }];
    
    UIView *topLineView = [[UIView alloc] init];
    topLineView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.8];
    [self.dateLabel addSubview:topLineView];
    [topLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(self.dateLabel);
        make.height.mas_equalTo(1);
        make.centerX.mas_equalTo(self.dateLabel);
        make.top.mas_equalTo(self.dateLabel);
    }];
    
    UIView *bottomLineView = [[UIView alloc] init];
    bottomLineView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.8];
    [self.dateLabel addSubview:bottomLineView];
    [bottomLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(self.dateLabel);
        make.height.mas_equalTo(1);
        make.centerX.mas_equalTo(self.dateLabel);
        make.bottom.mas_equalTo(self.dateLabel);
    }];
}

- (void)setupCountdownView {
    if (self.countdownView) {
        return;
    }
    self.countdownView = [[UIView alloc] init];
    self.countdownView.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:self.countdownView];
    [self.countdownView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.circleView);
    }];
    
    [self setupCountdownLabel];
}

- (void)setupCountdownLabel {
    if (self.countdownLabel) {
        return;
    }
    self.countdownLabel = [[UILabel alloc] init];
    self.countdownLabel.textColor = [[UIColor blackColor] colorWithAlphaComponent:0.8];
    self.countdownLabel.font = [UIFont systemFontOfSize:46];
    self.countdownLabel.textAlignment = NSTextAlignmentCenter;
    [self.countdownView addSubview:self.countdownLabel];
    [self.countdownLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self.countdownView);
    }];
}

@end
