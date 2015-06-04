//
//  YTVideoViewController.m
//  OhMyTube
//
//  Created by Denis Zamataev on 29/05/15.
//  Copyright (c) 2015 Mysterious Organization. All rights reserved.
//

#import "YTVideoViewController.h"

NSString *const kYTVideoViewControllerPlayNextEnabledUserDefaultsKey = @"PlayNextEnabled";

@interface YTVideoViewController () <DZVideoPlayerViewControllerDelegate>
@property (strong, nonatomic) DZVideoPlayerViewController *videoPlayerViewController;

@property (weak, nonatomic) IBOutlet DZVideoPlayerViewControllerContainerView *videoContainerView;

@property (weak, nonatomic) IBOutlet UIView *topToolbarView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topToolbarViewVerticalOffsetConstraint;

@property (weak, nonatomic) IBOutlet UILabel *playNextLabel;
@property (weak, nonatomic) IBOutlet UISwitch *playNextSwitch;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (assign, nonatomic) BOOL isPlayNextEnabled;

@property (strong, nonatomic) UIColor *initialBackgroundColor;

- (IBAction)showNextSwitchAction:(UISwitch *)sender;
- (IBAction)openInBrowserAction:(UIButton *)sender;
@end

@implementation YTVideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.initialBackgroundColor = self.view.backgroundColor;
    
    self.isPlayNextEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:kYTVideoViewControllerPlayNextEnabledUserDefaultsKey];
    [self.playNextSwitch setOn:self.isPlayNextEnabled animated:NO];
    
    NSAssert(self.video != nil, @"Video must be set beforehand");
    
    self.videoPlayerViewController = self.videoContainerView.videoPlayerViewController;
    self.videoPlayerViewController.delegate = self;
    self.videoPlayerViewController.isBackgroundPlaybackEnabled = YES;
    self.videoPlayerViewController.isShowFullscreenExpandAndShrinkButtonsEnabled = NO;
    
    [self playVideo];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
}

#pragma mark - Actions

- (void)playVideo {
    self.titleLabel.text = self.video.title;
    self.videoPlayerViewController.videoURL = self.video.fileURL;
    [self.videoPlayerViewController prepareAndPlayAutomatically:YES];
}

- (void)playNextVideo {
    YTVideo *nextVideo = (YTVideo*)[self.delegate videoViewControllerNeedsNextVideoToPlay:self];
    if (nextVideo) {
        self.video = nextVideo;
        [self playVideo];
    }
}

- (IBAction)showNextSwitchAction:(UISwitch *)sender {
    self.isPlayNextEnabled = sender.isOn;
    [[NSUserDefaults standardUserDefaults] setBool:self.isPlayNextEnabled forKey:kYTVideoViewControllerPlayNextEnabledUserDefaultsKey];
}

- (IBAction)openInBrowserAction:(UIButton *)sender {
    
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
}

#pragma mark - <DZVideoPlayerViewControllerDelegate>

- (void)playerFailedToLoadAssetWithError:(NSError *)error {

}

- (void)playerDidPlay {
    
}

- (void)playerDidPause {
    
}

- (void)playerDidStop {
    
}

- (void)playerDidToggleFullscreen {
    if (self.videoPlayerViewController.isFullscreen) {
        // expand videoPlayerViewController to fullscreen
        
    }
    else {
        // shrink videoPlayerViewController from fullscreen

    }
}

- (void)playerDidPlayToEndTime {
    [self playNextVideo];
}

- (void)playerFailedToPlayToEndTime {
    
}

- (void)playerPlaybackStalled {
    
}

- (void)playerDoneButtonTouched {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)playerGatherNowPlayingInfo:(NSMutableDictionary *)nowPlayingInfo {
//    [nowPlayingInfo setObject:self.video.author forKey:MPMediaItemPropertyArtist];
    [nowPlayingInfo setObject:self.video.title forKey:MPMediaItemPropertyTitle];
}


@end
