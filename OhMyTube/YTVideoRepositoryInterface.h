//
//  YTVideoRepositoryInterface.h
//  OhMyTube
//
//  Created by Denis Zamataev on 26/05/15.
//  Copyright (c) 2015 Mysterious Organization. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YTVideo.h"

@protocol YTVideoRepositoryInterface <NSObject>
- (void)addVideoWithIdentifier:(NSString *)identifier completion:(void (^)(YTVideo *video, NSError *error))completion;

- (void)downloadVideo:(YTVideo *)video;

- (void)stopDownloadForVideo:(YTVideo *)video;

- (void)deleteVideo:(YTVideo *)video;

- (void)stopDownloadAndDeleteVideo:(YTVideo *)video;

- (NSArray *)videos; // array of objects of type YTVideo
@end
