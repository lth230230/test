//
//  PracticeViewController.m
//  iOSStudyApp
//

#import "PracticeViewController.h"
#import "StudyDataStore.h"
#import "MYTheme.h"

@interface PracticeViewController ()
@property (nonatomic, strong) NSArray<NSDictionary *> *questions;
@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, assign) NSInteger score;
@property (nonatomic, strong) UILabel *progressLabel;
@property (nonatomic, strong) UILabel *questionLabel;
@property (nonatomic, strong) UIStackView *optionsStack;
@property (nonatomic, strong) UIButton *nextButton;
@property (nonatomic, assign) NSInteger selectedIndex;
@property (nonatomic, assign) BOOL answered;
@end

@implementation PracticeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"练习巩固";
    self.view.backgroundColor = [MYTheme backgroundColor];
    self.questions = [[StudyDataStore shared] quizForLesson:self.lesson];
    self.currentIndex = 0;
    self.score = 0;
    self.selectedIndex = -1;
    [self setupUI];
    [self renderQuestion];
}

- (void)setupUI {
    UIView *card = [[UIView alloc] init];
    [MYTheme applyCardStyleToView:card];
    card.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:card];
    
    self.progressLabel = [[UILabel alloc] init];
    self.progressLabel.font = [UIFont systemFontOfSize:13 weight:UIFontWeightSemibold];
    self.progressLabel.textColor = [MYTheme primaryColor];
    self.progressLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [card addSubview:self.progressLabel];
    
    self.questionLabel = [[UILabel alloc] init];
    self.questionLabel.font = [UIFont systemFontOfSize:20 weight:UIFontWeightBold];
    self.questionLabel.textColor = [MYTheme textPrimaryColor];
    self.questionLabel.numberOfLines = 0;
    self.questionLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [card addSubview:self.questionLabel];
    
    self.optionsStack = [[UIStackView alloc] init];
    self.optionsStack.axis = UILayoutConstraintAxisVertical;
    self.optionsStack.spacing = 12;
    self.optionsStack.translatesAutoresizingMaskIntoConstraints = NO;
    [card addSubview:self.optionsStack];
    
    self.nextButton = [MYTheme primaryButtonWithTitle:@"下一题"];
    self.nextButton.enabled = NO;
    self.nextButton.alpha = 0.5;
    self.nextButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.nextButton addTarget:self action:@selector(onNext) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.nextButton];
    
    [NSLayoutConstraint activateConstraints:@[
        [card.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:20],
        [card.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [card.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20],
        
        [self.progressLabel.topAnchor constraintEqualToAnchor:card.topAnchor constant:20],
        [self.progressLabel.leadingAnchor constraintEqualToAnchor:card.leadingAnchor constant:20],
        
        [self.questionLabel.topAnchor constraintEqualToAnchor:self.progressLabel.bottomAnchor constant:14],
        [self.questionLabel.leadingAnchor constraintEqualToAnchor:card.leadingAnchor constant:20],
        [self.questionLabel.trailingAnchor constraintEqualToAnchor:card.trailingAnchor constant:-20],
        
        [self.optionsStack.topAnchor constraintEqualToAnchor:self.questionLabel.bottomAnchor constant:24],
        [self.optionsStack.leadingAnchor constraintEqualToAnchor:card.leadingAnchor constant:20],
        [self.optionsStack.trailingAnchor constraintEqualToAnchor:card.trailingAnchor constant:-20],
        [self.optionsStack.bottomAnchor constraintEqualToAnchor:card.bottomAnchor constant:-24],
        
        [self.nextButton.topAnchor constraintEqualToAnchor:card.bottomAnchor constant:24],
        [self.nextButton.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:40],
        [self.nextButton.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-40],
        [self.nextButton.heightAnchor constraintEqualToConstant:48],
    ]];
}

- (void)renderQuestion {
    if (self.currentIndex >= self.questions.count) {
        [self showResult];
        return;
    }
    
    self.answered = NO;
    self.selectedIndex = -1;
    self.nextButton.enabled = NO;
    self.nextButton.alpha = 0.5;
    [self.nextButton setTitle:(self.currentIndex == self.questions.count - 1 ? @"查看成绩" : @"下一题")
                     forState:UIControlStateNormal];
    
    NSDictionary *item = self.questions[self.currentIndex];
    self.progressLabel.text = [NSString stringWithFormat:@"第 %ld / %ld 题 · %@",
                               (long)self.currentIndex + 1, (long)self.questions.count, self.lesson[@"title"]];
    self.questionLabel.text = item[@"q"];
    
    for (UIView *v in self.optionsStack.arrangedSubviews) {
        [self.optionsStack removeArrangedSubview:v];
        [v removeFromSuperview];
    }
    
    NSArray *options = item[@"options"];
    for (NSInteger i = 0; i < options.count; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
        btn.tag = i;
        if (@available(iOS 15.0, *)) {
            UIButtonConfiguration *config = [UIButtonConfiguration plainButtonConfiguration];
            config.contentInsets = NSDirectionalEdgeInsetsMake(14, 16, 14, 16);
            config.title = [NSString stringWithFormat:@"%@. %@", [self letterForIndex:i], options[i]];
            config.titleAlignment = UIButtonConfigurationTitleAlignmentLeading;
            config.baseForegroundColor = [MYTheme textPrimaryColor];
            config.titleTextAttributesTransformer = ^NSDictionary<NSAttributedStringKey,id> *(NSDictionary<NSAttributedStringKey,id> *incoming) {
                NSMutableDictionary *dict = [incoming mutableCopy] ?: [NSMutableDictionary dictionary];
                dict[NSFontAttributeName] = [UIFont systemFontOfSize:15 weight:UIFontWeightMedium];
                return dict;
            };
            btn.configuration = config;
        } else {
            btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
            btn.titleLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightMedium];
            btn.titleLabel.numberOfLines = 0;
            [btn setTitle:[NSString stringWithFormat:@"%@. %@", [self letterForIndex:i], options[i]]
                 forState:UIControlStateNormal];
            [btn setTitleColor:[MYTheme textPrimaryColor] forState:UIControlStateNormal];
        }
        btn.backgroundColor = [MYTheme backgroundColor];
        btn.layer.cornerRadius = 12;
        btn.layer.borderWidth = 1;
        btn.layer.borderColor = [MYTheme dividerColor].CGColor;
        [btn addTarget:self action:@selector(onSelect:) forControlEvents:UIControlEventTouchUpInside];
        [self.optionsStack addArrangedSubview:btn];
    }
    
    [UIView animateWithDuration:0.25 animations:^{
        self.questionLabel.alpha = 1;
        self.optionsStack.alpha = 1;
    }];
}

- (NSString *)letterForIndex:(NSInteger)index {
    return @[@"A", @"B", @"C", @"D"][MIN(index, 3)];
}

- (void)onSelect:(UIButton *)sender {
    if (self.answered) return;
    self.answered = YES;
    self.selectedIndex = sender.tag;
    NSDictionary *item = self.questions[self.currentIndex];
    NSInteger answer = [item[@"answer"] integerValue];
    
    for (UIButton *btn in self.optionsStack.arrangedSubviews) {
        btn.userInteractionEnabled = NO;
        UIColor *fg = [MYTheme textPrimaryColor];
        if (btn.tag == answer) {
            btn.backgroundColor = [[MYTheme successColor] colorWithAlphaComponent:0.15];
            btn.layer.borderColor = [MYTheme successColor].CGColor;
            fg = [MYTheme successColor];
        } else if (btn.tag == self.selectedIndex) {
            btn.backgroundColor = [[UIColor systemRedColor] colorWithAlphaComponent:0.12];
            btn.layer.borderColor = [UIColor systemRedColor].CGColor;
            fg = [UIColor systemRedColor];
        }
        if (@available(iOS 15.0, *)) {
            UIButtonConfiguration *config = btn.configuration;
            config.baseForegroundColor = fg;
            btn.configuration = config;
        } else {
            [btn setTitleColor:fg forState:UIControlStateNormal];
        }
    }
    
    if (self.selectedIndex == answer) {
        self.score += 1;
    }
    
    self.nextButton.enabled = YES;
    self.nextButton.alpha = 1;
}

- (void)onNext {
    self.currentIndex += 1;
    self.questionLabel.alpha = 0.2;
    self.optionsStack.alpha = 0.2;
    [self renderQuestion];
}

- (void)showResult {
    BOOL pass = self.score * 1.0 / MAX(self.questions.count, 1) >= 0.67;
    if (pass) {
        [[StudyDataStore shared] markLessonCompleted:self.lesson[@"id"]];
    }
    
    NSString *message = [NSString stringWithFormat:@"答对 %ld / %ld 题\n%@",
                         (long)self.score, (long)self.questions.count,
                         pass ? @"已自动标记本课为完成，继续保持！" : @"建议回顾课文后再试一次。"];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:pass ? @"练习通过" : @"再接再厉"
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    __weak typeof(self) weakSelf = self;
    [alert addAction:[UIAlertAction actionWithTitle:@"返回详情" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf.navigationController popViewControllerAnimated:YES];
    }]];
    if (!pass) {
        [alert addAction:[UIAlertAction actionWithTitle:@"再练一次" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            weakSelf.currentIndex = 0;
            weakSelf.score = 0;
            [weakSelf renderQuestion];
        }]];
    }
    [self presentViewController:alert animated:YES completion:nil];
}

@end
