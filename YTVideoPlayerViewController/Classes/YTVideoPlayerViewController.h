//
//  YTVideoPlayerViewController.h
//  OhMyTube
//
//  Created by Denis Zamataev on 29/05/15.
//  Copyright (c) 2015 Mysterious Organization. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <MediaPlayer/MediaPlayer.h>

#import "YTVideoPlayerViewControllerDelegate.h"
#import "YTPlayerView.h"
#import "YTProgressIndicatorSlider.h"

@interface YTVideoPlayerViewController : UIViewController
@property (weak, nonatomic) id<YTVideoPlayerViewControllerDelegate> delegate;

@property (strong, nonatomic) NSURL *videoURL;
@property (assign, nonatomic) BOOL isBackgroundPlaybackEnabled; // defaults to NO
@property (strong, nonatomic) NSMutableArray *viewsToHideOnIdle; // has toolbarView by default
@property (assign, nonatomic) NSTimeInterval timeIntervalBeforeHidingViewsOnIdle; // defaults to 3 seconds

// Interface Builder Outlets
@property (weak, nonatomic) IBOutlet YTPlayerView *playerView;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;

@property (weak, nonatomic) IBOutlet UIView *toolbarView;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UIButton *pauseButton;
@property (weak, nonatomic) IBOutlet YTProgressIndicatorSlider *progressIndicator;
@property (weak, nonatomic) IBOutlet UILabel *currentTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *remainingTimeLabel;
@property (weak, nonatomic) IBOutlet UIButton *fullscreenExpandButton;
@property (weak, nonatomic) IBOutlet UIButton *fullscreenShrinkButton;
//

- (void)prepareAndPlayAutomatically:(BOOL)playAutomatically;

- (void)play;

- (void)pause;

- (void)stop;

- (BOOL)isPlaying;

- (void)syncUI;

- (void)toggleFullscreen:(id)sender;

- (void)seek:(UISlider *)slider;

- (void)startSeeking:(id)sender;

- (void)endSeeking:(id)sender;

- (void)updateProgressIndicator:(id)sender;

- (void)startIdleCountdown;

- (void)stopIdleCountdown;

- (void)hideControls;

- (void)showControls;
@end
