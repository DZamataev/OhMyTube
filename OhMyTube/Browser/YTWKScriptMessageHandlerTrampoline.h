//
//  SBMessageHandlerTrampoline.h
//  WKWebViewExample
//
//  Created by Denis Zamataev on 22/05/15.
//  Copyright (c) 2015 Denis Zamataev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

@interface YTWKScriptMessageHandlerTrampoline : NSObject <WKScriptMessageHandler>
- (instancetype)initWithDelegate:(id<WKScriptMessageHandler>)delegate;
@property (nonatomic, weak) id<WKScriptMessageHandler> delegate;
@end
