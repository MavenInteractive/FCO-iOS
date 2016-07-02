//
//  FCOLoginViewController.m
//  fco
//
//  Created by kryptonite on 6/1/15.
//  Copyright (c) 2015 Kryptonite. All rights reserved.
//

#import "FCOLoginViewController.h"
#import "FCOAlertViewController.h"
#import "FCOSessionModel.h"
#import <monpromptview.h>
#import "FCOHTTPClient.h"
#import "FCOLoadingView.h"
#import <SCLAlertView-Objective-C/SCLAlertView.h>
#import <IQKeyboardManager/IQKeyboardReturnKeyHandler.h>
#import "FCOMainViewController.h"

@interface FCOLoginViewController ()

@property (strong, nonatomic) IBOutlet UIImageView *keyboardImageView;
@property (strong, nonatomic) IBOutlet UIImageView *bgImageView;
@property (strong, nonatomic) IBOutlet UIButton *closeButton;
@property (strong, nonatomic) IBOutlet UIButton *loginToggleButton;
@property (strong, nonatomic) IBOutlet UIButton *signupToggleButton;
@property (strong, nonatomic) IBOutlet UIView *loginView;
@property (strong, nonatomic) IBOutlet UIView *signupView;
@property (strong, nonatomic) IBOutlet UITextField *usernameTextField;
@property (strong, nonatomic) IBOutlet UITextField *passwordTextField;
@property (strong, nonatomic) IBOutlet UITextField *emailTextField;
@property (strong, nonatomic) IBOutlet UITextField *userTextField;
@property (strong, nonatomic) IBOutlet UITextField *passTextField;
@property (strong, nonatomic) IBOutlet UITextField *confirmPassTextField;
@property (strong, nonatomic) IBOutlet UIButton *loginButton;
@property (strong, nonatomic) IBOutlet UIButton *forgotButton;




@end

@implementation FCOLoginViewController
{
    IQKeyboardReturnKeyHandler *returnKeyHandler;
}

# pragma mark - View Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
     returnKeyHandler = [[IQKeyboardReturnKeyHandler alloc] initWithViewController:self];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardDidShowNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


# pragma mark - IBAction

- (IBAction)closeButtonPressed:(UIButton *)sender {
    [self.delegate loginDidCancel];
}
- (IBAction)loginToggleButtonPressed:(UIButton *)sender {
    [self.signupView setHidden:YES];
    [self.loginView setHidden:NO];
    [self.loginToggleButton setEnabled:NO];
    [self.signupToggleButton setEnabled:YES];
}

- (IBAction)signupToggleButtonPressed:(UIButton *)sender {
    [self.signupView setHidden:NO];
    [self.loginView setHidden:YES];
    [self.loginToggleButton setEnabled:YES];
    [self.signupToggleButton setEnabled:NO];
    [_emailTextField becomeFirstResponder];
}

- (IBAction)loginButtonPressed:(UIButton *)sender {
    [self.view endEditing:YES];
    self.loginButton.enabled = NO;
    [self loginUsername:self.usernameTextField.text withPassword:self.passwordTextField.text];
}

- (IBAction)signupButtonPressed:(UIButton *)sender {
    [self signupWithEmail:self.emailTextField.text withUsername:self.userTextField.text withPassword:self.passTextField.text withConfirmPass:self.confirmPassTextField.text];
}

- (IBAction)forgotButtonPressed:(UIButton *)sender {
    UIStoryboard *myStoryboard = [UIStoryboard storyboardWithName:@"Login" bundle:[NSBundle mainBundle]];
    FCOAlertViewController *customAlerViewController = [myStoryboard instantiateViewControllerWithIdentifier:@"AlertVC"];
    customAlerViewController.view.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.75];
    customAlerViewController.delegate = self;
    customAlerViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:customAlerViewController animated:true completion:nil];
    NSLog(@"forgot");
}

- (void)presentViewController {
    NSLog(@"asdassda");
}

# pragma mark - FCOAlertViewController Delegate

- (void)didCancel {
    [self dismissViewControllerAnimated:YES completion:nil];
}

# pragma mark - Private Methods

- (void)keyboardWillShow:(NSNotification*)aNotification {
    self.bgImageView.hidden = YES;
    self.keyboardImageView.hidden = NO;
}

- (void)keyboardWillHide:(NSNotification*)aNotification {
    self.bgImageView.hidden = NO;
    self.keyboardImageView.hidden = YES;
}

- (void)promptAlert:(NSString *)title message:(NSString *)message andDismissTitle:(NSString *)dismiss {
    
    NSDictionary *attributes = @{ kMONPromptViewAttribDismissButtonBackgroundColor: [UIColor colorWithRed:107/255.0f green:12/255.0f blue:13/255.0f alpha:1.0f],
                                  kMONPromptViewAttribDismissButtonTextColor: [UIColor whiteColor],
                                  kMONPromptViewAttribDismissButtonFont : [UIFont fontWithName:@"HelveticaNeue-Medium" size:16.0f],
                                  kMONPromptViewAttribDismissButtonFont: [UIFont fontWithName:@"HelveticaNeue-Light" size:14.0f],
                                  kMONPromptViewAttribMessageFont: [UIFont fontWithName:@"HelveticaNeue-Light" size:15.0f],
                                  kMONPromptViewAttribTitleFont: [UIFont fontWithName:@"FederalEscort" size:18.0f],
                                  kMONPromptViewAttribTitleTextColor : [UIColor colorWithRed:149/255.0f green:149/255.0f blue:149/255.0f alpha:1.0f]};
    MONPromptView *promptView = [[MONPromptView alloc] initWithTitle:title
                                                             message:message
                                                  dismissButtonTitle:dismiss
                                                          attributes:attributes];
    [promptView showInView:self.view];
}


- (void)promptSuccessAlert:(NSString *)title message:(NSString *)message andDismissTitle:(NSString *)dismiss {
    NSDictionary *attributes = @{ kMONPromptViewAttribDismissButtonBackgroundColor: [UIColor colorWithRed:18/255.0f green:161/255.0f blue:158/255.0f alpha:1.0f],
                                  kMONPromptViewAttribDismissButtonTextColor: [UIColor whiteColor],
                                  kMONPromptViewAttribDismissButtonFont : [UIFont fontWithName:@"HelveticaNeue-Medium" size:16.0f],
                                  kMONPromptViewAttribDismissButtonFont: [UIFont fontWithName:@"HelveticaNeue-Light" size:14.0f],
                                  kMONPromptViewAttribMessageFont: [UIFont fontWithName:@"HelveticaNeue-Light" size:15.0f],
                                  kMONPromptViewAttribTitleFont: [UIFont fontWithName:@"FederalEscort" size:18.0f],
                                  kMONPromptViewAttribTitleTextColor : [UIColor colorWithRed:149/255.0f green:149/255.0f blue:149/255.0f alpha:1.0f]};
    MONPromptView *promptView = [[MONPromptView alloc] initWithTitle:title
                                                             message:message
                                                  dismissButtonTitle:dismiss
                                                          attributes:attributes];
    [promptView showInView:self.view];
    
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

- (void)loginUsername:(NSString *)username withPassword:(NSString *)password {

    if ([username length] == 0) {
        [self promptAlert:@"Error" message:@"Email must be set" andDismissTitle:@"OK"];
    }
    else if ([password length] == 0) {
        
        [self promptAlert:@"Error" message:@"Password must be set" andDismissTitle:@"OK"];
    }
    else {
        
        NSDictionary *params = @{@"email":username,
                                 @"password":password};
        FCOHTTPClient *fcoHttpClient = [FCOHTTPClient sharedInstance];
        [fcoHttpClient POST:@"auth/login" parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
            [self.view endEditing:YES];
            [self.closeButton setHidden:YES];
            [self.loginButton setEnabled:NO];
            [self.loginToggleButton setEnabled:NO];
            [self.signupToggleButton setEnabled:NO];
            [self.forgotButton setEnabled:NO];
            [self.usernameTextField setEnabled:NO];
            [self.passwordTextField setEnabled:NO];
            FCOSessionModel *session = [FCOSessionModel sharedInstance];
            [session setToken:responseObject[@"token"]];
            
            //GET users
            FCOUserModel *userModel = [[FCOUserModel alloc] initWithDictionary:responseObject[@"user"]];
            [session setActiveUser:userModel];
            
            NSLog(@"%@", userModel.category_id);
            
            NSLog(@"response return %@", responseObject);
            
            SCLAlertView *alert = [[SCLAlertView alloc] init];
            [alert showWaiting:self title:@"Logging In" subTitle:@"Please Wait..." closeButtonTitle:nil duration:2];
            [alert setTitleFontFamily:@"FederalEscort" withSize:24];
            [alert setBodyTextFontFamily:@"HelveticaNeue" withSize:13];
            alert.backgroundType = Transparent;
            
            
            self.loginButton.enabled = YES;
            
            
            double delayInSeconds = 2.0;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds *   NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
               [self dismissViewControllerAnimated:YES completion:nil];
                           });
            NSLog(@"success %@", responseObject);
            
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            if (!error) {
                [self promptAlert:@"Error" message:[error localizedDescription] andDismissTitle:@"OK"];
                 self.loginButton.enabled = YES;
            } else {
                 [self promptAlert:@"Error" message:@"Invalid username or password" andDismissTitle:@"OK"];
                 self.loginButton.enabled = YES;
            } 
        }];
    }
}



- (void)signupWithEmail:(NSString *)email withUsername:(NSString *)username withPassword:(NSString *)password withConfirmPass:(NSString *)confirmPass {
    [self.view endEditing:YES];
    if ([email length] == 0) {
        [self promptAlert:@"Error" message:@"Please Input Email Address" andDismissTitle:@"OK"];
    } else if ([username length] < 8) { 
        [self promptAlert:@"Error" message:@"Username is too short" andDismissTitle:@"OK"];
    } else if (![password isEqualToString:confirmPass]) {
        [self promptAlert:@"Error" message:@"Password did not match!" andDismissTitle:@"OK"];
    } else if (password.length == 0 || confirmPass.length == 0) {
        [self promptAlert:@"Error" message:@"Please input password" andDismissTitle:@"OK"];
    } else if (password.length < 8 || confirmPass.length < 8) {
        [self promptAlert:@"Error" message:@"Password is too short" andDismissTitle:@"OK"];
    } else if (![self NSStringIsValidEmail:self.emailTextField.text]) {
        [self promptAlert:@"Error" message:@"Enter valid email" andDismissTitle:@"OK"];
    } else {
        NSDictionary *params = @{@"email": email,
                                 @"username": username,
                                 @"password": password,
                                 @"confirm_password": confirmPass
                                 };
        FCOLoadingView *loadingView = [[FCOLoadingView alloc]init];
        [loadingView setCenter:CGPointMake(self.view.center.x, self.view.center.y + 130)];
        [self.view addSubview:loadingView];
        [loadingView startAnimating];
        
        FCOHTTPClient *fcoHttpClient = [FCOHTTPClient sharedInstance];
        [fcoHttpClient POST:@"auth/register" parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
            [loadingView removeFromSuperview];
            [self.view endEditing:YES];
//            [self promptAlert:@"Success!" message:@"A confirmation email has been sent" andDismissTitle:@"OK"];
            
            [self promptAlertView:@"Success!!!" withSub:@"A confirmation email has been sent" withClose:nil];
            
            double delayInSeconds = 2;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds *   NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [self dismissViewControllerAnimated:YES completion:nil];
            });
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            [loadingView removeFromSuperview];
            NSString* ErrorResponse = [[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding];
            NSLog(@"%@",ErrorResponse);
            
            if ([ErrorResponse containsString:@"user_already_exists"]) {
//                [self promptAlert:@"Failed" message:@"User Already Exists. Please try a new one" andDismissTitle:@"OK"];
                
                [self promptAlertView:@"Warning!!!" withSub:@"User Already Exists. Please try a new one" withClose:@"OK"];
                
                NSLog(@"user already exist");
            } else {
//                [self promptAlert:@"Failed" message:@"Please Try Again" andDismissTitle:@"OK"];
                
              [self promptAlertView:@"Failed!!!" withSub:@"Please Try Again" withClose:@"OK"];
            }

        }];
    }
    
}

-(BOOL) NSStringIsValidEmail:(NSString *)checkString
{
    BOOL stricterFilter = NO; // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
    NSString *stricterFilterString = @"^[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}$";
    NSString *laxString = @"^.+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*$";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
