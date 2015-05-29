//
//  YTVideoRecord.m
//  OhMyTube
//
//  Created by Denis Zamataev on 26/05/15.
//  Copyright (c) 2015 Mysterious Organization. All rights reserved.
//

#import "YTVideoRecord.h"

@implementation YTVideoRecord
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
    [aCoder encodeObject:_fileURL forKey:@"fileURL"];
    [aCoder encodeObject:_qualityString forKey:@"qualityString"];
    [aCoder encodeObject:_title forKey:@"title"];
    [aCoder encodeObject:_duration forKey:@"duration"];
    [aCoder encodeObject:_thumbnailURL forKey:@"thumbnailURL"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    _identifier = [aDecoder decodeObjectForKey:@"identifier"];
    _downloadProgress = [aDecoder decodeObjectForKey:@"downloadProgress"];
    _fileURL = [aDecoder decodeObjectForKey:@"fileURL"];
    _qualityString = [aDecoder decodeObjectForKey:@"qualityString"];
    _title = [aDecoder decodeObjectForKey:@"title"];
    _duration = [aDecoder decodeObjectForKey:@"duration"];
    _thumbnailURL = [aDecoder decodeObjectForKey:@"thumbnailURL"];
    return self;
}

- (BOOL)isDownloaded {
    return (self.fileURL != nil && self.fileURL.absoluteString.length > 0 && self.downloadProgress.doubleValue >= 1.0);
}
@end
