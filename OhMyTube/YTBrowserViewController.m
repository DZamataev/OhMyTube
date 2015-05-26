//
//  YTBrowserViewController.m
//  OhMyTube
//
//  Created by Denis Zamataev on 26/05/15.
//  Copyright (c) 2015 Mysterious Organization. All rights reserved.
//

#import "YTBrowserViewController.h"
#import "YTWebViewControllerDelegate.h"
#import "YTWebViewController.h"

@interface YTBrowserViewController () <YTWebViewControllerDelegate>
@property (weak, nonatomic) YTWebViewController *webViewController;

@property (weak, nonatomic) IBOutlet UIView *toolbarView;
@property (weak, nonatomic) IBOutlet UIButton *navigateBackButton;
@property (weak, nonatomic) IBOutlet UIButton *navigateForwardButton;
@property (weak, nonatomic) IBOutlet UIButton *refreshPageButton;

@property (weak, nonatomic) IBOutlet UIView *topBarView;
@property (weak, nonatomic) IBOutlet M13ProgressViewBar *progressBar;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subtitleLabel;
@end

@implementation YTBrowserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.progressBar setPrimaryColor:self.progressBar.tintColor];
    [self.webViewController loadURL:[NSURL URLWithString:@"http://youtube.com/"]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"Embed_WebViewController"]) {
        self.webViewController = segue.destinationViewController;
        self.webViewController.delegate = self;
    }
}

#pragma mark - Actions

- (void)fireMinimalNotification:(NSString*)title subtitle:(NSString*)subtitle {
    JFMinimalNotification *note = [JFMinimalNotification notificationWithStyle:JFMinimalNotificationStyleInfo
                                                                         title:title
                                                                      subTitle:subtitle
                                                                dismissalDelay:0.3];
    if (self.view) {
        [self.view addSubview:note];
        [note show];
    }
}

- (IBAction)navigateBackAction:(id)sender {
    [self.webViewController navigateBack];
}

- (IBAction)navigateForwardAction:(id)sender {
    [self.webViewController navigateForward];
}

- (IBAction)refreshPageAction:(id)sender {
    [self.webViewController refresh];
}

#pragma mark - <YTWebViewControllerDelegate>

- (void)webViewController:(YTWebViewController *)webViewController fireNotification:(NSString *)title subtitle:(NSString *)subtitle {
    [self fireMinimalNotification:title subtitle:subtitle];
}

- (void)webViewController:(YTWebViewController *)webViewController didUpdateURL:(NSURL *)URL {
    self.subtitleLabel.text = URL.absoluteString;
}

- (void)webViewController:(YTWebViewController *)webViewController didUpdateTitle:(NSString *)title {
    self.titleLabel.text = title;
}

- (void)webViewController:(YTWebViewController *)webViewController didUpdateNavigationControlsWithBackButtonEnabled:(BOOL)backButtonEnabled andForwardButtonEnabled:(BOOL)forwardButtonEnabled;
{
    self.navigateBackButton.enabled = backButtonEnabled;
    self.navigateForwardButton.enabled = forwardButtonEnabled;
}

- (void)webViewController:(YTWebViewController *)webViewController didUpdateLoading:(BOOL)loading {
    if (loading) {

    }
    else {

    }
}

- (void)webViewController:(YTWebViewController *)webViewController didUpdateEstimatedProgress:(double)estimatedProgress {
    [self.progressBar setProgress:estimatedProgress animated:YES];
    if (estimatedProgress == 1.0f) {
        YTBrowserViewController __weak *welf = self;
        [UIView animateWithDuration:0.2f animations:^{
            
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.1f animations:^{
                welf.progressBar.alpha = 0.0f;
            }];
        }];
    }
    else if (self.progressBar.alpha == 0.0f) {
        YTBrowserViewController __weak *welf = self;
        [UIView animateWithDuration:0.1f animations:^{
            welf.progressBar.alpha = 1.0f;
        }];
    }
}

@end
