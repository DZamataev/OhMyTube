//
//  YTLaunchAnimationHelper.h
//  OhMyTube
//
//  Created by Denis Zamataev on 08/06/15.
//  Copyright (c) 2015 Mysterious Organization. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface YTLaunchAnimationHelper : NSObject
+ (void)setupAndStartAnimationInWindow:(UIWindow*)window withInitialViewController:(UIViewController*)initialViewController completion:(void (^)())completion;
@end
