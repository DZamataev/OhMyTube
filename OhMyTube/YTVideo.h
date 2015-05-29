//
//  YTVideo.h
//  OhMyTube
//
//  Created by Denis Zamataev on 26/05/15.
//  Copyright (c) 2015 Mysterious Organization. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XCDYouTubeKit/XCDYouTubeKit.h>

@interface YTVideo : NSObject

@property (readonly, nonatomic) NSString *identifier;
@property (strong, nonatomic) NSNumber *downloadProgress;
@property (strong, nonatomic) NSString *fileName;
@property (strong, nonatomic) NSString *qualityString;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSNumber *duration;
@property (strong, nonatomic) NSURL *thumbnailURL;

@property (strong, nonatomic) XCDYouTubeVideo *youTubeVideo;

@property (readonly, nonatomic) BOOL isDownloaded;
@property (readonly, nonatomic) NSString *filePath;
@property (readonly, nonatomic) NSURL *fileURL;

- (instancetype)initWithIdentifier:(NSString*)identifier;

@end
