//
//  NavigationListItem.h
//  WKWebViewExample
//
//  Created by Denis Zamataev on 20/05/15.
//  Copyright (c) 2015 Denis Zamataev. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YTNavigationListItem : NSObject <NSCoding>
/*! @abstract The URL of the webpage represented by this item.
 */
@property (readonly, copy) NSURL *URL;

/*! @abstract The title of the webpage represented by this item.
 */
@property (readonly, copy) NSString *title;

/*! @abstract The URL of the initial request that created this item.
 */
@property (readonly, copy) NSURL *initialURL;

- (BOOL)isEqualByURLTo:(YTNavigationListItem*)item;
- (instancetype)initWithURL:(NSURL*)URL title:(NSString*)title initialURL:(NSURL*)initialURL;

- (BOOL)isEqualTo:(YTNavigationListItem*)item;
@end
