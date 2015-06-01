//
//  YTDownloadsViewController.m
//  OhMyTube
//
//  Created by Denis Zamataev on 26/05/15.
//  Copyright (c) 2015 Mysterious Organization. All rights reserved.
//

#import "YTDownloadsViewController.h"
#import "YTTableSection.h"

#import "YTDownloadsTableViewCell.h"

#import "YTVideoViewController.h"

#import "YTVideoRepositoryInterface.h"

@interface YTDownloadsViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSMutableArray *sections;

@property (strong, nonatomic) id<YTVideoRepositoryInterface> videoRepository;

@property (strong, nonatomic) YTVideo *selectedItem;

@property (strong, nonatomic) NSDateComponentsFormatter *dateComponentsFormatter;

@property (weak, nonatomic) YTVideoViewController *videoViewController;
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
    self.dateComponentsFormatter = [[NSDateComponentsFormatter alloc] init];
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
    YTTableSection *firstSection = [[YTTableSection alloc] init];
    [self.sections addObject:firstSection];
    
    NSArray *videos = [self.videoRepository downloadingAndDownloadedVideos];
    
    [firstSection.items addObjectsFromArray:videos];
    
    [self.tableView reloadData];
}

- (void)playVideoWithItem:(YTVideo*)item {
    if (item.isDownloaded) {
        self.selectedItem = item;
        [self performSegueWithIdentifier:@"Present_VideoViewController" sender:nil];
    }
}

- (IBAction)unwindFromVideo:(UIStoryboardSegue*)segue {
    
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"Present_VideoViewController"]) {
        self.videoViewController = segue.destinationViewController;
        self.videoViewController.video = self.selectedItem;
    }
}

#pragma mark - Helpers

- (YTTableSection*)sectionAtIndex:(NSInteger)sectionIndex {
    return self.sections[sectionIndex];
}

- (YTVideo*)itemAtIndex:(NSIndexPath *)indexPath {
    YTTableSection *section = [self sectionAtIndex:indexPath.section];
    return section.items[indexPath.item];
}

- (void)removeItemAtIndexPath:(NSIndexPath *)indexPath {
    YTTableSection *section = [self sectionAtIndex:indexPath.section];
    [section.items removeObjectAtIndex:indexPath.row];
}

- (void)configureCell:(YTDownloadsTableViewCell*)cell withItem:(YTVideo*)item {
    [cell.progressBar setShowPercentage:NO];
    
    cell.titleLabel.text = item.title;
    cell.durationLabel.text = [self.dateComponentsFormatter stringFromTimeInterval:item.duration.doubleValue];
    cell.qualityLabel.text = item.qualityString;
    [cell.thumbnailImageView sd_setImageWithURL:item.thumbnailURL];
    if (item.downloadProgress.doubleValue < 1.0) {
        [cell.progressBar setProgress:item.downloadProgress.doubleValue animated:NO];
    }
    else {
        cell.progressBar.alpha = 0.0f;
    }

    [cell.KVOController observe:item keyPath:@"downloadProgress"
                        options:NSKeyValueObservingOptionNew
                          block:^(YTDownloadsTableViewCell *cell, YTVideo *item, NSDictionary *change) {
                              NSNumber *downloadProgress = change[NSKeyValueChangeNewKey];
                              if (downloadProgress != nil && [downloadProgress respondsToSelector:@selector(floatValue)]) {
                                  if (downloadProgress.doubleValue < 1.0) {
                                      [cell.progressBar setProgress:downloadProgress.floatValue animated:YES];
                                  }
                                  else {
                                      [UIView animateWithDuration:0.3f animations:^{
                                          cell.progressBar.alpha = 0.0f;
                                      }];
                                  }
                              }
                          }];
    
    [cell setOnPrepareForReuse:^(YTDownloadsTableViewCell *cell) {
        [cell.KVOController unobserveAll];
        cell.progressBar.alpha = 1.0f;
        [cell.progressBar setProgress:0.0f animated:NO];
    }];
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
    
    [self configureCell:(YTDownloadsTableViewCell*)cell withItem:[self itemAtIndex:indexPath]];
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [self sectionAtIndex:section].title;
}

#pragma mark - <UITableViewDelegate>

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self playVideoWithItem:[self itemAtIndex:indexPath]];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.videoRepository stopDownloadAndDeleteVideo:[self itemAtIndex:indexPath]];
        [self removeItemAtIndexPath:indexPath];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    }
}

@end

























