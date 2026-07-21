//
//  SceneDelegate.m
//  iOSStudyApp
//

#import "SceneDelegate.h"
#import "MYTabBarController.h"
#import "MYTheme.h"

@implementation SceneDelegate

- (void)scene:(UIScene *)scene willConnectToSession:(UISceneSession *)session options:(UISceneConnectionOptions *)connectionOptions {
    // Ignore external-display / non-application scenes.
    if (session.role != UIWindowSceneSessionRoleApplication) {
        return;
    }
    if (![scene isKindOfClass:[UIWindowScene class]]) {
        return;
    }
    
    UIWindowScene *windowScene = (UIWindowScene *)scene;
    UIWindow *window = [[UIWindow alloc] initWithWindowScene:windowScene];
    window.frame = windowScene.coordinateSpace.bounds;
    window.backgroundColor = [MYTheme backgroundColor];
    window.tintColor = [MYTheme primaryColor];
    window.rootViewController = [[MYTabBarController alloc] init];
    self.window = window;
    [window makeKeyAndVisible];
}

@end
