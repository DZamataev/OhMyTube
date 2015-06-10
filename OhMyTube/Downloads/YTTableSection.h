//
//  YTTableSection.h
//  OhMyTube
//
//  Created by Denis Zamataev on 27/05/15.
//  Copyright (c) 2015 Mysterious Organization. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YTTableSection : NSObject
@property (readonly, nonatomic) NSMutableArray *items;
@property (nonatomic, strong) NSString *title;
@end
