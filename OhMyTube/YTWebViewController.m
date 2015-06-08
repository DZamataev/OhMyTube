//
//  WebViewController.m
//  WKWebViewExample
//
//  Created by Denis Zamataev on 18/05/15.
//  Copyright (c) 2015 Denis Zamataev. All rights reserved.
//

#import "YTWebViewController.h"
#import "YTWKScriptMessageHandlerTrampoline.h"

//#define DEBUG_YTWebViewController
#ifdef DEBUG
#   ifdef DEBUG_YTWebViewController
#     define DLog(fmt, ...) NSLog((@"%s [Line %d] [URL %@]=>\n        " fmt), __PRETTY_FUNCTION__, __LINE__, self.webView.URL.absoluteString, ##__VA_ARGS__);
#   else
#     define DLog(...)
#   endif
#else
#   define DLog(...)
#endif

static NSString * const kPushStateChangedScriptMessageName = @"PushStateChanged";
static NSString * const kTitleChangedScriptMessageName = @"TitleChanged";

@interface YTWebViewController () <WKUIDelegate, WKNavigationDelegate, WKScriptMessageHandler, UIAlertViewDelegate, UITextFieldDelegate>
{
}
@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) UIAlertView *credentialsAlertView;
@property (nonatomic, strong) NSURL *lastProvisionalNavigationURL;
@property (nonatomic, copy) void (^authChallengeCompletionHandler)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential);
@end

@implementation YTWebViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [self initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self commonInit];
    }
    return self;
}

-(void)awakeFromNib {
    [super awakeFromNib];
    [self commonInit];
}

- (void)commonInit {
    [[JSObjection defaultInjector] injectDependencies:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.webView = [[WKWebView alloc] initWithFrame:self.view.frame configuration:[self webViewConfiguration]];
    self.webView.translatesAutoresizingMaskIntoConstraints = NO;
    self.webView.navigationDelegate = self;
    self.webView.UIDelegate = self;
    self.webView.allowsBackForwardNavigationGestures = YES;
    self.view.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.webView];
    NSDictionary *viewsDictionary = @{@"webView":self.webView};
    //Create the constraints using the visual language format
    NSMutableArray *constraintsArray = [NSMutableArray new];
    [constraintsArray addObjectsFromArray:[NSLayoutConstraint
                                           constraintsWithVisualFormat:@"H:|[webView]|"
                                           options:0 metrics:nil
                                           views:viewsDictionary]];
    [constraintsArray addObjectsFromArray:[NSLayoutConstraint
                                           constraintsWithVisualFormat:@"V:|[webView]|"
                                           options:0 metrics:nil
                                           views:viewsDictionary]];
    [self.view addConstraints:constraintsArray];
    
    // Update controls
    [self updateNavigationControls];
    
    // Observation
    [self.webView addObserver:self forKeyPath:@"URL" options:NSKeyValueObservingOptionNew context:nil];
    [self.webView addObserver:self forKeyPath:@"estimatedProgress" options: NSKeyValueObservingOptionNew context:nil];
    [self.webView addObserver:self forKeyPath:@"title" options: NSKeyValueObservingOptionNew context:nil];
    [self.webView addObserver:self forKeyPath:@"loading" options: NSKeyValueObservingOptionNew context:nil];
    [self.webView addObserver:self forKeyPath:@"canGoBack" options: NSKeyValueObservingOptionNew context:nil];
    [self.webView addObserver:self forKeyPath:@"canGoForward" options: NSKeyValueObservingOptionNew context:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [self.webView stopLoading];
    [self.webView setNavigationDelegate:nil];
    [self.webView setUIDelegate:nil];
    [self.webView removeObserver:self forKeyPath:@"URL"];
    [self.webView removeObserver:self forKeyPath:@"estimatedProgress"];
    [self.webView removeObserver:self forKeyPath:@"title"];
    [self.webView removeObserver:self forKeyPath:@"loading"];
    [self.webView removeObserver:self forKeyPath:@"canGoBack"];
    [self.webView removeObserver:self forKeyPath:@"canGoForward"];
    
    [self.webView.configuration.userContentController removeScriptMessageHandlerForName:kTitleChangedScriptMessageName];
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"URL"] && object == self.webView) {
        [self.delegate webViewController:self didUpdateURL:self.webView.URL];
    }
    else if ([keyPath isEqualToString:@"estimatedProgress"] && object == self.webView) {
        [self.delegate webViewController:self didUpdateEstimatedProgress:self.webView.estimatedProgress];
    }
    else if ([keyPath isEqualToString:@"title"] && object == self.webView) {
        [self.delegate webViewController:self didUpdateTitle:self.webView.title];
    }
    else if ([keyPath isEqualToString:@"loading"] && object == self.webView) {
        [self.delegate webViewController:self didUpdateLoading:self.webView.loading];
    }
    else if ([keyPath isEqualToString:@"canGoBack"] && object == self.webView) {
        [self updateNavigationControls];

    }
    else if ([keyPath isEqualToString:@"canGoForward"] && object == self.webView) {
        [self updateNavigationControls];

    }
    else {
        // Make sure to call the superclass's implementation in the else block in case it is also implementing KVO
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - Properties

- (WKWebViewConfiguration*)webViewConfiguration {
    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
    
    NSString *ytHistoryJS = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"__yt_history" ofType:@"js"] encoding:NSUTF8StringEncoding error:nil];
    [configuration.userContentController addScriptMessageHandler:[[YTWKScriptMessageHandlerTrampoline alloc] initWithDelegate:self]
                                                            name:kPushStateChangedScriptMessageName];
    WKUserScript *ytHistoryUserScript = [[WKUserScript alloc] initWithSource:ytHistoryJS
                                                      injectionTime:WKUserScriptInjectionTimeAtDocumentEnd
                                                   forMainFrameOnly:YES];
    [configuration.userContentController addUserScript:ytHistoryUserScript];
    
    // inject script that will post document title updates
    [configuration.userContentController addScriptMessageHandler:[[YTWKScriptMessageHandlerTrampoline alloc] initWithDelegate:self]
                                                            name:kTitleChangedScriptMessageName];
    NSString *scriptSource = [NSString stringWithFormat:@"webkit.messageHandlers.%@.postMessage(document.title);", kTitleChangedScriptMessageName];
    WKUserScript *userScript = [[WKUserScript alloc] initWithSource:scriptSource
                                                      injectionTime:WKUserScriptInjectionTimeAtDocumentEnd
                                                   forMainFrameOnly:YES];
    [configuration.userContentController addUserScript:userScript];
    //
    
    return configuration;
}

#pragma mark - Public Actions

- (void)loadURL:(NSURL *)url {
    [self.webView loadRequest:[[NSURLRequest alloc] initWithURL:url]];
}

- (void)navigateBack {
    [self.webView goBack];
}

- (void)navigateForward {
    [self.webView goForward];
}

- (void)refresh {
    [self.webView reload];
}

- (void)setContentInset:(UIEdgeInsets)inset {
    [self.webView.scrollView setContentInset:inset];
    [self.webView.scrollView setScrollIndicatorInsets:inset];
}

#pragma mark - Actions

- (void)presentCredentialDialogWithCompletionHandlerToInvoke:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential))completionHandler {
    
    if (self.authChallengeCompletionHandler) {
        self.authChallengeCompletionHandler(NSURLSessionAuthChallengeRejectProtectionSpace, nil);
        self.authChallengeCompletionHandler = nil;
    }
    self.authChallengeCompletionHandler = completionHandler;
    
    if (self.credentialsAlertView) {
        [self.credentialsAlertView dismissWithClickedButtonIndex:self.credentialsAlertView.cancelButtonIndex animated:NO];
        self.credentialsAlertView = nil;
    }
    
    self.credentialsAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"Authentication required",
                                                                                          nil,
                                                                                          @"Basic authorization login and password promt title")
                                                       message:@""
                                                      delegate:self
                                             cancelButtonTitle:@"Cancel"
                                             otherButtonTitles:@"OK", nil];
    [self.credentialsAlertView setAlertViewStyle:UIAlertViewStyleLoginAndPasswordInput];
    UITextField *loginTextField   = [self.credentialsAlertView textFieldAtIndex:0];
    loginTextField.placeholder        = @"Username";
    loginTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    loginTextField.delegate           = self;
    
    UITextField *passwordTextField  = [self.credentialsAlertView textFieldAtIndex:1];
    passwordTextField.placeholder        = @"Password";
    passwordTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    passwordTextField.delegate           = self;
    
    [self.credentialsAlertView show];
    
    [loginTextField  performSelector:@selector(becomeFirstResponder)
                          withObject:nil
                          afterDelay:0.1];
}

- (BOOL)isTrustedHost:(NSString*)host {
    return NO;
}

- (void)fetchDocumentTitle:(void (^)(NSString *title))completion {
    [self.webView evaluateJavaScript:@"document.title" completionHandler:^(id response, NSError *error) {
        NSString *title = @"";
        if ([response isKindOfClass:[NSString class]]) {
            title = response;
        }
        completion(title);
    }];
}

- (void)updateNavigationControls {
    [self.delegate webViewController:self didUpdateNavigationControlsWithBackButtonEnabled:self.webView.canGoBack andForwardButtonEnabled:self.webView.canGoForward];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


#pragma mark - <WKNavigationDelegate>

/*! @abstract Decides whether to allow or cancel a navigation.
 @param webView The web view invoking the delegate method.
 @param navigationAction Descriptive information about the action
 triggering the navigation request.
 @param decisionHandler The decision handler to call to allow or cancel the
 navigation. The argument is one of the constants of the enumerated type WKNavigationActionPolicy.
 @discussion If you do not implement this method, the web view will load the request or, if appropriate, forward it to another application.
 */
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    DLog(@"%@", navigationAction);
    decisionHandler(WKNavigationActionPolicyAllow);
}

/*! @abstract Decides whether to allow or cancel a navigation after its
 response is known.
 @param webView The web view invoking the delegate method.
 @param navigationResponse Descriptive information about the navigation
 response.
 @param decisionHandler The decision handler to call to allow or cancel the
 navigation. The argument is one of the constants of the enumerated type WKNavigationResponsePolicy.
 @discussion If you do not implement this method, the web view will allow the response, if the web view can show it.
 */
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
    DLog(@"%@", navigationResponse);
    decisionHandler(WKNavigationResponsePolicyAllow);
}

/*! @abstract Invoked when a main frame navigation starts.
 @param webView The web view invoking the delegate method.
 @param navigation The navigation.
 */
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    DLog(@"%@", navigation);
    self.lastProvisionalNavigationURL = webView.URL.copy;
}

/*! @abstract Invoked when a server redirect is received for the main
 frame.
 @param webView The web view invoking the delegate method.
 @param navigation The navigation.
 */
- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation {
    DLog(@"%@", navigation);
    
}

/*! @abstract Invoked when an error occurs while starting to load data for
 the main frame.
 @param webView The web view invoking the delegate method.
 @param navigation The navigation.
 @param error The error that occurred.
 */
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    DLog(@"%@, %@", navigation, error);
    
}

/*! @abstract Invoked when content starts arriving for the main frame.
 @param webView The web view invoking the delegate method.
 @param navigation The navigation.
 */
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation {
    DLog(@"%@", navigation);
    [self updateNavigationControls];
}

/*! @abstract Invoked when a main frame navigation completes.
 @param webView The web view invoking the delegate method.
 @param navigation The navigation.
 */
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    DLog(@"%@", navigation);
    
}

/*! @abstract Invoked when an error occurs during a committed main frame
 navigation.
 @param webView The web view invoking the delegate method.
 @param navigation The navigation.
 @param error The error that occurred.
 */
- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    DLog(@"%@, %@", navigation, error);
    
}

/*! @abstract Invoked when the web view needs to respond to an authentication challenge.
 @param webView The web view that received the authentication challenge.
 @param challenge The authentication challenge.
 @param completionHandler The completion handler you must invoke to respond to the challenge. The
 disposition argument is one of the constants of the enumerated type
 NSURLSessionAuthChallengeDisposition. When disposition is NSURLSessionAuthChallengeUseCredential,
 the credential argument is the credential to use, or nil to indicate continuing without a
 credential.
 @discussion If you do not implement this method, the web view will respond to the authentication challenge with the NSURLSessionAuthChallengeRejectProtectionSpace disposition.
 */
- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential))completionHandler {
    DLog(@"%@", challenge);
    DLog(@"auth method %@, thread %@", challenge.protectionSpace.authenticationMethod, [NSThread currentThread]);
    if ([challenge previousFailureCount] == 0) {
        if (challenge.proposedCredential && challenge.proposedCredential.hasPassword && ![challenge.proposedCredential.password isEqualToString:@""]) {
            DLog(@"use proposed credential with password");
            completionHandler(NSURLSessionAuthChallengePerformDefaultHandling, challenge.proposedCredential);
        }
        else if (challenge.protectionSpace && challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodHTTPBasic)
        {
            DLog(@"presented basic auth dialog");
            [self presentCredentialDialogWithCompletionHandlerToInvoke:completionHandler];
        }
        else if (challenge.protectionSpace && challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust) {
            DLog(@"SSL host %@", challenge.protectionSpace.host);
            if ([self isTrustedHost:challenge.protectionSpace.host]) {
                DLog(@"... is trusted by user");
                NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"SSL_USER_TRUSTED_REQUEST_PASSED_AUTH"/*SSL_USER_TRUSTED_REQUEST_PASSED_AUTH*/
                                                                    object:nil
                                                                  userInfo:@{@"host": challenge.protectionSpace.host}];
                completionHandler(NSURLSessionAuthChallengeUseCredential, credential);
            }
            else {
                DLog(@"... is handled as default");
                completionHandler(NSURLSessionAuthChallengePerformDefaultHandling, nil);
            }
        }
        else {
            // first try, nothing special
            completionHandler(NSURLSessionAuthChallengePerformDefaultHandling, nil);
        }
        
    }
    else {
        // repeatative try, cancel challenge
        completionHandler(NSURLSessionAuthChallengeCancelAuthenticationChallenge, nil);
    }
    DLog(@"done");
    
    /*
     The following code allows to accept an invalid cert in nightly WebKit build:
    
- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential))completionHandler {
    SecTrustRef serverTrust = challenge.protectionSpace.serverTrust;
    CFDataRef exceptions = SecTrustCopyExceptions(serverTrust);
    SecTrustSetExceptions(serverTrust, exceptions);
    CFRelease(exceptions);
    
    completionHandler(NSURLSessionAuthChallengeUseCredential,
                      [NSURLCredential credentialForTrust:serverTrust]);
}
    */
}


#pragma mark - <WKUIDelegate>

/*! @abstract Creates a new web view.
 @param webView The web view invoking the delegate method.
 @param configuration The configuration to use when creating the new web
 view.
 @param navigationAction The navigation action causing the new web view to
 be created.
 @param windowFeatures Window features requested by the webpage.
 @result A new web view or nil.
 @discussion The web view returned must be created with the specified configuration. WebKit will load the request in the returned web view.
 
 If you do not implement this method, the web view will cancel the navigation.
 */
- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures {
    DLog(@"%@, %@, %@", configuration, navigationAction, windowFeatures);
    if (!navigationAction.targetFrame.isMainFrame) {
        [webView loadRequest:navigationAction.request];
    }
    
    return nil;
}

/*! @abstract Displays a JavaScript alert panel.
 @param webView The web view invoking the delegate method.
 @param message The message to display.
 @param frame Information about the frame whose JavaScript initiated this
 call.
 @param completionHandler The completion handler to call after the alert
 panel has been dismissed.
 @discussion For user security, your app should call attention to the fact
 that a specific website controls the content in this panel. A simple forumla
 for identifying the controlling website is frame.request.URL.host.
 The panel should have a single OK button.
 
 If you do not implement this method, the web view will behave as if the user selected the OK button.
 */
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)())completionHandler {
    DLog(@"%@, %@", message, frame);
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:frame.request.URL.host message:message preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        completionHandler();
    }]];
    [self presentViewController:alertController animated:true completion:nil];
}

/*! @abstract Displays a JavaScript confirm panel.
 @param webView The web view invoking the delegate method.
 @param message The message to display.
 @param frame Information about the frame whose JavaScript initiated this call.
 @param completionHandler The completion handler to call after the confirm
 panel has been dismissed. Pass YES if the user chose OK, NO if the user
 chose Cancel.
 @discussion For user security, your app should call attention to the fact
 that a specific website controls the content in this panel. A simple forumla
 for identifying the controlling website is frame.request.URL.host.
 The panel should have two buttons, such as OK and Cancel.
 
 If you do not implement this method, the web view will behave as if the user selected the Cancel button.
 */
- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL result))completionHandler {
    DLog(@"%@, %@", message, frame);
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:frame.request.URL.host message:message preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        completionHandler(YES);
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        completionHandler(NO);
    }]];
    [self presentViewController:alertController animated:true completion:nil];
}

/*! @abstract Displays a JavaScript text input panel.
 @param webView The web view invoking the delegate method.
 @param message The message to display.
 @param defaultText The initial text to display in the text entry field.
 @param frame Information about the frame whose JavaScript initiated this call.
 @param completionHandler The completion handler to call after the text
 input panel has been dismissed. Pass the entered text if the user chose
 OK, otherwise nil.
 @discussion For user security, your app should call attention to the fact
 that a specific website controls the content in this panel. A simple forumla
 for identifying the controlling website is frame.request.URL.host.
 The panel should have two buttons, such as OK and Cancel, and a field in
 which to enter text.
 
 If you do not implement this method, the web view will behave as if the user selected the Cancel button.
 */
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString *result))completionHandler {
    DLog(@"%@, %@, %@", prompt, defaultText, frame);
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:frame.request.URL.host message:prompt preferredStyle:UIAlertControllerStyleAlert];
    UITextField __block *alertTextField;
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.text = defaultText;
        alertTextField = textField;
    }];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        completionHandler(alertTextField.text);
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        completionHandler(nil);
    }]];
    [self presentViewController:alertController animated:true completion:nil];
}


#pragma mark - <WKScriptMessageHandler>

/*! @abstract Invoked when a script message is received from a webpage.
 @param userContentController The user content controller invoking the
 delegate method.
 @param message The script message received.
 */
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    DLog(@"%@, %@", userContentController, message);
    if ([message.name isEqualToString:kTitleChangedScriptMessageName]) {
        // do nothing because we actually KVO title changes and use this only as an example
    }
    else if ([message.name isEqualToString:kPushStateChangedScriptMessageName]) {
        if ([self.delegate webViewController:self shouldStopLoadingAndGoBackOnStateUpdateWithString:[message.body stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]) {
            [self.webView stopLoading];
            [self.webView goBack];
        }
    }
}


#pragma mark - <UIAlertViewDelegate>

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView == self.credentialsAlertView) {
        UITextField *loginTextField   = [self.credentialsAlertView textFieldAtIndex:0];
        UITextField *passwordTextField  = [self.credentialsAlertView textFieldAtIndex:1];
        NSURLCredential *credential = [NSURLCredential credentialWithUser:loginTextField.text
                                                                 password:passwordTextField.text
                                                              persistence:NSURLCredentialPersistenceForSession];
        if (credential && self.authChallengeCompletionHandler) {
            self.authChallengeCompletionHandler(NSURLSessionAuthChallengeUseCredential, credential);
        }
        else {
            self.authChallengeCompletionHandler(NSURLSessionAuthChallengeCancelAuthenticationChallenge, nil);
        }
        
        self.authChallengeCompletionHandler = nil;
        self.credentialsAlertView = nil;
        
        DLog(@"finished basic auth dialog");
    }
}
@end
