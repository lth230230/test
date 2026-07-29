//
//  FriendDetailViewController.m
//  iOSStudyApp
//

#import "FriendDetailViewController.h"
#import "FriendStore.h"
#import "MYTheme.h"

static NSString * const kRecordCellId = @"FriendRecordCell";

@interface FriendDetailViewController () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, copy) NSString *friendId;
@property (nonatomic, copy) NSDictionary *friend;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, copy) NSArray<NSDictionary *> *records;
@end

@implementation FriendDetailViewController

- (instancetype)initWithFriendId:(NSString *)friendId {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _friendId = [friendId copy];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [MYTheme backgroundColor];
    self.friend = [[FriendStore shared] friendWithId:self.friendId];
    self.title = self.friend[@"name"] ?: @"好友详情";
    self.records = self.friend[@"records"] ?: @[];
    [self setupTable];
}

- (void)setupTable {
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleInsetGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = UIColor.clearColor;
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.tableView];
    [NSLayoutConstraint activateConstraints:@[
        [self.tableView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [self.tableView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.tableView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.tableView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
    ]];
    self.tableView.tableHeaderView = [self buildHeader];
}

- (UIView *)buildHeader {
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 148)];
    UIView *card = [[UIView alloc] init];
    card.backgroundColor = [MYTheme cardColor];
    card.layer.cornerRadius = 14;
    card.translatesAutoresizingMaskIntoConstraints = NO;
    [header addSubview:card];
    [MYTheme applySoftShadowToView:card];

    UILabel *totalTitle = [self captionLabel:@"累计学习时长"];
    UILabel *totalValue = [self valueLabel:[NSString stringWithFormat:@"%ld 分钟",
                                            (long)[self.friend[@"totalMinutes"] integerValue]]];
    UILabel *todayTitle = [self captionLabel:@"今日学习时长"];
    UILabel *todayValue = [self valueLabel:[NSString stringWithFormat:@"%ld 分钟",
                                            (long)[self.friend[@"todayMinutes"] integerValue]]];

    UIStackView *left = [[UIStackView alloc] initWithArrangedSubviews:@[totalTitle, totalValue]];
    left.axis = UILayoutConstraintAxisVertical;
    left.spacing = 6;
    UIStackView *right = [[UIStackView alloc] initWithArrangedSubviews:@[todayTitle, todayValue]];
    right.axis = UILayoutConstraintAxisVertical;
    right.spacing = 6;
    UIStackView *row = [[UIStackView alloc] initWithArrangedSubviews:@[left, right]];
    row.axis = UILayoutConstraintAxisHorizontal;
    row.distribution = UIStackViewDistributionFillEqually;
    row.translatesAutoresizingMaskIntoConstraints = NO;
    [card addSubview:row];

    [NSLayoutConstraint activateConstraints:@[
        [card.topAnchor constraintEqualToAnchor:header.topAnchor constant:12],
        [card.leadingAnchor constraintEqualToAnchor:header.leadingAnchor constant:20],
        [card.trailingAnchor constraintEqualToAnchor:header.trailingAnchor constant:-20],
        [card.bottomAnchor constraintEqualToAnchor:header.bottomAnchor constant:-8],
        [row.topAnchor constraintEqualToAnchor:card.topAnchor constant:20],
        [row.leadingAnchor constraintEqualToAnchor:card.leadingAnchor constant:20],
        [row.trailingAnchor constraintEqualToAnchor:card.trailingAnchor constant:-20],
        [row.bottomAnchor constraintEqualToAnchor:card.bottomAnchor constant:-20],
    ]];
    return header;
}

- (UILabel *)captionLabel:(NSString *)text {
    UILabel *label = [[UILabel alloc] init];
    label.text = text;
    label.font = [UIFont systemFontOfSize:13];
    label.textColor = [MYTheme textSecondaryColor];
    return label;
}

- (UILabel *)valueLabel:(NSString *)text {
    UILabel *label = [[UILabel alloc] init];
    label.text = text;
    label.font = [UIFont systemFontOfSize:22 weight:UIFontWeightBold];
    label.textColor = [MYTheme textPrimaryColor];
    return label;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    UIView *header = self.tableView.tableHeaderView;
    if (!header) return;
    CGFloat width = self.tableView.bounds.size.width;
    if (fabs(header.frame.size.width - width) > 0.5) {
        CGRect frame = header.frame;
        frame.size.width = width;
        header.frame = frame;
        self.tableView.tableHeaderView = header;
    }
}

#pragma mark - Table

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"最近学习记录";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.records.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kRecordCellId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kRecordCellId];
    }
    NSDictionary *record = self.records[indexPath.row];
    cell.textLabel.text = record[@"lessonTitle"];
    cell.textLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
    cell.textLabel.textColor = [MYTheme textPrimaryColor];
    cell.textLabel.numberOfLines = 2;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ · %ld 分钟",
                                 record[@"studiedAt"] ?: @"",
                                 (long)[record[@"minutes"] integerValue]];
    cell.detailTextLabel.textColor = [MYTheme textSecondaryColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.imageView.image = [UIImage systemImageNamed:@"book.closed.fill"];
    cell.imageView.tintColor = [MYTheme accentColor];
    cell.backgroundColor = [MYTheme cardColor];
    return cell;
}

@end
