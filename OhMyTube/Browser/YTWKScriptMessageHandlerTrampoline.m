//
//  SBMessageHandlerTrampoline.m
//  WKWebViewExample
//
//  Created by Denis Zamataev on 22/05/15.
//  Copyright (c) 2015 Denis Zamataev. All rights reserved.
//

#import "YTWKScriptMessageHandlerTrampoline.h"

@implementation YTWKScriptMessageHandlerTrampoline

- (instancetype)initWithDelegate:(id<WKScriptMessageHandler>)delegate {
    self = [super init];
    if (self) {
        self.delegate = delegate;
    }
    return self;
}

- (void)dealloc {
    
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(userContentController:didReceiveScriptMessage:)]) {
        [self.delegate userContentController:userContentController didReceiveScriptMessage:message];
    }
}
@end
