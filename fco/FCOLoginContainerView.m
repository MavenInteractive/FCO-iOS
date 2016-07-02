//
//  FCOLoginContainerView.m
//  fco
//
//  Created by delmarz on 6/14/15.
//  Copyright (c) 2015 Kryptonite. All rights reserved.
//

#import "FCOLoginContainerView.h"
#import "XXNibBridge.h"
#import "FCOAlertViewController.h"

@interface FCOLoginContainerView () <XXNibBridge>

@end
@implementation FCOLoginContainerView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (IBAction)forgotButtonPressed:(UIButton *)sender {
    UIViewController *obj=[[UIViewController alloc]init];
     UINavigationController *nav=[[UINavigationController alloc]initWithRootViewController:obj];
     [[[UIApplication sharedApplication]keyWindow].rootViewController presentViewController:nav animated:YES completion:NULL];
    NSLog(@"test");
    
}



@end
