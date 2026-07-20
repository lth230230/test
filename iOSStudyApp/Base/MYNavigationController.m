//
//  MYNavigationController.m
//  iOSStudyApp
//

#import "MYNavigationController.h"
#import "MYTheme.h"

@implementation MYNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [MYTheme backgroundColor];
    
    UINavigationBarAppearance *appearance = [[UINavigationBarAppearance alloc] init];
    [appearance configureWithOpaqueBackground];
    appearance.backgroundColor = [MYTheme primaryColor];
    appearance.titleTextAttributes = @{
        NSForegroundColorAttributeName: [UIColor whiteColor],
        NSFontAttributeName: [UIFont systemFontOfSize:17 weight:UIFontWeightSemibold]
    };
    appearance.largeTitleTextAttributes = @{
        NSForegroundColorAttributeName: [UIColor whiteColor]
    };
    appearance.shadowColor = [UIColor clearColor];
    
    self.navigationBar.standardAppearance = appearance;
    self.navigationBar.scrollEdgeAppearance = appearance;
    self.navigationBar.compactAppearance = appearance;
    self.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationBar.prefersLargeTitles = NO;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end
