//
//  YTVideoRepositoryInterface.h
//  OhMyTube
//
//  Created by Denis Zamataev on 26/05/15.
//  Copyright (c) 2015 Mysterious Organization. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YTVideoRecord.h"

@protocol YTVideoRepositoryInterface <NSObject>
- (void)addVideoWithIdentifier:(NSString*)identifier completion:(void (^)(YTVideoRecord *video, NSError *error))completion;

- (void)downloadVideo:(YTVideoRecord*)video;
@end
