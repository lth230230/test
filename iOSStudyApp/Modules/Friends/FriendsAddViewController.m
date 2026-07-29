//
//  FriendsAddViewController.m
//  iOSStudyApp
//

#import "FriendsAddViewController.h"
#import "FriendStore.h"
#import "MYTheme.h"

static NSString * const kAddCellId = @"AddFriendCell";

@interface FriendsAddViewController () <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, copy) NSArray<NSDictionary *> *candidates;
@end

@implementation FriendsAddViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"添加好友";
    self.view.backgroundColor = [MYTheme backgroundColor];
    [self setupSearch];
    [self setupTable];
    [self reloadCandidates];
}

- (void)setupSearch {
    self.searchBar = [[UISearchBar alloc] init];
    self.searchBar.placeholder = @"按昵称搜索本地候选人";
    self.searchBar.delegate = self;
    self.searchBar.searchBarStyle = UISearchBarStyleMinimal;
    self.searchBar.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.searchBar];
}

- (void)setupTable {
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleInsetGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = 64;
    self.tableView.backgroundColor = UIColor.clearColor;
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.tableView];

    [NSLayoutConstraint activateConstraints:@[
        [self.searchBar.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [self.searchBar.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.searchBar.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.tableView.topAnchor constraintEqualToAnchor:self.searchBar.bottomAnchor],
        [self.tableView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.tableView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.tableView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
    ]];
}

- (void)reloadCandidates {
    self.candidates = [[FriendStore shared] candidatesMatchingQuery:self.searchBar.text ?: @""];
    [self.tableView reloadData];
}

#pragma mark - Search

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [self reloadCandidates];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

#pragma mark - Table

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.candidates.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kAddCellId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kAddCellId];
    }
    NSDictionary *item = self.candidates[indexPath.row];
    NSString *friendId = item[@"id"];
    BOOL already = [[FriendStore shared] isFriend:friendId];
    cell.textLabel.text = item[@"name"];
    cell.textLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
    cell.textLabel.textColor = [MYTheme textPrimaryColor];
    cell.detailTextLabel.text = already
        ? @"已是好友"
        : [NSString stringWithFormat:@"累计 %ld 分钟", (long)[item[@"totalMinutes"] integerValue]];
    cell.detailTextLabel.textColor = already ? [MYTheme textTertiaryColor] : [MYTheme textSecondaryColor];
    cell.imageView.image = [UIImage systemImageNamed:@"person.crop.circle.badge.plus"];
    cell.imageView.tintColor = already ? [MYTheme textTertiaryColor] : [MYTheme primaryColor];
    cell.accessoryType = already ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    cell.selectionStyle = already ? UITableViewCellSelectionStyleNone : UITableViewCellSelectionStyleDefault;
    cell.backgroundColor = [MYTheme cardColor];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *item = self.candidates[indexPath.row];
    NSString *friendId = item[@"id"];
    FriendStore *store = [FriendStore shared];
    if ([store isFriend:friendId]) {
        [self showAlertWithTitle:@"提示" message:[NSString stringWithFormat:@"%@ 已在好友列表中", item[@"name"]]];
        return;
    }
    BOOL ok = [store addFriendWithId:friendId];
    if (ok) {
        [self showAlertWithTitle:@"已添加" message:[NSString stringWithFormat:@"已添加好友 %@", item[@"name"]]];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    } else {
        [self showAlertWithTitle:@"添加失败" message:@"无法添加该用户"];
    }
}

- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
