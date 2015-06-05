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

@implementation YTSettingsManager

objection_register_singleton(YTSettingsManager)

- (BOOL)isNativeVideoPlayerEnabled {
    return [[NSUserDefaults standardUserDefaults] boolForKey:kYTSettingsNativeVideoPlayerEnabledKey];
}

- (UIColor *)colorTheme {
    UIColor *color = [UIColor blueColor];
    NSString *key = [[NSUserDefaults standardUserDefaults] stringForKey:kYTSettingsColorThemeKey];
    NSDictionary *colors = @{@"Blue":[self blueColor], @"Cyan":[self cyanColor], @"Red":[self redColor], @"Orange":[self orangeColor]};
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
@end
