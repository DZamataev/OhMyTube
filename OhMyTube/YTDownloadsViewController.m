//
//  YTDownloadsViewController.m
//  OhMyTube
//
//  Created by Denis Zamataev on 26/05/15.
//  Copyright (c) 2015 Mysterious Organization. All rights reserved.
//

#import "YTDownloadsViewController.h"
#import "YTDownloadsSection.h"
#import "YTDownloadsItem.h"

#import "YTDownloadsTableViewCell.h"

#import "YTVideoRepositoryInterface.h"

@interface YTDownloadsViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSMutableArray *sections;

@property (strong, nonatomic) id<YTVideoRepositoryInterface> videoRepository;
@end

@implementation YTDownloadsViewController

objection_requires_sel(@selector(videoRepository))

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
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.estimatedRowHeight = 120;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    [self.tableView reloadData];
}

#pragma mark - Actions

- (void)populateSections {
    self.sections = [NSMutableArray new];
    YTDownloadsSection *firstSection = [[YTDownloadsSection alloc] init];
    [self.sections addObject:firstSection];
    
    NSDateComponentsFormatter *dateComponentsFormatter = [[NSDateComponentsFormatter alloc] init];
    
    NSArray *videos = [self.videoRepository videos];
    for (YTVideoRecord *video in videos) {
        YTDownloadsItem *item = [YTDownloadsItem new];
        item.title = video.youTubeVideo.title;
        item.duration = [dateComponentsFormatter stringFromTimeInterval:video.youTubeVideo.duration];
        item.thumbnailURL = video.youTubeVideo.mediumThumbnailURL;
        item.userInfo = video;
        [firstSection.items addObject:item];
    }
    
    [self.tableView reloadData];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

#pragma mark - Helpers

- (YTDownloadsSection*)sectionAtIndex:(NSInteger)sectionIndex {
    return self.sections[sectionIndex];
}

- (YTDownloadsItem*)itemAtIndex:(NSIndexPath*)indexPath {
    YTDownloadsSection *section = [self sectionAtIndex:indexPath.section];
    return section.items[indexPath.item];
}

#pragma mark - <UITableViewDataSource>

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self sectionAtIndex:section].items.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sections.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *reuseIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    YTDownloadsTableViewCell *downloadsCell = (YTDownloadsTableViewCell*)cell;
    [downloadsCell configureWithItem:[self itemAtIndex:indexPath]];
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [self sectionAtIndex:section].title;
}

#pragma mark - <UITableViewDelegate>


@end

























