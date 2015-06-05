//
//  AppDelegate.m
//  OhMyTube
//
//  Created by Denis Zamataev on 26/05/15.
//  Copyright (c) 2015 Mysterious Organization. All rights reserved.
//

#import "AppDelegate.h"
#import <Objection.h>
#import "YTAppModule.h"

#import "YTSettingsManager.h"

@interface AppDelegate ()
@property (strong, nonatomic) YTSettingsManager *settingsManager;
@end

@implementation AppDelegate

objection_requires_sel(@selector(settingsManager))

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    JSObjectionInjector *injector = [JSObjection createInjector:[[YTAppModule alloc] init]];
    [JSObjection setDefaultInjector:injector];
    [[JSObjection defaultInjector] injectDependencies:self];
    
    
    UIImage *outerIcon = [UIImage imageNamed:@"logo_graphics_outer_1024"];
    
    UIImage *icon = [UIImage imageNamed:@"logo_graphics_filled_1024"];
    UIColor *color = [UIColor colorWithRed:55.0/255.0 green:99.0/255.0 blue:225.0/255.0 alpha:1.0];
    
    CGRect bounds = CGRectMake(0, 0, 72, 72);
    CGRect secondBounds = CGRectMake(0, 0, 52, 52);
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = color;
    [self.window makeKeyAndVisible];
    
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:[[NSBundle mainBundle].infoDictionary objectForKey:@"UIMainStoryboardFile"] bundle:[NSBundle mainBundle]];
    UIViewController *initialViewController = [mainStoryboard instantiateInitialViewController];
    self.window.rootViewController = initialViewController;
    
    // logo mask
    CALayer *maskLayer = [[CALayer alloc] init];
    maskLayer.contents = (__bridge id)(outerIcon.CGImage);
    maskLayer.bounds = bounds;
    maskLayer.anchorPoint = CGPointMake(0.5, 0.5);
    maskLayer.position = CGPointMake(CGRectGetWidth(initialViewController.view.frame)/2, CGRectGetHeight(initialViewController.view.frame)/2);
    initialViewController.view.layer.mask = maskLayer;
    
    // logo mask second
    CALayer *maskLayerSecond = [[CALayer alloc] init];
    maskLayerSecond.contents = (__bridge id)(outerIcon.CGImage);
    maskLayerSecond.bounds = bounds;
    maskLayerSecond.position = CGPointMake(0, 0);
    maskLayerSecond.anchorPoint = CGPointMake(0.5, 0.5);
    
    // logo mask background view
    UIView *maskBgView = [[UIView alloc] initWithFrame:initialViewController.view.frame];
    maskBgView.backgroundColor = color;
    [initialViewController.view addSubview:maskBgView];
    [initialViewController.view bringSubviewToFront:maskBgView];
    
    // icon image layer
    CALayer *iconLayer = [[CALayer alloc] init];
    iconLayer.contents = (__bridge id)(icon.CGImage);
    iconLayer.bounds = bounds;
    iconLayer.anchorPoint = CGPointMake(0.5, 0.5);
    iconLayer.position = CGPointMake(CGRectGetWidth(initialViewController.view.frame)/2, CGRectGetHeight(initialViewController.view.frame)/2);
    iconLayer.mask = maskLayerSecond;
    [self.window.layer addSublayer:iconLayer];
    
    // logo mask animation
    CAKeyframeAnimation *transformAnimation = [CAKeyframeAnimation animationWithKeyPath:@"bounds"];
    transformAnimation.delegate = self;
    transformAnimation.duration = 1;
    transformAnimation.beginTime = CACurrentMediaTime() + 1; // 1 second delay
    NSValue *initialBoundsValue = [NSValue valueWithCGRect:maskLayer.bounds];
    NSValue *secondBoundsValue = [NSValue valueWithCGRect:secondBounds];
    NSValue *finalBoundsValue = [NSValue valueWithCGRect:CGRectMake(0, 0, 2000, 2000)];
    
    transformAnimation.values = @[initialBoundsValue, secondBoundsValue, finalBoundsValue];
    transformAnimation.keyTimes = @[@(0), @(0.5), @(1)];
    transformAnimation.timingFunctions = @[[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                           [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    transformAnimation.removedOnCompletion = false;
    transformAnimation.fillMode = kCAFillModeForwards;
    
    [maskLayer addAnimation:transformAnimation forKey:@"maskAnimation"];
    [iconLayer addAnimation:transformAnimation forKey:@"iconAnimation"];
    
    // logo mask background view animation
    [UIView animateWithDuration:0.1 delay:1.35 options:UIViewAnimationOptionCurveEaseIn animations:^{
        maskBgView.alpha = 0.0;
    } completion:^(BOOL finished) {
        [maskBgView removeFromSuperview];
    }];
    
    // root view animation
    [UIView animateWithDuration:0.25 delay:1.3 options:UIViewAnimationOptionTransitionNone animations:^{
        self.window.rootViewController.view.transform = CGAffineTransformMakeScale(1.05, 1.05);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.window.rootViewController.view.transform = CGAffineTransformIdentity;
        } completion:nil];
    }];
    
    /*
     self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
     self.window!.backgroundColor = UIColor(red: 241/255, green: 196/255, blue: 15/255, alpha: 1)
     self.window!.makeKeyAndVisible()
     
     // rootViewController from StoryBoard
     let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
     var navigationController = mainStoryboard.instantiateViewControllerWithIdentifier("navigationController") as! UIViewController
     self.window!.rootViewController = navigationController
     
     // logo mask
     navigationController.view.layer.mask = CALayer()
     navigationController.view.layer.mask.contents = UIImage(named: "logo.png")!.CGImage
     navigationController.view.layer.mask.bounds = CGRect(x: 0, y: 0, width: 60, height: 60)
     navigationController.view.layer.mask.anchorPoint = CGPoint(x: 0.5, y: 0.5)
     navigationController.view.layer.mask.position = CGPoint(x: navigationController.view.frame.width / 2, y: navigationController.view.frame.height / 2)
     
     // logo mask background view
     var maskBgView = UIView(frame: navigationController.view.frame)
     maskBgView.backgroundColor = UIColor.whiteColor()
     navigationController.view.addSubview(maskBgView)
     navigationController.view.bringSubviewToFront(maskBgView)
     
     // logo mask animation
     let transformAnimation = CAKeyframeAnimation(keyPath: "bounds")
     transformAnimation.delegate = self
     transformAnimation.duration = 1
     transformAnimation.beginTime = CACurrentMediaTime() + 1 //add delay of 1 second
     let initalBounds = NSValue(CGRect: navigationController.view.layer.mask.bounds)
     let secondBounds = NSValue(CGRect: CGRect(x: 0, y: 0, width: 50, height: 50))
     let finalBounds = NSValue(CGRect: CGRect(x: 0, y: 0, width: 2000, height: 2000))
     transformAnimation.values = [initalBounds, secondBounds, finalBounds]
     transformAnimation.keyTimes = [0, 0.5, 1]
     transformAnimation.timingFunctions = [CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut), CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)]
     transformAnimation.removedOnCompletion = false
     transformAnimation.fillMode = kCAFillModeForwards
     navigationController.view.layer.mask.addAnimation(transformAnimation, forKey: "maskAnimation")
     
     // logo mask background view animation
     UIView.animateWithDuration(0.1,
     delay: 1.35,
     options: UIViewAnimationOptions.CurveEaseIn,
     animations: {
     maskBgView.alpha = 0.0
     },
     completion: { finished in
     maskBgView.removeFromSuperview()
     })
     */
    
    /*
     
     // root view animation
     UIView.animateWithDuration(0.25,
     delay: 1.3,
     options: UIViewAnimationOptions.TransitionNone,
     animations: {
     self.window!.rootViewController!.view.transform = CGAffineTransformMakeScale(1.05, 1.05)
     },
     completion: { finished in
     UIView.animateWithDuration(0.3,
     delay: 0.0,
     options: UIViewAnimationOptions.CurveEaseInOut,
     animations: {
     self.window!.rootViewController!.view.transform = CGAffineTransformIdentity
     },
     completion: nil
     )
     })
     */
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [self.window setTintColor:[self.settingsManager colorTheme]];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
