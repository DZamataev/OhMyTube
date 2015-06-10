//
//  WebViewController.h
//  WKWebViewExample
//
//  Created by Denis Zamataev on 18/05/15.
//  Copyright (c) 2015 Denis Zamataev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import <Objection.h>

#import "YTWebViewControllerDelegate.h"

@interface YTWebViewController : UIViewController
@property (nonatomic, weak) id<YTWebViewControllerDelegate> delegate;
- (void)loadURL:(NSURL*)url;
- (void)navigateBack;
- (void)navigateForward;
- (void)refresh;
- (void)setContentInset:(UIEdgeInsets)inset;
@end
