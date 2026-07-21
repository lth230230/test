//
//  MYTabBarController.m
//  iOSStudyApp
//

#import "MYTabBarController.h"
#import "HomeViewController.h"
#import "LearnViewController.h"
#import "ResourcesViewController.h"
#import "SettingsViewController.h"
#import "MYNavigationController.h"
#import "MYTheme.h"

@implementation MYTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [MYTheme backgroundColor];
    
    UITabBarAppearance *appearance = [[UITabBarAppearance alloc] init];
    [appearance configureWithOpaqueBackground];
    appearance.backgroundColor = [UIColor whiteColor];
    appearance.shadowColor = [[UIColor blackColor] colorWithAlphaComponent:0.06];
    self.tabBar.standardAppearance = appearance;
    self.tabBar.scrollEdgeAppearance = appearance;
    self.tabBar.tintColor = [MYTheme primaryColor];
    self.tabBar.unselectedItemTintColor = [MYTheme textTertiaryColor];
    
    [self setupChildControllers];
}

- (void)setupChildControllers {
    HomeViewController *homeVC = [[HomeViewController alloc] init];
    [self addChildVC:homeVC title:@"首页" image:@"house" tag:0];
    
    LearnViewController *learnVC = [[LearnViewController alloc] init];
    [self addChildVC:learnVC title:@"学习" image:@"book" tag:1];
    
    ResourcesViewController *resourcesVC = [[ResourcesViewController alloc] init];
    [self addChildVC:resourcesVC title:@"资源" image:@"tray.full" tag:2];
    
    SettingsViewController *settingsVC = [[SettingsViewController alloc] init];
    [self addChildVC:settingsVC title:@"设置" image:@"gearshape" tag:3];
}

- (void)addChildVC:(UIViewController *)vc title:(NSString *)title image:(NSString *)imageName tag:(NSInteger)tag {
    vc.tabBarItem = [[UITabBarItem alloc] initWithTitle:title
                                                  image:[UIImage systemImageNamed:imageName]
                                          selectedImage:[UIImage systemImageNamed:[imageName stringByAppendingString:@".fill"]]];
    vc.tabBarItem.tag = tag;
    MYNavigationController *nav = [[MYNavigationController alloc] initWithRootViewController:vc];
    [self addChildViewController:nav];
}

@end
