//
//  YTSettingsManager.m
//  OhMyTube
//
//  Created by Denis Zamataev on 27/05/15.
//  Copyright (c) 2015 Mysterious Organization. All rights reserved.
//

#import "YTSettingsManager.h"

NSString *kYTSettingsNativeVideoPlayerEnabledKey = @"native_video_player_enabled";

@implementation YTSettingsManager

objection_register_singleton(YTSettingsManager)

- (BOOL)isNativeVideoPlayerEnabled {
    return [[NSUserDefaults standardUserDefaults] boolForKey:kYTSettingsNativeVideoPlayerEnabledKey];
}
@end
