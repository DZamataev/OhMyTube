//
//  YTVideoRecord.h
//  OhMyTube
//
//  Created by Denis Zamataev on 26/05/15.
//  Copyright (c) 2015 Mysterious Organization. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XCDYouTubeKit/XCDYouTubeKit.h>

@interface YTVideoRecord : NSObject

@property (readonly, nonatomic) NSString *identifier;
@property (strong, nonatomic) NSNumber *downloadProgress;
@property (strong, nonatomic) NSURL *fileURL;
@property (strong, nonatomic) NSString *qualityString;

@property (strong, nonatomic) XCDYouTubeVideo *youTubeVideo;

@property (readonly, nonatomic) BOOL isDownloaded;

- (instancetype)initWithIdentifier:(NSString*)identifier;

@end
