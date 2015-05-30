//
//  YTVideoPlayerViewControllerDelegate.h
//  OhMyTube
//
//  Created by Denis Zamataev on 29/05/15.
//  Copyright (c) 2015 Mysterious Organization. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol YTVideoPlayerViewControllerDelegate <NSObject>

@optional

- (void)playerFailedToLoadAssetWithError:(NSError *)error;
- (void)playerDidPlay;
- (void)playerDidPause;
- (void)playerDidStop;
- (void)playerDidPlayToEndTime;
- (void)playerFailedToPlayToEndTime;
- (void)playerPlaybackStalled;

/*
 Provide now playing info like this:
 [nowPlayingInfo setObject:track.artistName forKey:MPMediaItemPropertyArtist];
 [nowPlayingInfo setObject:track.trackTitle forKey:MPMediaItemPropertyTitle];
 */
- (void)playerGatherNowPlayingInfo:(NSMutableDictionary *)nowPlayingInfo;
@end
