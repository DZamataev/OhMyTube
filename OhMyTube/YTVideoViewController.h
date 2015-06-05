//
//  YTVideoViewController.h
//  OhMyTube
//
//  Created by Denis Zamataev on 29/05/15.
//  Copyright (c) 2015 Mysterious Organization. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DZVideoPlayerViewController.h>

#import "YTVideoViewControllerDelegate.h"

#import "YTVideoRepositoryInterface.h"

#import "YTNotifications.h"

@interface YTVideoViewController : UIViewController
@property (nonatomic, weak) id <YTVideoViewControllerDelegate> delegate;
@property (nonatomic, strong) YTVideo *video;
@end
