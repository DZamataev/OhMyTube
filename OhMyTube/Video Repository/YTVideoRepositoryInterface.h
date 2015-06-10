//
//  YTVideoRepositoryInterface.h
//  OhMyTube
//
//  Created by Denis Zamataev on 26/05/15.
//  Copyright (c) 2015 Mysterious Organization. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YTVideo.h"

FOUNDATION_EXPORT NSString *const YTVideoRepositoryErrorDomain;

FOUNDATION_EXPORT NSString *const YTVideoRepositoryEntityUpdateNotification;

@protocol YTVideoRepositoryInterface <NSObject>
- (void)prepareForDownloadVideoWithIdentifier:(NSString *)identifier completion:(void (^)(YTVideo *video, NSError *error))completion;

- (void)downloadVideo:(YTVideo *)video started:(void (^)(YTVideo *video, NSError *error))started;

- (void)stopDownloadForVideo:(YTVideo *)video;

- (void)deleteVideo:(YTVideo *)video;

- (void)stopDownloadAndDeleteVideo:(YTVideo *)video;

- (NSArray *)allVideos; // array of objects of type YTVideo
@end
