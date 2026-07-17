//
//  MYNavigationController.m
//  iOSStudyApp
//

#import "MYNavigationController.h"

@implementation MYNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:0.15 green:0.50 blue:0.85 alpha:1.0];
    
    UINavigationBarAppearance *appearance = [[UINavigationBarAppearance alloc] init];
    [appearance configureWithOpaqueBackground];
    appearance.backgroundColor = [UIColor colorWithRed:0.15 green:0.50 blue:0.85 alpha:1.0];
    appearance.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
    appearance.shadowColor = [UIColor clearColor];
    
    self.navigationBar.standardAppearance = appearance;
    self.navigationBar.scrollEdgeAppearance = appearance;
    self.navigationBar.tintColor = [UIColor whiteColor];
}

@end
