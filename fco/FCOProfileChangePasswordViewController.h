//
//  FCOProfileChangePasswordViewController.h
//  fco
//
//  Created by Kryptonite on 9/18/15.
//  Copyright (c) 2015 Kryptonite. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FCOUserModel.h"

@protocol FCOProfileChangePasswordViewControllerDelegage <NSObject>

- (void)didCancel;
- (void)didUpdate;

@end


@interface FCOProfileChangePasswordViewController : UIViewController
@property (weak, nonatomic) id <FCOProfileChangePasswordViewControllerDelegage> delegate;

@property (strong, nonatomic) IBOutlet UITextField *usernameTextField;
@property (strong, nonatomic) IBOutlet UITextField *oldPasswordTextFied;
@property (strong, nonatomic) IBOutlet UITextField *NwPasswordTextField;
@property (strong, nonatomic) IBOutlet UITextField *confirmPasswordTextField;
@property (strong, nonatomic) FCOUserModel *userModel;

- (IBAction)cancelButtonPressed:(UIButton *)sender;
- (IBAction)saveButtonPressed:(UIButton *)sender;


@end
