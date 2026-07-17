//
//  ResourcesViewController.m
//  iOSStudyApp
//

#import "ResourcesViewController.h"

@interface ResourcesViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray<NSArray<NSDictionary *> *> *sections;

@end

@implementation ResourcesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"学习资源";
    self.view.backgroundColor = [UIColor colorWithWhite:0.97 alpha:1.0];
    [self loadData];
    [self setupTableView];
}

- (void)loadData {
    self.sections = @[
        @[
            @{@"icon": @"doc.text.fill", @"title": @"官方文档", @"detail": @"Apple Developer Documentation"},
            @{@"icon": @"book.fill", @"title": @"推荐书籍", @"detail": @"《Effective Objective-C》等"},
            @{@"icon": @"play.rectangle.fill", @"title": @"视频教程", @"detail": @"WWDC 精选视频"},
        ],
        @[
            @{@"icon": @"hammer.fill", @"title": @"开发工具", @"detail": @"Xcode、Instruments、Reveal"},
            @{@"icon": @"puzzlepiece.fill", @"title": @"常用框架", @"detail": @"AFNetworking、SDWebImage等"},
            @{@"icon": @"square.and.arrow.down.fill", @"title": @"开源项目", @"detail": @"GitHub 优质源码推荐"},
        ],
        @[
            @{@"icon": @"person.2.fill", @"title": @"学习社区", @"detail": @"Stack Overflow、掘金、简书"},
            @{@"icon": @"graduationcap.fill", @"title": @"面试题库", @"detail": @"iOS 常见面试题汇总"},
        ],
    ];
}

- (void)setupTableView {
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleInsetGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = 56;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"ResourceCell"];
    [self.view addSubview:self.tableView];
    
    [NSLayoutConstraint activateConstraints:@[
        [self.tableView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [self.tableView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.tableView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.tableView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
    ]];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView { return self.sections.count; }
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section { return self.sections[section].count; }

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ResourceCell" forIndexPath:indexPath];
    NSDictionary *item = self.sections[indexPath.section][indexPath.row];
    cell.imageView.image = [UIImage systemImageNamed:item[@"icon"]];
    cell.imageView.tintColor = [UIColor colorWithRed:0.18 green:0.60 blue:0.96 alpha:1.0];
    cell.textLabel.text = item[@"title"];
    cell.textLabel.font = [UIFont systemFontOfSize:15];
    
    UILabel *detail = [[UILabel alloc] init];
    detail.text = item[@"detail"];
    detail.font = [UIFont systemFontOfSize:12];
    detail.textColor = [UIColor lightGrayColor];
    [detail sizeToFit];
    cell.accessoryView = detail;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *item = self.sections[indexPath.section][indexPath.row];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:item[@"title"]
                                                                   message:item[@"detail"]
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
