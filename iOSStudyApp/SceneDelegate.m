//
//  SceneDelegate.m
//  iOSStudyApp
//

#import "SceneDelegate.h"
#import "MYTabBarController.h"
#import "MYTheme.h"

@implementation SceneDelegate
- (void)scene:(UIScene *)scene willConnectToSession:(UISceneSession *)session options:(UISceneConnectionOptions *)connectionOptions {
    UIWindowScene *windowScene = (UIWindowScene *)scene;
    self.window = [[UIWindow alloc] initWithWindowScene:windowScene];
    self.window.frame = windowScene.coordinateSpace.bounds;
    self.window.backgroundColor = [MYTheme primaryColor];
    self.window.tintColor = [MYTheme primaryColor];
    
    MYTabBarController *tabBarVC = [[MYTabBarController alloc] init];
    self.window.rootViewController = tabBarVC;
    [self.window makeKeyAndVisible];
}
@end
