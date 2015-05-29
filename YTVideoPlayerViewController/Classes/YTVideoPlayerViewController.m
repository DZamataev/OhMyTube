//
//  YTVideoPlayerViewController.m
//  OhMyTube
//
//  Created by Denis Zamataev on 29/05/15.
//  Copyright (c) 2015 Mysterious Organization. All rights reserved.
//

#import "YTVideoPlayerViewController.h"

@interface YTVideoPlayerViewController ()
{
    NSDateFormatter *_dateFormatter;
}
@property (strong, nonatomic) AVPlayer *player;
@property (strong, nonatomic) AVPlayerLayer *playerLayer;
@property (strong, nonatomic) AVPlayerItem *currentItem;

@property (strong, nonatomic) NSTimer *progressTimer;

@property (assign, nonatomic) BOOL isSeeking;
@property (assign, nonatomic) BOOL isFullscreen;
@property (assign, nonatomic) CGRect initialFrame;

@property (readonly, nonatomic) NSDateFormatter *dateFormatter;
@end

@implementation YTVideoPlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupActions];
    [self setupNotifications];
    [self setupAudioSession];
    [self setupPlayer];
    
    self.initialFrame = self.view.frame;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [self resignNotifications];
}

-(void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    CGRect frame = self.videoContainerView.frame;
    frame.origin = CGPointZero;
    self.playerLayer.frame = frame;
}

#pragma mark - Properties

- (NSDateFormatter *)dateFormatter {
    if (_dateFormatter == nil) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setDateFormat:@"hh:mm:ss"];
    }
    return _dateFormatter;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Actions

- (void)prepareAndPlayAutomatically:(BOOL)playAutomatically {
    if (self.player) {
        [self stop];
    }
    
    self.player = [[AVPlayer alloc] initWithPlayerItem:nil];
    
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:self.videoURL options:nil];
    NSArray *keys = [NSArray arrayWithObject:@"playable"];
    
    [asset loadValuesAsynchronouslyForKeys:keys completionHandler:^{
        self.currentItem = [AVPlayerItem playerItemWithAsset:asset];
        [self.player replaceCurrentItemWithPlayerItem:self.currentItem];
        
        if (playAutomatically) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self play];
            });
        }
    }];
    
    [self.player setAllowsExternalPlayback:YES];
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    [self.view.layer addSublayer:self.playerLayer];
    
    self.initialFrame = self.view.frame;
    CGRect playerLayerFrame = self.view.frame;
    playerLayerFrame.origin = CGPointZero;
    [self.playerLayer setFrame:playerLayerFrame];
    
    [self.player addObserver:self forKeyPath:@"rate" options:0 context:nil];
    [self.currentItem addObserver:self forKeyPath:@"status" options:0 context:nil];
    
    [self.player seekToTime:kCMTimeZero];
    [self.player setRate:0.0f];
}

- (void)play {
    [self.player play];
    [self updateControlsToPause];
    self.progressTimer = [NSTimer scheduledTimerWithTimeInterval:0.1f
                                                          target:self
                                                        selector:@selector(updateProgressIndicator:)
                                                        userInfo:nil
                                                         repeats:YES];
    if ([self.delegate respondsToSelector:@selector(playerDidResume)]) {
        [self.delegate playerDidResume];
    }
}

- (void)pause {
    [self.player pause];
    [self updateControlsToPlay];
    if ([self.delegate respondsToSelector:@selector(playerDidPause)]) {
        [self.delegate playerDidPause];
    }
}

- (void)stop {
    [self.player pause];
    [self.player seekToTime:kCMTimeZero];
    [self updateControlsToPlay];
}

- (BOOL)isPlaying {
    return [self.player rate] > 0.0f;
}


#pragma mark - Private

- (void)updateControlsToPlay {
    self.playButton.hidden = NO;
    self.pauseButton.hidden = YES;
}

- (void)updateControlsToPause {
    self.playButton.hidden = YES;
    self.pauseButton.hidden = NO;
}

- (void)togglePlay:(id)sender {
    if ([self isPlaying]) {
        [self pause];
        
    } else {
        [self play];
    }
}

- (void)toggleFullscreen:(id)sender {
    if (self.isFullscreen) {
        if ([self.delegate respondsToSelector:@selector(playerWillLeaveFullscreen)]) {
            [self.delegate playerWillLeaveFullscreen];
        }
        YTVideoPlayerViewController __weak *welf = self;
        [UIView animateWithDuration:0.2f animations:^{
            welf.view.transform = CGAffineTransformMakeRotation(0);
            welf.view.frame = welf.initialFrame;
            
            CGRect frame = welf.initialFrame;
            frame.origin = CGPointZero;
            welf.playerLayer.frame = frame;
        } completion:^(BOOL finished) {
            welf.isFullscreen = NO;
            
            if ([welf.delegate respondsToSelector:@selector(playerDidLeaveFullscreen)]) {
                [welf.delegate playerDidLeaveFullscreen];
            }
        }];
    }
    else {
        UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
        
        CGFloat width = CGRectGetWidth([[UIScreen mainScreen] bounds]);
        CGFloat height = CGRectGetHeight([[UIScreen mainScreen] bounds]);
        CGRect frame;
        
        if (UIInterfaceOrientationIsPortrait(orientation)) {
            CGFloat aux = width;
            width = height;
            height = aux;
            frame = CGRectMake((height - width) / 2, (width - height) / 2, width, height);
        } else {
            frame = CGRectMake(0, 0, width, height);
        }
        
        if ([self.delegate respondsToSelector:@selector(playerWillEnterFullscreen)]) {
            [self.delegate playerWillEnterFullscreen];
        }
        
        YTVideoPlayerViewController __weak *welf = self;
        [UIView animateWithDuration:0.2f animations:^{
            welf.view.frame = frame;
            
            welf.playerLayer.frame = CGRectMake(0, 0, width, height);
            
            if (UIInterfaceOrientationIsPortrait(orientation)) {
                welf.view.transform = CGAffineTransformMakeRotation(M_PI_2);
            }
            
        } completion:^(BOOL finished) {
            welf.isFullscreen = YES;
            
            if ([welf.delegate respondsToSelector:@selector(playerDidEnterFullscreen)]) {
                [welf.delegate playerDidEnterFullscreen];
            }
        }];
    }
}

- (void)seek:(UISlider *)slider {
    int timescale = self.currentItem.asset.duration.timescale;
    float time = slider.value * (self.currentItem.asset.duration.value / timescale);
    [self.player seekToTime:CMTimeMakeWithSeconds(time, timescale)];
}

- (void)startSeeking:(id)sender {
    self.isSeeking = YES;
}

- (void)endSeeking:(id)sender {
    self.isSeeking = NO;
}

- (void)updateProgressIndicator:(id)sender {
    CGFloat duration = CMTimeGetSeconds(self.currentItem.asset.duration);
    
    if (duration == 0 || isnan(duration)) {
        // Video is a live stream
        self.progressIndicator.hidden = YES;
        [self.currentTimeLabel setText:nil];
        [self.remainingTimeLabel setText:nil];
    }
    else {
        self.progressIndicator.hidden = NO;
        
        CGFloat current = self.isSeeking ?
        self.progressIndicator.value * duration :         // If seeking, reflects the position of the slider
        CMTimeGetSeconds(self.player.currentTime);             // Otherwise, use the actual video position
        
        [self.progressIndicator setValue:(current / duration)];
        [self.progressIndicator setSecondaryValue:([self availableDuration] / duration)];
        
        // Set time labels
        
        NSDate *currentTime = [NSDate dateWithTimeIntervalSince1970:current];
        NSDate *remainingTime = [NSDate dateWithTimeIntervalSince1970:(duration - current)];
        
        [self.currentTimeLabel setText:[[self dateFormatter] stringFromDate:currentTime]];
        [self.remainingTimeLabel setText:[NSString stringWithFormat:@"-%@", [[self dateFormatter] stringFromDate:remainingTime]]];
        
    }
}

- (NSTimeInterval)availableDuration {
    NSTimeInterval result = 0;
    NSArray *loadedTimeRanges = self.player.currentItem.loadedTimeRanges;
    
    if ([loadedTimeRanges count] > 0) {
        CMTimeRange timeRange = [[loadedTimeRanges objectAtIndex:0] CMTimeRangeValue];
        Float64 startSeconds = CMTimeGetSeconds(timeRange.start);
        Float64 durationSeconds = CMTimeGetSeconds(timeRange.duration);
        result = startSeconds + durationSeconds;
    }
    
    return result;
}

#pragma mark - Helpers

- (void)setupPlayer {
    self.player = [[AVPlayer alloc] initWithPlayerItem:nil];
    [self.player setAllowsExternalPlayback:YES];
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    [self.videoContainerView.layer addSublayer:self.playerLayer];
    [self.view sendSubviewToBack:self.videoContainerView];
    [self.view bringSubviewToFront:self.toolbarView];
    
    [self.player addObserver:self forKeyPath:@"rate" options:0 context:nil];
    [self.currentItem addObserver:self forKeyPath:@"status" options:0 context:nil];
    
    [self.player seekToTime:kCMTimeZero];
    [self.player setRate:0.0f];
}

- (void)setupAudioSession {
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    
    NSError *setCategoryError = nil;
    BOOL success = [audioSession setCategory:AVAudioSessionCategoryPlayback error:&setCategoryError];
    if (!success) { /* handle the error condition */ }
    
    NSError *activationError = nil;
    success = [audioSession setActive:YES error:&activationError];
    if (!success) { /* handle the error condition */ }
}

- (void)setupActions {
    [self.playButton addTarget:self action:@selector(play) forControlEvents:UIControlEventTouchUpInside];
    [self.pauseButton addTarget:self action:@selector(pause) forControlEvents:UIControlEventTouchUpInside];
    [self.fullscreenButton addTarget:self action:@selector(toggleFullscreen:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.progressIndicator addTarget:self action:@selector(seek:) forControlEvents:UIControlEventValueChanged];
    [self.progressIndicator addTarget:self action:@selector(startSeeking:) forControlEvents:UIControlEventTouchDown];
    [self.progressIndicator addTarget:self action:@selector(endSeeking:) forControlEvents:UIControlEventTouchUpInside|UIControlEventTouchUpOutside];
}

- (void)setupNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerDidFinishPlaying:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerFailedToPlayToEnd:)
                                                 name:AVPlayerItemFailedToPlayToEndTimeNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerStalled:)
                                                 name:AVPlayerItemPlaybackStalledNotification object:nil];
}

- (void)resignNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemFailedToPlayToEndTimeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemPlaybackStalledNotification object:nil];
}

#pragma mark - AVPlayer Notification Handlers

- (void)playerDidFinishPlaying:(NSNotification *)notification {
    [self stop];
    
    if (self.isFullscreen) {
        [self toggleFullscreen:self];
    }
    
    if ([self.delegate respondsToSelector:@selector(playerDidEndPlaying)]) {
        [self.delegate playerDidEndPlaying];
    }
}

- (void)playerFailedToPlayToEnd:(NSNotification *)notification {
    [self stop];
    
    if ([self.delegate respondsToSelector:@selector(playerFailedToPlayToEnd)]) {
        [self.delegate playerFailedToPlayToEnd];
    }
}

- (void)playerStalled:(NSNotification *)notification {
    [self togglePlay:self];
    
    if ([self.delegate respondsToSelector:@selector(playerStalled)]) {
        [self.delegate playerStalled];
    }
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"status"] && object == self.currentItem) {
        if (self.currentItem.status == AVPlayerItemStatusFailed) {
            if ([self.delegate respondsToSelector:@selector(playerFailedToPlayToEnd)]) {
                [self.delegate playerFailedToPlayToEnd];
            }
        }
    }
    else if ([keyPath isEqualToString:@"rate"] && object == self.player) {
        CGFloat rate = [self.player rate];
        if (rate > 0) {
        }
    }
    else {
        // Make sure to call the superclass's implementation in the else block in case it is also implementing KVO
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}
@end
