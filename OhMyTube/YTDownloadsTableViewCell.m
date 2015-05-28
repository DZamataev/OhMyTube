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
- (void)configureWithItem:(YTDownloadsItem *)item {
    self.titleLabel.text = item.title;
    self.durationLabel.text = item.duration;
    [self.thumbnailImageView sd_setImageWithURL:item.thumbnailURL];
}
@end
