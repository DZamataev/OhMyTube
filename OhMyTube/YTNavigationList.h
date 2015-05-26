//
//  NavigationList.h
//  WKWebViewExample
//
//  Created by Denis Zamataev on 20/05/15.
//  Copyright (c) 2015 Denis Zamataev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YTNavigationListItem.h"

@interface YTNavigationList : NSObject <NSCoding>
/*! @abstract The current item.
 */
- (YTNavigationListItem *)currentItem;

/*! @abstract The item immediately preceding the current item, or nil
 if there isn't one.
 */
- (YTNavigationListItem *)backItem;

/*! @abstract The item immediately following the current item, or nil
 if there isn't one.
 */
- (YTNavigationListItem *)forwardItem;

/*! @abstract Returns the item at a specified distance from the current
 item.
 @param index Index of the desired list item relative to the current item:
 0 for the current item, -1 for the immediately preceding item, 1 for the
 immediately following item, and so on.
 @result The item at the specified distance from the current item, or nil
 if the index parameter exceeds the limits of the list.
 */
- (YTNavigationListItem *)itemAtIndex:(NSInteger)index;

/*! @abstract The portion of the list preceding the current item.
 @discussion The items are in the order in which they were originally
 visited.
 */
- (NSArray *)backList;

/*! @abstract The portion of the list following the current item.
 @discussion The items are in the order in which they were originally
 visited.
 */
- (NSArray *)forwardList;

- (void)navigateWithItem:(YTNavigationListItem *)item;

- (BOOL)canGoForward;
- (BOOL)canGoBack;

@end
