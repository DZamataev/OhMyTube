//
//  NavigationListItem.m
//  WKWebViewExample
//
//  Created by Denis Zamataev on 20/05/15.
//  Copyright (c) 2015 Denis Zamataev. All rights reserved.
//

#import "YTNavigationListItem.h"

@implementation YTNavigationListItem
- (instancetype)initWithURL:(NSURL *)URL title:(NSString *)title initialURL:(NSURL *)initialURL {
    self = [super init];
    if (self) {
        _URL = URL.copy;
        _title = title.copy;
        _initialURL = initialURL.copy;
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_title forKey:@"title"];
    [aCoder encodeObject:_URL forKey:@"URL"];
    [aCoder encodeObject:_initialURL forKey:@"initialURL"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    _title = [aDecoder decodeObjectForKey:@"title"];
    _URL = [aDecoder decodeObjectForKey:@"URL"];
    _initialURL = [aDecoder decodeObjectForKey:@"initialURL"];
    return self;
}

- (BOOL)isEqualByURLTo:(YTNavigationListItem*)item {
    return [_URL.absoluteString isEqualToString:item.URL.absoluteString];
}

- (BOOL)isEqualTo:(YTNavigationListItem *)item {
    BOOL pointerEqual = (self == item);
    if (pointerEqual) {
        return YES;
    }
    
    BOOL fieldsEqual = ([_URL.absoluteString isEqualToString:item.URL.absoluteString] &&
                        [_title isEqualToString:item.title] &&
                        [_initialURL.absoluteString isEqualToString:item.initialURL.absoluteString]);
    if (fieldsEqual) {
        return YES;
    }
    
    return NO;
}
@end
