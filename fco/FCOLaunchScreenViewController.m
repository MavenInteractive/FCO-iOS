//
//  FCOLaunchScreenViewController.m
//  fco
//
//  Created by Kryptonite on 6/9/15.
//  Copyright (c) 2015 Kryptonite. All rights reserved.
//

#import "FCOLaunchScreenViewController.h"
#import "FCOLoadingView.h"

@interface FCOLaunchScreenViewController ()

@end

@implementation FCOLaunchScreenViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    FCOLoadingView *loadingView = [[FCOLoadingView alloc]init];
    [loadingView setCenter:CGPointMake(self.view.center.x, self.view.center.y + 130)];
    [self.view addSubview:loadingView];
    [loadingView startAnimating];
    
    //set the delay interval when animating
    double delayInSeconds = 2.5; //0.1;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds *   NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self performSegueWithIdentifier:@"splashToMainSegue" sender:self];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
