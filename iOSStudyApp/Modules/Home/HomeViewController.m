//
//  HomeViewController.m
//  iOSStudyApp
//

#import "HomeViewController.h"
#import "HomeHeaderView.h"
#import "HomeCell.h"
#import "LearnDetailViewController.h"
#import "StudyDataStore.h"
#import "MYTheme.h"

@interface HomeViewController () <UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) HomeHeaderView *headerView;
@property (nonatomic, strong) NSArray<NSDictionary *> *lessons;
@property (nonatomic, strong) NSArray<NSDictionary *> *filteredLessons;
@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, assign) NSInteger filterMode; // 0 all, 1 todo, 2 done, 3 bookmark
@property (nonatomic, strong) UISegmentedControl *filterControl;
@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"iOS 学习助手";
    self.view.backgroundColor = [MYTheme backgroundColor];
    self.filterMode = 0;
    
    [self setupSearch];
    [self setupTableView];
    [self reloadData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData)
                                                 name:StudyDataDidChangeNotification object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.headerView refresh];
}

- (void)setupSearch {
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    self.searchController.obscuresBackgroundDuringPresentation = NO;
    self.searchController.searchBar.placeholder = @"搜索课程、知识点";
    self.navigationItem.searchController = self.searchController;
    self.navigationItem.hidesSearchBarWhenScrolling = YES;
    self.definesPresentationContext = YES;
}

- (void)setupTableView {
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = 92;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    [self.tableView registerClass:[HomeCell class] forCellReuseIdentifier:@"HomeCell"];
    [self.view addSubview:self.tableView];
    
    self.headerView = [[HomeHeaderView alloc] initWithFrame:CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, 210)];
    __weak typeof(self) weakSelf = self;
    self.headerView.onContinue = ^{
        [weakSelf continueLearning];
    };
    self.tableView.tableHeaderView = self.headerView;
    
    UIView *filterWrap = [[UIView alloc] initWithFrame:CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, 54)];
    self.filterControl = [[UISegmentedControl alloc] initWithItems:@[@"全部", @"待学", @"已完成", @"收藏"]];
    self.filterControl.selectedSegmentIndex = 0;
    self.filterControl.translatesAutoresizingMaskIntoConstraints = NO;
    [self.filterControl addTarget:self action:@selector(filterChanged) forControlEvents:UIControlEventValueChanged];
    [filterWrap addSubview:self.filterControl];
    [NSLayoutConstraint activateConstraints:@[
        [self.filterControl.leadingAnchor constraintEqualToAnchor:filterWrap.leadingAnchor constant:20],
        [self.filterControl.trailingAnchor constraintEqualToAnchor:filterWrap.trailingAnchor constant:-20],
        [self.filterControl.centerYAnchor constraintEqualToAnchor:filterWrap.centerYAnchor],
    ]];
    
    // Put filter below header by embedding in a container header
    UIView *container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, 264)];
    self.headerView.frame = CGRectMake(0, 0, container.bounds.size.width, 210);
    filterWrap.frame = CGRectMake(0, 210, container.bounds.size.width, 54);
    [container addSubview:self.headerView];
    [container addSubview:filterWrap];
    self.tableView.tableHeaderView = container;
    
    [NSLayoutConstraint activateConstraints:@[
        [self.tableView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [self.tableView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.tableView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.tableView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
    ]];
}

- (void)reloadData {
    self.lessons = [[StudyDataStore shared] dailyRecommend];
    [self applyFilterAndSearch];
    [self.headerView refresh];
}

- (void)filterChanged {
    self.filterMode = self.filterControl.selectedSegmentIndex;
    [self applyFilterAndSearch];
}

- (void)applyFilterAndSearch {
    StudyDataStore *store = [StudyDataStore shared];
    NSArray *source = (self.filterMode == 3) ? [store bookmarkedLessons] : self.lessons;
    
    NSMutableArray *filtered = [NSMutableArray array];
    for (NSDictionary *lesson in source) {
        NSString *lid = lesson[@"id"];
        BOOL done = [store isLessonCompleted:lid];
        if (self.filterMode == 1 && done) continue;
        if (self.filterMode == 2 && !done) continue;
        [filtered addObject:lesson];
    }
    
    NSString *keyword = self.searchController.searchBar.text ?: @"";
    keyword = [keyword stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
    if (keyword.length) {
        NSPredicate *pred = [NSPredicate predicateWithBlock:^BOOL(NSDictionary *lesson, NSDictionary *bindings) {
            NSString *title = lesson[@"title"] ?: @"";
            NSString *desc = lesson[@"desc"] ?: @"";
            NSString *tag = lesson[@"tag"] ?: @"";
            return [title localizedCaseInsensitiveContainsString:keyword]
                || [desc localizedCaseInsensitiveContainsString:keyword]
                || [tag localizedCaseInsensitiveContainsString:keyword];
        }];
        filtered = [[filtered filteredArrayUsingPredicate:pred] mutableCopy];
    }
    
    self.filteredLessons = filtered;
    [self.tableView reloadData];
}

- (void)continueLearning {
    NSDictionary *next = [[StudyDataStore shared] nextLessonToContinue];
    if (!next) return;
    [self openLesson:next];
}

- (void)openLesson:(NSDictionary *)lesson {
    LearnDetailViewController *detailVC = [[LearnDetailViewController alloc] init];
    detailVC.data = lesson;
    detailVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:detailVC animated:YES];
}

#pragma mark - Search

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    [self applyFilterAndSearch];
}

#pragma mark - Table

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.filteredLessons.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HomeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HomeCell" forIndexPath:indexPath];
    NSDictionary *lesson = self.filteredLessons[indexPath.row];
    BOOL done = [[StudyDataStore shared] isLessonCompleted:lesson[@"id"]];
    [cell configureWithData:lesson completed:done];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self openLesson:self.filteredLessons[indexPath.row]];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (self.filteredLessons.count == 0) {
        UILabel *empty = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 120)];
        empty.textAlignment = NSTextAlignmentCenter;
        empty.textColor = [MYTheme textTertiaryColor];
        empty.font = [UIFont systemFontOfSize:14];
        empty.text = @"暂无匹配课程，换个筛选试试";
        return empty;
    }
    UIView *wrap = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 36)];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(24, 8, 200, 24)];
    label.text = @"每日推荐";
    label.font = [UIFont systemFontOfSize:17 weight:UIFontWeightBold];
    label.textColor = [MYTheme textPrimaryColor];
    [wrap addSubview:label];
    return wrap;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return self.filteredLessons.count == 0 ? 120 : 36;
}

@end
