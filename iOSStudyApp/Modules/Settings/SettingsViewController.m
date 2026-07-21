//
//  SettingsViewController.m
//  iOSStudyApp
//

#import "SettingsViewController.h"
#import "StudyDataStore.h"
#import "MYTheme.h"

@interface SettingsViewController () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray<NSArray<NSDictionary *> *> *sections;
@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"设置";
    self.view.backgroundColor = [MYTheme backgroundColor];
    [self rebuildSections];
    [self setupTableView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onDataChange)
                                                 name:StudyDataDidChangeNotification object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)onDataChange {
    [self rebuildSections];
    [self.tableView reloadData];
}

- (void)rebuildSections {
    StudyDataStore *store = [StudyDataStore shared];
    self.sections = @[
        @[
            @{@"key": @"profile", @"icon": @"person.crop.circle", @"title": @"个人资料",
              @"detail": store.userName, @"type": @"disclosure"},
            @{@"key": @"reminder", @"icon": @"bell", @"title": @"学习提醒",
              @"detail": @"每日提醒开关", @"type": @"switch"},
        ],
        @[
            @{@"key": @"stats", @"icon": @"chart.bar", @"title": @"学习统计",
              @"detail": [NSString stringWithFormat:@"累计 %ld 分钟 · 完成 %ld 课",
                          (long)store.totalStudyMinutes, (long)store.completedCount],
              @"type": @"info"},
            @{@"key": @"goal", @"icon": @"target", @"title": @"每日目标",
              @"detail": [NSString stringWithFormat:@"%ld 分钟", (long)store.dailyGoalMinutes],
              @"type": @"disclosure"},
            @{@"key": @"bookmarks", @"icon": @"bookmark", @"title": @"我的收藏",
              @"detail": [NSString stringWithFormat:@"%ld 课", (long)store.bookmarkedLessons.count],
              @"type": @"info"},
        ],
        @[
            @{@"key": @"reset", @"icon": @"arrow.counterclockwise", @"title": @"重置学习进度",
              @"detail": @"清除完成记录与时长", @"type": @"destructive"},
            @{@"key": @"about", @"icon": @"info.circle", @"title": @"关于",
              @"detail": @"v1.1.0", @"type": @"disclosure"},
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
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"SettingCell"];
    [self.view addSubview:self.tableView];
    
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 120)];
    UIView *avatar = [[UIView alloc] initWithFrame:CGRectMake(0, 16, 64, 64)];
    avatar.backgroundColor = [MYTheme primarySoftColor];
    avatar.layer.cornerRadius = 32;
    [header addSubview:avatar];
    
    UIImageView *icon = [[UIImageView alloc] initWithImage:[UIImage systemImageNamed:@"graduationcap.fill"]];
    icon.tintColor = [MYTheme primaryColor];
    icon.frame = CGRectMake(18, 18, 28, 28);
    [avatar addSubview:icon];
    
    UILabel *name = [[UILabel alloc] initWithFrame:CGRectMake(0, 88, 0, 22)];
    name.tag = 99;
    name.font = [UIFont systemFontOfSize:18 weight:UIFontWeightBold];
    name.textColor = [MYTheme textPrimaryColor];
    name.textAlignment = NSTextAlignmentCenter;
    name.text = [StudyDataStore shared].userName;
    [header addSubview:name];
    
    self.tableView.tableHeaderView = header;
    
    // Center header subviews on layout
    dispatch_async(dispatch_get_main_queue(), ^{
        CGFloat w = self.tableView.bounds.size.width;
        avatar.center = CGPointMake(w / 2.0, 48);
        name.frame = CGRectMake(20, 88, w - 40, 22);
    });
    
    [NSLayoutConstraint activateConstraints:@[
        [self.tableView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [self.tableView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.tableView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.tableView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
    ]];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    UIView *header = self.tableView.tableHeaderView;
    if (!header) return;
    UIView *avatar = header.subviews.firstObject;
    UILabel *name = [header viewWithTag:99];
    CGFloat w = self.tableView.bounds.size.width;
    avatar.center = CGPointMake(w / 2.0, 48);
    name.frame = CGRectMake(20, 88, w - 40, 22);
    name.text = [StudyDataStore shared].userName;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView { return self.sections.count; }
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section { return self.sections[section].count; }

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SettingCell" forIndexPath:indexPath];
    cell.accessoryView = nil;
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    
    NSDictionary *item = self.sections[indexPath.section][indexPath.row];
    NSString *type = item[@"type"];
    
    if (@available(iOS 14.0, *)) {
        UIListContentConfiguration *config = [UIListContentConfiguration valueCellConfiguration];
        config.image = [UIImage systemImageNamed:item[@"icon"]];
        config.imageProperties.tintColor = [type isEqualToString:@"destructive"] ? [UIColor systemRedColor] : [MYTheme primaryColor];
        config.text = item[@"title"];
        config.secondaryText = [type isEqualToString:@"switch"] ? nil : item[@"detail"];
        config.textProperties.color = [type isEqualToString:@"destructive"] ? [UIColor systemRedColor] : [MYTheme textPrimaryColor];
        cell.contentConfiguration = config;
    } else {
        cell.imageView.image = [UIImage systemImageNamed:item[@"icon"]];
        cell.textLabel.text = item[@"title"];
        cell.detailTextLabel.text = item[@"detail"];
    }
    
    if ([type isEqualToString:@"switch"]) {
        UISwitch *toggle = [[UISwitch alloc] init];
        toggle.on = [StudyDataStore shared].reminderEnabled;
        toggle.onTintColor = [MYTheme primaryColor];
        [toggle addTarget:self action:@selector(reminderChanged:) forControlEvents:UIControlEventValueChanged];
        cell.accessoryView = toggle;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    } else if ([type isEqualToString:@"disclosure"] || [type isEqualToString:@"destructive"]) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    cell.backgroundColor = [MYTheme cardColor];
    return cell;
}

- (void)reminderChanged:(UISwitch *)sender {
    [[StudyDataStore shared] setReminderEnabled:sender.isOn];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *item = self.sections[indexPath.section][indexPath.row];
    NSString *key = item[@"key"];
    
    if ([key isEqualToString:@"profile"]) {
        [self editProfile];
    } else if ([key isEqualToString:@"goal"]) {
        [self editGoal];
    } else if ([key isEqualToString:@"reset"]) {
        [self confirmReset];
    } else if ([key isEqualToString:@"about"]) {
        [self showAbout];
    } else if ([key isEqualToString:@"stats"] || [key isEqualToString:@"bookmarks"]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:item[@"title"]
                                                                       message:item[@"detail"]
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (void)editProfile {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"编辑昵称"
                                                                   message:@"设置你在学习首页显示的名字"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = [StudyDataStore shared].userName;
        textField.placeholder = @"学习者";
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    }];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:@"保存" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[StudyDataStore shared] setUserName:alert.textFields.firstObject.text];
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)editGoal {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"每日目标"
                                                                   message:@"选择每天希望学习的分钟数"
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    NSArray *options = @[@15, @30, @45, @60, @90];
    for (NSNumber *mins in options) {
        [alert addAction:[UIAlertAction actionWithTitle:[NSString stringWithFormat:@"%@ 分钟", mins]
                                                  style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction * _Nonnull action) {
            [[StudyDataStore shared] setDailyGoalMinutes:mins.integerValue];
        }]];
    }
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)confirmReset {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"重置学习进度？"
                                                                   message:@"将清除完成记录、收藏与学习时长，此操作不可撤销。"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:@"确认重置" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [[StudyDataStore shared] resetAllProgress];
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)showAbout {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"iOS 学习助手"
                                                                   message:@"版本 1.1.0\n\n本地课程学习 Demo：支持进度记录、收藏、筛选搜索与练习测验。适合作为 Objective-C / UIKit 学习项目。"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
