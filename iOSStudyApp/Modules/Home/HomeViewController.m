//
//  HomeViewController.m
//  iOSStudyApp
//

#import "HomeViewController.h"
#import "HomeHeaderView.h"
#import "HomeCell.h"
#import "LearnDetailViewController.h"

@interface HomeViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) HomeHeaderView *headerView;
@property (nonatomic, strong) NSArray<NSDictionary *> *dailyRecommend;

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"iOS学习助手";
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self loadData];
    [self setupTableView];
}

- (void)loadData {
    self.dailyRecommend = @[
        @{@"title": @"Objective-C 基础语法", @"desc": @"数据类型、方法调用、属性声明", @"time": @"15分钟", @"tag": @"入门"},
        @{@"title": @"AutoLayout 约束实战", @"desc": @"纯代码布局与Masonry使用技巧", @"time": @"20分钟", @"tag": @"进阶"},
        @{@"title": @"UITableView 复用机制", @"desc": @"Cell重用池、高度缓存、滑动优化", @"time": @"25分钟", @"tag": @"核心"},
        @{@"title": @"网络请求与数据解析", @"desc": @"NSURLSession + JSON模型转换", @"time": @"30分钟", @"tag": @"进阶"},
        @{@"title": @"CoreData 数据持久化", @"desc": @"增删改查、多线程、迁移", @"time": @"35分钟", @"tag": @"高阶"},
        @{@"title": @"多线程与 GCD", @"desc": @"队列、信号量、死锁避免", @"time": @"25分钟", @"tag": @"核心"},
        @{@"title": @"内存管理与 ARC", @"desc": @"循环引用、weak/strong、自动释放池", @"time": @"20分钟", @"tag": @"核心"},
        @{@"title": @"App 上架全流程", @"desc": @"证书、打包、TestFlight、审核", @"time": @"15分钟", @"tag": @"实战"},
    ];
}

- (void)setupTableView {
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = 80;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor colorWithWhite:0.97 alpha:1.0];
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.tableView registerClass:[HomeCell class] forCellReuseIdentifier:@"HomeCell"];
    [self.view addSubview:self.tableView];
    
    self.headerView = [[HomeHeaderView alloc] initWithFrame:CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, 180)];
    self.tableView.tableHeaderView = self.headerView;
    
    [NSLayoutConstraint activateConstraints:@[
        [self.tableView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [self.tableView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.tableView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.tableView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
    ]];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dailyRecommend.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HomeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HomeCell" forIndexPath:indexPath];
    [cell configureWithData:self.dailyRecommend[indexPath.row]];
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    LearnDetailViewController *detailVC = [[LearnDetailViewController alloc] init];
    detailVC.data = self.dailyRecommend[indexPath.row];
    detailVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:detailVC animated:YES];
}

@end
