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
    // Must set delegateClass; otherwise SceneDelegate never runs and the app stays on a black screen.
    UISceneConfiguration *configuration = [[UISceneConfiguration alloc] initWithName:@"Default Configuration"
                                                                          sessionRole:connectingSceneSession.role];
    configuration.delegateClass = SceneDelegate.class;
    return configuration;
}

@end
