//
//  YTVideoViewController.m
//  OhMyTube
//
//  Created by Denis Zamataev on 29/05/15.
//  Copyright (c) 2015 Mysterious Organization. All rights reserved.
//

#import "YTVideoViewController.h"
#import "YTVideoPlayerViewController.h"

@interface YTVideoViewController () <YTVideoPlayerViewControllerDelegate>
@property (weak, nonatomic) YTVideoPlayerViewController *videoPlayerViewController;

@property (weak, nonatomic) IBOutlet UIView *videoContainerView;

@end

@implementation YTVideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSAssert(self.video != nil, @"Video must be set beforehand");
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
    if ([segue.identifier isEqualToString:@"Embed_VideoPlayerViewController"]) {
        self.videoPlayerViewController = segue.destinationViewController;
        self.videoPlayerViewController.delegate = self;
    }
}

#pragma mark - Video Player View Controller Delegate

- (void)playerGatherNowPlayingInfo:(NSMutableDictionary *)nowPlayingInfo {
//    [nowPlayingInfo setObject: forKey:MPMediaItemPropertyArtist];
    [nowPlayingInfo setObject:self.video.title forKey:MPMediaItemPropertyTitle];
}


@end
