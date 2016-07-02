//
//  FCOProfileChangePasswordViewController.m
//  fco
//
//  Created by Kryptonite on 9/18/15.
//  Copyright (c) 2015 Kryptonite. All rights reserved.
//

#import "FCOProfileChangePasswordViewController.h"
#import <SCLAlertView-Objective-C/SCLAlertView.h>
#import "FCOSessionModel.h"
#import "FCOHTTPClient.h"

@interface FCOProfileChangePasswordViewController ()

@end

@implementation FCOProfileChangePasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self passwordInfo];
    
  
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if ([self.oldPasswordTextFied.text length] >0 && [self.NwPasswordTextField.text length] >0 && [self.confirmPasswordTextField.text length] >0) {
        [self.delegate didUpdate];
    }
}


- (IBAction)cancelButtonPressed:(UIButton *)sender {
    [self.delegate didCancel];
}

- (IBAction)saveButtonPressed:(UIButton *)sender {
    //[self.delegate didCancel];
    [self changePassword];

  
}

#pragma mark - Private Methods

- (void)promptCustomAlertView:(NSString *)title withSub:(NSString *)subtitle withClose:(NSString *)close {
    SCLAlertView *alert = [[SCLAlertView alloc] init];
    UIColor *color = [UIColor colorWithRed:103.0/255.0 green:10.0/255.0 blue:5.0/255.0 alpha:1.0];
    [alert addButton:@"Re-Login" actionBlock:^(void) {
    //[self.delegate didCancel];
    [self performSegueWithIdentifier:@"changePassToLoginSegue" sender:self];
   
    NSLog(@"done");
    }];
    
    [alert showCustom:self image:[UIImage imageNamed:@"icon_punch"] color:color title:title     subTitle:subtitle closeButtonTitle:close duration:0.0f];
    [alert setTitleFontFamily:@"FederalEscort" withSize:24];
    [alert setBodyTextFontFamily:@"HelveticaNeue" withSize:13];
    alert.backgroundViewColor = [UIColor whiteColor];
    alert.backgroundType = Blur;
}

- (void)promptAlertView:(NSString *)title withSub:(NSString *)subtitle withClose:(NSString *)close {
    
    SCLAlertView *alert = [[SCLAlertView alloc] init];
    UIColor *color = [UIColor colorWithRed:103.0/255.0 green:10.0/255.0 blue:5.0/255.0 alpha:1.0];
    
    [alert showCustom:self image:[UIImage imageNamed:@"icon_punch"] color:color title:title     subTitle:subtitle closeButtonTitle:close duration:0.0f];
    [alert setTitleFontFamily:@"FederalEscort" withSize:24];
    [alert setBodyTextFontFamily:@"HelveticaNeue" withSize:13];
    alert.backgroundViewColor = [UIColor whiteColor];
    alert.backgroundType = Blur;
}

- (void)passwordInfo {
    NSLog(@"my username is %@", self.userModel.username);
    self.usernameTextField.text = self.userModel.username;
    self.oldPasswordTextFied.text = nil;
    self.NwPasswordTextField.text = nil;
    self.confirmPasswordTextField.text = nil;
}

- (void)changePassword {
    if ([self.usernameTextField.text length] == 0 || [self.oldPasswordTextFied.text length] == 0 || [self.NwPasswordTextField.text length] == 0 || [self.confirmPasswordTextField.text length] == 0) {
        [self promptAlertView:@"Error!!!" withSub:@"Field must be set!" withClose:@"OK"];
    } else if ([self.NwPasswordTextField.text length] < 8 && [self.confirmPasswordTextField.text length] < 8) {
        [self promptAlertView:@"Error!!!" withSub:@"Password must be at least 8 characters" withClose:@"OK"];
    }
    else if (![self.usernameTextField.text isEqualToString:self.userModel.username]) {
        [self promptAlertView:@"Warning!!!" withSub:@"Your username did not match!" withClose:@"OK"];
    } else {
        FCOSessionModel *session = [FCOSessionModel sharedInstance];
        self.userModel = [session activeUser];
        NSDictionary *params = @{@"username": self.userModel.username,
                                 @"password": self.oldPasswordTextFied.text,
                                 @"new_password": self.NwPasswordTextField.text,
                                 @"confirm_password": self.confirmPasswordTextField.text
                                 };
        
        FCOHTTPClient *fcoHttpClient = [FCOHTTPClient sharedInstance];
        [fcoHttpClient POST:@"auth/reset" parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
            
            SCLAlertView *alert = [[SCLAlertView alloc] init];
            [alert showWaiting:self title:@"Loading" subTitle:@"Please Wait..." closeButtonTitle:nil duration:2];
            [alert setTitleFontFamily:@"FederalEscort" withSize:24];
            [alert setBodyTextFontFamily:@"HelveticaNeue" withSize:13];
            alert.backgroundType = Transparent;
            
            double delayInSeconds = 2;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds *   NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [self promptCustomAlertView:@"Success!!" withSub:@"Change Password Successfully Updated, Please Re-Login" withClose:nil];
            });
            
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            
            NSString* ErrorResponse = [[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding];
            NSLog(@"%@",ErrorResponse);
            
            
            if ([ErrorResponse containsString:@"password_mismatch1"]) {
                [self promptAlertView:@"Error!!!" withSub:@"Your new password mismatch!" withClose:@"OK"];
                NSLog(@"confirm mismatch");
            } else if ([ErrorResponse containsString:@"password_mismatch2"]) {
                [self promptAlertView:@"Error!!!" withSub:@"Your old password mismatch!" withClose:@"OK"];
                NSLog(@"old pass mismatch");
            }
            
            
        }];
    }
}


@end
