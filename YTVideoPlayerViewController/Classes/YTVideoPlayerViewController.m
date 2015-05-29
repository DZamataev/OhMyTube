//
//  YTVideoPlayerViewController.m
//  OhMyTube
//
//  Created by Denis Zamataev on 29/05/15.
//  Copyright (c) 2015 Mysterious Organization. All rights reserved.
//

#import "YTVideoPlayerViewController.h"

static const NSString *ItemStatusContext;
static const NSString *PlayerRateContext;
static const NSString *PlayerStatusContext;

@interface YTVideoPlayerViewController ()
{
    NSDateFormatter *_dateFormatter;
}
@property (strong, nonatomic) AVPlayer *player;
@property (strong, nonatomic) AVPlayerItem *playerItem;

@property (assign, nonatomic) BOOL isSeeking;
@property (assign, nonatomic) BOOL isFullscreen;
@property (assign, nonatomic) CGRect initialFrame;

@end

@implementation YTVideoPlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.initialFrame = self.view.frame;
    
    [self setupActions];
    [self setupNotifications];
    [self setupAudioSession];
    [self setupPlayer];
    [self syncUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [self resignNotifications];
    [self resignKVO];
}

-(void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
}

#pragma mark - Properties


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
}


#pragma mark - Actions

- (void)prepareAndPlayAutomatically:(BOOL)playAutomatically {
    if (self.player) {
        [self stop];
    }
    
    if (self.playerItem) {
        [self.playerItem removeObserver:self forKeyPath:@"status" context:&ItemStatusContext];
    }
    
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:self.videoURL options:nil];
    NSString *playableKey = @"playable";
    
    [asset loadValuesAsynchronouslyForKeys:@[playableKey] completionHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            NSError *error;
            AVKeyValueStatus status = [asset statusOfValueForKey:playableKey error:&error];
            
            if (status == AVKeyValueStatusLoaded) {
                self.playerItem = [AVPlayerItem playerItemWithAsset:asset];
                // ensure that this is done before the playerItem is associated with the player
                [self.playerItem addObserver:self forKeyPath:@"status"
                                     options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew
                                     context:&ItemStatusContext];
                
                [self.player replaceCurrentItemWithPlayerItem:self.playerItem];
                
                if (playAutomatically) {
                    [self play];
                }
            }
            else {
                // You should deal with the error appropriately.
                NSLog(@"Error, the asset is not playable: %@", error);
            }
        });
        
    }];
}

- (void)play {
    [self.player play];
    [self syncUI];
    if ([self.delegate respondsToSelector:@selector(playerDidResume)]) {
        [self.delegate playerDidResume];
    }
}

- (void)pause {
    [self.player pause];
    [self syncUI];
    if ([self.delegate respondsToSelector:@selector(playerDidPause)]) {
        [self.delegate playerDidPause];
    }
}

- (void)stop {
    [self.player pause];
    [self.player seekToTime:kCMTimeZero];
    [self syncUI];
}

- (BOOL)isPlaying {
    return [self.player rate] > 0.0f;
}

- (void)clean {
    
}

#pragma mark - Private

- (void)syncUI {
    if ([self isPlaying]) {
        self.playButton.hidden = YES;
        self.playButton.enabled = NO;
        
        self.pauseButton.hidden = NO;
        self.pauseButton.enabled = YES;
    }
    else {
        self.playButton.hidden = NO;
        self.playButton.enabled = YES;
        
        self.pauseButton.hidden = YES;
        self.pauseButton.enabled = NO;
    }
}

- (void)toggleFullscreen:(id)sender {
    if (self.isFullscreen) {
        
    }
    else {
        
    }
}

- (void)seek:(UISlider *)slider {
    int timescale = self.playerItem.asset.duration.timescale;
    float time = slider.value * (self.playerItem.asset.duration.value / timescale);
    [self.player seekToTime:CMTimeMakeWithSeconds(time, timescale)];
}

- (void)startSeeking:(id)sender {
    self.isSeeking = YES;
}

- (void)endSeeking:(id)sender {
    self.isSeeking = NO;
}

- (void)updateProgressIndicator:(id)sender {
    CGFloat duration = CMTimeGetSeconds(self.playerItem.asset.duration);
    
    if (duration == 0 || isnan(duration)) {
        // Video is a live stream
        self.progressIndicator.hidden = YES;
        [self.currentTimeLabel setText:nil];
        [self.remainingTimeLabel setText:nil];
    }
    else {
        self.progressIndicator.hidden = NO;
        
        CGFloat current;
        if (self.isSeeking) {
            current = self.progressIndicator.value * duration;
        }
        else {
            // Otherwise, use the actual video position
            current = CMTimeGetSeconds(self.player.currentTime);
        }
        
        [self.progressIndicator setValue:(current / duration)];
        [self.progressIndicator setSecondaryValue:([self availableDuration] / duration)];
        
        // Set time labels
        
        NSString *currentTimeString = [self stringFromTimeInterval:current];
        NSString *remainingTimeString = [self stringFromTimeInterval:duration];
        
        [self.currentTimeLabel setText:currentTimeString];
        [self.remainingTimeLabel setText:[NSString stringWithFormat:@"-%@", remainingTimeString]];
        
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

- (NSString *)stringFromTimeInterval:(NSTimeInterval)time {
    NSString *string = [NSString stringWithFormat:@"%02li:%02li:%02li",
                        lround(floor(time / 3600.)) % 100,
                        lround(floor(time / 60.)) % 60,
                        lround(floor(time)) % 60];
    
    NSString *extraZeroes = @"00:";
    
    if ([string hasPrefix:extraZeroes]) {
        string = [string substringFromIndex:extraZeroes.length];
    }
    
    return string;
}

#pragma mark - Helpers

- (void)setupPlayer {
    self.player = [[AVPlayer alloc] initWithPlayerItem:nil];
    
    [self.player addObserver:self forKeyPath:@"rate"
                     options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:&PlayerRateContext];
    
    [self.player addObserver:self forKeyPath:@"status"
                     options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:&PlayerStatusContext];
    
    YTVideoPlayerViewController __weak *welf = self;
    [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 1)  queue:nil usingBlock:^(CMTime time) {
        [welf updateProgressIndicator:welf];
    }];
    
    self.playerView.player = self.player;
    self.playerView.videoFillMode = AVLayerVideoGravityResizeAspect;
    
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

- (void)resignKVO {
    [self.playerItem removeObserver:self forKeyPath:@"status" context:&ItemStatusContext];
    [self.player removeObserver:self forKeyPath:@"rate" context:&PlayerRateContext];
    [self.player removeObserver:self forKeyPath:@"status" context:&PlayerStatusContext];
}

- (void)setupNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleAVPlayerItemDidPlayToEndTime:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleAVPlayerItemFailedToPlayToEndTime:)
                                                 name:AVPlayerItemFailedToPlayToEndTimeNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleAVPlayerItemPlaybackStalled:)
                                                 name:AVPlayerItemPlaybackStalledNotification object:nil];
}

- (void)resignNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemFailedToPlayToEndTimeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemPlaybackStalledNotification object:nil];
}

#pragma mark - AVPlayer Notification Handlers

- (void)handleAVPlayerItemDidPlayToEndTime:(NSNotification *)notification {
    [self stop];
}

- (void)handleAVPlayerItemFailedToPlayToEndTime:(NSNotification *)notification {
    [self stop];
}

- (void)handleAVPlayerItemPlaybackStalled:(NSNotification *)notification {
    [self pause];
    [self.activityIndicatorView startAnimating];
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (context == &ItemStatusContext) {
//        AVPlayerItemStatus status = [change[NSKeyValueChangeNewKey] integerValue];
        dispatch_async(dispatch_get_main_queue(),
                       ^{
                           [self syncUI];
                       });
    }
    else if (context == &PlayerRateContext) {
        float rate = [change[NSKeyValueChangeNewKey] floatValue];
        dispatch_async(dispatch_get_main_queue(),
                       ^{
                           if (rate > 0) {
                               [self.activityIndicatorView stopAnimating];
                           }
                       });
        
    }
    else if (context == &PlayerStatusContext) {
//        AVPlayerStatus status = [change[NSKeyValueChangeNewKey] integerValue];
        dispatch_async(dispatch_get_main_queue(),
                       ^{
                           [self syncUI];
                       });
    }
    else {
        // Make sure to call the superclass's implementation in the else block in case it is also implementing KVO
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}
@end
