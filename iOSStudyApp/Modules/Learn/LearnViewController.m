//
//  LearnViewController.m
//  iOSStudyApp
//

#import "LearnViewController.h"
#import "CourseListViewController.h"
#import "LearnDetailViewController.h"
#import "StudyDataStore.h"
#import "MYTheme.h"

@interface LearnViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSArray<NSDictionary *> *categories;
@property (nonatomic, strong) NSArray<NSDictionary *> *hotCourses;
@end

@implementation LearnViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"课程中心";
    self.view.backgroundColor = [MYTheme backgroundColor];
    self.categories = [[StudyDataStore shared] categories];
    self.hotCourses = [[StudyDataStore shared] hotCourses];
    [self setupCollectionView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reload)
                                                 name:StudyDataDidChangeNotification object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)reload {
    self.hotCourses = [[StudyDataStore shared] hotCourses];
    [self.collectionView reloadData];
}

- (void)setupCollectionView {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumLineSpacing = 14;
    layout.minimumInteritemSpacing = 14;
    layout.sectionInset = UIEdgeInsetsMake(8, 20, 20, 20);
    layout.headerReferenceSize = CGSizeMake(UIScreen.mainScreen.bounds.size.width, 44);
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"CategoryCell"];
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"HotCell"];
    [self.collectionView registerClass:[UICollectionReusableView class]
            forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                   withReuseIdentifier:@"Header"];
    [self.view addSubview:self.collectionView];
    
    [NSLayoutConstraint activateConstraints:@[
        [self.collectionView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [self.collectionView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.collectionView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.collectionView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
    ]];
}

#pragma mark - DataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 2;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return section == 0 ? self.categories.count : self.hotCourses.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat width = collectionView.bounds.size.width - 40;
    if (indexPath.section == 0) {
        CGFloat itemWidth = (width - 14) / 2.0;
        return CGSizeMake(itemWidth, 118);
    }
    return CGSizeMake(width, 86);
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView *header = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"Header" forIndexPath:indexPath];
    for (UIView *v in header.subviews) [v removeFromSuperview];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(24, 10, 220, 28)];
    label.text = indexPath.section == 0 ? @"课程分类" : @"热门推荐";
    label.font = [UIFont systemFontOfSize:18 weight:UIFontWeightBold];
    label.textColor = [MYTheme textPrimaryColor];
    [header addSubview:label];
    return header;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return [self categoryCellAt:indexPath];
    }
    return [self hotCellAt:indexPath];
}

- (UICollectionViewCell *)categoryCellAt:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"CategoryCell" forIndexPath:indexPath];
    for (UIView *v in cell.contentView.subviews) [v removeFromSuperview];
    
    NSDictionary *item = self.categories[indexPath.item];
    UIColor *color = [MYTheme categoryColorForName:item[@"color"]];
    NSArray *lessons = [[StudyDataStore shared] lessonsForCategory:item[@"id"]];
    NSInteger done = 0;
    for (NSDictionary *lesson in lessons) {
        if ([[StudyDataStore shared] isLessonCompleted:lesson[@"id"]]) done += 1;
    }
    
    cell.contentView.backgroundColor = [color colorWithAlphaComponent:0.10];
    cell.contentView.layer.cornerRadius = 16;
    
    UIImageView *iconView = [[UIImageView alloc] init];
    iconView.image = [UIImage systemImageNamed:item[@"icon"]];
    iconView.tintColor = color;
    iconView.translatesAutoresizingMaskIntoConstraints = NO;
    [cell.contentView addSubview:iconView];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = item[@"title"];
    titleLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightSemibold];
    titleLabel.textColor = color;
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [cell.contentView addSubview:titleLabel];
    
    UILabel *countLabel = [[UILabel alloc] init];
    countLabel.text = [NSString stringWithFormat:@"%ld 课时 · 完成 %ld", (long)lessons.count, (long)done];
    countLabel.font = [UIFont systemFontOfSize:12];
    countLabel.textColor = [MYTheme textSecondaryColor];
    countLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [cell.contentView addSubview:countLabel];
    
    [NSLayoutConstraint activateConstraints:@[
        [iconView.centerXAnchor constraintEqualToAnchor:cell.contentView.centerXAnchor],
        [iconView.topAnchor constraintEqualToAnchor:cell.contentView.topAnchor constant:20],
        [iconView.widthAnchor constraintEqualToConstant:28],
        [iconView.heightAnchor constraintEqualToConstant:28],
        [titleLabel.centerXAnchor constraintEqualToAnchor:cell.contentView.centerXAnchor],
        [titleLabel.topAnchor constraintEqualToAnchor:iconView.bottomAnchor constant:10],
        [countLabel.centerXAnchor constraintEqualToAnchor:cell.contentView.centerXAnchor],
        [countLabel.topAnchor constraintEqualToAnchor:titleLabel.bottomAnchor constant:4],
    ]];
    return cell;
}

- (UICollectionViewCell *)hotCellAt:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"HotCell" forIndexPath:indexPath];
    for (UIView *v in cell.contentView.subviews) [v removeFromSuperview];
    
    NSDictionary *item = self.hotCourses[indexPath.item];
    [MYTheme applyCardStyleToView:cell.contentView];
    cell.contentView.layer.cornerRadius = 14;
    
    UILabel *title = [[UILabel alloc] init];
    title.text = item[@"title"];
    title.font = [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold];
    title.textColor = [MYTheme textPrimaryColor];
    title.translatesAutoresizingMaskIntoConstraints = NO;
    [cell.contentView addSubview:title];
    
    UILabel *desc = [[UILabel alloc] init];
    desc.text = [NSString stringWithFormat:@"%@ · %@", item[@"desc"], item[@"time"]];
    desc.font = [UIFont systemFontOfSize:13];
    desc.textColor = [MYTheme textSecondaryColor];
    desc.translatesAutoresizingMaskIntoConstraints = NO;
    [cell.contentView addSubview:desc];
    
    UIImageView *chevron = [[UIImageView alloc] initWithImage:[UIImage systemImageNamed:@"chevron.right"]];
    chevron.tintColor = [MYTheme textTertiaryColor];
    chevron.translatesAutoresizingMaskIntoConstraints = NO;
    [cell.contentView addSubview:chevron];
    
    BOOL done = [[StudyDataStore shared] isLessonCompleted:item[@"id"]];
    UILabel *badge = [[UILabel alloc] init];
    badge.text = done ? @"已完成" : item[@"tag"];
    badge.font = [UIFont systemFontOfSize:11 weight:UIFontWeightBold];
    badge.textColor = done ? [MYTheme successColor] : [MYTheme tagColorForName:item[@"tag"]];
    badge.translatesAutoresizingMaskIntoConstraints = NO;
    [cell.contentView addSubview:badge];
    
    [NSLayoutConstraint activateConstraints:@[
        [title.leadingAnchor constraintEqualToAnchor:cell.contentView.leadingAnchor constant:16],
        [title.topAnchor constraintEqualToAnchor:cell.contentView.topAnchor constant:18],
        [title.trailingAnchor constraintLessThanOrEqualToAnchor:chevron.leadingAnchor constant:-8],
        [desc.leadingAnchor constraintEqualToAnchor:title.leadingAnchor],
        [desc.topAnchor constraintEqualToAnchor:title.bottomAnchor constant:6],
        [desc.trailingAnchor constraintLessThanOrEqualToAnchor:chevron.leadingAnchor constant:-8],
        [badge.trailingAnchor constraintEqualToAnchor:chevron.leadingAnchor constant:-10],
        [badge.centerYAnchor constraintEqualToAnchor:cell.contentView.centerYAnchor],
        [chevron.trailingAnchor constraintEqualToAnchor:cell.contentView.trailingAnchor constant:-14],
        [chevron.centerYAnchor constraintEqualToAnchor:cell.contentView.centerYAnchor],
        [chevron.widthAnchor constraintEqualToConstant:12],
        [chevron.heightAnchor constraintEqualToConstant:16],
    ]];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        CourseListViewController *list = [[CourseListViewController alloc] init];
        list.category = self.categories[indexPath.item];
        list.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:list animated:YES];
    } else {
        LearnDetailViewController *detail = [[LearnDetailViewController alloc] init];
        detail.data = self.hotCourses[indexPath.item];
        detail.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:detail animated:YES];
    }
}

@end
