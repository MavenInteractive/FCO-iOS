//
//  FCOAlertViewController.m
//  fco
//
//  Created by delmarz on 6/13/15.
//  Copyright (c) 2015 Kryptonite. All rights reserved.
//

#import "FCOAlertViewController.h"
#import "FCOHTTPClient.h"
#import <SCLAlertView-Objective-C/SCLAlertView.h>

@interface FCOAlertViewController ()

@end

@implementation FCOAlertViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
 

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private Methods

- (void)promptCustomAlertView:(NSString *)title withSub:(NSString *)subtitle withClose:(NSString *)close {
    SCLAlertView *alert = [[SCLAlertView alloc] init];
    UIColor *color = [UIColor colorWithRed:103.0/255.0 green:10.0/255.0 blue:5.0/255.0 alpha:1.0];
    [alert addButton:@"OK" actionBlock:^(void) {
        [self.delegate didCancel];
        [self dismissViewControllerAnimated:YES completion:nil];
        NSLog(@"done");
    }];
    
    [alert showCustom:self image:[UIImage imageNamed:@"icon_punch"] color:color title:title     subTitle:subtitle closeButtonTitle:close duration:0.0f];
    [alert setTitleFontFamily:@"FederalEscort" withSize:24];
    [alert setBodyTextFontFamily:@"HelveticaNeue" withSize:13];
    alert.backgroundViewColor = [UIColor whiteColor];
    alert.backgroundType = Blur;
}

- (void)requestForgotPassword {
    NSDictionary *params = @{@"email": self.forgotEmailTextField.text
                            };
    FCOHTTPClient *fcoHttpClient = [FCOHTTPClient sharedInstance];
    [fcoHttpClient POST:@"auth/forgot" parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
//        SCLAlertView *alert = [[SCLAlertView alloc] init];
//        [alert showWaiting:self title:@"Loading" subTitle:@"Please Wait..." closeButtonTitle:nil duration:2];
//        [alert setTitleFontFamily:@"FederalEscort" withSize:24];
//        [alert setBodyTextFontFamily:@"HelveticaNeue" withSize:13];
//        alert.backgroundType = Transparent;
    [self promptCustomAlertView:@"SUCCESS!!!" withSub:@"Successfully sent request to email" withClose:nil];

    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSString* ErrorResponse = [[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding];
        NSLog(@"%@",ErrorResponse);
    
        if ([ErrorResponse containsString:@"failed_to_send_email"]) {
        [self promptCustomAlertView:@"ERROR!!!" withSub:@"Failed to send request to email, please try again later" withClose:nil];
        } else if ([ErrorResponse containsString:@"email_not_found"]) {
        [self promptCustomAlertView:@"ERROR!!!" withSub:@"Email not found" withClose:nil];
        }
    }];
}

- (IBAction)closeButtonPressed:(UIButton *)sender {
    [self.delegate didCancel];
}

- (IBAction)sendButtonPressed:(UIButton *)sender {
    [self requestForgotPassword];
    //[self.delegate didCancel];
}
@end
