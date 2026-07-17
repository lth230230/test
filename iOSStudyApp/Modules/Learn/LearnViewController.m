//
//  LearnViewController.m
//  iOSStudyApp
//

#import "LearnViewController.h"
#import "LearnDetailViewController.h"

@interface LearnViewController () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSArray<NSDictionary *> *categories;
@property (nonatomic, strong) NSArray<NSDictionary *> *hotCourses;

@end

@implementation LearnViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"课程中心";
    self.view.backgroundColor = [UIColor colorWithWhite:0.97 alpha:1.0];
    [self loadData];
    [self setupCollectionView];
}

- (void)loadData {
    self.categories = @[
        @{@"icon": @"textformat.abc", @"title": @"语法基础", @"count": @"12课时", @"color": @"blue"},
        @{@"icon": @"rectangle.3.group", @"title": @"UIKit", @"count": @"18课时", @"color": @"red"},
        @{@"icon": @"network", @"title": @"网络编程", @"count": @"8课时", @"color": @"green"},
        @{@"icon": @"cylinder.split.1x2", @"title": @"数据持久化", @"count": @"6课时", @"color": @"orange"},
        @{@"icon": @"arrow.triangle.branch", @"title": @"多线程", @"count": @"10课时", @"color": @"purple"},
        @{@"icon": @"lock.shield", @"title": @"安全与签名", @"count": @"4课时", @"color": @"pink"},
    ];
    
    self.hotCourses = @[
        @{@"title": @"AutoLayout 从入门到精通", @"desc": @"纯代码布局全攻略", @"time": @"45分钟"},
        @{@"title": @"SwiftUI 快速上手", @"desc": @"现代声明式UI开发", @"time": @"60分钟"},
        @{@"title": @"性能优化实战指南", @"desc": @"启动速度、内存、包体积", @"time": @"40分钟"},
    ];
}

- (void)setupCollectionView {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    CGFloat spacing = 16;
    CGFloat itemWidth = (UIScreen.mainScreen.bounds.size.width - spacing * 3) / 2;
    layout.itemSize = CGSizeMake(itemWidth, 120);
    layout.minimumLineSpacing = spacing;
    layout.minimumInteritemSpacing = spacing;
    layout.sectionInset = UIEdgeInsetsMake(spacing, spacing, spacing, spacing);
    layout.headerReferenceSize = CGSizeMake(UIScreen.mainScreen.bounds.size.width, 40);
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"CategoryCell"];
    [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"Header"];
    [self.view addSubview:self.collectionView];
    
    [NSLayoutConstraint activateConstraints:@[
        [self.collectionView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [self.collectionView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.collectionView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.collectionView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
    ]];
}

- (NSArray *)colorForName:(NSString *)name {
    NSDictionary *colors = @{
        @"blue": @[[UIColor colorWithRed:0.18 green:0.60 blue:0.96 alpha:1.0], [UIColor colorWithRed:0.18 green:0.60 blue:0.96 alpha:0.08]],
        @"red": @[[UIColor colorWithRed:0.95 green:0.42 blue:0.38 alpha:1.0], [UIColor colorWithRed:0.95 green:0.42 blue:0.38 alpha:0.08]],
        @"green": @[[UIColor colorWithRed:0.55 green:0.83 blue:0.40 alpha:1.0], [UIColor colorWithRed:0.55 green:0.83 blue:0.40 alpha:0.08]],
        @"orange": @[[UIColor colorWithRed:0.95 green:0.65 blue:0.22 alpha:1.0], [UIColor colorWithRed:0.95 green:0.65 blue:0.22 alpha:0.08]],
        @"purple": @[[UIColor colorWithRed:0.65 green:0.50 blue:0.85 alpha:1.0], [UIColor colorWithRed:0.65 green:0.50 blue:0.85 alpha:0.08]],
        @"pink": @[[UIColor colorWithRed:0.95 green:0.50 blue:0.65 alpha:1.0], [UIColor colorWithRed:0.95 green:0.50 blue:0.65 alpha:0.08]],
    };
    return colors[name] ?: colors[@"blue"];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.categories.count;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView *header = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"Header" forIndexPath:indexPath];
    for (UIView *v in header.subviews) [v removeFromSuperview];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 8, 200, 30)];
    label.text = @"课程分类";
    label.font = [UIFont systemFontOfSize:18 weight:UIFontWeightBold];
    label.textColor = [UIColor blackColor];
    [header addSubview:label];
    
    return header;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CategoryCell" forIndexPath:indexPath];
    for (UIView *v in cell.contentView.subviews) [v removeFromSuperview];
    
    NSDictionary *item = self.categories[indexPath.row];
    NSArray *colors = [self colorForName:item[@"color"]];
    
    cell.contentView.backgroundColor = colors[1];
    cell.contentView.layer.cornerRadius = 12;
    
    UIImageView *iconView = [[UIImageView alloc] init];
    iconView.image = [UIImage systemImageNamed:item[@"icon"]];
    iconView.tintColor = colors[0];
    iconView.translatesAutoresizingMaskIntoConstraints = NO;
    [cell.contentView addSubview:iconView];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = item[@"title"];
    titleLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightSemibold];
    titleLabel.textColor = colors[0];
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [cell.contentView addSubview:titleLabel];
    
    UILabel *countLabel = [[UILabel alloc] init];
    countLabel.text = item[@"count"];
    countLabel.font = [UIFont systemFontOfSize:12];
    countLabel.textColor = [UIColor grayColor];
    countLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [cell.contentView addSubview:countLabel];
    
    [NSLayoutConstraint activateConstraints:@[
        [iconView.centerXAnchor constraintEqualToAnchor:cell.contentView.centerXAnchor],
        [iconView.topAnchor constraintEqualToAnchor:cell.contentView.topAnchor constant:22],
        [iconView.widthAnchor constraintEqualToConstant:28],
        [iconView.heightAnchor constraintEqualToConstant:28],
        
        [titleLabel.centerXAnchor constraintEqualToAnchor:cell.contentView.centerXAnchor],
        [titleLabel.topAnchor constraintEqualToAnchor:iconView.bottomAnchor constant:10],
        
        [countLabel.centerXAnchor constraintEqualToAnchor:cell.contentView.centerXAnchor],
        [countLabel.topAnchor constraintEqualToAnchor:titleLabel.bottomAnchor constant:4],
    ]];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    NSDictionary *item = self.categories[indexPath.row];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:item[@"title"]
                                                                   message:[NSString stringWithFormat:@"「%@」课程共 %@，即将开放学习", item[@"title"], item[@"count"]]
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
