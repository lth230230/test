//
//  ResourcesViewController.m
//  iOSStudyApp
//

#import "ResourcesViewController.h"
#import "ResourceDetailViewController.h"
#import "StudyDataStore.h"
#import "MYTheme.h"

@interface ResourcesViewController () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray<NSArray<NSDictionary *> *> *sections;
@property (nonatomic, strong) NSArray<NSString *> *sectionTitles;
@end

@implementation ResourcesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"学习资源";
    self.view.backgroundColor = [MYTheme backgroundColor];
    self.sections = [[StudyDataStore shared] resourceSections];
    self.sectionTitles = @[@"精选资料", @"工具与源码", @"社区与面试"];
    [self setupTableView];
}

- (void)setupTableView {
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleInsetGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = 64;
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

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.sectionTitles[section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ResourceCell" forIndexPath:indexPath];
    NSDictionary *item = self.sections[indexPath.section][indexPath.row];
    
    if (@available(iOS 14.0, *)) {
        UIListContentConfiguration *config = [UIListContentConfiguration subtitleCellConfiguration];
        config.image = [UIImage systemImageNamed:item[@"icon"]];
        config.imageProperties.tintColor = [MYTheme primaryColor];
        config.text = item[@"title"];
        config.secondaryText = item[@"detail"];
        config.textProperties.font = [UIFont systemFontOfSize:15 weight:UIFontWeightSemibold];
        config.secondaryTextProperties.font = [UIFont systemFontOfSize:12];
        config.secondaryTextProperties.color = [MYTheme textTertiaryColor];
        cell.contentConfiguration = config;
    } else {
        cell.imageView.image = [UIImage systemImageNamed:item[@"icon"]];
        cell.imageView.tintColor = [MYTheme primaryColor];
        cell.textLabel.text = item[@"title"];
        cell.detailTextLabel.text = item[@"detail"];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.backgroundColor = [MYTheme cardColor];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    ResourceDetailViewController *detail = [[ResourceDetailViewController alloc] init];
    detail.resource = self.sections[indexPath.section][indexPath.row];
    detail.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:detail animated:YES];
}

@end
