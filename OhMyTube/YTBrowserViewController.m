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

#import "YTVideoRepositoryInterface.h"

#import "YTSettingsManager.h"

@interface YTBrowserViewController () <YTWebViewControllerDelegate>
@property (weak, nonatomic) YTWebViewController *webViewController;

@property (weak, nonatomic) IBOutlet UIView *toolbarView;
@property (weak, nonatomic) IBOutlet UIButton *navigateBackButton;
@property (weak, nonatomic) IBOutlet UIButton *navigateForwardButton;
@property (weak, nonatomic) IBOutlet UIButton *refreshPageButton;
@property (weak, nonatomic) IBOutlet UIButton *downloadButton;

@property (weak, nonatomic) IBOutlet UIView *topBarView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subtitleLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topBarVerticalOffsetConstraint;
@property (assign, nonatomic) BOOL isTopBarDismissed;

@property (weak, nonatomic) IBOutlet M13ProgressViewBar *progressBar;

@property (weak, nonatomic) IBOutlet UIView *notificationContainerView;

@property (strong, nonatomic) id <YTVideoRepositoryInterface> videoRepository;
@property (strong, nonatomic) YTSettingsManager *settingsManager;

@property (strong, nonatomic) YTVideo *videoToDownload;
@end

@implementation YTBrowserViewController

objection_requires_sel(@selector(videoRepository), @selector(settingsManager))

- (instancetype)init {
    self = [super init];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [self initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self commonInit];
    }
    return self;
}

-(void)awakeFromNib {
    [super awakeFromNib];
    [self commonInit];
}

- (void)commonInit {
    [[JSObjection defaultInjector] injectDependencies:self];
    [self subscribeForNotifications];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.downloadButton.enabled = false;
    self.titleLabel.text = NSLocalizedString(@"Loading YouTube...", nil);
    self.subtitleLabel.text = nil;
    [self.progressBar setPrimaryColor:self.progressBar.tintColor];
    [self.progressBar setShowPercentage:NO];
    [self loadLastVisitedURLOrHomePage];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [self unsubscribeFromNotifications];
}

#pragma mark - Properties

- (void)setVideoToDownload:(YTVideo *)videoToDownload {
    _videoToDownload = videoToDownload;
    if (videoToDownload != nil) {
        self.downloadButton.enabled = YES;
    }
    else {
        self.downloadButton.enabled = NO;
    }
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

- (void)loadLastVisitedURLOrHomePage {
    NSURL *lastVisitedURL = [self.settingsManager lastVisitedURL];
    if (lastVisitedURL) {
        [self loadPageWithURL:lastVisitedURL];
    }
    else {
        [self loadHomePage];
    }
}

- (void)loadHomePage {
    [self loadPageWithURL:[NSURL URLWithString:@"http://youtube.com/"]];
}

- (void)loadPageWithURL:(NSURL*)URL {
    [self.webViewController loadURL:URL];
}

- (void)subscribeForNotifications {
    YTBrowserViewController __weak *welf = self;
    [[NSNotificationCenter defaultCenter] addObserverForName:YTNotificaionsOpenInBrowser object:nil queue:nil usingBlock:^(NSNotification *note) {
        [welf.webViewController loadURL:note.userInfo[@"URL"]];
    }];
}

- (void)unsubscribeFromNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:YTNotificaionsOpenInBrowser object:nil];
}

- (void)fireMinimalNotification:(NSString*)title subtitle:(NSString*)subtitle style:(JFMinimalNotificationStytle)style {
    JFMinimalNotification *note = [JFMinimalNotification notificationWithStyle:style
                                                                         title:title
                                                                      subTitle:subtitle
                                                                dismissalDelay:1.0];
    if (self.notificationContainerView) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.notificationContainerView addSubview:note];
            [note show];
        });
    }
}

- (IBAction)navigateBackAction:(id)sender {
    [self resetVideoToDownload];
    [self.webViewController navigateBack];
}

- (IBAction)navigateForwardAction:(id)sender {
    [self resetVideoToDownload];
    [self.webViewController navigateForward];
}

- (IBAction)refreshPageAction:(id)sender {
    if (self.subtitleLabel.text && self.subtitleLabel.text.length > 0) {
        [self.webViewController refresh];
    }
    else {
        [self loadLastVisitedURLOrHomePage];
    }
}

- (IBAction)downloadAction:(id)sender {
    if (self.videoToDownload) {
        [self.videoRepository downloadVideo:self.videoToDownload started:^(YTVideo *video, NSError *error) {
            YTBrowserViewController __weak *welf = self;
            if (error == nil) {
                [self fireMinimalNotification:NSLocalizedString(@"Video download started", nil) subtitle:nil style:JFMinimalNotificationStyleSuccess];
                welf.downloadButton.enabled = NO;
            }
            else {
                [self fireMinimalNotification:NSLocalizedString(@"Error", nil) subtitle:error.localizedDescription style:JFMinimalNotificationStyleError];
            }
        }];
    }
}

- (void)processVideoRequestWithURL:(NSURL*)URL allowLoading:(BOOL*)allow {
    *allow = YES;
    [self resetVideoToDownload];
    
    if ([URL.absoluteString hasPrefix:@"http://m.youtube.com/watch?"] || [URL.absoluteString hasPrefix:@"http://youtube.com/watch?"]) {
        NSDictionary *parameters = [self dictionaryByParsingParametersFromURL:URL];
        
        NSString *identifier = parameters[@"v"];
        if (identifier && identifier.length > 0) {
            YTBrowserViewController __weak *welf = self;
            [self.videoRepository prepareForDownloadVideoWithIdentifier:identifier completion:^(YTVideo *video, NSError *error) {
                if (error == nil) {
                    welf.videoToDownload = video;
                }
                else {
                    [welf fireMinimalNotification:NSLocalizedString(@"Error", nil) subtitle:error.localizedDescription style:JFMinimalNotificationStyleError];
                }
            }];
            
            BOOL isNativeVideoPlayerEnabled = self.settingsManager.isNativeVideoPlayerEnabled;
            if (isNativeVideoPlayerEnabled) {
                *allow = NO;
                XCDYouTubeVideoPlayerViewController *videoPlayerViewController = [[XCDYouTubeVideoPlayerViewController alloc]
                                                                                  initWithVideoIdentifier:identifier];
                [welf presentMoviePlayerViewControllerAnimated:videoPlayerViewController];
            }
        }
    }
}

- (void)resetVideoToDownload {
    self.videoToDownload = nil;
}

- (void)dismissTopBarIfNeeded {
    if (!self.isTopBarDismissed) {
        self.isTopBarDismissed = YES;
        self.topBarVerticalOffsetConstraint.constant = - CGRectGetHeight(self.topBarView.bounds);
        [UIView animateWithDuration:0.3f animations:^{
            [self.topBarView layoutIfNeeded];
        }];
    }
}

#pragma mark - Helpers

- (NSDictionary*)dictionaryByParsingParametersFromURL:(NSURL*)URL {
    NSMutableDictionary *queryStrings = [[NSMutableDictionary alloc] init];
    for (NSString *qs in [URL.query componentsSeparatedByString:@"&"]) {
        // Get the parameter name
        NSString *key = [[qs componentsSeparatedByString:@"="] objectAtIndex:0];
        // Get the parameter value
        NSString *value = [[qs componentsSeparatedByString:@"="] objectAtIndex:1];
        value = [value stringByReplacingOccurrencesOfString:@"+" withString:@" "];
        value = [value stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        queryStrings[key] = value;
    }
    return queryStrings;
}



#pragma mark - <YTWebViewControllerDelegate>

- (void)webViewController:(YTWebViewController *)webViewController fireNotification:(NSString *)title subtitle:(NSString *)subtitle {
    [self fireMinimalNotification:title subtitle:subtitle style:JFMinimalNotificationStyleInfo];
}

- (void)webViewController:(YTWebViewController *)webViewController didUpdateURL:(NSURL *)URL {
    self.subtitleLabel.text = URL.absoluteString;
    if (URL != nil) {
        [self.settingsManager setLastVisitedURL:URL];
    }
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
    if (estimatedProgress == 1.0) {
        [self dismissTopBarIfNeeded];
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

- (BOOL)webViewController:(YTWebViewController *)webViewController shouldStopLoadingAndGoBackOnStateUpdateWithString:(NSString *)stateUpdate {
    BOOL shouldStop = NO;
    NSString *pushstate = @"pushstate?";
    if ([stateUpdate hasPrefix:pushstate]) {
        NSString *argumentURLString = [stateUpdate substringFromIndex:pushstate.length];
        if (argumentURLString && argumentURLString.length > 0) {
            NSURL *argumentURL = [NSURL URLWithString:argumentURLString];
            if (argumentURL) {
                BOOL allowLoading = YES;
                [self processVideoRequestWithURL:argumentURL allowLoading:&allowLoading];
                shouldStop = !allowLoading;
            }
        }
    }
    return shouldStop;
}
@end
