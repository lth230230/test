//
//  SettingsViewController.m
//  iOSStudyApp
//

#import "SettingsViewController.h"

@interface SettingsViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray<NSArray<NSDictionary *> *> *sections;

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"设置";
    self.view.backgroundColor = [UIColor colorWithWhite:0.97 alpha:1.0];
    [self loadData];
    [self setupTableView];
}

- (void)loadData {
    self.sections = @[
        @[
            @{@"icon": @"person.crop.circle", @"title": @"个人资料", @"detail": @"编辑学习信息"},
            @{@"icon": @"bell", @"title": @"学习提醒", @"detail": @"每日9:00推送"},
        ],
        @[
            @{@"icon": @"chart.bar", @"title": @"学习统计", @"detail": @"累计学习 28 小时"},
            @{@"icon": @"target", @"title": @"学习目标", @"detail": @"今日目标: 2课时"},
        ],
        @[
            @{@"icon": @"arrow.triangle.2.circlepath", @"title": @"数据同步", @"detail": @"iCloud 已开启"},
            @{@"icon": @"square.and.arrow.down", @"title": @"离线缓存", @"detail": @"已缓存 6 课时"},
        ],
        @[
            @{@"icon": @"star", @"title": @"给我们评分", @"detail": @"您的支持是最大动力"},
            @{@"icon": @"envelope", @"title": @"意见反馈", @"detail": @"帮助我们做得更好"},
            @{@"icon": @"info.circle", @"title": @"关于", @"detail": @"v1.0.0"},
        ],
    ];
}

- (void)setupTableView {
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleInsetGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = 52;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"SettingCell"];
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SettingCell" forIndexPath:indexPath];
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
