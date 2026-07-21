//
//  AppDelegate.m
//  iOSStudyApp
//

#import "AppDelegate.h"
#import "SceneDelegate.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    return YES;
}

- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    // Only wire our SceneDelegate to the main app scene.
    // External-display sessions must not get the same root UI, or the phone
    // can stay black while content appears under an "External Display" chrome.
    if (connectingSceneSession.role == UIWindowSceneSessionRoleApplication) {
        UISceneConfiguration *configuration = [[UISceneConfiguration alloc] initWithName:@"Default Configuration"
                                                                              sessionRole:connectingSceneSession.role];
        configuration.delegateClass = SceneDelegate.class;
        return configuration;
    }
    
    return [[UISceneConfiguration alloc] initWithName:nil sessionRole:connectingSceneSession.role];
}

@end
