//
//  YTDownloadsCollectionViewCell.m
//  OhMyTube
//
//  Created by Denis Zamataev on 27/05/15.
//  Copyright (c) 2015 Mysterious Organization. All rights reserved.
//

#import "YTDownloadsTableViewCell.h"
@interface YTDownloadsTableViewCell ()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *durationLabel;
@property (weak, nonatomic) IBOutlet UIImageView *thumbnailImageView;
@property (weak, nonatomic) IBOutlet M13ProgressViewBar *progressBar;
@end

@implementation YTDownloadsTableViewCell
- (void)prepareForReuse {
    [self.KVOController unobserveAll];
    self.progressBar.alpha = 1.0f;
    [self.progressBar setProgress:0.0f animated:NO];
}

- (void)configureWithItem:(YTDownloadsItem *)item {
    [self.progressBar setShowPercentage:NO];
    
    self.titleLabel.text = item.title;
    self.durationLabel.text = item.duration;
    [self.thumbnailImageView sd_setImageWithURL:item.thumbnailURL];
    
    [self.KVOController observe:item keyPath:@"downloadProgress"
                        options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew
                          block:^(YTDownloadsTableViewCell *cell, YTDownloadsItem *item, NSDictionary *change) {
                              NSNumber *downloadProgress = change[NSKeyValueChangeNewKey];
                              if (downloadProgress != nil && [downloadProgress respondsToSelector:@selector(floatValue)]) {
                                  if (downloadProgress.floatValue < 1.0f) {
                                      [cell.progressBar setProgress:downloadProgress.floatValue animated:YES];
                                  }
                                  else {
                                      [UIView animateWithDuration:0.3f animations:^{
                                          cell.progressBar.alpha = 0.0f;
                                      }];
                                  }
                              }
                          }];
}
@end
