//
//  YTDownloadsCollectionViewCell.m
//  OhMyTube
//
//  Created by Denis Zamataev on 27/05/15.
//  Copyright (c) 2015 Mysterious Organization. All rights reserved.
//

#import "YTDownloadsTableViewCell.h"
@interface YTDownloadsTableViewCell ()
@end

@implementation YTDownloadsTableViewCell
- (void)prepareForReuse {
    if (self.onPrepareForReuse) {
        self.onPrepareForReuse(self);
    }
}
@end
