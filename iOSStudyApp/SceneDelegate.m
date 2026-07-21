//
//  SceneDelegate.m
//  iOSStudyApp
//

#import "SceneDelegate.h"
#import "MYTabBarController.h"
#import "MYTheme.h"

@implementation SceneDelegate

- (void)scene:(UIScene *)scene willConnectToSession:(UISceneSession *)session options:(UISceneConnectionOptions *)connectionOptions {
    if (![scene isKindOfClass:[UIWindowScene class]]) {
        return;
    }
    
    UIWindowScene *windowScene = (UIWindowScene *)scene;
    self.window = [[UIWindow alloc] initWithWindowScene:windowScene];
    self.window.frame = windowScene.coordinateSpace.bounds;
    self.window.backgroundColor = [MYTheme backgroundColor];
    self.window.tintColor = [MYTheme primaryColor];
    self.window.rootViewController = [[MYTabBarController alloc] init];
    [self.window makeKeyAndVisible];
}

@end
