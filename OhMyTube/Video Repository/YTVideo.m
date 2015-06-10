//
//  YTVideo.m
//  OhMyTube
//
//  Created by Denis Zamataev on 26/05/15.
//  Copyright (c) 2015 Mysterious Organization. All rights reserved.
//

#import "YTVideo.h"

@implementation YTVideo
- (instancetype)initWithIdentifier:(NSString *)identifier {
    self = [super init];
    if (self) {
        _identifier = identifier;
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_identifier forKey:@"identifier"];
    [aCoder encodeObject:_downloadProgress forKey:@"downloadProgress"];
    [aCoder encodeObject:_fileName forKey:@"fileName"];
    [aCoder encodeObject:_qualityString forKey:@"qualityString"];
    [aCoder encodeObject:_title forKey:@"title"];
    [aCoder encodeObject:_duration forKey:@"duration"];
    [aCoder encodeObject:_thumbnailURL forKey:@"thumbnailURL"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    _identifier = [aDecoder decodeObjectForKey:@"identifier"];
    _downloadProgress = [aDecoder decodeObjectForKey:@"downloadProgress"];
    _fileName = [aDecoder decodeObjectForKey:@"fileName"];
    _qualityString = [aDecoder decodeObjectForKey:@"qualityString"];
    _title = [aDecoder decodeObjectForKey:@"title"];
    _duration = [aDecoder decodeObjectForKey:@"duration"];
    _thumbnailURL = [aDecoder decodeObjectForKey:@"thumbnailURL"];
    return self;
}

- (BOOL)isDownloaded {
    NSString* documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString* filePath = [documentsPath stringByAppendingPathComponent:self.fileName];
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
    return (fileExists && self.downloadProgress.doubleValue >= 1.0);
}

- (NSString *)filePath {
    NSString *fileName = self.fileName;
    if (fileName && fileName.length > 0) {
        NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *filePath = [documentsPath stringByAppendingPathComponent:self.fileName];
        if (filePath) {
            BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
            if (fileExists) {
                return filePath;
            }
        }
    }
    
    return nil;
}

- (NSURL *)fileURL {
    NSString *filePath = [self filePath];
    if (filePath) {
        NSURL *fileURL = [NSURL fileURLWithPath:filePath];
        if (fileURL) {
            return fileURL;
        }
    }
    return nil;
}

- (NSURL *)youTubeVideoURL {
    NSString *URLString = [@"http://youtube.com/watch?v=" stringByAppendingString:self.identifier];
    return [NSURL URLWithString:URLString];
}

- (NSURL *)youTubeVideoStreamWithBestQualityURL {
    NSNumber *qualityNumber = [self bestPossibleQuality];
    NSURL *streamURL = self.youTubeVideo.streamURLs[qualityNumber];
    return streamURL;
}

- (NSNumber*)bestPossibleQuality {
    NSNumber *quality;
    NSArray *qualityOptionsArray = @[@(XCDYouTubeVideoQualityHD720), @(XCDYouTubeVideoQualityMedium360), @(XCDYouTubeVideoQualitySmall240)];
    for (NSNumber *qualityNumber in qualityOptionsArray) {
        NSURL *streamURL = self.youTubeVideo.streamURLs[qualityNumber];
        if (streamURL != nil) {
            quality = qualityNumber;
            break;
        }
    }
    return quality;
}

- (NSURL*)bestPossibleThumbnailURL {
    NSURL *thumbnailURL;
    if (self.youTubeVideo.largeThumbnailURL != nil) {
        thumbnailURL = self.youTubeVideo.largeThumbnailURL;
    }
    else if (self.youTubeVideo.mediumThumbnailURL != nil) {
        thumbnailURL = self.youTubeVideo.mediumThumbnailURL;
    }
    else if (self.youTubeVideo.smallThumbnailURL != nil) {
        thumbnailURL = self.youTubeVideo.smallThumbnailURL;
    }
    return thumbnailURL;
}
@end
