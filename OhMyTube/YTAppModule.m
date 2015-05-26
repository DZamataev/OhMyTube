//
//  YTAppModule.m
//  OhMyTube
//
//  Created by Denis Zamataev on 26/05/15.
//  Copyright (c) 2015 Mysterious Organization. All rights reserved.
//

#import "YTAppModule.h"

#import "YTVideoRepositoryInterface.h"
#import "YTVideoRepositoryImpl.h"

@implementation YTAppModule
- (void)configure {
    YTVideoRepositoryImpl *videoRepository = [[YTVideoRepositoryImpl alloc] init];
    [self bind:videoRepository toProtocol:@protocol(YTVideoRepositoryInterface)];
}
@end
