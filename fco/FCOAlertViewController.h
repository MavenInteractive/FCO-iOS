//
//  FCOAlertViewController.h
//  fco
//
//  Created by delmarz on 6/13/15.
//  Copyright (c) 2015 Kryptonite. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FCOAlertViewControllerDelegate <NSObject>

- (void)didCancel;

@end
@interface FCOAlertViewController : UIViewController
@property (weak, nonatomic) id <FCOAlertViewControllerDelegate> delegate;

@property (strong, nonatomic) IBOutlet UITextField *forgotEmailTextField;
@property (strong, nonatomic) IBOutlet UIView *alertView;


- (IBAction)closeButtonPressed:(UIButton *)sender;
- (IBAction)sendButtonPressed:(UIButton *)sender;

@end
