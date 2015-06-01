//
//  YTVideoViewController.m
//  OhMyTube
//
//  Created by Denis Zamataev on 29/05/15.
//  Copyright (c) 2015 Mysterious Organization. All rights reserved.
//

#import "YTVideoViewController.h"

@interface YTVideoViewController () <DZVideoPlayerViewControllerDelegate>
@property (strong, nonatomic) DZVideoPlayerViewController *videoPlayerViewController;

@property (weak, nonatomic) IBOutlet DZVideoPlayerViewControllerContainerView *videoContainerView;

@end

@implementation YTVideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSAssert(self.video != nil, @"Video must be set beforehand");
    
    self.videoPlayerViewController = self.videoContainerView.videoPlayerViewController;
    self.videoPlayerViewController.videoURL = self.video.fileURL;
    self.videoPlayerViewController.isBackgroundPlaybackEnabled = YES;
    [self.videoPlayerViewController prepareAndPlayAutomatically:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    
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
        // TODO: implement expand videoPlayerViewController to fullscreen
    }
    else {
        // TODO: implement shrink videoPlayerViewController from fullscreen
    }
}

- (void)playerDidPlayToEndTime {
    
}

- (void)playerFailedToPlayToEndTime {
    
}

- (void)playerPlaybackStalled {
    
}

- (void)playerGatherNowPlayingInfo:(NSMutableDictionary *)nowPlayingInfo {
//    [nowPlayingInfo setObject:self.video.author forKey:MPMediaItemPropertyArtist];
    [nowPlayingInfo setObject:self.video.title forKey:MPMediaItemPropertyTitle];
}


@end
