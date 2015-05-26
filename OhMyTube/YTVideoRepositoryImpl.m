//
//  YTVideoRepositoryImpl.m
//  OhMyTube
//
//  Created by Denis Zamataev on 26/05/15.
//  Copyright (c) 2015 Mysterious Organization. All rights reserved.
//

#import "YTVideoRepositoryImpl.h"

@interface YTVideoRepositoryImpl ()
@property (nonatomic, strong) NSMutableArray *collection;
@end

@implementation YTVideoRepositoryImpl
- (void)addVideoWithIdentifier:(NSString *)videoIdentifier {
    NSAssert(videoIdentifier, @"Identifier must be non-nil");
    
    YTVideoRecord *newRecord = [[YTVideoRecord alloc] initWithIdentifier:videoIdentifier];
    [self.collection addObject:newRecord];
    
    [[XCDYouTubeClient defaultClient] getVideoWithIdentifier:videoIdentifier completionHandler:^(XCDYouTubeVideo *video, NSError *error) {
        if (video) {
            newRecord.video = video;
        }
        else {
            NSLog(@"Error getting video: %@", error);
        }
    }];
}
@end
