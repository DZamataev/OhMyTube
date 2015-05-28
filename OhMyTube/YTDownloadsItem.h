//
//  YTDownloadsItem.h
//  OhMyTube
//
//  Created by Denis Zamataev on 27/05/15.
//  Copyright (c) 2015 Mysterious Organization. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YTDownloadsItem : NSObject
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSNumber *downloadProgress;
@property (strong, nonatomic) NSString *duration;
@property (strong, nonatomic) NSURL *thumbnailURL;
@property (strong, nonatomic) id userInfo;
@end
