//
//  NavigationList.m
//  WKWebViewExample
//
//  Created by Denis Zamataev on 20/05/15.
//  Copyright (c) 2015 Denis Zamataev. All rights reserved.
//

#import "YTNavigationList.h"

@interface YTNavigationList ()
@property (nonatomic, strong) NSMutableArray *backArray;
@property (nonatomic, strong) NSMutableArray *forwardArray;
@property (nonatomic, strong) YTNavigationListItem *current;
@end

@implementation YTNavigationList

- (instancetype)init {
    self = [super init];
    if (self) {
        self.backArray = [NSMutableArray new];
        self.forwardArray = [NSMutableArray new];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_backArray forKey:@"backArray"];
    [aCoder encodeObject:_forwardArray forKey:@"forwardArray"];
    [aCoder encodeObject:_current forKey:@"current"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    _backArray = [aDecoder decodeObjectForKey:@"backArray"];
    _forwardArray = [aDecoder decodeObjectForKey:@"forwardArray"];
    _current = [aDecoder decodeObjectForKey:@"current"];
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"{backArray:%@, current: %@, forwardArray: %@}", self.backArray, self.current, self.forwardArray];
}

- (YTNavigationListItem *)currentItem {
    return self.current;
}

- (YTNavigationListItem *)backItem {
    if (self.backArray.count > 0) {
        return self.backArray.lastObject;
    }
    else {
        return nil;
    }
}

- (YTNavigationListItem *)forwardItem {
    if (self.forwardArray.count > 0) {
        return self.forwardArray.lastObject;
    }
    else {
        return nil;
    }
}

- (YTNavigationListItem *)itemAtIndex:(NSInteger)index {
    YTNavigationListItem *item;
    if (index == 0) { // [==0==]
        item = self.currentItem;
    }
    else if (index > 0) { // [==0==1==2==3==4==]
        NSInteger indexInForwardArray = self.forwardArray.count - index;
        item = self.forwardArray[indexInForwardArray];
    }
    else if (index < 0) { // [==-4==-3==-2==-1==0]
        NSInteger indexInBackArray = labs(index) - 1;
        item = self.backArray[indexInBackArray];
    }
    return item;
}

- (BOOL)canGoForward {
    return (self.forwardArray.count > 0);
}

- (void)navigateWithItem:(YTNavigationListItem *)item {
    NSAssert(item != nil, @"Cannot navigate to nil item");
    
    if (self.current == nil) {
        self.current = item;
    }
    else {
        BOOL goToTheSamePage = NO;
        BOOL goJustBack = NO;
        BOOL goJustForward = NO;
        BOOL goForwardToAnotherBranch = NO;
        BOOL goForwardThroughTheList = NO;
        
        BOOL decided = NO;
        
        if (!decided) {
            if ([item isEqualByURLTo:self.current]) {
                decided = YES;
                goToTheSamePage = YES;
                // do nothing
            }
        }
        
        if (!decided) {
            YTNavigationListItem *backItem = [self backItem];
            if (backItem != nil && [backItem isEqualByURLTo:item]) {
                decided = YES;
                goJustBack = YES;
                [self.forwardArray addObject:self.current];
                self.current = backItem;
                [self.backArray removeLastObject];
            }
        }
        
        if (!decided) {
            YTNavigationListItem *forwardItem = [self forwardItem];
            if (forwardItem != nil) {
                if ([forwardItem isEqualByURLTo:item]) {
                    decided = YES;
                    goForwardThroughTheList = YES;
                    [self.backArray addObject:self.current];
                    self.current = forwardItem;
                    [self.forwardArray removeLastObject];
                }
                else {
                    decided = YES;
                    goForwardToAnotherBranch = YES;
                    [self.backArray addObject:self.current];
                    self.current = item;
                    [self.forwardArray removeAllObjects];
                }
            }
        }
        
        if (!decided) {
            decided = YES;
            goJustForward = YES;
            [self.backArray addObject:self.current];
            self.current = item;
        }
    }
}

- (BOOL)canGoBack {
    return (self.backArray.count > 0);
}

- (void)goBack {
    NSAssert(self.backArray.count > 0, @"Cannot go back because there is no records in backList");
    [self.forwardArray addObject:self.current];
    self.current = [self.backArray lastObject];
    [self.backArray removeLastObject];
}

- (NSArray *)forwardList {
    return [NSArray arrayWithArray:self.forwardArray];
}

- (NSArray *)backList {
    return [NSArray arrayWithArray:self.backArray];
}

@end
