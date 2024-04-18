//
//  PBEventAlertView.m
//  PomoBuddy
//
//  Created by Wu Yongwei on 2024/4/18.
//

#import "PBEventAlertView.h"
#import <Masonry/Masonry.h>
#import <BlocksKit/UIControl+BlocksKit.h>

@interface PBEventAlertView ()

@property (nonatomic, strong) UIView *headView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIButton *confirmButton;

@property (nonatomic, strong) UITextField *inputField;
@property (nonatomic, strong) UISlider *timeSlider;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UISegmentedControl *repeatControl;

@property (nonatomic, assign) NSInteger duration;

@end

@implementation PBEventAlertView

- (instancetype)init {
    if (self = [super init]) {
        [self setupViews];
    }
    return self;
}

- (void)show {
    self.alpha = 0;
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 1;
    }];
}

- (void)dismiss {
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void)setDuration:(NSInteger)duration {
    _duration = duration;
    [self updateTimeLabel];
}

- (void)updateTimeLabel {
    NSInteger mins = self.duration / 60;
    NSInteger secs = self.duration % 60;
    NSString *text = nil;
    if (secs > 0) {
        text = [NSString stringWithFormat:@"%ld m %ld s", mins, secs];
    } else {
        text = [NSString stringWithFormat:@"%ld min%@", mins, mins > 1 ? @"s": @""];
    }
    self.timeLabel.text = text;
    [self sizeToFit];
}

- (void)setupViews {
    self.backgroundColor = [UIColor whiteColor];
    self.layer.borderColor = [[UIColor blackColor] colorWithAlphaComponent:0.1].CGColor;
    // 圆角设置
    self.layer.cornerRadius = 10;  // 角度设置为10
    self.layer.masksToBounds = YES;
    self.layer.borderWidth = 2;
    [self createHeadView];
    [self createInputField];
    [self createTimeLabel];
    [self createTimeSlider];
    [self createRepeatControl];
}

- (void)createHeadView {
    if (self.headView) {
        return;
    }
    self.headView = [[UIView alloc] init];
    self.headView.backgroundColor = [UIColor colorWithRed:225/255.0 green:180/255.0 blue:135/255.0 alpha:1];
    // 圆角设置
    self.headView.layer.cornerRadius = 10;  // 角度设置为10
    self.headView.layer.masksToBounds = YES;
    
    [self addSubview:self.headView];

    [self.headView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(320);
        make.height.mas_equalTo(50);
        make.left.right.mas_equalTo(0);
        make.top.mas_equalTo(0);
    }];
    [self createTitleLabel];
    [self createCancelButton];
    [self createConfirmButton];
}

- (void)createTitleLabel {
    if (self.titleLabel) {
        return;
    }
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.text = @"New Event";
    [self addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self.headView);
    }];
}

- (void)createCancelButton {
    if (self.cancelButton) {
        return;
    }
    self.cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.cancelButton setImage:[UIImage imageNamed:@"cancel"] forState:UIControlStateNormal];
    WEAK_REF(self);
    [self.cancelButton bk_addEventHandler:^(id sender) {
        STRONG_REF(self);
        if (self.cancelBlock) {
            self.cancelBlock();
        }
    } forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.cancelButton];
    [self.cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(30);
        make.centerY.mas_equalTo(self.headView);
        make.left.mas_equalTo(10);
    }];
}

- (void)createConfirmButton {
    if (self.confirmButton) {
        return;
    }
    self.confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.confirmButton setImage:[UIImage imageNamed:@"confirm"] forState:UIControlStateNormal];
    WEAK_REF(self);
    [self.confirmButton bk_addEventHandler:^(id sender) {
        STRONG_REF(self);
        if (self.confirmBlock) {
            PBEvent *event = [PBEvent eventWithTitle:self.inputField.text spendTime:self.duration totalTime:0];
            self.confirmBlock(event);
        }
    } forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.confirmButton];
    [self.confirmButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(30);
        make.centerY.mas_equalTo(self.headView);
        make.right.mas_equalTo(-10);
    }];
}

- (void)createInputField {
    if (self.inputField) {
        return;
    }
    self.inputField = [[UITextField alloc] init];
    self.inputField.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.3];
    self.inputField.borderStyle = UITextBorderStyleRoundedRect;
    self.inputField.textAlignment = NSTextAlignmentCenter;
    [self addSubview:self.inputField];
    [self.inputField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.headView.mas_bottom).offset(20);
        make.left.mas_equalTo(60);
        make.right.mas_equalTo(-60);
        make.height.mas_equalTo(30);
    }];
}

- (void)createTimeLabel {
    if (self.timeLabel) {
        return;
    }
    self.timeLabel = [[UILabel alloc] init];
    self.timeLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:self.timeLabel];
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.inputField.mas_bottom).offset(10);
        make.height.mas_equalTo(30);
        make.centerX.mas_equalTo(self);
    }];
}

- (void)createTimeSlider {
    if (self.timeSlider) {
        return;
    }
    self.timeSlider = [[UISlider alloc] init];
    const NSInteger minValue = 1, maxValue = 60;
    WEAK_REF(self);
    __auto_type handler = ^(UISlider *sender){
        STRONG_REF(self);
        self.duration = @((minValue + (maxValue - minValue) * sender.value)).integerValue * 60;
    };
    [self.timeSlider bk_addEventHandler:handler forControlEvents:UIControlEventValueChanged];
    handler(self.timeSlider); // 触发一下初始展示
    [self addSubview:self.timeSlider];
    [self.timeSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.timeLabel.mas_bottom).offset(10);
        make.centerX.mas_equalTo(self);
        make.left.mas_equalTo(50);
        make.right.mas_equalTo(-50);
    }];
}

- (void)createRepeatControl {
    if (self.repeatControl) {
        return;
    }
    self.repeatControl = [[UISegmentedControl alloc] initWithItems:@[@"Once", @"Repeat"]];
    self.repeatControl.selectedSegmentIndex = 0;
    [self addSubview:self.repeatControl];
    [self.repeatControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(200);
        make.height.mas_equalTo(30);
        make.top.mas_equalTo(self.timeSlider.mas_bottom).offset(30);
        make.centerX.mas_equalTo(self);
        make.bottom.mas_equalTo(self).offset(-20);
    }];
}


@end
