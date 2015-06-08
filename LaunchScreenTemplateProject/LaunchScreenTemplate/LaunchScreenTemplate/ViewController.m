//
//  ViewController.m
//  LaunchScreenTemplate
//
//  Created by Denis Zamataev on 08/06/15.
//  Copyright (c) 2015 Mysterious Organization. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    
    UIColor *color1 = [UIColor colorWithRed:55.0/255.0 green:99.0/255.0 blue:225.0/255.0 alpha:1.0];
    UIColor *color2 = [UIColor colorWithRed:71.0/255.0 green:220.0/255.0 blue:201.0/255.0 alpha:1.0];
    
    CAGradientLayer *gradient1 = [CAGradientLayer layer];
    gradient1.colors = [NSArray arrayWithObjects:(id)[color1 CGColor], (id)[color2 CGColor], nil];
    gradient1.frame = self.view.layer.bounds;
    [self.view.layer insertSublayer:gradient1 atIndex:0];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
