//
//  HomeHeaderView.m
//  iOSStudyApp
//

#import "HomeHeaderView.h"

@implementation HomeHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) [self setupUI];
    return self;
}

- (void)setupUI {
    UIView *cardView = [[UIView alloc] init];
    cardView.backgroundColor = [UIColor colorWithRed:0.18 green:0.60 blue:0.96 alpha:1.0];
    cardView.layer.cornerRadius = 16;
    cardView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:cardView];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"今日学习";
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.font = [UIFont systemFontOfSize:14];
    titleLabel.alpha = 0.8;
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [cardView addSubview:titleLabel];
    
    self.dayLabel = [[UILabel alloc] init];
    self.dayLabel.text = @"第 12 天";
    self.dayLabel.textColor = [UIColor whiteColor];
    self.dayLabel.font = [UIFont systemFontOfSize:28 weight:UIFontWeightBold];
    self.dayLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [cardView addSubview:self.dayLabel];
    
    self.progressLabel = [[UILabel alloc] init];
    self.progressLabel.text = @"已完成 8/32 课时 · 25%";
    self.progressLabel.textColor = [UIColor whiteColor];
    self.progressLabel.font = [UIFont systemFontOfSize:13];
    self.progressLabel.alpha = 0.9;
    self.progressLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [cardView addSubview:self.progressLabel];
    
    UIProgressView *progressBar = [[UIProgressView alloc] init];
    progressBar.progressTintColor = [UIColor whiteColor];
    progressBar.trackTintColor = [[UIColor whiteColor] colorWithAlphaComponent:0.3];
    progressBar.progress = 0.25;
    progressBar.layer.cornerRadius = 4;
    progressBar.clipsToBounds = YES;
    progressBar.translatesAutoresizingMaskIntoConstraints = NO;
    [cardView addSubview:progressBar];
    
    self.continueBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.continueBtn setTitle:@"继续学习 →" forState:UIControlStateNormal];
    [self.continueBtn setTitleColor:[UIColor colorWithRed:0.18 green:0.60 blue:0.96 alpha:1.0] forState:UIControlStateNormal];
    self.continueBtn.titleLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightBold];
    self.continueBtn.backgroundColor = [UIColor whiteColor];
    self.continueBtn.layer.cornerRadius = 20;
    self.continueBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [cardView addSubview:self.continueBtn];
    
    [NSLayoutConstraint activateConstraints:@[
        [cardView.topAnchor constraintEqualToAnchor:self.topAnchor constant:16],
        [cardView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:20],
        [cardView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-20],
        [cardView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:-8],
        
        [titleLabel.topAnchor constraintEqualToAnchor:cardView.topAnchor constant:20],
        [titleLabel.leadingAnchor constraintEqualToAnchor:cardView.leadingAnchor constant:20],
        
        [self.dayLabel.topAnchor constraintEqualToAnchor:titleLabel.bottomAnchor constant:4],
        [self.dayLabel.leadingAnchor constraintEqualToAnchor:titleLabel.leadingAnchor],
        
        [self.progressLabel.topAnchor constraintEqualToAnchor:self.dayLabel.bottomAnchor constant:8],
        [self.progressLabel.leadingAnchor constraintEqualToAnchor:titleLabel.leadingAnchor],
        
        [progressBar.topAnchor constraintEqualToAnchor:self.progressLabel.bottomAnchor constant:10],
        [progressBar.leadingAnchor constraintEqualToAnchor:titleLabel.leadingAnchor],
        [progressBar.trailingAnchor constraintEqualToAnchor:cardView.trailingAnchor constant:-20],
        [progressBar.heightAnchor constraintEqualToConstant:8],
        
        [self.continueBtn.topAnchor constraintEqualToAnchor:progressBar.bottomAnchor constant:14],
        [self.continueBtn.trailingAnchor constraintEqualToAnchor:cardView.trailingAnchor constant:-20],
        [self.continueBtn.widthAnchor constraintEqualToConstant:130],
        [self.continueBtn.heightAnchor constraintEqualToConstant:40],
    ]];
}

@end
