//
//  YTLaunchAnimationHelper.m
//  OhMyTube
//
//  Created by Denis Zamataev on 08/06/15.
//  Copyright (c) 2015 Mysterious Organization. All rights reserved.
//

#import "YTLaunchAnimationHelper.h"

@implementation YTLaunchAnimationHelper
+ (void)setupAndStartAnimationInWindow:(UIWindow*)window withInitialViewController:(UIViewController*)initialViewController completion:(void (^)())completion {
    UIImage *maskImage = [UIImage imageNamed:@"logo_graphics_window_1024"];
    
    UIImage *icon = [UIImage imageNamed:@"logo_graphics_1024"];
    UIColor *color1 = [UIColor colorWithRed:55.0/255.0 green:99.0/255.0 blue:225.0/255.0 alpha:1.0];
    UIColor *color2 = [UIColor colorWithRed:71.0/255.0 green:220.0/255.0 blue:201.0/255.0 alpha:1.0];
    
    CGRect bounds = CGRectMake(0, 0, 140, 140);
    CGRect secondBounds = CGRectMake(0, 0, 120, 120);
    
    CGFloat maxScreenSideLength = MAX(CGRectGetWidth([[UIScreen mainScreen] bounds]), CGRectGetHeight([[UIScreen mainScreen] bounds]));
    maxScreenSideLength *= 6;
    CGRect finalBounds = CGRectMake(0, 0, maxScreenSideLength, maxScreenSideLength);
    
    
    // gradient into window
    CAGradientLayer *gradient1 = [CAGradientLayer layer];
    gradient1.colors = [NSArray arrayWithObjects:(id)[color1 CGColor], (id)[color2 CGColor], nil];
    gradient1.frame = window.layer.bounds;
    [window.layer insertSublayer:gradient1 atIndex:0];
    
    // mask layer
    CALayer *maskLayer = [[CALayer alloc] init];
    maskLayer.contents = (__bridge id)(maskImage.CGImage);
    maskLayer.bounds = bounds;
    maskLayer.anchorPoint = CGPointMake(0.5, 0.5);
    maskLayer.position = CGPointMake(CGRectGetWidth(initialViewController.view.frame)/2, CGRectGetHeight(initialViewController.view.frame)/2);
    initialViewController.view.layer.mask = maskLayer;
    
    // mask background view
    UIView *maskBgView = [[UIView alloc] initWithFrame:initialViewController.view.frame];
    [initialViewController.view addSubview:maskBgView];
    [initialViewController.view bringSubviewToFront:maskBgView];
    
    // gradient into mask background view
    CAGradientLayer *gradient2 = [CAGradientLayer layer];
    gradient2.colors = [NSArray arrayWithObjects:(id)[color1 CGColor], (id)[color2 CGColor], nil];
    gradient2.frame = maskBgView.bounds;
    [maskBgView.layer insertSublayer:gradient2 atIndex:0];
    
    // icon image layer
    CALayer *iconLayer = [[CALayer alloc] init];
    iconLayer.contents = (__bridge id)(icon.CGImage);
    iconLayer.bounds = bounds;
    iconLayer.anchorPoint = CGPointMake(0.5, 0.5);
    iconLayer.position = CGPointMake(CGRectGetWidth(initialViewController.view.frame)/2, CGRectGetHeight(initialViewController.view.frame)/2);
    [window.layer addSublayer:iconLayer];
    
    // logo mask animation
    [CATransaction begin];
    [CATransaction setCompletionBlock:^{
        [maskLayer removeFromSuperlayer];
        [iconLayer removeFromSuperlayer];
        [gradient1 removeFromSuperlayer];
        [gradient2 removeFromSuperlayer];
        if (completion) {
            completion();
        }
    }];
    CAKeyframeAnimation *transformAnimation = [CAKeyframeAnimation animationWithKeyPath:@"bounds"];
    transformAnimation.delegate = self;
    transformAnimation.duration = 1;
    transformAnimation.beginTime = CACurrentMediaTime() + 1; // 1 second delay
    NSValue *initialBoundsValue = [NSValue valueWithCGRect:maskLayer.bounds];
    NSValue *secondBoundsValue = [NSValue valueWithCGRect:secondBounds];
    NSValue *finalBoundsValue = [NSValue valueWithCGRect:finalBounds];
    
    transformAnimation.values = @[initialBoundsValue, secondBoundsValue, finalBoundsValue];
    transformAnimation.keyTimes = @[@(0), @(0.5), @(1)];
    transformAnimation.timingFunctions = @[[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                           [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    transformAnimation.removedOnCompletion = false;
    transformAnimation.fillMode = kCAFillModeForwards;
    [maskLayer addAnimation:transformAnimation forKey:@"boundsAnimation"];
    [iconLayer addAnimation:transformAnimation forKey:@"boundsAnimation"];
    [CATransaction commit];
    
    // logo mask background view animation
    [UIView animateWithDuration:0.50 delay:0.95 options:UIViewAnimationOptionCurveEaseIn animations:^{
        maskBgView.alpha = 0.0;
    } completion:^(BOOL finished) {
        [maskBgView removeFromSuperview];
    }];
    
    // root view animation
    initialViewController.view.transform = CGAffineTransformMakeScale(1.10, 1.10);
    [UIView animateWithDuration:0.45 delay:1.35 options:UIViewAnimationOptionTransitionNone animations:^{
        initialViewController.view.transform = CGAffineTransformIdentity;
    } completion: nil];

}
@end
