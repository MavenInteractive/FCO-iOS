//
//  FCOProfileEditViewController.h
//  fco
//
//  Created by Kryptonite on 6/29/15.
//  Copyright (c) 2015 Kryptonite. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FCOUserModel.h"

@protocol FCOProfileEditViewControllerDelegate <NSObject>
-(void)didCancel;

@end

@interface FCOProfileEditViewController : UIViewController
@property (weak, nonatomic) id <FCOProfileEditViewControllerDelegate> delegate;
@property (strong, nonatomic) IBOutlet UITextField *firstNameTextField;
@property (strong, nonatomic) IBOutlet UITextField *lastNameTextField;
@property (strong, nonatomic) IBOutlet UITextField *roleTextField;
@property (strong, nonatomic) IBOutlet UITextField *sportsTypeTextField;
@property (strong, nonatomic) IBOutlet UITextField *genderTextField;
@property (strong, nonatomic) IBOutlet UITextField *birthDateTextField;
@property (strong, nonatomic) IBOutlet UITextField *emailTextField;
@property (strong, nonatomic) IBOutlet UIImageView *userImageView;
@property (strong, nonatomic) IBOutlet UIButton *uploadPhotoButton;

@property (strong, nonatomic) FCOUserModel *currentUser;
- (IBAction)cancelButtonPressed:(UIButton *)sender;
- (IBAction)saveButtonPressed:(UIButton *)sender;
- (IBAction)uploadPhoto:(UIButton *)sender;
- (IBAction)changePassButtonPressed:(UIButton *)sender;


@end
