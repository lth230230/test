//
//  CourseListViewController.m
//  iOSStudyApp
//

#import "CourseListViewController.h"
#import "StudyDataStore.h"
#import "MYTheme.h"
#import "HomeCell.h"
#import "LearnDetailViewController.h"

@interface CourseListViewController () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray<NSDictionary *> *lessons;
@end

@implementation CourseListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = self.category[@"title"] ?: @"课程列表";
    self.view.backgroundColor = [MYTheme backgroundColor];
    self.lessons = [[StudyDataStore shared] lessonsForCategory:self.category[@"id"]];
    [self setupTable];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reload)
                                                 name:StudyDataDidChangeNotification object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setupTable {
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = 92;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.tableView registerClass:[HomeCell class] forCellReuseIdentifier:@"HomeCell"];
    [self.view addSubview:self.tableView];
    
    UILabel *footer = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 40)];
    footer.textAlignment = NSTextAlignmentCenter;
    footer.font = [UIFont systemFontOfSize:12];
    footer.textColor = [MYTheme textTertiaryColor];
    footer.text = [NSString stringWithFormat:@"共 %ld 课时", (long)self.lessons.count];
    self.tableView.tableFooterView = footer;
    
    [NSLayoutConstraint activateConstraints:@[
        [self.tableView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [self.tableView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.tableView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.tableView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
    ]];
}

- (void)reload {
    [self.tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.lessons.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HomeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HomeCell" forIndexPath:indexPath];
    NSDictionary *lesson = self.lessons[indexPath.row];
    BOOL done = [[StudyDataStore shared] isLessonCompleted:lesson[@"id"]];
    [cell configureWithData:lesson completed:done];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    LearnDetailViewController *detail = [[LearnDetailViewController alloc] init];
    detail.data = self.lessons[indexPath.row];
    detail.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:detail animated:YES];
}

@end
