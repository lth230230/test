//
//  HomeHeaderView.m
//  iOSStudyApp
//

#import "HomeHeaderView.h"
#import "StudyDataStore.h"
#import "MYTheme.h"

@interface HomeHeaderView ()
@property (nonatomic, strong) UIView *cardView;
@property (nonatomic, strong) UILabel *greetingLabel;
@property (nonatomic, strong) UILabel *dayLabel;
@property (nonatomic, strong) UILabel *progressLabel;
@property (nonatomic, strong) UIProgressView *progressBar;
@property (nonatomic, strong, readwrite) UIButton *continueBtn;
@property (nonatomic, strong) UILabel *goalLabel;
@end

@implementation HomeHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) [self setupUI];
    return self;
}

- (NSLayoutConstraint *)flexibleTrailing:(NSLayoutConstraint *)constraint {
    // UITableView may temporarily force tableHeaderView width to 0.
    // Keep trailing constraints breakable so layout can recover without console spam.
    constraint.priority = UILayoutPriorityDefaultHigh;
    return constraint;
}

- (void)setupUI {
    self.clipsToBounds = NO;
    
    self.cardView = [[UIView alloc] init];
    self.cardView.backgroundColor = [MYTheme primaryColor];
    self.cardView.layer.cornerRadius = 20;
    self.cardView.translatesAutoresizingMaskIntoConstraints = NO;
    [MYTheme applySoftShadowToView:self.cardView];
    [self addSubview:self.cardView];
    
    UIView *glow = [[UIView alloc] init];
    glow.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.10];
    glow.layer.cornerRadius = 60;
    glow.translatesAutoresizingMaskIntoConstraints = NO;
    [self.cardView addSubview:glow];
    
    self.greetingLabel = [[UILabel alloc] init];
    self.greetingLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.85];
    self.greetingLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
    self.greetingLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.cardView addSubview:self.greetingLabel];
    
    self.dayLabel = [[UILabel alloc] init];
    self.dayLabel.textColor = [UIColor whiteColor];
    self.dayLabel.font = [UIFont systemFontOfSize:28 weight:UIFontWeightBold];
    self.dayLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.cardView addSubview:self.dayLabel];
    
    self.progressLabel = [[UILabel alloc] init];
    self.progressLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.92];
    self.progressLabel.font = [UIFont systemFontOfSize:13];
    self.progressLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.cardView addSubview:self.progressLabel];
    
    self.progressBar = [[UIProgressView alloc] init];
    self.progressBar.progressTintColor = [UIColor whiteColor];
    self.progressBar.trackTintColor = [[UIColor whiteColor] colorWithAlphaComponent:0.28];
    self.progressBar.layer.cornerRadius = 4;
    self.progressBar.clipsToBounds = YES;
    self.progressBar.translatesAutoresizingMaskIntoConstraints = NO;
    [self.cardView addSubview:self.progressBar];
    
    self.goalLabel = [[UILabel alloc] init];
    self.goalLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.85];
    self.goalLabel.font = [UIFont systemFontOfSize:12];
    self.goalLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.cardView addSubview:self.goalLabel];
    
    self.continueBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.continueBtn setTitle:@"继续学习" forState:UIControlStateNormal];
    [self.continueBtn setTitleColor:[MYTheme primaryColor] forState:UIControlStateNormal];
    self.continueBtn.titleLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightBold];
    self.continueBtn.backgroundColor = [UIColor whiteColor];
    self.continueBtn.layer.cornerRadius = 20;
    self.continueBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [self.continueBtn addTarget:self action:@selector(continueTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.cardView addSubview:self.continueBtn];
    
    NSLayoutConstraint *cardTrailing = [self.cardView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-20];
    NSLayoutConstraint *progressTrailing = [self.progressLabel.trailingAnchor constraintEqualToAnchor:self.cardView.trailingAnchor constant:-20];
    NSLayoutConstraint *barTrailing = [self.progressBar.trailingAnchor constraintEqualToAnchor:self.cardView.trailingAnchor constant:-20];
    NSLayoutConstraint *btnTrailing = [self.continueBtn.trailingAnchor constraintEqualToAnchor:self.cardView.trailingAnchor constant:-20];
    
    [NSLayoutConstraint activateConstraints:@[
        [self.cardView.topAnchor constraintEqualToAnchor:self.topAnchor constant:12],
        [self.cardView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:20],
        [self flexibleTrailing:cardTrailing],
        [self.cardView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:-8],
        
        [glow.trailingAnchor constraintEqualToAnchor:self.cardView.trailingAnchor constant:30],
        [glow.topAnchor constraintEqualToAnchor:self.cardView.topAnchor constant:-40],
        [glow.widthAnchor constraintEqualToConstant:120],
        [glow.heightAnchor constraintEqualToConstant:120],
        
        [self.greetingLabel.topAnchor constraintEqualToAnchor:self.cardView.topAnchor constant:20],
        [self.greetingLabel.leadingAnchor constraintEqualToAnchor:self.cardView.leadingAnchor constant:20],
        
        [self.dayLabel.topAnchor constraintEqualToAnchor:self.greetingLabel.bottomAnchor constant:4],
        [self.dayLabel.leadingAnchor constraintEqualToAnchor:self.greetingLabel.leadingAnchor],
        [self.dayLabel.trailingAnchor constraintLessThanOrEqualToAnchor:self.continueBtn.leadingAnchor constant:-12],
        
        [self.progressLabel.topAnchor constraintEqualToAnchor:self.dayLabel.bottomAnchor constant:10],
        [self.progressLabel.leadingAnchor constraintEqualToAnchor:self.greetingLabel.leadingAnchor],
        [self flexibleTrailing:progressTrailing],
        
        [self.progressBar.topAnchor constraintEqualToAnchor:self.progressLabel.bottomAnchor constant:10],
        [self.progressBar.leadingAnchor constraintEqualToAnchor:self.greetingLabel.leadingAnchor],
        [self flexibleTrailing:barTrailing],
        [self.progressBar.heightAnchor constraintEqualToConstant:8],
        
        [self.goalLabel.topAnchor constraintEqualToAnchor:self.progressBar.bottomAnchor constant:10],
        [self.goalLabel.leadingAnchor constraintEqualToAnchor:self.greetingLabel.leadingAnchor],
        [self.goalLabel.bottomAnchor constraintEqualToAnchor:self.cardView.bottomAnchor constant:-18],
        
        [self.continueBtn.centerYAnchor constraintEqualToAnchor:self.dayLabel.centerYAnchor],
        [self flexibleTrailing:btnTrailing],
        [self.continueBtn.widthAnchor constraintEqualToConstant:110],
        [self.continueBtn.heightAnchor constraintEqualToConstant:40],
    ]];
}

- (void)refresh {
    StudyDataStore *store = [StudyDataStore shared];
    self.greetingLabel.text = [NSString stringWithFormat:@"你好，%@", store.userName];
    self.dayLabel.text = [NSString stringWithFormat:@"连续学习第 %ld 天", (long)store.streakDays];
    
    NSInteger done = store.completedCount;
    NSInteger total = store.totalLessonCount;
    float progress = store.overallProgress;
    self.progressLabel.text = [NSString stringWithFormat:@"已完成 %ld/%ld 课时 · %.0f%%",
                               (long)done, (long)total, progress * 100];
    [self.progressBar setProgress:progress animated:YES];
    
    NSInteger goal = store.dailyGoalMinutes;
    self.goalLabel.text = [NSString stringWithFormat:@"今日已学 %@ · 目标 %ld 分钟",
                           store.todayStudyDurationText, (long)goal];
    
    NSDictionary *next = [store nextLessonToContinue];
    NSString *title = next ? @"继续学习" : @"去看看";
    [self.continueBtn setTitle:title forState:UIControlStateNormal];
}

- (void)continueTapped {
    if (self.onContinue) self.onContinue();
}

@end
