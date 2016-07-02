//
//  FCOEditCalloutViewController.m
//  fco
//
//  Created by Kryptonite on 7/14/15.
//  Copyright (c) 2015 Kryptonite. All rights reserved.
//

#import "FCOEditCalloutViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "UzysAssetsPickerController.h"
#import <GUIPlayerView/GUIPlayerView.h>
#import "FCOHTTPClient.h"
#import "FCOSessionModel.h"
#import <monpromptview.h>
#import "FCOLoadingView.h"
#import <TDSemiModal/TDSemiModal.h>
#import "FCOCustomTimePickerViewController.h"
#import "FCOCustomDatePickerViewController.h"
#import <AFNetworking/UIImageView+AFNetworking.h>
#import <IQKeyboardManager/iquiview+hierarchy.h>
#import <SCLAlertView-Objective-C/SCLAlertView.h>
#import "UIPlacePicker.h"

@interface FCOEditCalloutViewController () <GUIPlayerViewDelegate, FCOCustomTimePickerViewControllerDelegate, FCOCustomDatePickerViewControllerDelegate, UzysAssetsPickerControllerDelegate, UIPlacePickerDelegate>


@property (strong, nonatomic) GUIPlayerView *playerView;
@property (strong, nonatomic) GUIPlayerView *toogleView;
@property (strong, nonatomic) FCOCustomDatePickerViewController *datePickerView;
@property (strong, nonatomic) FCOCustomTimePickerViewController *timePickerView;
@property (strong, nonatomic) NSString *uploadID;
@property (strong, nonatomic) NSString *videoID;

@property (strong, nonatomic) UIPlacePicker *picker;
@property (strong, nonatomic) UIPlace *place;

@property (strong, nonatomic) NSString *latitude;
@property (strong, nonatomic) NSString *longitude;

@property BOOL isShowing;

@end

@implementation FCOEditCalloutViewController
@synthesize playerView;



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.progressView.hidden = YES;
    self.timeTextField.delegate = self;
    self.dateTextField.delegate = self;
    self.venueTextField.delegate = self;
    self.broadcastTextField.delegate = self;
    self.ticketTextField.delegate = self;

    [self getUserCalloutLabel];

    [self.textViewLabel setFont:[UIFont fontWithName:@"HelveticaNeue-MediumItalic" size:13]];
//    [self setOriginalTimeFormat:self.calloutModel.details_time];
//    [self setOriginalDateFormat:self.calloutModel.details_date];
//    self.venueTextField.text = self.calloutModel.details_venue;
    self.voteCountLabel.text = [NSString stringWithFormat:@"%@ VIEWS • %@ POINTS • %@ GOOD • %@ BAD • %@ COMMENTS", self.calloutModel.total_views, self.calloutModel.total_votes,  self.calloutModel.up , self.calloutModel.down ,self.calloutModel.total_comments];
    
    self.datePickerView = [[FCOCustomDatePickerViewController alloc] initWithNibName:@"FCOCustomDatePickerViewController" bundle:nil];
    self.datePickerView.delegate = self;
    
    self.timePickerView = [[FCOCustomTimePickerViewController alloc] initWithNibName:@"FCOCustomTimePickerViewController" bundle:nil];
    self.timePickerView.delegate = self;
    
    [self getCalloutImage];
    [self calloutInfo];
    
}



- (void)calloutInfo {
    NSLog(@"date textfield %@", self.timeTextField.text);
    NSLog(@"time textfield %@", self.dateTextField.text);
    NSLog(@"details date %@", self.calloutModel.details_date);
    NSLog(@"details time %@", self.calloutModel.details_time);
    
    
    UITapGestureRecognizer *tapImage = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(calloutThumbImageViewTapped:)];
    [self.calloutImageView addGestureRecognizer:tapImage];
    self.calloutImageView.userInteractionEnabled = YES;
    
    
    
    if (self.calloutModel.broadcast_url == (id)[NSNull null]) {
        self.broadcastTextField.text = @"http://";
    } else if (self.calloutModel.ticket_url == (id)[NSNull null]) {
        self.ticketTextField.text = @"http://";
    } else {
        self.broadcastTextField.text = self.calloutModel.broadcast_url;
        self.ticketTextField.text = self.calloutModel.ticket_url;
    }
    
    [self setOriginalDateFormat:self.calloutModel.details_date];
    [self setOriginalTimeFormat:self.calloutModel.details_time];
    self.venueTextField.text = self.calloutModel.details_venue;
    //self.broadcastTextField.text = self.calloutModel.broadcast_url;
    //self.ticketTextField.text = self.calloutModel.ticket_url;
    self.textViewLabel.text = self.calloutModel.desc;
    self.titleCategoryLabel.text = self.calloutModel.category;
}

- (void)calloutThumbImageViewTapped:(UIGestureRecognizer *)gestureRecognizer {
    if (self.calloutModel.video != (id)[NSNull null] && _isShowing == YES) {
        [self getVideoCallout];
        self.calloutImageView.hidden = YES;
        self.videoLabel.hidden = YES;
        _isShowing = NO;
        NSLog(@"tapped!");
    }
      NSLog(@"test tap!");
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.calloutModel.video != (id)[NSNull null]) {
        //[self getVideoCallout];
        //self.calloutImageView.hidden = NO;
        self.videoLabel.hidden = NO;
        if (self.calloutModel.photo != (id)[NSNull null]) {
            [self getCalloutPhoto];
        } else {
            [self getCalloutImage];
        }
    } else if (self.calloutModel.photo != (id)[NSNull null]) {
        [self getCalloutPhoto];
        self.videoLabel.text = @"Note: No video uploaded";
        self.videoLabel.hidden = NO;
        //self.calloutImageView.hidden = NO;
    } else {
        [self getCalloutImage];
        if (self.calloutModel.video == (id)[NSNull null]) {
            self.videoLabel.text = @"Note: No video uploaded";
            self.videoLabel.hidden = NO;
        } else {
            _isShowing = YES;
        }
        //self.calloutImageView.image = [UIImage imageNamed:@"callout_thumbnail"];
    }
    NSLog(@"video: %@", self.calloutModel.video);
    NSLog(@"photo: %@", self.calloutModel.photo);
    

    
}

-(void) viewWillDisappear:(BOOL)animated {
        [super viewWillDisappear:animated];
    if ([self.navigationController.viewControllers indexOfObject:self]==NSNotFound) {
          [playerView clean];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

# pragma mark - IBAction

- (IBAction)cancelButtonPressed:(UIButton *)sender {
   
}

- (IBAction)updateButtonPressed:(UIButton *)sender {

}

- (IBAction)cancelBarButtonPressed:(UIBarButtonItem *)sender {
    if (self.uploadID != nil) {
        SCLAlertView *alert = [[SCLAlertView alloc] init];
        UIColor *color = [UIColor colorWithRed:103.0/255.0 green:10.0/255.0 blue:5.0/255.0 alpha:1.0];
        [alert addButton:@"Discard" actionBlock:^(void) {
            [self.delegate cancel];
            [playerView clean];
            self.uploadID = nil;
            NSLog(@"discard upload url %@", self.uploadID);
        }];
        [alert showCustom:self image:[UIImage imageNamed:@"icon_punch"] color:color title:@"Confirm!" subTitle:@"You are already uploaded photo. Are you sure to discard?" closeButtonTitle:@"Close" duration:0.0f];
        [alert setTitleFontFamily:@"FederalEscort" withSize:24];
        [alert setBodyTextFontFamily:@"HelveticaNeue-Medium" withSize:13];
        alert.backgroundViewColor = [UIColor whiteColor];
        alert.backgroundType = Blur;
    } else if (self.uploadID != nil) {
        SCLAlertView *alert = [[SCLAlertView alloc] init];
        UIColor *color = [UIColor colorWithRed:103.0/255.0 green:10.0/255.0 blue:5.0/255.0 alpha:1.0];
        [alert addButton:@"Discard" actionBlock:^(void) {
            self.uploadID = nil;
            [self.tabBarController setSelectedIndex:1];
            NSLog(@"discard upload url %@", self.uploadID);
        }];
        [alert showCustom:self image:[UIImage imageNamed:@"icon_punch"] color:color title:@"Confirm!" subTitle:@"You are already uploaded photo. Are you sure to discard?" closeButtonTitle:@"Close" duration:0.0f];
        [alert setTitleFontFamily:@"FederalEscort" withSize:24];
        [alert setBodyTextFontFamily:@"HelveticaNeue-Medium" withSize:13];
        alert.backgroundViewColor = [UIColor whiteColor];
        alert.backgroundType = Blur;
        NSLog(@"upload url %@", self.uploadID);
        
    } else if (self.videoID != nil) {
        SCLAlertView *alert = [[SCLAlertView alloc] init];
        UIColor *color = [UIColor colorWithRed:103.0/255.0 green:10.0/255.0 blue:5.0/255.0 alpha:1.0];
        [alert addButton:@"Discard" actionBlock:^(void) {
            self.videoID = nil;
            [self.tabBarController setSelectedIndex:1];
            NSLog(@"discard upload url %@", self.videoID);
        }];
        [alert showCustom:self image:[UIImage imageNamed:@"icon_punch"] color:color title:@"Confirm!" subTitle:@"You are already uploaded video. Are you sure to discard?" closeButtonTitle:@"Close" duration:0.0f];
        [alert setTitleFontFamily:@"FederalEscort" withSize:24];
        [alert setBodyTextFontFamily:@"HelveticaNeue-Medium" withSize:13];
        alert.backgroundViewColor = [UIColor whiteColor];
        alert.backgroundType = Blur;
        
    }else {
        [self.delegate cancel];
        [playerView clean];
    }
}

- (IBAction)updateBarButtonPressed:(UIBarButtonItem *)sender {
    if ([self.textViewLabel.text length] == 0 || [self.dateTextField.text length] == 0 || [self.timeTextField.text length] == 0 || [self.venueTextField.text length] == 0) {
        [self promptAlertView:@"Warning!!!" withSub:@"Field must be set" withClose:@"OK"];
    } else if ((![self.broadcastTextField.text containsString:@"http://"] && [self.broadcastTextField.text length] >0) || (![self.ticketTextField.text containsString:@"http://"] && [self.ticketTextField.text length] >0)) {
        [self promptAlertView:@"Error!!!" withSub:@"Invalid URL avoid spaces or you must input \"http://\"                       Example: http://www.epicentre.tv" withClose:@"OK"];
    }
    else {
        [self setTimePickerFormat:self.timeTextField.text];
        [self setDatePickerFormat:self.dateTextField.text];
        NSString *urlAction = [NSString stringWithFormat:@"callouts/%@", self.calloutModel._id];
        
        if (self.uploadID == nil) {
            self.uploadID = self.calloutModel.photo;
            NSLog(@"upload id value %@", self.calloutModel.photo);
        } else if (self.uploadID != nil) {
            self.uploadID = self.uploadID;
            NSLog(@"upload not nil id value %@", self.uploadID);
        }
        
        if (self.videoID == nil) {
            self.videoID = self.calloutModel.video;
            NSLog(@"video id value %@", self.calloutModel.video);
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
        
        NSDictionary *params = @{
                                 @"user_id": self.calloutModel.user_id,
                                 @"description": self.textViewLabel.text,
                                 @"details_date": self.dateTextField.text,
                                 @"details_time": self.timeTextField.text,
                                 @"details_venue": self.venueTextField.text,
                                 @"broadcast_url": self.broadcastTextField.text,
                                 @"ticket_url": self.ticketTextField.text,
                                 @"photo": self.uploadID,
                                 @"video": self.videoID,
                                 @"latitude": self.latitude,
                                 @"longitude": self.longitude
                                 
                                 };
        FCOHTTPClient *fcoHttpClient = [FCOHTTPClient sharedInstance];
        [fcoHttpClient PUT:urlAction parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
            [playerView clean];
            SCLAlertView *alert = [[SCLAlertView alloc] init];
            [alert showWaiting:self title:@"Loading" subTitle:@"Please Wait..." closeButtonTitle:nil duration:2];
            [alert setTitleFontFamily:@"FederalEscort" withSize:24];
            [alert setBodyTextFontFamily:@"HelveticaNeue" withSize:13];
            alert.backgroundType = Transparent;
            
            double delayInSeconds = 2;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds *   NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                
                [self promptCustomAlertView:@"Success!!" withSub:@"Callout Successfully Updated!!" withClose:nil];
                [self updateCalloutsInfo];
                self.uploadID = nil;
                self.videoID = nil;
                self.latitude = nil;
                self.longitude = nil;
            });
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            NSLog(@"error callouts: %@", error);
        }];
    }
}

- (IBAction)uploadImageButtonPressed:(UIButton *)sender {
    UzysAssetsPickerController *picker = [[UzysAssetsPickerController alloc] init];
    picker.delegate = self;
    if ([sender isEqual:self.uploadImageButton]) {
        picker.maximumNumberOfSelectionVideo = 0;
        picker.maximumNumberOfSelectionPhoto = 1;
    }
    [self presentViewController:picker animated:YES completion:nil];
}

- (IBAction)uploadVideosButtonPressed:(UIButton *)sender {
    UzysAssetsPickerController *picker = [[UzysAssetsPickerController alloc] init];
    picker.delegate = self;
    if ([sender isEqual:self.uploadVideoButton]) {
        picker.maximumNumberOfSelectionPhoto = 0;
        picker.maximumNumberOfSelectionVideo = 1;
    }
    [self presentViewController:picker animated:YES completion:nil];
}



#pragma mark - Private Methods

- (void)updateCalloutsInfo {
   // [self setOriginalTimeFormat:self.timeTextField.text];
    //[self setOriginalDateFormat:self.dateTextField.text];
    self.calloutModel.desc = self.textViewLabel.text;
    self.calloutModel.details_date = self.dateTextField.text;
    self.calloutModel.details_time = self.timeTextField.text;
    self.calloutModel.details_venue = self.venueTextField.text;
    self.calloutModel.broadcast_url = self.broadcastTextField.text;
    self.calloutModel.ticket_url = self.ticketTextField.text;
    self.calloutModel.photo = self.uploadID;
    self.calloutModel.latitude = self.latitude;
    self.calloutModel.longitude = self.longitude;
    
    NSLog(@"details venue callout %@", self.calloutModel.details_venue);
}

- (void)getUserCalloutLabel {
    NSString *checkString = [NSString stringWithFormat:@"CALLS-OUT %@ & %@ for a %@", self.calloutModel.fighter_a, self.calloutModel.fighter_b, self.calloutModel.match_type];
    if (![checkString containsString:self.calloutModel.fighter_b]) {
        checkString = [NSString stringWithFormat:@"CALLS-OUT %@ for a %@", self.calloutModel.fighter_a, self.calloutModel.match_type];
    } else if (![checkString containsString:self.calloutModel.fighter_a]) {
        checkString = [NSString stringWithFormat:@"CALLS-OUT %@ for a %@", self.calloutModel.fighter_b, self.calloutModel.match_type];
    } else {
        checkString = [NSString stringWithFormat:@"CALLS-OUT %@ & %@ for a %@", self.calloutModel.fighter_a, self.calloutModel.fighter_b, self.calloutModel.match_type];
    }
    self.calloutLabel.text = checkString;
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

- (void)promptCustomAlertView:(NSString *)title withSub:(NSString *)subtitle withClose:(NSString *)close {
    
    SCLAlertView *alert = [[SCLAlertView alloc] init];
    UIColor *color = [UIColor colorWithRed:103.0/255.0 green:10.0/255.0 blue:5.0/255.0 alpha:1.0];
    [alert addButton:@"Done" actionBlock:^(void) {
        [self.view endEditing:YES];
        [self.delegate didUpdate];
        //[self updateCalloutsInfo];
        [self.textViewLabel resignFirstResponder];
        [self.dateTextField resignFirstResponder];
        [self.timeTextField resignFirstResponder];
        [playerView clean];
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

- (void)promptSelectePhotoAlertView:(NSString *)title withSub:(NSString *)subtitle withClose:(NSString *)close {
    SCLAlertView *alert = [[SCLAlertView alloc] init];
    UIColor *color = [UIColor colorWithRed:103.0/255.0 green:10.0/255.0 blue:5.0/255.0 alpha:1.0];
    [alert addButton:@"Done" actionBlock:^(void) {
    }];
    [alert showCustom:self image:[UIImage imageNamed:@"icon_punch"] color:color title:title     subTitle:subtitle closeButtonTitle:close duration:0.0f];
    [alert setTitleFontFamily:@"FederalEscort" withSize:24];
    [alert setBodyTextFontFamily:@"HelveticaNeue" withSize:13];
    alert.backgroundViewColor = [UIColor whiteColor];
    alert.backgroundType = Blur;
}

- (void)getVideoCallout {
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    playerView = [[GUIPlayerView alloc] initWithFrame:CGRectMake(0, 106, width, self.childView.bounds.size.height - 470)];
    [playerView setDelegate:self];
  
    [self.scrollView addSubview:playerView];
    //NSURL *URL = [NSURL URLWithString:@"http://download.blender.org/peach/bigbuckbunny_movies/BigBuckBunny_320x180.mp4"];
    //NSURL *url = [NSURL URLWithString:@"http://178.33.63.43/video/SWKFQ7JQ3LohDzfqmSgynw/1438768029/v55c1be71e54fc.mp4"];
    //NSURL *urlString = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"BenSaavaFightCallOut4" ofType:@"mp4"]];
    NSURL *urlString = [NSURL URLWithString:[NSString stringWithFormat:@"http://api.fightcallout.com/api/v1.0/uploads/%@.mp4", self.calloutModel.video]];
    [playerView setVideoURL:urlString];
    [playerView prepareAndPlayAutomatically:YES];
    //[playerView.fullscreenButton setEnabled:YES];
}

- (void)getCalloutPhoto {
    NSString *urlID = [NSString stringWithFormat:@"http://api.fightcallout.com/api/v1.0/uploads/%@", self.calloutModel.photo];
    NSURL *logoImageUrl = [NSURL URLWithString:urlID];
    __weak FCOEditCalloutViewController *selfRef = self;
    [self.calloutImageView setImageWithURLRequest:[NSURLRequest requestWithURL:logoImageUrl] placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        selfRef.calloutImageView.image = image;
        _isShowing = YES;
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        NSLog(@"error: %@", error);
    }];
}

//- (void)getUserPhoto {
//    FCOSessionModel *session = [FCOSessionModel sharedInstance];
//    FCOUserModel *userModel = [session activeUser];
//    NSString *urlID = [NSString stringWithFormat:@"http://api.fightcallout.com/api/v1.0/uploads/%@", userModel.photo];
//    NSURL *logoImageUrl = [NSURL URLWithString:urlID];
//    __weak FCOEditCalloutViewController *selfRef = self;
//    [self.imageView setImageWithURLRequest:[NSURLRequest requestWithURL:logoImageUrl] placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
//        selfRef.imageView.image = image;
//    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
//        NSLog(@"error photo: %@", error);
//    }];
//}

- (void)getCalloutImage {
    FCOSessionModel *session = [FCOSessionModel sharedInstance];
    FCOUserModel *userModel = [session activeUser];
    NSString *urlID = [NSString stringWithFormat:@"http://api.fightcallout.com/api/v1.0/uploads/%@", userModel.photo];
    NSURL *logoImageUrl = [NSURL URLWithString:urlID];
    __weak FCOEditCalloutViewController *selfRef = self;
    [self.imageView setImageWithURLRequest:[NSURLRequest requestWithURL:logoImageUrl] placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        selfRef.calloutImageView.image = image;
        _isShowing = YES;
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        NSLog(@"error photo: %@", error);
    }];
}

- (void)setOriginalDateFormat:(NSString *)originalDate {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *date = [dateFormatter dateFromString:originalDate];
    NSDateFormatter *dteFormatter = [[NSDateFormatter alloc] init];
    [dteFormatter setDateFormat:@"MMM. dd, yyyy"];
    NSString *convertedTime = [dteFormatter stringFromDate:date];
    self.dateTextField.text = convertedTime;
}

- (void)setOriginalTimeFormat:(NSString *)originalTime {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setDateFormat:@"HH:mm:ss"];
    NSDate *time = [formatter dateFromString: originalTime];
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
    [timeFormatter setDateFormat:@"hh:mm a"];
    NSString *timex = [timeFormatter stringFromDate:time];
    self.timeTextField.text = timex;
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

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
        
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
    }
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

#pragma mark - UIPlacePicker Delegate

-(void)placePickerDidCancel {
    [self hidePlacePicker];
    [playerView clean];
    NSLog(@"taee");
}
-(void)hidePlacePicker{
    [self.picker dismissViewControllerAnimated:YES completion:^{
        self.venueTextField.text = [self.picker getAddressWithCurrentLocation];
      //  NSLog(@"test place %@", [self.picker getAddressWithCurrentLocation]);
        
        self.latitude = [NSString stringWithFormat:@"%f", self.picker.myLocation.coordinate.latitude];
        self.longitude = [NSString stringWithFormat:@"%f", self.picker.myLocation.coordinate.longitude];
        NSLog(@"latitude %@", self.latitude);
        NSLog(@"longitude %@", self.longitude);
    }];
}


- (void)placePickerDidSelectPlace:(UIPlace *)place {
    self.place = place;
    
}

- (void)updateTextField:(NSString *)placeName {
    
    self.venueTextField.text = placeName;

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
            //weakSelf.calloutImageView.image = img;
            
            NSData *dataToUpload = UIImageJPEGRepresentation(img, 0.5);
            if ([UIImage imageWithData:dataToUpload]) {
                [self.cancelBarButton setEnabled:NO];
                [self.cancelBarButton setEnabled:NO];
                
                SCLAlertView *alert = [[SCLAlertView alloc] init];
                
                UIColor *color = [UIColor colorWithRed:103.0/255.0 green:10.0/255.0 blue:5.0/255.0 alpha:1.0];
                [alert addButton:@"Save" actionBlock:^(void) {
                    NSLog(@"Save button tapped");
                    [_scrollView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
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

                        
                        [self promptSelectePhotoAlertView:@"Success!!!" withSub:@"Photo was successfully uploaded!" withClose:nil];
                        [self.cancelBarButton setEnabled:YES];
                        [self.updateBarButton setEnabled:YES];
                    
                        self.uploadID = responseObject[@"upload"][@"id"];
                    } failure:^(NSURLSessionDataTask *task, NSError *error) {
                        //NSString *errorMsg = [NSString stringWithUTF8String:[error.userInfo[@"com.alamofire.serialization.response.error.data"] bytes]];
                        NSLog(@"error %@", error.localizedDescription);
                    }];
                }];
                [alert addButton:@"Discard" actionBlock:^(void) {
                    //                    [self getPhoto];
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
                [self.cancelBarButton setEnabled:NO];
                [self.cancelBarButton setEnabled:NO];
                
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
                            [self.cancelBarButton setEnabled:YES];
                            [self.updateBarButton setEnabled:YES];
                            NSLog(@"upload video id %@", self.videoID);
                        } failure:^(NSURLSessionDataTask *task, NSError *error) {
                            //NSString *errorMsg = [NSString stringWithUTF8String:[error.userInfo[@"com.alamofire.serialization.response.error.data"] bytes]];
                            NSLog(@"error %@", error.localizedDescription);
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

# pragma mark - UITextField Delegate

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (textField == self.broadcastTextField || textField == self.ticketTextField) {
        
        return YES;
    }
    
    if (textField.isAskingCanBecomeFirstResponder == NO) {
            //Do your work on tapping textField.
            if (self.dateTextField == textField) {
                [self presentSemiModalViewController:self.datePickerView];
            } else if (self.timeTextField == textField) {
                [self presentSemiModalViewController:self.timePickerView];
            } else if (self.venueTextField == textField) {
                self.picker = [[UIPlacePicker alloc] initWithUIPlace:self.place];
                self.picker.delegate = self;
                [self presentViewController:self.picker animated:YES completion:^{
                }];
            }
        }
        return NO;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField {
    if (self.broadcastTextField == textField && [textField.text length] == 0) {
        self.broadcastTextField.text = @"http://";
    }
    if (self.ticketTextField == textField && [textField.text length] == 0) {
        self.ticketTextField.text = @"http://";
        NSLog(@"ticket!!");
    }
    
}


-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (self.broadcastTextField == textField || self.ticketTextField == textField) {
        NSMutableString *mutableText = textField.text.mutableCopy;
        [mutableText replaceCharactersInRange:range withString:string];
        return [mutableText hasPrefix:@"http://"];
    }
    return YES;
}


#pragma mark - FCOCustomDatePickerController Delegate

-(void)datePickerSetDate:(FCOCustomDatePickerViewController *)viewController {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *stringDate = [dateFormatter stringFromDate:viewController.datePicker.date];
    NSDate *date = [dateFormatter dateFromString:stringDate];
    NSDateFormatter *dteFormatter = [[NSDateFormatter alloc] init];
    [dteFormatter setDateFormat:@"MMM. dd, yyyy"];
    NSString *convertedTime = [dteFormatter stringFromDate:date];
    self.dateTextField.text = convertedTime;
    [self dismissSemiModalViewController:self.datePickerView];
}


-(void)datePickerCancel:(FCOCustomDatePickerViewController *)viewController {
    [self dismissSemiModalViewController:self.datePickerView];
    self.dateTextField.text = nil;
}

# pragma mark - FCOCustomTimePickerController Delegate

- (void)timePickerSetTime:(FCOCustomTimePickerViewController *)viewController {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm:ss"];
    NSString *stringDate = [dateFormatter stringFromDate:viewController.timePicker.date];
    NSDate *date = [dateFormatter dateFromString:stringDate];
    NSDateFormatter *dteFormatter = [[NSDateFormatter alloc] init];
    [dteFormatter setDateFormat:@"hh:mm a"];
    NSString *convertedTime = [dteFormatter stringFromDate:date];
    self.timeTextField.text = convertedTime;
    [self dismissSemiModalViewController:self.timePickerView];
    
}
- (void)timePickerCancel:(FCOCustomTimePickerViewController *)viewController {
    [self dismissSemiModalViewController:self.timePickerView];
}


#pragma mark - GUI Player View Delegate Methods

- (void)playerWillEnterFullscreen {
    [[self navigationController] setNavigationBarHidden:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    [_scrollView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
    self.scrollView.scrollEnabled = NO;
    [self.cancelBarButton setEnabled:YES];
    [self.updateBarButton setEnabled:NO];
    NSLog(@"to fullscreen");
}

- (void)playerWillLeaveFullscreen {
    [[self navigationController] setNavigationBarHidden:NO];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    self.scrollView.scrollEnabled = YES;
    [self.cancelBarButton setEnabled:YES];
    [self.updateBarButton setEnabled:YES];
}

- (void)playerDidEndPlaying {
    [playerView pause];
}

- (void)playerFailedToPlayToEnd {
    NSLog(@"Error: could not play video");
    [playerView clean];
}


@end
