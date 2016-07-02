//
//  FCOCallIOutViewController.m
//  fco
//
//  Created by Kryptonite on 6/9/15.
//  Copyright (c) 2015 Kryptonite. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "FCOCallIOutViewController.h"
#import "UzysAssetsPickerController.h"
#import <MONPromptView/monpromptview.h>
#import <GUIPlayerView/GUIPlayerView.h>
#import "FCOHTTPClient.h"
#import "FCOSessionModel.h"
#import "FCOUserModel.h"
#import "FCOCategoryModel.h"
#import "FCOMainViewController.h"
#import <TDSemiModal/TDSemiModal.h>
#import <AFNetworking/UIImageView+AFNetworking.h>
#import <IQKeyboardManager/iquiview+hierarchy.h>
#import <SCLAlertView-Objective-C/SCLAlertView.h>
#import "FCOLoadingView.h"
#import <AFNetworking/UIProgressView+AFNetworking.h>
#import "UIPlacePicker.h"

// Degrees to radians
#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)

@interface FCOCallIOutViewController () <UzysAssetsPickerControllerDelegate, GUIPlayerViewDelegate, FCOCustomTimePickerViewControllerDelegate, FCOCustomDatePickerViewControllerDelegate, UITextViewDelegate, UIPlacePickerDelegate>
@property (strong, nonatomic) AVPlayerItem *playerItem;
@property (strong, nonatomic) NSMutableDictionary *editUserParameters;
@property (strong, nonatomic) NSMutableArray *matchType;
@property (strong, nonatomic) NSMutableArray *sportsType;
@property (strong, nonatomic) NSString *matchTypeSelectedValue;
@property (strong, nonatomic) NSString *sportsTypeSelectedValaue;

@property (strong, nonatomic) GUIPlayerView *playerView;
@property (strong, nonatomic) FCOCustomDatePickerViewController *datePickerView;
@property (strong, nonatomic) FCOCustomTimePickerViewController *timePickerView;
@property (strong, nonatomic) UIPlacePicker *picker;
@property (strong, nonatomic) UIPlace *place;
@property (strong, nonatomic) NSString *uploadID;
@property (strong, nonatomic) NSString *videoID;

@property (strong, nonatomic) NSString *latitude;
@property (strong, nonatomic) NSString *longitude;

@end

@implementation FCOCallIOutViewController

@synthesize playerView;


# pragma mark - View Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.progressView.hidden = YES;
    self.dateTextField.delegate = self;
    self.timeTextField.delegate = self;
    self.venueTextField.delegate = self;
    self.descriptionTextView.delegate = self;
    self.broadcastingURLTextField.delegate = self;
    self.ticketingURLTextField.delegate = self;
    
    [[UISegmentedControl appearance] setTitleTextAttributes:@{
                                                              NSForegroundColorAttributeName : [UIColor whiteColor]
                                                              } forState:UIControlStateNormal];
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"FederalEscort" size:21], NSFontAttributeName, [UIColor lightGrayColor], NSForegroundColorAttributeName, nil]];
    
    [self customTextField];

    self.datePickerView = [[FCOCustomDatePickerViewController alloc] initWithNibName:@"FCOCustomDatePickerViewController" bundle:nil];
    self.datePickerView.delegate = self;
    
    self.timePickerView = [[FCOCustomTimePickerViewController alloc] initWithNibName:@"FCOCustomTimePickerViewController" bundle:nil];
    self.timePickerView.delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
    
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    FCOSessionModel *session = [FCOSessionModel sharedInstance];
    if (!session.isLoggedIn) {
        [self.tabBarController setSelectedIndex:1];
        [session setToken:nil];
    } else {
        if ([self.descriptionTextView.text length] > 0) {
            [self.placeholderLabel setHidden:YES];
        } else {
            [self.placeholderLabel setHidden:NO];
        }
        
        [_scrollView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
        FCOSessionModel *session = [FCOSessionModel sharedInstance];
        FCOUserModel *userModel = [session activeUser];
        
        NSString *urlID = [NSString stringWithFormat:@"http://api.fightcallout.com/api/v1.0/uploads/%@", userModel.photo];
        
        NSURL *logoImageUrl = [NSURL URLWithString:urlID];
        __weak FCOCallIOutViewController *selfRef = self;
        [self.userImageView setImageWithURLRequest:[NSURLRequest requestWithURL:logoImageUrl] placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
            selfRef.userImageView.image = image;
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
            NSLog(@"error: %@", error);
        }];
        self.matchType = [NSMutableArray array];
        self.sportsType = [NSMutableArray array];
        self.editUserParameters = [NSMutableDictionary dictionary];
        
        [self getCategories];
        
        self.sportsTypeDownPicker = [[DownPicker alloc] initWithTextField:self.sportsTypeTextField];
        [self.sportsTypeDownPicker setPlaceholder:@"Fight Style"];
        [self.sportsTypeDownPicker addTarget:self action:@selector(sportsTypeSelected:) forControlEvents:UIControlEventValueChanged];
        
        NSMutableArray *matchType = [[NSMutableArray alloc] init];
        [matchType addObject:@"Fight"];
        //[matchType addObject:@"Rematch"];
        [matchType addObject:@"Sparring"];
        
        self.matchTypeDownPicker = [[DownPicker alloc] initWithTextField:self.matchTypeTextField withData:matchType];
        [self.matchTypeDownPicker setPlaceholder:@"Contest"];
        [self.matchTypeDownPicker addTarget:self action:@selector(matchTypSelected:) forControlEvents:UIControlEventValueChanged];
    }
}

-(void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if ([self.navigationController.viewControllers indexOfObject:self]==NSNotFound) {
        [self dismissSemiModalViewController:self.datePickerView];
        self.dateTextField.text = nil;
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

# pragma mark - IBAction

- (IBAction)cancelButtonPressed:(UIButton *)sender {
    if ([self.fighterATextField.text length] != 0 || [self.fighterBTextField.text length] != 0 || [self.matchTypeTextField.text length] != 0 || [self.sportsTypeTextField.text length] != 0 || [self.dateTextField.text length] != 0 || [self.timeTextField.text length] != 0 || [self.venueTextField.text length] != 0) {
        
        SCLAlertView *alert = [[SCLAlertView alloc] init];
        UIColor *color = [UIColor colorWithRed:103.0/255.0 green:10.0/255.0 blue:5.0/255.0 alpha:1.0];
        [alert addButton:@"Discard" actionBlock:^(void) {
            [self updateFieldToNil];
            [self.venueTextField resignFirstResponder];
            [self.fighterATextField resignFirstResponder];
            [self.fighterBTextField resignFirstResponder];
            [self.descriptionTextView resignFirstResponder];
            [self.broadcastingURLTextField resignFirstResponder];
            [self.ticketingURLTextField resignFirstResponder];
            [self.tabBarController setSelectedIndex:1];
        }];
        [alert showCustom:self image:[UIImage imageNamed:@"icon_punch"] color:color title:@"Warning!" subTitle:@"Are you sure to discard creating callout?" closeButtonTitle:@"Close" duration:0.0f];
        [alert setTitleFontFamily:@"FederalEscort" withSize:24];
        [alert setBodyTextFontFamily:@"HelveticaNeue-Medium" withSize:13];
        alert.backgroundViewColor = [UIColor whiteColor];
        alert.backgroundType = Blur;
        NSLog(@"cancel button");
    } else if (self.uploadID != nil) {
        SCLAlertView *alert = [[SCLAlertView alloc] init];
        UIColor *color = [UIColor colorWithRed:103.0/255.0 green:10.0/255.0 blue:5.0/255.0 alpha:1.0];
        [alert addButton:@"Discard" actionBlock:^(void) {
            [self updateFieldToNil];
            [self.venueTextField resignFirstResponder];
            [self.fighterATextField resignFirstResponder];
            [self.fighterBTextField resignFirstResponder];
            [self.descriptionTextView resignFirstResponder];
            [self.broadcastingURLTextField resignFirstResponder];
            [self.ticketingURLTextField resignFirstResponder];
            self.uploadID = nil;
            [self.tabBarController setSelectedIndex:1];
            NSLog(@"discard upload url %@", self.uploadID);
        }];
        [alert showCustom:self image:[UIImage imageNamed:@"icon_punch"] color:color title:@"Warning!" subTitle:@"You are already uploaded photo. Are you sure to discard?" closeButtonTitle:@"Close" duration:0.0f];
        [alert setTitleFontFamily:@"FederalEscort" withSize:24];
        [alert setBodyTextFontFamily:@"HelveticaNeue-Medium" withSize:13];
        alert.backgroundViewColor = [UIColor whiteColor];
        alert.backgroundType = Blur;
        NSLog(@"upload url %@", self.uploadID);
        
    } else if (self.videoID != nil) {
        SCLAlertView *alert = [[SCLAlertView alloc] init];
        UIColor *color = [UIColor colorWithRed:103.0/255.0 green:10.0/255.0 blue:5.0/255.0 alpha:1.0];
        [alert addButton:@"Discard" actionBlock:^(void) {
            [self updateFieldToNil];
            [self.venueTextField resignFirstResponder];
            [self.fighterATextField resignFirstResponder];
            [self.fighterBTextField resignFirstResponder];
            [self.descriptionTextView resignFirstResponder];
            [self.broadcastingURLTextField resignFirstResponder];
            [self.ticketingURLTextField resignFirstResponder];
            self.videoID = nil;
            [self.tabBarController setSelectedIndex:1];
            NSLog(@"discard upload url %@", self.videoID);
        }];
        [alert showCustom:self image:[UIImage imageNamed:@"icon_punch"] color:color title:@"Warning!" subTitle:@"You are already uploaded video. Are you sure to discard?" closeButtonTitle:@"Close" duration:0.0f];
        [alert setTitleFontFamily:@"FederalEscort" withSize:24];
        [alert setBodyTextFontFamily:@"HelveticaNeue-Medium" withSize:13];
        alert.backgroundViewColor = [UIColor whiteColor];
        alert.backgroundType = Blur;
       
        
    } else {
        [self.tabBarController setSelectedIndex:1];
        [self.venueTextField resignFirstResponder];
        [self.fighterATextField resignFirstResponder];
        [self.fighterBTextField resignFirstResponder];
        [self.descriptionTextView resignFirstResponder];
        [self.broadcastingURLTextField resignFirstResponder];
        [self.ticketingURLTextField resignFirstResponder];
        [self updateFieldToNil];
    }
}

- (IBAction)saveButtonPressed:(UIButton *)sender {
    _saveButton.enabled = NO;
    [self setTimePickerFormat:self.timeTextField.text];
    [self setDatePickerFormat:self.dateTextField.text];
    if ([self.sportsTypeTextField.text length] == 0 || [self.matchTypeTextField.text length] == 0 || [self.descriptionTextView.text length] == 0) {
        [self promptAlertView:@"Error" withSub:@"Field must be set!" withClose:@"OK"];
    } else if ((![self.broadcastingURLTextField.text containsString:@"http://"] && [self.broadcastingURLTextField.text length] >0) || (![self.ticketingURLTextField.text containsString:@"http://"] && [self.ticketingURLTextField.text length] >0)) {
        [self promptAlertView:@"Error!!!" withSub:@"Invalid URL avoid spaces or you must input \"http://\"                       Example: http://www.epicentre.tv" withClose:@"OK"];
    } else {
        FCOSessionModel *session = [FCOSessionModel sharedInstance];
        FCOUserModel *activeUser = [session activeUser];
        NSString *userID = [NSString stringWithFormat:@"%@", activeUser._id];
        
        if (self.uploadID == nil) {
            self.uploadID = (id)[NSNull null];
            NSLog(@"upload id value %@", self.uploadID);
        } else if (self.uploadID != nil) {
            self.uploadID = self.uploadID;
            NSLog(@"upload id value %@", self.uploadID);
        }
            
        if (self.videoID == nil) {
            self.videoID = (id)[NSNull null];
               NSLog(@"video id value %@", self.videoID);
        } else if (self.videoID != nil) {
            self.videoID = self.videoID;
               NSLog(@"video id value %@", self.videoID);
        }
        
        if (self.latitude == nil) {
            self.latitude = (id)[NSNull null];
            NSLog(@"latitude is nil %@", self.latitude);
        } else if (self.latitude != nil) {
            self.latitude = self.latitude;
            NSLog(@"latitude is not nil %@", self.latitude);
        }
       
        if (self.longitude == nil) {
            self.longitude = (id)[NSNull null];
            NSLog(@"longitude is nil %@", self.longitude);
        } else if (self.longitude != nil) {
        self.longitude = self.longitude;
        NSLog(@"longitude is not nil %@", self.longitude);
        }
        self.editUserParameters = [@{
                                     @"user_id": userID,
                                     @"category_id": self.sportsTypeSelectedValaue,
                                     @"match_type": self.matchTypeSelectedValue,
                                     @"description": self.descriptionTextView.text,
                                     @"fighter_a": [self.fighterATextField.text capitalizedString],
                                     @"fighter_b": [self.fighterBTextField.text capitalizedString],
                                     @"details_date": self.dateTextField.text,
                                     @"details_venue": self.venueTextField.text,
                                     @"details_time": self.timeTextField.text,
                                     @"photo": self.uploadID,
                                     @"video": self.videoID,
                                     @"latitude": self.latitude,
                                     @"longitude": self.longitude,
                                     @"broadcast_url": self.broadcastingURLTextField.text,
                                     @"ticket_url": self.ticketingURLTextField.text
                                     }mutableCopy];
        NSLog(@"%@", self.editUserParameters);
        [self.navigationController popToRootViewControllerAnimated:YES];
        FCOHTTPClient *fcoHttpClient = [FCOHTTPClient sharedInstance];
        [fcoHttpClient POST:@"callouts" parameters:self.editUserParameters success:^(NSURLSessionDataTask *task, id responseObject) {
            _saveButton.enabled = NO;
            SCLAlertView *alert = [[SCLAlertView alloc] init];
            [alert showWaiting:self title:@"Loading" subTitle:@"Please Wait..." closeButtonTitle:nil duration:2];
            [alert setTitleFontFamily:@"FederalEscort" withSize:24];
            [alert setBodyTextFontFamily:@"HelveticaNeue" withSize:13];
            alert.backgroundType = Transparent;
            
            double delayInSeconds = 2;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds *   NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                
                [self promptCustomAlertView:@"Success!!" withSub:@"Callout Successfully Created!!" withClose:nil];
                self.uploadID = nil;
                self.videoID = nil;
                self.latitude = nil;
                self.longitude = nil;
                _saveButton.enabled = YES;
                
            });
            NSLog(@"success %@", responseObject);
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            NSInteger statusCode = error.code;
            if (statusCode == -999 || statusCode == -1011) {
                [self promptExpiredToken:@"Error!!!" withSub:@"Session Expired Please Re-log" withClose:nil];
            }
            NSLog(@"error %@", error);
             _saveButton.enabled = YES;
        }];
    }
}

- (void)matchTypSelected:(id)dp {
    self.matchTypeSelectedValue = [self.matchTypeDownPicker text];
    NSLog(@"%@", self.matchTypeSelectedValue);
}

- (void)sportsTypeSelected:(id)dp {
    self.sportsTypeSelectedValaue = [self.sportsTypeDownPicker text];
    
    NSMutableArray *items = [[self.sportsType filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(desc == %@)", self.sportsTypeSelectedValaue]]mutableCopy];
    
    FCOCategoryModel *selectedCategory = (FCOCategoryModel *)[items firstObject];
    [self.editUserParameters setObject:selectedCategory._id forKey:@"category_id"];
    self.sportsTypeSelectedValaue = [self.editUserParameters objectForKey:@"category_id"];
    
    NSLog(@"%@", self.sportsTypeSelectedValaue);
}

- (IBAction)takeUploadOfImageButtonPressed:(UIButton *)sender {
    UzysAssetsPickerController *picker = [[UzysAssetsPickerController alloc] init];
    picker.delegate = self;
    if ([sender isEqual:self.takeUploadOfImageButton]) {
        picker.maximumNumberOfSelectionVideo = 0;
        picker.maximumNumberOfSelectionPhoto = 1;
    }
    [self presentViewController:picker animated:YES completion:nil];
}

- (IBAction)recordOrUploadVideoButtonPressed:(UIButton *)sender {
    UzysAssetsPickerController *picker = [[UzysAssetsPickerController alloc] init];
    picker.delegate = self;
    if ([sender isEqual:self.recordOrUploadVideoButton]) {
        picker.maximumNumberOfSelectionPhoto = 0;
        picker.maximumNumberOfSelectionVideo = 1;
    }
    [self presentViewController:picker animated:YES completion:nil];
}

# pragma mark - Private Methods

- (void)setUserDetails:(FCOUserModel *)user {
    self.fighterATextField.text = [user.first_name capitalizedString];
}

- (BOOL)isTheStringDate:(NSString *)theString {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *dateFromString = [[NSDate alloc] init];
    
    if (dateFromString !=nil && ![theString containsString:@"."] && ![theString containsString:@"/"]) {
        NSLog(@"date: %@", theString);
        return true;
    }
    else {
        return false;
    }
}

- (void)customTextField {
    //date
    UIImageView *date = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"detail_icon_date"]];
    date.frame = CGRectMake(0.0, 0.0, date.image.size.width+20.0, date.image.size.height);
    date.contentMode = UIViewContentModeCenter;
    _dateTextField.leftView = date;
    _dateTextField.leftViewMode = UITextFieldViewModeAlways;
    [UILabel appearanceWhenContainedIn:[_dateTextField class], nil];
    //date
    UIImageView *time = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"detail_icon_time"]];
    time.frame = CGRectMake(0.0, 0.0, time.image.size.width+20.0, time.image.size.height);
    time.contentMode = UIViewContentModeCenter;
    _timeTextField.leftView = time;
    _timeTextField.leftViewMode = UITextFieldViewModeAlways;
    [UILabel appearanceWhenContainedIn:[_timeTextField class], nil];
    //date
    UIImageView *location = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"detail_icon_location"]];
    location.frame = CGRectMake(0.0, 0.0, date.image.size.width+20.0, date.image.size.height);
    location.contentMode = UIViewContentModeCenter;
    _venueTextField.leftView = location;
    _venueTextField.leftViewMode = UITextFieldViewModeAlways;
    [UILabel appearanceWhenContainedIn:[_venueTextField class], nil] ;
    //broadcasting
    UIImageView *broadcast = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"detail_icon_broadcast"]];
    broadcast.frame = CGRectMake(0.0, 0.0, broadcast.image.size.width+20.0, broadcast.image.size.height);
    broadcast.contentMode = UIViewContentModeCenter;
    _broadcastingURLTextField.leftView = broadcast;
    _broadcastingURLTextField.leftViewMode = UITextFieldViewModeAlways;
    [UILabel appearanceWhenContainedIn:[_broadcastingURLTextField class], nil];
    //ticketing
    UIImageView *ticket = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"detail_icon_ticket"]];
    ticket.frame = CGRectMake(0.0, 0.0, ticket.image.size.width+17.0, ticket.image.size.height);
    ticket.contentMode = UIViewContentModeCenter;
    _ticketingURLTextField.leftView = ticket;
    _ticketingURLTextField.leftViewMode = UITextFieldViewModeAlways;
    [UILabel appearanceWhenContainedIn:[_ticketingURLTextField class], nil];
}

-(BOOL)isTheStringTime:(NSString *)theString {
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
    [timeFormatter setDateFormat:@"hh:mm a"];
    NSDate *timeFromString = [[NSDate alloc] init];
    timeFromString = [timeFormatter dateFromString:theString];
    
    if (timeFromString != nil && ![theString containsString:@"."]) {
        NSLog(@"time: %@", theString);
        return true;
    } else {
        return false;
    }
}

- (void)updateFieldToNil {
    self.fighterATextField.text = nil;
    self.fighterBTextField.text = nil;
    self.matchTypeTextField.text = nil;
    self.sportsTypeTextField.text = nil;
    self.dateTextField.text = nil;
    self.timeTextField.text = nil;
    self.venueTextField.text = nil;
    self.descriptionTextView.text = nil;
    self.broadcastingURLTextField.text = nil;
    self.ticketingURLTextField.text = nil;
}

- (void)promptSelectePhotoAlertView:(NSString *)title withSub:(NSString *)subtitle withClose:(NSString *)close {
    SCLAlertView *alert = [[SCLAlertView alloc] init];
    UIColor *color = [UIColor colorWithRed:103.0/255.0 green:10.0/255.0 blue:5.0/255.0 alpha:1.0];
    [alert addButton:@"Done" actionBlock:^(void) {
        [self.cancelButton setEnabled:YES];
        [self.saveButton setEnabled:YES];
    }];
    
    [alert showCustom:self image:[UIImage imageNamed:@"icon_punch"] color:color title:title     subTitle:subtitle closeButtonTitle:close duration:0.0f];
    [alert setTitleFontFamily:@"FederalEscort" withSize:24];
    [alert setBodyTextFontFamily:@"HelveticaNeue" withSize:13];
    alert.backgroundViewColor = [UIColor whiteColor];
    alert.backgroundType = Blur;
}


- (void)promptExpiredToken:(NSString *)title withSub:(NSString *)subtitle withClose:(NSString *)close {
    SCLAlertView *alert = [[SCLAlertView alloc] init];
    UIColor *color = [UIColor colorWithRed:103.0/255.0 green:10.0/255.0 blue:5.0/255.0 alpha:1.0];
    [alert addButton:@"Re-Log" actionBlock:^(void) {
        [self performSegueWithIdentifier:@"createCalloutToLoginSegue" sender:self];
    }];
    
    [alert showCustom:self image:[UIImage imageNamed:@"icon_punch"] color:color title:title     subTitle:subtitle closeButtonTitle:close duration:0.0f];
    [alert setTitleFontFamily:@"FederalEscort" withSize:24];
    [alert setBodyTextFontFamily:@"HelveticaNeue" withSize:13];
    alert.backgroundViewColor = [UIColor whiteColor];
    alert.backgroundType = Blur;
}

- (void)promptCustomAlertView:(NSString *)title withSub:(NSString *)subtitle withClose:(NSString *)close {
    SCLAlertView *alert = [[SCLAlertView alloc] init];
    UIColor *color = [UIColor colorWithRed:103.0/255.0 green:10.0/255.0 blue:5.0/255.0 alpha:1.0];
    [alert addButton:@"Done" actionBlock:^(void) {
        [self updateFieldToNil];
        [self.venueTextField resignFirstResponder];
        [self.fighterATextField resignFirstResponder];
        [self.fighterBTextField resignFirstResponder];
        [self.descriptionTextView resignFirstResponder];
        [self.broadcastingURLTextField resignFirstResponder];
        [self.ticketingURLTextField resignFirstResponder];
        [self.tabBarController setSelectedIndex:1];
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

- (void)setTimePickerFormat:(NSString *)originalDate {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setDateFormat:@"hh:mm a"];
    NSDate *time = [formatter dateFromString: originalDate];
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
    [timeFormatter setDateFormat:@"HH:mm:ss"];
    NSString *timex = [timeFormatter stringFromDate:time];
    self.timeTextField.text = timex;
    NSLog(@"timexxxxx %@", self.timeTextField.text);
}

- (void)setDatePickerFormat:(NSString *)originalDate {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMM. dd, yyyy"];
    NSDate *date = [dateFormatter dateFromString:originalDate];
    NSDateFormatter *dteFormatter = [[NSDateFormatter alloc] init];
    [dteFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *convertedTime = [dteFormatter stringFromDate:date];
    self.dateTextField.text = convertedTime;
    NSLog(@"dateeeee %@", self.dateTextField.text);
}


- (void)getCategories {
    FCOHTTPClient *fcoHttpClient = [FCOHTTPClient sharedInstance];
    [fcoHttpClient GET:@"categories" parameters:@"" success:^(NSURLSessionDataTask *task, id responseObject) {
        NSMutableArray *temp = [NSMutableArray array];
        for (NSDictionary *categoryDictionary in responseObject) {
            FCOCategoryModel *category = [[FCOCategoryModel alloc] initWithDictionary:categoryDictionary];
            [self.sportsType addObject:category];
            [temp addObject:category.desc];
        }
        [self.sportsTypeDownPicker setData:temp];
        NSLog(@"response %@", temp);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSInteger statusError = error.code;
        if (statusError == 400) {
            NSLog(@"need hedear!!");
        }
        NSLog(@"error %@", error);
    }];
}

- (void)keyboardWillShow:(NSNotification*)aNotification {
    _scrollView.contentSize = CGSizeMake(_scrollView.frame.size.width, 586);
   

}

- (void)keyboardWillHide:(NSNotification*)aNotification {
    _scrollView.contentSize = CGSizeMake(_scrollView.frame.size.width, 686);
    [_scrollView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
}


#pragma mark - UIPlacePicker Delegate

-(void)placePickerDidCancel {
    [self hidePlacePicker];
    
    NSLog(@"taee");
}
-(void)hidePlacePicker{

    [self.picker dismissViewControllerAnimated:NO completion:^{
        self.venueTextField.text = [self.picker getAddressWithCurrentLocation];
        CGPoint bottomOffset = CGPointMake(0, self.scrollView.contentSize.height - self.scrollView.bounds.size.height);
        [self.scrollView setContentOffset:bottomOffset animated:YES];
        //NSLog(@"test place %@", [self.picker getAddressWithCurrentLocation]);
       //self.latitude = self.picker.myLocation.coordinate.latitude;
       //self.longitude = self.picker.myLocation.coordinate.longitude;
       //
       //NSLog(@"test latitude %f",self.latitude);
       //NSLog(@"test longtitude %f",self.longitude);
        
        
        self.latitude = [NSString stringWithFormat:@"%f", self.picker.myLocation.coordinate.latitude];
        self.longitude = [NSString stringWithFormat:@"%f", self.picker.myLocation.coordinate.longitude];
        NSLog(@"latitude %@", self.latitude);
        NSLog(@"longitude %@", self.longitude);
    }];
}


- (void)placePickerDidSelectPlace:(UIPlace *)place {
    self.place = place;
    
}

# pragma mark - UITextView Delegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    
    if (range.location>0 || text.length!=0) {
        self.placeholderLabel.hidden = YES;
    }else{
        self.placeholderLabel.hidden = NO;
    }
    return YES;
}

# pragma mark - UITextField Delegate

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    
    
    if (textField == self.broadcastingURLTextField || textField == self.ticketingURLTextField) {
        
        return YES;
    }
    
    
        if (textField.isAskingCanBecomeFirstResponder == NO) {
            //Do your work on tapping textField.
            
            if (self.dateTextField == textField) {
                [self presentSemiModalViewController:self.datePickerView];
            } else if (self.timeTextField == textField) {
                [self presentSemiModalViewController:self.timePickerView];
            } else if (self.venueTextField == textField) {
                self.picker = [[UIPlacePicker alloc] initWithUIPlace:nil];
                self.picker.delegate = self;
                [self presentViewController:self.picker animated:YES completion:^{
                }];
                NSLog(@"venue");
            }
        }
        return NO;
}


-(void)textFieldDidBeginEditing:(UITextField *)textField {
    if (self.broadcastingURLTextField == textField && [textField.text length] == 0) {
        self.broadcastingURLTextField.text = @"http://";
    }
    if (self.ticketingURLTextField == textField && [textField.text length] == 0) {
        self.ticketingURLTextField.text = @"http://";
        NSLog(@"ticket!!");
    }

}


-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (self.broadcastingURLTextField == textField || self.ticketingURLTextField == textField) {
        NSMutableString *mutableText = textField.text.mutableCopy;
        [mutableText replaceCharactersInRange:range withString:string];
        return [mutableText hasPrefix:@"http://"];
    }
    return YES;
}

#pragma mark - FCOCustomDatePickerController Delegate

-(void)datePickerSetDate:(FCOCustomDatePickerViewController *)viewController {
    NSDate *now = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *stringDate = [dateFormatter stringFromDate:viewController.datePicker.date];
    NSDate *date = [dateFormatter dateFromString:stringDate];
    NSDateFormatter *dteFormatter = [[NSDateFormatter alloc] init];
    [dteFormatter setDateFormat:@"MMM. dd, yyyy"];
    NSString *convertedTime = [dteFormatter stringFromDate:date];

    NSString *strCompleteDate = convertedTime;
    NSDate *completeDate;
    NSDateFormatter *completeFomatter = [[NSDateFormatter alloc] init];
    if (_timeTextField.text.length > 0) {
        strCompleteDate = [NSString stringWithFormat:@"%@ %@",convertedTime,_timeTextField.text];
        [completeFomatter setDateFormat:@"MMM. dd, yyyy hh:mm a"];
    }
    else
    {
        strCompleteDate = [NSString stringWithFormat:@"%@ 11:59 PM",convertedTime];
        [completeFomatter setDateFormat:@"MMM. dd, yyyy hh:mm a"];
    }
    completeDate = [completeFomatter dateFromString:strCompleteDate];
    if ([now compare:completeDate] == NSOrderedDescending) {
        [self dismissSemiModalViewController:self.datePickerView];
        SCLAlertView *alert = [[SCLAlertView alloc] init];
        UIColor *color = [UIColor colorWithRed:103.0/255.0 green:10.0/255.0 blue:5.0/255.0 alpha:1.0];
        
        [alert showCustom:self image:[UIImage imageNamed:@"icon_punch"] color:color title:@"Warning"     subTitle:@"Please select another date." closeButtonTitle:@"OK" duration:0.0f];
        [alert setTitleFontFamily:@"FederalEscort" withSize:24];
        [alert setBodyTextFontFamily:@"HelveticaNeue" withSize:13];
        alert.backgroundViewColor = [UIColor whiteColor];
        alert.backgroundType = Blur;
        [alert alertIsDismissed:^{
            NSLog(@"Dismissed");
            [self.dateTextField becomeFirstResponder];
        }];
    }
    else
    {
        self.dateTextField.text = convertedTime;
        [self dismissSemiModalViewController:self.datePickerView];
    }
    
}


-(void)datePickerCancel:(FCOCustomDatePickerViewController *)viewController {
        [self dismissSemiModalViewController:self.datePickerView];
        self.dateTextField.text = nil;
}


#pragma mark - FCOCustomTimePickerController Delegate

- (void)timePickerSetTime:(FCOCustomTimePickerViewController *)viewController {
    NSDate *now = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm:ss"];
    NSString *stringDate = [dateFormatter stringFromDate:viewController.timePicker.date];
    NSDate *date = [dateFormatter dateFromString:stringDate];
    NSDateFormatter *dteFormatter = [[NSDateFormatter alloc] init];
    [dteFormatter setDateFormat:@"hh:mm a"];
    NSString *convertedTime = [dteFormatter stringFromDate:date];
    
    NSString *strCompleteDate = convertedTime;
    NSDate *completeDate;
    NSDateFormatter *completeFomatter = [[NSDateFormatter alloc] init];
    if (_dateTextField.text.length > 0) {
        strCompleteDate = [NSString stringWithFormat:@"%@ %@",_dateTextField.text,convertedTime];
        [completeFomatter setDateFormat:@"MMM. dd, yyyy hh:mm a"];
    }
    else
    {
        [completeFomatter setDateFormat:@"MMM. dd, yyyy"];
    }
    completeDate = [completeFomatter dateFromString:strCompleteDate];
    if ([now compare:completeDate] == NSOrderedDescending) {
        [self dismissSemiModalViewController:self.timePickerView];
        SCLAlertView *alert = [[SCLAlertView alloc] init];
        UIColor *color = [UIColor colorWithRed:103.0/255.0 green:10.0/255.0 blue:5.0/255.0 alpha:1.0];
        
        [alert showCustom:self image:[UIImage imageNamed:@"icon_punch"] color:color title:@"Warning"     subTitle:@"Please select another time." closeButtonTitle:@"OK" duration:0.0f];
        [alert setTitleFontFamily:@"FederalEscort" withSize:24];
        [alert setBodyTextFontFamily:@"HelveticaNeue" withSize:13];
        alert.backgroundViewColor = [UIColor whiteColor];
        alert.backgroundType = Blur;
        [alert alertIsDismissed:^{
            NSLog(@"Dismissed");
            [self.timeTextField becomeFirstResponder];
        }];
    }
    else
    {
        self.timeTextField.text = convertedTime;
        [self dismissSemiModalViewController:self.timePickerView];
    }
    
    
}
- (void)timePickerCancel:(FCOCustomTimePickerViewController *)viewController {
    [self dismissSemiModalViewController:self.timePickerView];
    self.timeTextField.text = nil;
}

# pragma mark - UzyAssetsPickerController Delegate

- (void)uzysAssetsPickerController:(UzysAssetsPickerController *)picker didFinishPickingAssets:(NSArray *)assets {
    //__weak typeof(self) weakSelf = self;
    if([[assets[0] valueForProperty:@"ALAssetPropertyType"] isEqualToString:@"ALAssetTypePhoto"]) //Photo
    {
        [assets enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            ALAsset *representation = obj;
            
            UIImage *img = [UIImage imageWithCGImage:representation.defaultRepresentation.fullResolutionImage
                                               scale:representation.defaultRepresentation.scale
                                         orientation:(UIImageOrientation)representation.defaultRepresentation.orientation];
            //weakSelf.leftOpponentImageView.image = img;
            
            NSData *dataToUpload = UIImageJPEGRepresentation(img, 0.5);
            if ([UIImage imageWithData:dataToUpload]) {
                
                SCLAlertView *alert = [[SCLAlertView alloc] init];
                
                UIColor *color = [UIColor colorWithRed:103.0/255.0 green:10.0/255.0 blue:5.0/255.0 alpha:1.0];
                [alert addButton:@"Save" actionBlock:^(void) {
                    NSLog(@"Save button tapped");
                    
                    [self.cancelButton setEnabled:NO];
                    [self.saveButton setEnabled:NO];
                    
                    //                    FCOSessionModel *session = [FCOSessionModel sharedInstance];
                    //                    FCOUserModel *userModel = [session activeUser];
                    NSString *urlAction = [NSString stringWithFormat:@"callouts/upload"];
                    
                    FCOHTTPClient *fcoHttpClient = [FCOHTTPClient sharedInstance];
                    [fcoHttpClient POST:urlAction parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                        
                        
                        [fcoHttpClient setTaskDidSendBodyDataBlock:^(NSURLSession *session, NSURLSessionTask *task, int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend) {
                            
                            dispatch_async(dispatch_get_main_queue(), ^{
                                self.progressView.progress = totalBytesSent * 1.0 / totalBytesExpectedToSend;
                                self.progressView.hidden = NO;
                                if (self.progressView.progress == 1.000000) {
                                    [self.progressView setHidden:YES];
                                }
                            });
                            
                            NSLog(@"%f%% uploaded", self.progressView.progress);
                        }];
                        
                        
                        [formData appendPartWithFileData:dataToUpload name:@"photo" fileName:@"attachment.jpg" mimeType:@"image/jpeg"];
                    } success:^(NSURLSessionDataTask *task, id responseObject) {
                        //                        [self updateUserPhoto];
                        [self promptSelectePhotoAlertView:@"Success!!!" withSub:@"Photo was successfully uploaded!" withClose:nil];
                        self.uploadID = responseObject[@"upload"][@"id"];
                    } failure:^(NSURLSessionDataTask *task, NSError *error) {
                        NSString *errorMsg = [NSString stringWithUTF8String:[error.userInfo[@"com.alamofire.serialization.response.error.data"] bytes]];
                        NSLog(@"error %@", errorMsg);
                        
                        NSInteger statusCode = error.code;
                        if (statusCode == -999 || statusCode == -1011) {
                            [self promptExpiredToken:@"Error!!!" withSub:@"Session Expired Please Re-log" withClose:nil];
                        }
                        
                        [self.cancelButton setEnabled:YES];
                        [self.saveButton setEnabled:YES];
                    }];
            
                }];
                [alert addButton:@"Discard" actionBlock:^(void) {
                    //     [self getPhoto];
                }];
                [alert showCustom:self image:[UIImage imageNamed:@"icon_punch"] color:color title:@"Confirm!!!" subTitle:@"Do you want to upload a selected photo?" closeButtonTitle:nil duration:0.0f];
                [alert setTitleFontFamily:@"FederalEscort" withSize:24];
                [alert setBodyTextFontFamily:@"HelveticaNeue" withSize:13];
                alert.backgroundViewColor = [UIColor whiteColor];
                alert.backgroundType = Blur;
                NSLog(@"success");
            }
            *stop = YES;
        }];
    }
    else //Video
    {
        SCLAlertView *alert = [[SCLAlertView alloc] init];
        UIColor *color = [UIColor colorWithRed:103.0/255.0 green:10.0/255.0 blue:5.0/255.0 alpha:1.0];
    
        ALAsset *alAsset = assets[0];
        
        if (alAsset) {
            [alert addButton:@"Save" actionBlock:^(void) {
                NSLog(@"Save button tapped");
                [self.cancelButton setEnabled:NO];
                [self.saveButton setEnabled:NO];
                
                ALAssetRepresentation *representation = alAsset.defaultRepresentation;
                NSURL *movieURL = representation.url;
                NSString *dataFilePath = [[NSTemporaryDirectory() stringByAppendingPathComponent:@"test"] stringByAppendingString:@".mp4"];
                NSURL *uploadURL = [NSURL fileURLWithPath:dataFilePath];
                
                NSError *error;
                if ([[NSFileManager defaultManager] isDeletableFileAtPath:dataFilePath]) {
                    BOOL success = [[NSFileManager defaultManager] removeItemAtPath:dataFilePath error:&error];
                    if (success) {
                        NSLog(@"file deleted ");
                    }else
                    {
                        NSLog(@"file not deleted ");
                    }
                }
                
                AVAsset *asset      = [AVURLAsset URLAssetWithURL:movieURL options:nil];
                AVAssetExportSession *session =
                [AVAssetExportSession exportSessionWithAsset:asset presetName:AVAssetExportPresetMediumQuality];
                
//                AVMutableComposition* mixComposition = [AVMutableComposition composition];
//                
//                AVMutableCompositionTrack *compositionVideoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo  preferredTrackID:kCMPersistentTrackID_Invalid];
//                
//                AVAssetTrack *clipVideoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
//                
//                
//                [compositionVideoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration)
//                                               ofTrack:clipVideoTrack
//                                                atTime:kCMTimeZero error:nil];
//                
//                
//                
//                
//                [compositionVideoTrack setPreferredTransform:[[[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] preferredTransform]];
//                
//                // add watermark when playing
//                UIImage *myImage = [UIImage imageNamed:@"detail_img_fightcalloutlogo"];
//                CALayer *aLayer = [CALayer layer];
//                aLayer.contents = (id)myImage.CGImage;
//                aLayer.frame = CGRectMake(30, 140, 277, 277); //Needed for proper display. We are using the app icon (57x57). If you use 0,0 you will not see it
//                aLayer.opacity = 0.65; //Feel free to alter the alpha here
//                
//                CGSize videoSize = [[[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] naturalSize];
//
//                CALayer *parentLayer = [CALayer layer];
//                CALayer *videoLayer = [CALayer layer];
//                parentLayer.frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
//                videoLayer.frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
//                [parentLayer addSublayer:videoLayer];
//                [parentLayer addSublayer:aLayer];
//             
//                AVMutableVideoComposition* videoComp = [AVMutableVideoComposition videoComposition];
//                videoComp.renderSize = videoSize;
//                videoComp.frameDuration = CMTimeMake(1, 30);
//                videoComp.animationTool = [AVVideoCompositionCoreAnimationTool      videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer inLayer:parentLayer];
//                
//                AVMutableVideoCompositionInstruction *instruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
//                instruction.timeRange = CMTimeRangeMake(kCMTimeZero, [mixComposition duration]);
//                
//                AVAssetTrack *videoTrack = [[mixComposition tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
//                
//                
//                AVMutableVideoCompositionLayerInstruction* layerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];
//                [layerInstruction setTransform:videoTrack.preferredTransform atTime:kCMTimeZero];
//
//                
//                instruction.layerInstructions = [NSArray arrayWithObject:layerInstruction];
//                videoComp.instructions = [NSArray arrayWithObject: instruction];
//                
//                session.videoComposition = videoComp;
                
            
                
                
                session.outputFileType  = AVFileTypeQuickTimeMovie;
                session.outputURL       = uploadURL;
                //NSData *videoData = [NSData dataWithContentsOfURL:uploadURL];

                [session exportAsynchronouslyWithCompletionHandler:^{
                    if (session.status == AVAssetExportSessionStatusCompleted)
                    {
                        DLog(@"output Video URL %@",uploadURL);
                            NSString *urlAction = [NSString stringWithFormat:@"callouts/upload"];
                            
                            FCOHTTPClient *fcoHttpClient = [FCOHTTPClient sharedInstance];
                            [fcoHttpClient POST:urlAction parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                                
                                [fcoHttpClient setTaskDidSendBodyDataBlock:^(NSURLSession *session, NSURLSessionTask *task, int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend) {

                                    dispatch_async(dispatch_get_main_queue(), ^{
                                    self.progressView.progress = totalBytesSent * 1.0 / totalBytesExpectedToSend;
                                        self.progressView.hidden = NO;
                                        if (self.progressView.progress == 1.000000) {
                                            [self.progressView setHidden:YES];
                                        }
                                    });
                                    NSLog(@"%f%% uploaded", self.progressView.progress);
                                }];
                                [formData appendPartWithFileURL:uploadURL name:@"video" fileName:@"video.mov" mimeType:@"video/quicktime" error:nil];
                            } success:^(NSURLSessionDataTask *task, id responseObject) {
                                [self promptSelectePhotoAlertView:@"Success!!!" withSub:@"Video was successfully uploaded!" withClose:nil];
                                 self.videoID = responseObject[@"upload"][@"id"];
                                NSLog(@"upload video id %@", self.videoID);
                            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                NSString *errorMsg = [NSString stringWithUTF8String:[error.userInfo[@"com.alamofire.serialization.response.error.data"] bytes]];
                                NSLog(@"error %@", errorMsg);
                                NSInteger statusCode = error.code;
                                if (statusCode == -999 || statusCode == -1011) {
                                    [self promptExpiredToken:@"Error!!!" withSub:@"Session Expired Please Re-log" withClose:nil];
                                }
                                [self.cancelButton setEnabled:YES];
                                [self.saveButton setEnabled:YES];
                            }];
                                NSLog(@"selected upload %@", uploadURL);
                        
                    } else {
                                NSLog(@"selected called %@", uploadURL);
                    }
                }];
            }];
            [alert addButton:@"Discard" actionBlock:^(void) {
            }];
            [alert showCustom:self image:[UIImage imageNamed:@"icon_punch"] color:color title:@"Confirm!!!" subTitle:@"Do you want to upload a selected video?" closeButtonTitle:nil duration:0.0f];
            [alert setTitleFontFamily:@"FederalEscort" withSize:24];
            [alert setBodyTextFontFamily:@"HelveticaNeue" withSize:13];
            alert.backgroundViewColor = [UIColor whiteColor];
            alert.backgroundType = Blur;
        }
    }
}

-(BOOL) isVideoPortrait:(AVAsset *)asset
{
    BOOL isPortrait = FALSE;
    NSArray *tracks = [asset tracksWithMediaType:AVMediaTypeVideo];
    if([tracks    count] > 0) {
        AVAssetTrack *videoTrack = [tracks objectAtIndex:0];
        
        CGAffineTransform t = videoTrack.preferredTransform;
        // Portrait
        if(t.a == 0 && t.b == 1.0 && t.c == -1.0 && t.d == 0)
        {
            isPortrait = YES;
        }
        // PortraitUpsideDown
        if(t.a == 0 && t.b == -1.0 && t.c == 1.0 && t.d == 0)  {
            
            isPortrait = YES;
        }
        // LandscapeRight
        if(t.a == 1.0 && t.b == 0 && t.c == 0 && t.d == 1.0)
        {
            isPortrait = NO;
        }
        // LandscapeLeft
        if(t.a == -1.0 && t.b == 0 && t.c == 0 && t.d == -1.0)
        {
            isPortrait = NO;
        }
    }
    return isPortrait;
}


- (AVMutableVideoCompositionLayerInstruction *)layerInstructionAfterFixingOrientationForAsset:(AVAsset *)inAsset
                                                                                     forTrack:(AVMutableCompositionTrack *)inTrack
                                                                                       atTime:(CMTime)inTime
{
    //FIXING ORIENTATION//
    AVMutableVideoCompositionLayerInstruction *videolayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:inTrack];
    AVAssetTrack *videoAssetTrack = [[inAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    UIImageOrientation videoAssetOrientation_  = UIImageOrientationUp;
    BOOL  isVideoAssetPortrait_  = NO;
    CGAffineTransform videoTransform = videoAssetTrack.preferredTransform;
    
    if(videoTransform.a == 0 && videoTransform.b == 1.0 && videoTransform.c == -1.0 && videoTransform.d == 0)  {videoAssetOrientation_= UIImageOrientationRight; isVideoAssetPortrait_ = YES;}
    if(videoTransform.a == 0 && videoTransform.b == -1.0 && videoTransform.c == 1.0 && videoTransform.d == 0)  {videoAssetOrientation_ =  UIImageOrientationLeft; isVideoAssetPortrait_ = YES;}
    if(videoTransform.a == 1.0 && videoTransform.b == 0 && videoTransform.c == 0 && videoTransform.d == 1.0)   {videoAssetOrientation_ =  UIImageOrientationUp;}
    if(videoTransform.a == -1.0 && videoTransform.b == 0 && videoTransform.c == 0 && videoTransform.d == -1.0) {videoAssetOrientation_ = UIImageOrientationDown;}
    
    CGFloat FirstAssetScaleToFitRatio = 320.0 / videoAssetTrack.naturalSize.width;
    
    if(isVideoAssetPortrait_) {
        FirstAssetScaleToFitRatio = 320.0/videoAssetTrack.naturalSize.height;
        CGAffineTransform FirstAssetScaleFactor = CGAffineTransformMakeScale(FirstAssetScaleToFitRatio,FirstAssetScaleToFitRatio);
        [videolayerInstruction setTransform:CGAffineTransformConcat(videoAssetTrack.preferredTransform, FirstAssetScaleFactor) atTime:kCMTimeZero];
    }else{
        CGAffineTransform FirstAssetScaleFactor = CGAffineTransformMakeScale(FirstAssetScaleToFitRatio,FirstAssetScaleToFitRatio);
        [videolayerInstruction setTransform:CGAffineTransformConcat(CGAffineTransformConcat(videoAssetTrack.preferredTransform, FirstAssetScaleFactor),CGAffineTransformMakeTranslation(0, 160)) atTime:kCMTimeZero];
    }
    [videolayerInstruction setOpacity:0.0 atTime:inTime];
    return videolayerInstruction;
}

#pragma mark - GUI Player View Delegate Methods

- (void)playerWillEnterFullscreen {
    [[self navigationController] setNavigationBarHidden:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    playerView.layer.zPosition = 1;
}

- (void)playerWillLeaveFullscreen {
    [[self navigationController] setNavigationBarHidden:NO];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
}

- (void)playerDidEndPlaying {
    [playerView clean];
}

- (void)playerFailedToPlayToEnd {
    NSLog(@"Error: could not play video");
    [playerView clean];
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
