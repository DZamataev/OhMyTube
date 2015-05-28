//
//  ViewController.m
//  OhMyTube
//
//  Created by Denis Zamataev on 26/05/15.
//  Copyright (c) 2015 Mysterious Organization. All rights reserved.
//

#import "YTRootViewController.h"

#import "YTDownloadsViewController.h"

@interface YTRootViewController ()
@property (weak, nonatomic) IBOutlet YTDownloadsViewController *downloadsViewController;

@property (weak, nonatomic) IBOutlet UIView *browserContainerView;
@property (weak, nonatomic) IBOutlet UIView *downloadsContainerView;
@property (weak, nonatomic) IBOutlet UIView *tabsView;
@property (weak, nonatomic) IBOutlet UIButton *browserButton;
@property (weak, nonatomic) IBOutlet UIButton *downloadsButton;
@end

@implementation YTRootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.browserButton addTarget:self action:@selector(showBrowser:) forControlEvents:UIControlEventTouchUpInside];
    [self.downloadsButton addTarget:self action:@selector(showDownloads:) forControlEvents:UIControlEventTouchUpInside];
    [self showBrowser:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showBrowser:(id)sender {
    [self.view bringSubviewToFront:self.browserContainerView];
}

- (void)showDownloads:(id)sender {
    [self.view bringSubviewToFront:self.downloadsContainerView];
    [self.downloadsViewController populateSections];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"Embed_DownloadsViewController"]) {
        self.downloadsViewController = segue.destinationViewController;
    }
}
@end
