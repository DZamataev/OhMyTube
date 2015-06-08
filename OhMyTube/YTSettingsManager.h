//
//  YTSettingsManager.h
//  OhMyTube
//
//  Created by Denis Zamataev on 27/05/15.
//  Copyright (c) 2015 Mysterious Organization. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Objection.h>

typedef NS_ENUM(NSInteger, YTSettingsManagerLastViewedScene) {
    YTSettingsManagerLastViewedSceneDefault = 1,
    YTSettingsManagerLastViewedSceneBrowser = 1,
    YTSettingsManagerLastViewedSceneDownloads = 2
};

@interface YTSettingsManager : NSObject
- (BOOL)isNativeVideoPlayerEnabled;
- (UIColor *)colorTheme;

- (void)setLastViewedScene:(YTSettingsManagerLastViewedScene)lastViewedScene;
- (YTSettingsManagerLastViewedScene)lastViewedScene;
@end
