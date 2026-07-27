//
//  LearnDetailViewController.m
//  iOSStudyApp
//

#import "LearnDetailViewController.h"
#import "PracticeViewController.h"
#import "StudyDataStore.h"
#import "MYTheme.h"

@interface LearnDetailViewController ()
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIStackView *stack;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *tagLabel;
@property (nonatomic, strong) UILabel *metaLabel;
@property (nonatomic, strong) UIButton *practiceBtn;
@property (nonatomic, strong) UIButton *completeBtn;
@property (nonatomic, strong) UIBarButtonItem *bookmarkItem;
@end

@implementation LearnDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"课程详情";
    self.view.backgroundColor = [MYTheme backgroundColor];
    [self setupNav];
    [self setupUI];
    [self configureData];
    
    if (self.data[@"id"]) {
        [[StudyDataStore shared] setLastLessonId:self.data[@"id"]];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(configureData)
                                                 name:StudyDataDidChangeNotification object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setupNav {
    self.bookmarkItem = [[UIBarButtonItem alloc] initWithImage:[UIImage systemImageNamed:@"bookmark"]
                                                         style:UIBarButtonItemStylePlain
                                                        target:self
                                                        action:@selector(toggleBookmark)];
    self.navigationItem.rightBarButtonItem = self.bookmarkItem;
}

- (void)setupUI {
    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.alwaysBounceVertical = YES;
    self.scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.scrollView];
    
    self.contentView = [[UIView alloc] init];
    self.contentView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.scrollView addSubview:self.contentView];
    
    self.stack = [[UIStackView alloc] init];
    self.stack.axis = UILayoutConstraintAxisVertical;
    self.stack.spacing = 14;
    self.stack.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:self.stack];
    
    self.completeBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    self.completeBtn.titleLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightSemibold];
    self.completeBtn.layer.cornerRadius = 22;
    self.completeBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [self.completeBtn addTarget:self action:@selector(toggleComplete) forControlEvents:UIControlEventTouchUpInside];
    
    self.practiceBtn = [MYTheme primaryButtonWithTitle:@"开始练习"];
    self.practiceBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [self.practiceBtn addTarget:self action:@selector(startPractice) forControlEvents:UIControlEventTouchUpInside];
    
    [NSLayoutConstraint activateConstraints:@[
        [self.scrollView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [self.scrollView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.scrollView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.scrollView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
        
        [self.contentView.topAnchor constraintEqualToAnchor:self.scrollView.topAnchor],
        [self.contentView.leadingAnchor constraintEqualToAnchor:self.scrollView.leadingAnchor],
        [self.contentView.trailingAnchor constraintEqualToAnchor:self.scrollView.trailingAnchor],
        [self.contentView.bottomAnchor constraintEqualToAnchor:self.scrollView.bottomAnchor],
        [self.contentView.widthAnchor constraintEqualToAnchor:self.view.widthAnchor],
        
        [self.stack.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:16],
        [self.stack.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:20],
        [self.stack.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-20],
        [self.stack.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:-28],
        
        [self.completeBtn.heightAnchor constraintEqualToConstant:44],
        [self.practiceBtn.heightAnchor constraintEqualToConstant:48],
    ]];
}

#pragma mark - Section builders

- (UIView *)bannerView {
    UIView *bannerView = [[UIView alloc] init];
    bannerView.backgroundColor = [MYTheme primarySoftColor];
    bannerView.layer.cornerRadius = 18;
    
    UIImageView *iconView = [[UIImageView alloc] initWithImage:[UIImage systemImageNamed:@"book.closed.fill"]];
    iconView.tintColor = [MYTheme primaryColor];
    iconView.translatesAutoresizingMaskIntoConstraints = NO;
    [bannerView addSubview:iconView];
    
    self.tagLabel = [[UILabel alloc] init];
    self.tagLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightBold];
    self.tagLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [bannerView addSubview:self.tagLabel];
    
    [NSLayoutConstraint activateConstraints:@[
        [bannerView.heightAnchor constraintEqualToConstant:100],
        [iconView.centerXAnchor constraintEqualToAnchor:bannerView.centerXAnchor],
        [iconView.centerYAnchor constraintEqualToAnchor:bannerView.centerYAnchor constant:-10],
        [iconView.widthAnchor constraintEqualToConstant:34],
        [iconView.heightAnchor constraintEqualToConstant:34],
        [self.tagLabel.centerXAnchor constraintEqualToAnchor:bannerView.centerXAnchor],
        [self.tagLabel.topAnchor constraintEqualToAnchor:iconView.bottomAnchor constant:6],
    ]];
    return bannerView;
}

- (UIView *)cardWithTitle:(NSString *)title body:(NSString *)body {
    UIView *card = [[UIView alloc] init];
    [MYTheme applyCardStyleToView:card];
    
    UILabel *h = [[UILabel alloc] init];
    h.text = title;
    h.font = [UIFont systemFontOfSize:16 weight:UIFontWeightBold];
    h.textColor = [MYTheme textPrimaryColor];
    h.translatesAutoresizingMaskIntoConstraints = NO;
    
    UILabel *b = [[UILabel alloc] init];
    b.text = body;
    b.font = [UIFont systemFontOfSize:14];
    b.textColor = [MYTheme textPrimaryColor];
    b.numberOfLines = 0;
    b.translatesAutoresizingMaskIntoConstraints = NO;
    
    [card addSubview:h];
    [card addSubview:b];
    [NSLayoutConstraint activateConstraints:@[
        [h.topAnchor constraintEqualToAnchor:card.topAnchor constant:14],
        [h.leadingAnchor constraintEqualToAnchor:card.leadingAnchor constant:14],
        [h.trailingAnchor constraintEqualToAnchor:card.trailingAnchor constant:-14],
        [b.topAnchor constraintEqualToAnchor:h.bottomAnchor constant:8],
        [b.leadingAnchor constraintEqualToAnchor:h.leadingAnchor],
        [b.trailingAnchor constraintEqualToAnchor:h.trailingAnchor],
        [b.bottomAnchor constraintEqualToAnchor:card.bottomAnchor constant:-14],
    ]];
    return card;
}

- (NSString *)bulleted:(NSArray *)items prefix:(NSString *)prefix {
    if (![items isKindOfClass:NSArray.class] || items.count == 0) return @"";
    NSMutableString *s = [NSMutableString string];
    [items enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (prefix.length) {
            [s appendFormat:@"%@%lu  %@\n", prefix, (unsigned long)idx + 1, obj];
        } else {
            [s appendFormat:@"• %@\n", obj];
        }
    }];
    return [s stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
}

- (void)configureData {
    for (UIView *v in self.stack.arrangedSubviews) {
        [self.stack removeArrangedSubview:v];
        [v removeFromSuperview];
    }
    
    NSString *lessonId = self.data[@"id"];
    StudyDataStore *store = [StudyDataStore shared];
    NSString *tag = self.data[@"tag"] ?: @"";
    BOOL done = [store isLessonCompleted:lessonId];
    BOOL bookmarked = [store isBookmarked:lessonId];
    
    UIView *banner = [self bannerView];
    self.tagLabel.text = [NSString stringWithFormat:@"· %@ ·", tag];
    self.tagLabel.textColor = [MYTheme tagColorForName:tag];
    [self.stack addArrangedSubview:banner];
    
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.text = self.data[@"title"];
    self.titleLabel.font = [UIFont systemFontOfSize:24 weight:UIFontWeightBold];
    self.titleLabel.textColor = [MYTheme textPrimaryColor];
    self.titleLabel.numberOfLines = 0;
    [self.stack addArrangedSubview:self.titleLabel];
    
    self.metaLabel = [[UILabel alloc] init];
    self.metaLabel.font = [UIFont systemFontOfSize:13];
    self.metaLabel.textColor = [MYTheme textSecondaryColor];
    self.metaLabel.numberOfLines = 0;
    self.metaLabel.text = [NSString stringWithFormat:@"预计学习时长: %@  |  难度: %@  |  %@\n%@",
                           self.data[@"time"] ?: @"—",
                           [self difficultyForTag:tag],
                           done ? @"已完成" : @"未完成",
                           self.data[@"desc"] ?: @""];
    [self.stack addArrangedSubview:self.metaLabel];
    
    NSString *prereq = [self bulleted:self.data[@"prerequisites"] prefix:nil];
    if (prereq.length) [self.stack addArrangedSubview:[self cardWithTitle:@"前置要求" body:prereq]];
    
    NSString *goals = [self bulleted:self.data[@"learningGoals"] prefix:@""];
    if (goals.length) [self.stack addArrangedSubview:[self cardWithTitle:@"学习目标" body:goals]];
    
    NSString *path = [self bulleted:self.data[@"learningPath"] prefix:@"Step "];
    if (path.length) [self.stack addArrangedSubview:[self cardWithTitle:@"从 0 到 1 学习路径" body:path]];
    
    NSArray *chapters = self.data[@"chapters"];
    if ([chapters isKindOfClass:NSArray.class] && chapters.count) {
        NSMutableString *lecture = [NSMutableString string];
        for (NSDictionary *ch in chapters) {
            if (![ch isKindOfClass:NSDictionary.class]) continue;
            [lecture appendFormat:@"%@\n\n%@\n\n", ch[@"title"] ?: @"", ch[@"body"] ?: @""];
        }
        [self.stack addArrangedSubview:[self cardWithTitle:@"完整讲义" body:[lecture stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]]];
    } else if ([self.data[@"content"] length]) {
        [self.stack addArrangedSubview:[self cardWithTitle:@"完整讲义" body:self.data[@"content"]]];
    }
    
    NSArray *materials = self.data[@"materials"];
    if ([materials isKindOfClass:NSArray.class] && materials.count) {
        NSMutableString *m = [NSMutableString string];
        for (NSDictionary *item in materials) {
            if (![item isKindOfClass:NSDictionary.class]) continue;
            [m appendFormat:@"[%@] %@\n%@\n", item[@"type"] ?: @"资料", item[@"title"] ?: @"", item[@"detail"] ?: @""];
            if ([item[@"url"] length]) [m appendFormat:@"链接：%@\n", item[@"url"]];
            [m appendString:@"\n"];
        }
        [self.stack addArrangedSubview:[self cardWithTitle:@"完整学习资料" body:[m stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]]];
    }
    
    NSString *check = [self bulleted:self.data[@"checklist"] prefix:nil];
    if (check.length) [self.stack addArrangedSubview:[self cardWithTitle:@"掌握清单（学完请自检）" body:check]];
    
    NSArray *glossary = self.data[@"glossary"];
    if ([glossary isKindOfClass:NSArray.class] && glossary.count) {
        NSMutableString *g = [NSMutableString string];
        for (NSDictionary *item in glossary) {
            if (![item isKindOfClass:NSDictionary.class]) continue;
            [g appendFormat:@"%@\n%@\n\n", item[@"term"] ?: @"", item[@"definition"] ?: @""];
        }
        [self.stack addArrangedSubview:[self cardWithTitle:@"术语表" body:[g stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]]];
    }
    
    self.bookmarkItem.image = [UIImage systemImageNamed:bookmarked ? @"bookmark.fill" : @"bookmark"];
    
    if (done) {
        [self.completeBtn setTitle:@"取消完成标记" forState:UIControlStateNormal];
        [self.completeBtn setTitleColor:[MYTheme primaryColor] forState:UIControlStateNormal];
        self.completeBtn.backgroundColor = [MYTheme primarySoftColor];
    } else {
        [self.completeBtn setTitle:@"标记为已完成" forState:UIControlStateNormal];
        [self.completeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.completeBtn.backgroundColor = [MYTheme accentColor];
    }
    [self.stack addArrangedSubview:self.completeBtn];
    
    NSArray *quiz = [store quizForLesson:self.data];
    BOOL hasQuiz = quiz.count > 0;
    self.practiceBtn.hidden = !hasQuiz;
    self.practiceBtn.enabled = hasQuiz;
    self.practiceBtn.alpha = hasQuiz ? 1.0 : 0.0;
    if (hasQuiz) {
        [self.practiceBtn setTitle:[NSString stringWithFormat:@"开始练习（%lu 题）", (unsigned long)quiz.count]
                         forState:UIControlStateNormal];
        [self.stack addArrangedSubview:self.practiceBtn];
    }
}

- (NSString *)difficultyForTag:(NSString *)tag {
    if ([tag isEqualToString:@"入门"]) return @"⭐";
    if ([tag isEqualToString:@"进阶"]) return @"⭐⭐";
    if ([tag isEqualToString:@"核心"]) return @"⭐⭐⭐";
    if ([tag isEqualToString:@"高阶"]) return @"⭐⭐⭐⭐";
    if ([tag isEqualToString:@"实战"]) return @"⭐⭐⭐⭐⭐";
    return @"⭐⭐⭐";
}

- (void)toggleBookmark {
    [[StudyDataStore shared] toggleBookmark:self.data[@"id"]];
    UIImpactFeedbackGenerator *gen = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleLight];
    [gen impactOccurred];
}

- (void)toggleComplete {
    StudyDataStore *store = [StudyDataStore shared];
    NSString *lessonId = self.data[@"id"];
    if ([store isLessonCompleted:lessonId]) {
        [store unmarkLessonCompleted:lessonId];
    } else {
        [store markLessonCompleted:lessonId];
    }
}

- (void)startPractice {
    if ([[StudyDataStore shared] quizForLesson:self.data].count == 0) {
        UIAlertController *alert =
            [UIAlertController alertControllerWithTitle:@"暂无练习"
                                               message:@"这节课还没有测验题"
                                        preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    PracticeViewController *practice = [[PracticeViewController alloc] init];
    practice.lesson = self.data;
    [self.navigationController pushViewController:practice animated:YES];
}

@end
