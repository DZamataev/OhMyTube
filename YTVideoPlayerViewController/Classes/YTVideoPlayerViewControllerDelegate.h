//
//  YTVideoPlayerViewControllerDelegate.h
//  OhMyTube
//
//  Created by Denis Zamataev on 29/05/15.
//  Copyright (c) 2015 Mysterious Organization. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol YTVideoPlayerViewControllerDelegate <NSObject>
- (void)playerDidResume;
- (void)playerDidPause;
- (void)playerDidStop;
- (void)playerDidPlayToEndTime;
- (void)playerFailedToPlayToEndTime;
- (void)playerPlaybackStalled;
@end
