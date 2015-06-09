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

@property (weak, nonatomic) IBOutlet UIView *contentContainerView;

@property (weak, nonatomic) IBOutlet UILabel *playNextLabel;
@property (weak, nonatomic) IBOutlet UISwitch *playNextSwitch;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (assign, nonatomic) BOOL isPlayNextEnabled;

@property (strong, nonatomic) UIColor *initialBackgroundColor;

- (IBAction)showNextSwitchAction:(UISwitch *)sender;
- (IBAction)openInBrowserAction:(UIButton *)sender;
@end

@implementation YTVideoViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateControlsWhenEnteringInterfaceOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.initialBackgroundColor = self.view.backgroundColor;
    
    self.isPlayNextEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:kYTVideoViewControllerPlayNextEnabledUserDefaultsKey];
    [self.playNextSwitch setOn:self.isPlayNextEnabled animated:NO];
    
    UISwipeGestureRecognizer *swipeUpDown = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleUpDownSwipeGesture:)];
    [swipeUpDown setDirection:(UISwipeGestureRecognizerDirectionUp | UISwipeGestureRecognizerDirectionDown )];
    [self.videoContainerView addGestureRecognizer:swipeUpDown];
    
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
    //The device has already rotated, that's why this method is being called.
    UIInterfaceOrientation toOrientation   = [[UIDevice currentDevice] orientation];
    //fixes orientation mismatch (between UIDeviceOrientation and UIInterfaceOrientation)
    if (toOrientation == UIInterfaceOrientationLandscapeRight) toOrientation = UIInterfaceOrientationLandscapeLeft;
    else if (toOrientation == UIInterfaceOrientationLandscapeLeft) toOrientation = UIInterfaceOrientationLandscapeRight;
    
//    UIInterfaceOrientation fromOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    [self updateControlsWhenEnteringInterfaceOrientation:toOrientation];
}

#pragma mark - Actions

- (void)dismiss {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

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
    [[NSNotificationCenter defaultCenter] postNotificationName:YTNotificaionsOpenInBrowser object:nil userInfo:@{@"URL":self.video.youTubeVideoURL}];
    [self dismiss];
}

- (IBAction)shareAction:(UIButton *)sender {
    NSArray *activityItems = @[self.video.youTubeVideoURL];
    UIActivityViewController *actVC = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        UIPopoverController *popoverController = [[UIPopoverController alloc] initWithContentViewController:actVC];
        [popoverController presentPopoverFromRect:[sender frame] inView:[sender superview] permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
    else {
        [self presentViewController:actVC animated:YES completion:nil];
    }
}

- (void)handleUpDownSwipeGesture:(UISwipeGestureRecognizer*)swipeGestureRecognizer {
    if (swipeGestureRecognizer.state == UIGestureRecognizerStateRecognized) {
        [self dismiss];
    }
}

- (void)updateControlsWhenEnteringInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    if (UIInterfaceOrientationIsPortrait(interfaceOrientation)) {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
        }
        self.contentContainerView.alpha = 1.0f;
    }
    else {
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
        self.contentContainerView.alpha = 0.0f;
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [super prepareForSegue:segue sender:sender];
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

- (void)playerRequireNextTrack {
    
}

- (void)playerRequirePreviousTrack {
    
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
    if (self.isPlayNextEnabled) {
        [self playNextVideo];
    }
}

- (void)playerFailedToPlayToEndTime {
    
}

- (void)playerPlaybackStalled {
    
}

- (void)playerDoneButtonTouched {
    [self dismiss];
}

- (void)playerGatherNowPlayingInfo:(NSMutableDictionary *)nowPlayingInfo {
//    [nowPlayingInfo setObject:self.video.author forKey:MPMediaItemPropertyArtist];
    [nowPlayingInfo setObject:self.video.title forKey:MPMediaItemPropertyTitle];
}


@end
