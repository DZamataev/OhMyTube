//
//  YTDownloadsSection.m
//  OhMyTube
//
//  Created by Denis Zamataev on 27/05/15.
//  Copyright (c) 2015 Mysterious Organization. All rights reserved.
//

#import "YTDownloadsSection.h"

@implementation YTDownloadsSection
- (instancetype)init {
    self = [super init];
    if (self) {
        _items = [NSMutableArray new];
    }
    return self;
}
@end
