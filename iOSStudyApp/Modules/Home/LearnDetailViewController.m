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
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *tagLabel;
@property (nonatomic, strong) UILabel *metaLabel;
@property (nonatomic, strong) UILabel *bodyLabel;
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
    
    UIView *bannerView = [[UIView alloc] init];
    bannerView.backgroundColor = [MYTheme primarySoftColor];
    bannerView.layer.cornerRadius = 18;
    bannerView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:bannerView];
    
    UIImageView *iconView = [[UIImageView alloc] init];
    iconView.image = [UIImage systemImageNamed:@"book.closed.fill"];
    iconView.tintColor = [MYTheme primaryColor];
    iconView.translatesAutoresizingMaskIntoConstraints = NO;
    [bannerView addSubview:iconView];
    
    self.tagLabel = [[UILabel alloc] init];
    self.tagLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightBold];
    self.tagLabel.textColor = [MYTheme primaryColor];
    self.tagLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [bannerView addSubview:self.tagLabel];
    
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.font = [UIFont systemFontOfSize:24 weight:UIFontWeightBold];
    self.titleLabel.textColor = [MYTheme textPrimaryColor];
    self.titleLabel.numberOfLines = 0;
    self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:self.titleLabel];
    
    self.metaLabel = [[UILabel alloc] init];
    self.metaLabel.font = [UIFont systemFontOfSize:13];
    self.metaLabel.textColor = [MYTheme textSecondaryColor];
    self.metaLabel.numberOfLines = 0;
    self.metaLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:self.metaLabel];
    
    UIView *bodyCard = [[UIView alloc] init];
    [MYTheme applyCardStyleToView:bodyCard];
    bodyCard.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:bodyCard];
    
    self.bodyLabel = [[UILabel alloc] init];
    self.bodyLabel.font = [UIFont systemFontOfSize:15];
    self.bodyLabel.textColor = [MYTheme textPrimaryColor];
    self.bodyLabel.numberOfLines = 0;
    self.bodyLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [bodyCard addSubview:self.bodyLabel];
    
    self.completeBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    self.completeBtn.titleLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightSemibold];
    self.completeBtn.layer.cornerRadius = 22;
    self.completeBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [self.completeBtn addTarget:self action:@selector(toggleComplete) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.completeBtn];
    
    self.practiceBtn = [MYTheme primaryButtonWithTitle:@"开始练习"];
    self.practiceBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [self.practiceBtn addTarget:self action:@selector(startPractice) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.practiceBtn];
    
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
        
        [bannerView.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:20],
        [bannerView.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:20],
        [bannerView.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-20],
        [bannerView.heightAnchor constraintEqualToConstant:110],
        
        [iconView.centerXAnchor constraintEqualToAnchor:bannerView.centerXAnchor],
        [iconView.centerYAnchor constraintEqualToAnchor:bannerView.centerYAnchor constant:-10],
        [iconView.widthAnchor constraintEqualToConstant:36],
        [iconView.heightAnchor constraintEqualToConstant:36],
        
        [self.tagLabel.centerXAnchor constraintEqualToAnchor:bannerView.centerXAnchor],
        [self.tagLabel.topAnchor constraintEqualToAnchor:iconView.bottomAnchor constant:6],
        
        [self.titleLabel.topAnchor constraintEqualToAnchor:bannerView.bottomAnchor constant:20],
        [self.titleLabel.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:20],
        [self.titleLabel.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-20],
        
        [self.metaLabel.topAnchor constraintEqualToAnchor:self.titleLabel.bottomAnchor constant:10],
        [self.metaLabel.leadingAnchor constraintEqualToAnchor:self.titleLabel.leadingAnchor],
        [self.metaLabel.trailingAnchor constraintEqualToAnchor:self.titleLabel.trailingAnchor],
        
        [bodyCard.topAnchor constraintEqualToAnchor:self.metaLabel.bottomAnchor constant:18],
        [bodyCard.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:20],
        [bodyCard.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-20],
        
        [self.bodyLabel.topAnchor constraintEqualToAnchor:bodyCard.topAnchor constant:18],
        [self.bodyLabel.leadingAnchor constraintEqualToAnchor:bodyCard.leadingAnchor constant:16],
        [self.bodyLabel.trailingAnchor constraintEqualToAnchor:bodyCard.trailingAnchor constant:-16],
        [self.bodyLabel.bottomAnchor constraintEqualToAnchor:bodyCard.bottomAnchor constant:-18],
        
        [self.completeBtn.topAnchor constraintEqualToAnchor:bodyCard.bottomAnchor constant:22],
        [self.completeBtn.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:20],
        [self.completeBtn.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-20],
        [self.completeBtn.heightAnchor constraintEqualToConstant:44],
        
        [self.practiceBtn.topAnchor constraintEqualToAnchor:self.completeBtn.bottomAnchor constant:12],
        [self.practiceBtn.leadingAnchor constraintEqualToAnchor:self.completeBtn.leadingAnchor],
        [self.practiceBtn.trailingAnchor constraintEqualToAnchor:self.completeBtn.trailingAnchor],
        [self.practiceBtn.heightAnchor constraintEqualToConstant:48],
        [self.practiceBtn.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:-30],
    ]];
}

- (void)configureData {
    NSString *lessonId = self.data[@"id"];
    StudyDataStore *store = [StudyDataStore shared];
    
    self.titleLabel.text = self.data[@"title"];
    NSString *tag = self.data[@"tag"] ?: @"";
    self.tagLabel.text = [NSString stringWithFormat:@"· %@ ·", tag];
    self.tagLabel.textColor = [MYTheme tagColorForName:tag];
    
    BOOL done = [store isLessonCompleted:lessonId];
    BOOL bookmarked = [store isBookmarked:lessonId];
    self.metaLabel.text = [NSString stringWithFormat:@"预计学习时长: %@  |  难度: %@  |  %@",
                           self.data[@"time"], [self difficultyForTag:tag],
                           done ? @"已完成" : @"未完成"];
    
    NSString *content = self.data[@"content"];
    if (!content.length) {
        content = [NSString stringWithFormat:@"%@\n\n暂无详细正文，完成练习也可标记掌握。", self.data[@"desc"] ?: @""];
    }
    self.bodyLabel.text = content;
    
    UIImage *bookmarkImage = [UIImage systemImageNamed:bookmarked ? @"bookmark.fill" : @"bookmark"];
    self.bookmarkItem.image = bookmarkImage;
    
    if (done) {
        [self.completeBtn setTitle:@"取消完成标记" forState:UIControlStateNormal];
        [self.completeBtn setTitleColor:[MYTheme primaryColor] forState:UIControlStateNormal];
        self.completeBtn.backgroundColor = [MYTheme primarySoftColor];
    } else {
        [self.completeBtn setTitle:@"标记为已完成" forState:UIControlStateNormal];
        [self.completeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.completeBtn.backgroundColor = [MYTheme accentColor];
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
    PracticeViewController *practice = [[PracticeViewController alloc] init];
    practice.lesson = self.data;
    [self.navigationController pushViewController:practice animated:YES];
}

@end
