//
//  AppDelegate.m
//  OhMyTube
//
//  Created by Denis Zamataev on 26/05/15.
//  Copyright (c) 2015 Mysterious Organization. All rights reserved.
//

#import "AppDelegate.h"
#import <Objection.h>
#import "YTAppModule.h"
#import "YTNotifications.h"
#import "YTSettingsManager.h"
#import "YTLaunchAnimationHelper.h"

@interface AppDelegate ()
@property (strong, nonatomic) YTSettingsManager *settingsManager;
@end

@implementation AppDelegate

objection_requires_sel(@selector(settingsManager))

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    JSObjectionInjector *injector = [JSObjection createInjector:[[YTAppModule alloc] init]];
    [JSObjection setDefaultInjector:injector];
    [[JSObjection defaultInjector] injectDependencies:self];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self.window makeKeyAndVisible];
    
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:[[NSBundle mainBundle].infoDictionary objectForKey:@"UIMainStoryboardFile"] bundle:[NSBundle mainBundle]];
    UIViewController *initialViewController = [mainStoryboard instantiateInitialViewController];
    self.window.rootViewController = initialViewController;
    
    [YTLaunchAnimationHelper setupAndStartAnimationInWindow:self.window withInitialViewController:initialViewController completion:^{
    }];
    
    [self performSelector:@selector(darkenStatusBar) withObject:nil afterDelay:1.6];
    
    return YES;
}

- (void)darkenStatusBar {
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    if ([url.absoluteString hasPrefix:@"ohmytube://x-callback-url/open/"]) {
        // handle open with url to show in browser
        NSDictionary *parameters = [self dictionaryByParsingParametersFromURL:url];
        NSString *urlString = parameters[@"url"];
        if (urlString && urlString.length > 0) {
            NSURL *URL = [NSURL URLWithString:urlString];
            if (URL) {
                [[NSNotificationCenter defaultCenter] postNotificationName:YTNotificaionsOpenInBrowser object:nil userInfo:@{@"URL":URL}];
            }
        }
    }
    return YES;
}

- (NSDictionary*)dictionaryByParsingParametersFromURL:(NSURL*)URL {
    NSMutableDictionary *queryStrings = [[NSMutableDictionary alloc] init];
    for (NSString *qs in [URL.query componentsSeparatedByString:@"&"]) {
        // Get the parameter name
        NSString *key = [[qs componentsSeparatedByString:@"="] objectAtIndex:0];
        // Get the parameter value
        NSString *value = [[qs componentsSeparatedByString:@"="] objectAtIndex:1];
        value = [value stringByReplacingOccurrencesOfString:@"+" withString:@" "];
        value = [value stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        queryStrings[key] = value;
    }
    return queryStrings;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [self.window setTintColor:[self.settingsManager colorTheme]];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
