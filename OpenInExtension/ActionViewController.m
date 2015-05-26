//
//  ActionViewController.m
//  OpenInExtension
//
//  Created by Denis Zamataev on 26/05/15.
//  Copyright (c) 2015 Mysterious Organization. All rights reserved.
//

#import "ActionViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>

@interface ActionViewController ()

@property(strong,nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation ActionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    BOOL urlFound = NO;
    for (NSExtensionItem *item in self.extensionContext.inputItems) {
        for (NSItemProvider *itemProvider in item.attachments) {
            if ([itemProvider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeURL]) {
                [itemProvider loadItemForTypeIdentifier:(NSString *)kUTTypeURL options:nil completionHandler:^(id<NSSecureCoding> item, NSError *error) {
                    if (item) {
                        NSURL *url = (NSURL*)item;
                        if ([url isKindOfClass:[NSURL class]]) {
                            NSString *decodedUrl = url.absoluteString;
                            decodedUrl = encodeToPercentEscapeString(decodedUrl);
                            
                            NSURL *launchURL = [NSURL URLWithString:[@"ohmytube://x-callback-url/open/?url=" stringByAppendingString:decodedUrl]];
                            
                            UIResponder* responder = self;
                            while ((responder = [responder nextResponder]) != nil)
                            {
                                if([responder respondsToSelector:@selector(openURL:)] == YES)
                                {
                                    ActionViewController __weak *welf = self;
                                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * 2.0), dispatch_get_main_queue(), ^(void){
                                        [welf done];
                                    });
                                    [responder performSelector:@selector(openURL:) withObject:launchURL];
                                }
                            }
                        }
                    }
                }];
                
                urlFound = YES;
                break;
            }
        }
        
        if (urlFound) {
            break;
        }
    }
}

// Encode a string to embed in an URL.
NSString* encodeToPercentEscapeString(NSString *string) {
    return (NSString *)
    CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,
                                                              (CFStringRef) string,
                                                              NULL,
                                                              (CFStringRef) @"!*'();:@&=+$,/?%#[]",
                                                              kCFStringEncodingUTF8));
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)done {
    // Return any edited content to the host app.
    [self.extensionContext completeRequestReturningItems:self.extensionContext.inputItems completionHandler:nil];
}

@end
