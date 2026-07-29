//
//  FriendsViewController.m
//  iOSStudyApp
//

#import "FriendsViewController.h"
#import "FriendsAddViewController.h"
#import "FriendDetailViewController.h"
#import "FriendStore.h"
#import "MYTheme.h"

static NSString * const kFriendCellId = @"FriendCellSubtitle";

@interface FriendsViewController () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UILabel *emptyLabel;
@property (nonatomic, copy) NSArray<NSDictionary *> *friends;
@end

@implementation FriendsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"好友";
    self.view.backgroundColor = [MYTheme backgroundColor];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                                           target:self
                                                                                           action:@selector(onAdd)];
    [self setupTable];
    [self setupEmpty];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadFriends)
                                                 name:FriendDataDidChangeNotification
                                               object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self reloadFriends];
}

- (void)setupTable {
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleInsetGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = 72;
    self.tableView.backgroundColor = UIColor.clearColor;
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.tableView];
    [NSLayoutConstraint activateConstraints:@[
        [self.tableView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [self.tableView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.tableView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.tableView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
    ]];
}

- (void)setupEmpty {
    self.emptyLabel = [[UILabel alloc] init];
    self.emptyLabel.text = @"还没有好友\n点右上角添加本地好友";
    self.emptyLabel.numberOfLines = 0;
    self.emptyLabel.textAlignment = NSTextAlignmentCenter;
    self.emptyLabel.textColor = [MYTheme textTertiaryColor];
    self.emptyLabel.font = [UIFont systemFontOfSize:15];
    self.emptyLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.emptyLabel.hidden = YES;
    [self.view addSubview:self.emptyLabel];
    [NSLayoutConstraint activateConstraints:@[
        [self.emptyLabel.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.emptyLabel.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor],
        [self.emptyLabel.leadingAnchor constraintGreaterThanOrEqualToAnchor:self.view.leadingAnchor constant:32],
        [self.emptyLabel.trailingAnchor constraintLessThanOrEqualToAnchor:self.view.trailingAnchor constant:-32],
    ]];
}

- (void)reloadFriends {
    self.friends = [FriendStore shared].friends;
    BOOL hasFriends = self.friends.count > 0;
    self.emptyLabel.hidden = hasFriends;
    self.tableView.hidden = !hasFriends;
    [self.tableView reloadData];
}

- (void)onAdd {
    FriendsAddViewController *addVC = [[FriendsAddViewController alloc] init];
    [self.navigationController pushViewController:addVC animated:YES];
}

#pragma mark - Table

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.friends.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kFriendCellId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kFriendCellId];
    }
    NSDictionary *friend = self.friends[indexPath.row];
    cell.textLabel.text = friend[@"name"];
    cell.textLabel.font = [UIFont systemFontOfSize:17 weight:UIFontWeightSemibold];
    cell.textLabel.textColor = [MYTheme textPrimaryColor];
    NSInteger total = [friend[@"totalMinutes"] integerValue];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"累计学习 %ld 分钟", (long)total];
    cell.detailTextLabel.textColor = [MYTheme textSecondaryColor];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.imageView.image = [UIImage systemImageNamed:@"person.circle.fill"];
    cell.imageView.tintColor = [MYTheme primaryColor];
    cell.backgroundColor = [MYTheme cardColor];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *friend = self.friends[indexPath.row];
    FriendDetailViewController *detail = [[FriendDetailViewController alloc] initWithFriendId:friend[@"id"]];
    [self.navigationController pushViewController:detail animated:YES];
}

@end
