//
//  YTVideoViewControllerDelegate.h
//  OhMyTube
//
//  Created by Denis Zamataev on 02/06/15.
//  Copyright (c) 2015 Mysterious Organization. All rights reserved.
//

#import <Foundation/Foundation.h>

@class YTVideoViewController;

@protocol YTVideoViewControllerDelegate <NSObject>
- (id)videoViewControllerNeedsNextVideoToPlay:(YTVideoViewController*)videoViewController;
@end
