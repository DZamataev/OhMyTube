//
//  WebViewControllerDelegate.h
//  WKWebViewExample
//
//  Created by Denis Zamataev on 19/05/15.
//  Copyright (c) 2015 Denis Zamataev. All rights reserved.
//

#import <Foundation/Foundation.h>

@class YTWebViewController;

@protocol YTWebViewControllerDelegate <NSObject>

@required

- (void)webViewController:(YTWebViewController*)webViewController fireNotification:(NSString*)title subtitle:(NSString*)subtitle;
- (void)webViewController:(YTWebViewController*)webViewController didUpdateURL:(NSURL*)URL;
- (void)webViewController:(YTWebViewController*)webViewController didUpdateTitle:(NSString*)title;
- (void)webViewController:(YTWebViewController *)webViewController didUpdateNavigationControlsWithBackButtonEnabled:(BOOL)backButtonEnabled andForwardButtonEnabled:(BOOL)forwardButtonEnabled;
- (void)webViewController:(YTWebViewController *)webViewController didUpdateLoading:(BOOL)loading;
- (void)webViewController:(YTWebViewController *)webViewController didUpdateEstimatedProgress:(double)estimatedProgress;

@optional


@end
