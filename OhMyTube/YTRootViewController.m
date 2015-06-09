//
//  ViewController.m
//  OhMyTube
//
//  Created by Denis Zamataev on 26/05/15.
//  Copyright (c) 2015 Mysterious Organization. All rights reserved.
//

#import "YTRootViewController.h"

#import "YTDownloadsViewController.h"

#import "YTSettingsManager.h"

@interface YTRootViewController ()
@property (weak, nonatomic) YTDownloadsViewController *downloadsViewController;

@property (weak, nonatomic) IBOutlet UIView *browserContainerView;
@property (weak, nonatomic) IBOutlet UIView *downloadsContainerView;
@property (weak, nonatomic) IBOutlet UIView *tabsView;
@property (weak, nonatomic) IBOutlet UIView *tabsVisualEffectView;
@property (weak, nonatomic) IBOutlet UIButton *browserButton;
@property (weak, nonatomic) IBOutlet UIButton *downloadsButton;

@property (strong, nonatomic) YTSettingsManager *settingsManager;
@end

@implementation YTRootViewController

objection_requires_sel(@selector(settingsManager))

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
    [self.browserButton addTarget:self action:@selector(showBrowser:) forControlEvents:UIControlEventTouchUpInside];
    [self.downloadsButton addTarget:self action:@selector(showDownloads:) forControlEvents:UIControlEventTouchUpInside];
    
    YTSettingsManagerLastViewedScene lastViewedScene = [self.settingsManager lastViewedScene];
    switch (lastViewedScene) {
        case YTSettingsManagerLastViewedSceneBrowser:
            [self showBrowser:nil];
            break;
            
        case YTSettingsManagerLastViewedSceneDownloads:
            [self showDownloads:nil];
            break;
            
        default:
            [self showBrowser:nil];
            break;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showBrowser:(id)sender {
    self.browserContainerView.hidden = NO;
    self.downloadsContainerView.hidden = YES;
    self.tabsVisualEffectView.hidden = YES;
    [self.settingsManager setLastViewedScene:YTSettingsManagerLastViewedSceneBrowser];
}

- (void)showDownloads:(id)sender {
    self.browserContainerView.hidden = YES;
    self.downloadsContainerView.hidden = NO;
    self.tabsVisualEffectView.hidden = NO;
    [self.settingsManager setLastViewedScene:YTSettingsManagerLastViewedSceneDownloads];
    [self.downloadsViewController populateSections];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"Embed_DownloadsViewController"]) {
        self.downloadsViewController = segue.destinationViewController;
    }
}

- (void)dealloc {
    [self unsubscribeFromNotifications];
}

- (void)subscribeForNotifications {
    YTRootViewController __weak *welf = self;
    [[NSNotificationCenter defaultCenter] addObserverForName:YTNotificaionsOpenInBrowser object:nil queue:nil usingBlock:^(NSNotification *note) {
        [welf showBrowser:note];
    }];
}

- (void)unsubscribeFromNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:YTNotificaionsOpenInBrowser object:nil];
}
@end
