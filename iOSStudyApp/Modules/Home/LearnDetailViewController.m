//
//  LearnDetailViewController.m
//  iOSStudyApp
//

#import "LearnDetailViewController.h"

@interface LearnDetailViewController ()
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *tagLabel;
@property (nonatomic, strong) UILabel *metaLabel;
@property (nonatomic, strong) UILabel *bodyLabel;
@property (nonatomic, strong) UIButton *practiceBtn;
@end

@implementation LearnDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = self.data[@"title"];
    self.view.backgroundColor = [UIColor whiteColor];
    [self setupUI];
    [self configureData];
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
    bannerView.backgroundColor = [UIColor colorWithRed:0.18 green:0.60 blue:0.96 alpha:0.08];
    bannerView.layer.cornerRadius = 12;
    bannerView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:bannerView];
    
    UIImageView *iconView = [[UIImageView alloc] init];
    iconView.image = [UIImage systemImageNamed:@"book.closed.fill"];
    iconView.tintColor = [UIColor colorWithRed:0.18 green:0.60 blue:0.96 alpha:1.0];
    iconView.translatesAutoresizingMaskIntoConstraints = NO;
    [bannerView addSubview:iconView];
    
    self.tagLabel = [[UILabel alloc] init];
    self.tagLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightBold];
    self.tagLabel.textColor = [UIColor colorWithRed:0.18 green:0.60 blue:0.96 alpha:1.0];
    self.tagLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [bannerView addSubview:self.tagLabel];
    
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.font = [UIFont systemFontOfSize:22 weight:UIFontWeightBold];
    self.titleLabel.textColor = [UIColor blackColor];
    self.titleLabel.numberOfLines = 0;
    self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:self.titleLabel];
    
    self.metaLabel = [[UILabel alloc] init];
    self.metaLabel.font = [UIFont systemFontOfSize:13];
    self.metaLabel.textColor = [UIColor grayColor];
    self.metaLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:self.metaLabel];
    
    self.bodyLabel = [[UILabel alloc] init];
    self.bodyLabel.font = [UIFont systemFontOfSize:15];
    self.bodyLabel.textColor = [UIColor colorWithWhite:0.2 alpha:1.0];
    self.bodyLabel.numberOfLines = 0;
    self.bodyLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:self.bodyLabel];
    
    self.practiceBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.practiceBtn setTitle:@"开始练习" forState:UIControlStateNormal];
    [self.practiceBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.practiceBtn.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightBold];
    self.practiceBtn.backgroundColor = [UIColor colorWithRed:0.18 green:0.60 blue:0.96 alpha:1.0];
    self.practiceBtn.layer.cornerRadius = 22;
    self.practiceBtn.translatesAutoresizingMaskIntoConstraints = NO;
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
        
        [bannerView.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:110],
        [bannerView.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:20],
        [bannerView.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-20],
        [bannerView.heightAnchor constraintEqualToConstant:100],
        
        [iconView.centerXAnchor constraintEqualToAnchor:bannerView.centerXAnchor],
        [iconView.centerYAnchor constraintEqualToAnchor:bannerView.centerYAnchor constant:-10],
        [iconView.widthAnchor constraintEqualToConstant:36],
        [iconView.heightAnchor constraintEqualToConstant:36],
        
        [self.tagLabel.centerXAnchor constraintEqualToAnchor:bannerView.centerXAnchor],
        [self.tagLabel.topAnchor constraintEqualToAnchor:iconView.bottomAnchor constant:6],
        
        [self.titleLabel.topAnchor constraintEqualToAnchor:bannerView.bottomAnchor constant:24],
        [self.titleLabel.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:20],
        [self.titleLabel.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-20],
        
        [self.metaLabel.topAnchor constraintEqualToAnchor:self.titleLabel.bottomAnchor constant:10],
        [self.metaLabel.leadingAnchor constraintEqualToAnchor:self.titleLabel.leadingAnchor],
        
        [self.bodyLabel.topAnchor constraintEqualToAnchor:self.metaLabel.bottomAnchor constant:20],
        [self.bodyLabel.leadingAnchor constraintEqualToAnchor:self.titleLabel.leadingAnchor],
        [self.bodyLabel.trailingAnchor constraintEqualToAnchor:self.titleLabel.trailingAnchor],
        
        [self.practiceBtn.topAnchor constraintEqualToAnchor:self.bodyLabel.bottomAnchor constant:30],
        [self.practiceBtn.centerXAnchor constraintEqualToAnchor:self.contentView.centerXAnchor],
        [self.practiceBtn.widthAnchor constraintEqualToConstant:200],
        [self.practiceBtn.heightAnchor constraintEqualToConstant:44],
        [self.practiceBtn.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:-30],
    ]];
}

- (void)configureData {
    self.titleLabel.text = self.data[@"title"];
    self.tagLabel.text = [NSString stringWithFormat:@"· %@ ·", self.data[@"tag"]];
    self.metaLabel.text = [NSString stringWithFormat:@"预计学习时长: %@  |  难度: %@", self.data[@"time"], [self difficultyForTag:self.data[@"tag"]]];
    self.bodyLabel.text = [NSString stringWithFormat:
        @"%@\n\n"
        @"一、概念理解\n\n"
        @"在 iOS 开发中，这是一个非常重要的知识点。掌握它可以帮助你写出更高效、更稳定的代码。\n\n"
        @"二、核心要点\n\n"
        @"1. 理解基本原理和适用场景\n"
        @"2. 掌握常见的 API 调用方式\n"
        @"3. 注意内存管理和性能优化\n"
        @"4. 了解最佳实践和常见坑点\n\n"
        @"三、代码示例\n\n"
        @"// 示例代码\n"
        @"- (void)viewDidLoad {\n"
        @"    [super viewDidLoad];\n"
        @"    // 在这里编写你的代码\n"
        @"    NSLog(@\"Hello iOS!\");\n"
        @"}\n\n"
        @"四、注意事项\n\n"
        @"在实际开发中，需要特别注意以下几点：\n"
        @"• 避免循环引用\n"
        @"• 注意线程安全\n"
        @"• 做好异常处理\n"
        @"• 编写可测试的代码",
        self.data[@"desc"]];
}

- (NSString *)difficultyForTag:(NSString *)tag {
    if ([tag isEqualToString:@"入门"]) return @"⭐";
    if ([tag isEqualToString:@"进阶"]) return @"⭐⭐";
    if ([tag isEqualToString:@"核心"]) return @"⭐⭐⭐";
    if ([tag isEqualToString:@"高阶"]) return @"⭐⭐⭐⭐";
    if ([tag isEqualToString:@"实战"]) return @"⭐⭐⭐⭐⭐";
    return @"⭐⭐⭐";
}

@end
