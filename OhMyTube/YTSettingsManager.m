//
//  YTSettingsManager.m
//  OhMyTube
//
//  Created by Denis Zamataev on 27/05/15.
//  Copyright (c) 2015 Mysterious Organization. All rights reserved.
//

#import "YTSettingsManager.h"

NSString *kYTSettingsNativeVideoPlayerEnabledKey = @"native_video_player_enabled";
NSString *kYTSettingsColorThemeKey = @"color_theme";
NSString *kYTSettingsLastViewedSceneKey = @"last_viewed_scene";
NSString *kYTSettingsLastVisitedURLKey = @"last_visited_URL";

@implementation YTSettingsManager

objection_register_singleton(YTSettingsManager)

- (BOOL)isNativeVideoPlayerEnabled {
    return [[NSUserDefaults standardUserDefaults] boolForKey:kYTSettingsNativeVideoPlayerEnabledKey];
}

- (UIColor *)colorTheme {
    UIColor *color = [UIColor blueColor];
    NSString *key = [[NSUserDefaults standardUserDefaults] stringForKey:kYTSettingsColorThemeKey];
    NSDictionary *colors = @{@"Blue":[self blueColor], @"Cyan":[self cyanColor], @"Red":[self redColor], @"Orange":[self orangeColor], @"Purple":[self purpleColor]};
    UIColor *preferredColor = colors[key];
    if (preferredColor) {
        color = preferredColor;
    }
    return color;
}

- (UIColor *)blueColor {
    return [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0]; // iOS 7 default tint color
}

- (UIColor *)cyanColor {
    return [UIColor colorWithRed:71.0/255.0 green:220.0/255.0 blue:201.0/255.0 alpha:1.0];
}

- (UIColor *)redColor {
    return [UIColor colorWithRed:245.0/255.0 green:81.0/255.0 blue:95.0/255.0 alpha:1.0];
}

- (UIColor *)orangeColor {
    return [UIColor colorWithRed:245.0/255.0 green:107.0/255.0 blue:28.0/255.0 alpha:1.0];
}

- (UIColor *)purpleColor {
    return [UIColor colorWithRed:127.0/255.0 green:0.0/255.0 blue:127.0/255.0 alpha:1.0];
}

- (void)setLastViewedScene:(YTSettingsManagerLastViewedScene)lastViewedScene {
    [[NSUserDefaults standardUserDefaults] setObject:@(lastViewedScene) forKey:kYTSettingsLastViewedSceneKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (YTSettingsManagerLastViewedScene)lastViewedScene {
    YTSettingsManagerLastViewedScene result = YTSettingsManagerLastViewedSceneDefault;
    NSNumber *userDefaultsValue = [[NSUserDefaults standardUserDefaults] objectForKey:kYTSettingsLastViewedSceneKey];
    if (userDefaultsValue != nil) {
        result = [userDefaultsValue integerValue];
    }
    return result;
}

- (void)setLastVisitedURL:(NSURL*)URL {
    NSString *URLString = [URL absoluteString];
    [[NSUserDefaults standardUserDefaults] setObject:URLString forKey:kYTSettingsLastVisitedURLKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSURL *)lastVisitedURL {
    NSString *URLString = [[NSUserDefaults standardUserDefaults] objectForKey:kYTSettingsLastVisitedURLKey];
    return [NSURL URLWithString:URLString];
}
@end
