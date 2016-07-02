//
//  FCOCustomTimePickerViewController.m
//  fco
//
//  Created by Kryptonite on 7/16/15.
//  Copyright (c) 2015 Kryptonite. All rights reserved.
//

#import "FCOCustomTimePickerViewController.h"

@interface FCOCustomTimePickerViewController ()

@end

@implementation FCOCustomTimePickerViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    self.timePicker.date = [NSDate date];
    
    [self.timePicker setValue:[UIColor whiteColor] forKeyPath:@"textColor"];
    SEL selector = NSSelectorFromString( @"setHighlightsToday:" );
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature :
                                [UIDatePicker
                                 instanceMethodSignatureForSelector:selector]];
    BOOL no = NO;
    [invocation setSelector:selector];
    [invocation setArgument:&no atIndex:2];
    [invocation invokeWithTarget:self.timePicker];
    
    // we need to set the subview dimensions or it will not always render correctly
    // http://stackoverflow.com/questions/1088163
    for (UIView* subview in self.timePicker.subviews) {
        subview.frame = self.timePicker.bounds;
    }
    
}

-(BOOL)shouldAutorotate
{
    return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}


#pragma mark -
#pragma mark Actions


-(IBAction)saveDateEdit:(id)sender {
    if([self.delegate respondsToSelector:@selector(timePickerSetTime:)]) {
        [self.delegate timePickerSetTime:self];
    }
}

-(IBAction)cancelDateEdit:(id)sender {
    if([self.delegate respondsToSelector:@selector(timePickerCancel:)]) {
        [self.delegate timePickerCancel:self];
    } else {
        // just dismiss the view automatically?
    }
}

#pragma mark -
#pragma mark Memory Management

- (void)viewDidUnload
{
    [self setToolbar:nil];
    [super viewDidUnload];
    
    self.timePicker = nil;
    self.delegate = nil;
    
}


@end
