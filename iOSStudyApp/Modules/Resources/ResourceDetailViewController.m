//
//  ResourceDetailViewController.m
//  iOSStudyApp
//

#import "ResourceDetailViewController.h"
#import "MYTheme.h"

@implementation ResourceDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = self.resource[@"title"];
    self.view.backgroundColor = [MYTheme backgroundColor];
    [self setupUI];
}

- (void)setupUI {
    UIScrollView *scroll = [[UIScrollView alloc] init];
    scroll.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:scroll];
    
    UIView *content = [[UIView alloc] init];
    content.translatesAutoresizingMaskIntoConstraints = NO;
    [scroll addSubview:content];
    
    UIView *banner = [[UIView alloc] init];
    banner.backgroundColor = [MYTheme primarySoftColor];
    banner.layer.cornerRadius = 18;
    banner.translatesAutoresizingMaskIntoConstraints = NO;
    [content addSubview:banner];
    
    UIImageView *icon = [[UIImageView alloc] initWithImage:[UIImage systemImageNamed:self.resource[@"icon"]]];
    icon.tintColor = [MYTheme primaryColor];
    icon.contentMode = UIViewContentModeScaleAspectFit;
    icon.translatesAutoresizingMaskIntoConstraints = NO;
    [banner addSubview:icon];
    
    UILabel *title = [[UILabel alloc] init];
    title.text = self.resource[@"title"];
    title.font = [UIFont systemFontOfSize:24 weight:UIFontWeightBold];
    title.textColor = [MYTheme textPrimaryColor];
    title.numberOfLines = 0;
    title.translatesAutoresizingMaskIntoConstraints = NO;
    [content addSubview:title];
    
    UILabel *detail = [[UILabel alloc] init];
    detail.text = self.resource[@"detail"];
    detail.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
    detail.textColor = [MYTheme primaryColor];
    detail.translatesAutoresizingMaskIntoConstraints = NO;
    [content addSubview:detail];
    
    UILabel *summary = [[UILabel alloc] init];
    summary.text = self.resource[@"summary"];
    summary.font = [UIFont systemFontOfSize:16];
    summary.textColor = [MYTheme textSecondaryColor];
    summary.numberOfLines = 0;
    summary.translatesAutoresizingMaskIntoConstraints = NO;
    [content addSubview:summary];
    
    UIButton *openBtn = [MYTheme primaryButtonWithTitle:@"在浏览器中打开"];
    openBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [openBtn addTarget:self action:@selector(openLink) forControlEvents:UIControlEventTouchUpInside];
    [content addSubview:openBtn];
    
    UIButton *copyBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [copyBtn setTitle:@"复制链接" forState:UIControlStateNormal];
    [copyBtn setTitleColor:[MYTheme primaryColor] forState:UIControlStateNormal];
    copyBtn.titleLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightSemibold];
    copyBtn.backgroundColor = [MYTheme primarySoftColor];
    copyBtn.layer.cornerRadius = 22;
    copyBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [copyBtn addTarget:self action:@selector(copyLink) forControlEvents:UIControlEventTouchUpInside];
    [content addSubview:copyBtn];
    
    [NSLayoutConstraint activateConstraints:@[
        [scroll.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [scroll.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [scroll.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [scroll.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
        
        [content.topAnchor constraintEqualToAnchor:scroll.topAnchor],
        [content.leadingAnchor constraintEqualToAnchor:scroll.leadingAnchor],
        [content.trailingAnchor constraintEqualToAnchor:scroll.trailingAnchor],
        [content.bottomAnchor constraintEqualToAnchor:scroll.bottomAnchor],
        [content.widthAnchor constraintEqualToAnchor:self.view.widthAnchor],
        
        [banner.topAnchor constraintEqualToAnchor:content.topAnchor constant:24],
        [banner.leadingAnchor constraintEqualToAnchor:content.leadingAnchor constant:20],
        [banner.trailingAnchor constraintEqualToAnchor:content.trailingAnchor constant:-20],
        [banner.heightAnchor constraintEqualToConstant:120],
        
        [icon.centerXAnchor constraintEqualToAnchor:banner.centerXAnchor],
        [icon.centerYAnchor constraintEqualToAnchor:banner.centerYAnchor],
        [icon.widthAnchor constraintEqualToConstant:44],
        [icon.heightAnchor constraintEqualToConstant:44],
        
        [title.topAnchor constraintEqualToAnchor:banner.bottomAnchor constant:24],
        [title.leadingAnchor constraintEqualToAnchor:content.leadingAnchor constant:20],
        [title.trailingAnchor constraintEqualToAnchor:content.trailingAnchor constant:-20],
        
        [detail.topAnchor constraintEqualToAnchor:title.bottomAnchor constant:8],
        [detail.leadingAnchor constraintEqualToAnchor:title.leadingAnchor],
        [detail.trailingAnchor constraintEqualToAnchor:title.trailingAnchor],
        
        [summary.topAnchor constraintEqualToAnchor:detail.bottomAnchor constant:16],
        [summary.leadingAnchor constraintEqualToAnchor:title.leadingAnchor],
        [summary.trailingAnchor constraintEqualToAnchor:title.trailingAnchor],
        
        [openBtn.topAnchor constraintEqualToAnchor:summary.bottomAnchor constant:28],
        [openBtn.leadingAnchor constraintEqualToAnchor:content.leadingAnchor constant:20],
        [openBtn.trailingAnchor constraintEqualToAnchor:content.trailingAnchor constant:-20],
        [openBtn.heightAnchor constraintEqualToConstant:48],
        
        [copyBtn.topAnchor constraintEqualToAnchor:openBtn.bottomAnchor constant:12],
        [copyBtn.leadingAnchor constraintEqualToAnchor:openBtn.leadingAnchor],
        [copyBtn.trailingAnchor constraintEqualToAnchor:openBtn.trailingAnchor],
        [copyBtn.heightAnchor constraintEqualToConstant:48],
        [copyBtn.bottomAnchor constraintEqualToAnchor:content.bottomAnchor constant:-30],
    ]];
}

- (void)openLink {
    NSString *urlString = self.resource[@"url"];
    NSURL *url = [NSURL URLWithString:urlString];
    if (!url) return;
    [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
}

- (void)copyLink {
    UIPasteboard.generalPasteboard.string = self.resource[@"url"] ?: @"";
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"已复制"
                                                                   message:@"链接已复制到剪贴板"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
