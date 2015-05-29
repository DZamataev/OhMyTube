//
//  YTVideoViewController.m
//  OhMyTube
//
//  Created by Denis Zamataev on 29/05/15.
//  Copyright (c) 2015 Mysterious Organization. All rights reserved.
//

#import "YTVideoViewController.h"
#import "YTVideoPlayerViewController.h"

@interface YTVideoViewController () <PBJVideoPlayerControllerDelegate>
@property (weak, nonatomic) IBOutlet UIView *videoContainerView;

@property (weak, nonatomic) YTVideoPlayerViewController *videoPlayerViewController;
@end

@implementation YTVideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSAssert(self.video != nil, @"Video must be set beforehand");

    self.videoPlayerViewController.videoPath = self.video.filePath;
    [self.videoPlayerViewController playFromBeginning];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"Embed_VideoPlayerViewController"]) {
        self.videoPlayerViewController = segue.destinationViewController;
        self.videoPlayerViewController.delegate = self;
    }
}


#pragma mark - <PBJVideoPlayerControllerDelegate>

- (void)videoPlayerReady:(PBJVideoPlayerController *)videoPlayer {
    
}

- (void)videoPlayerPlaybackStateDidChange:(PBJVideoPlayerController *)videoPlayer {
    
}

- (void)videoPlayerPlaybackWillStartFromBeginning:(PBJVideoPlayerController *)videoPlayer {
    
}

- (void)videoPlayerPlaybackDidEnd:(PBJVideoPlayerController *)videoPlayer {
    
}

- (void)videoPlayerBufferringStateDidChange:(PBJVideoPlayerController *)videoPlayer {
    
}


@end
