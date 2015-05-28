//
//  YTDownloadsCollectionViewCell.h
//  OhMyTube
//
//  Created by Denis Zamataev on 27/05/15.
//  Copyright (c) 2015 Mysterious Organization. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <M13ProgressSuite/M13ProgressViewBar.h>
#import <SDWebImage/UIImageView+WebCache.h>

#import "YTDownloadsItem.h"

@interface YTDownloadsTableViewCell : UITableViewCell
- (void)configureWithItem:(YTDownloadsItem*)item;
@end
