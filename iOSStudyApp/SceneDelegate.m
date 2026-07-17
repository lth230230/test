//
//  SceneDelegate.m
//  iOSStudyApp
//

#import "SceneDelegate.h"
#import "MYTabBarController.h"

@implementation SceneDelegate
- (void)scene:(UIScene *)scene willConnectToSession:(UISceneSession *)session options:(UISceneConnectionOptions *)connectionOptions {
    UIWindowScene *windowScene = (UIWindowScene *)scene;
    self.window = [[UIWindow alloc] initWithWindowScene:windowScene];
    self.window.frame = windowScene.coordinateSpace.bounds;
    self.window.backgroundColor = [UIColor colorWithRed:0.15 green:0.50 blue:0.85 alpha:1.0];
    
    MYTabBarController *tabBarVC = [[MYTabBarController alloc] init];
    self.window.rootViewController = tabBarVC;
    [self.window makeKeyAndVisible];
}
@end
