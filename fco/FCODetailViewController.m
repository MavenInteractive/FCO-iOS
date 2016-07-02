//
//  FCODetailViewController.m
//  fco
//
//  Created by Kryptonite on 6/18/15.
//  Copyright (c) 2015 Kryptonite. All rights reserved.
//

#import "FCODetailViewController.h"
#import <GUIPlayerView/GUIPlayerView.h>
#import <AFNetworking/UIImageView+AFNetworking.h>
#import "FCOCommentViewController.h"
#import "LGSemiModalNavViewController.h"
#import <IQKeyboardManager/IQKeyboardManager.h>
#import "FCOLoginViewController.h"
#import "FCOHTTPClient.h"
#import "FCOSessionModel.h"
#import <SCLAlertView-Objective-C/SCLAlertView.h>
#import <JMActionSheetDescription/JMActionSheet.h>
#import "JMCollectionItem.h"
#import <FBSDKShareKit/FBSDKShareKit.h>
#import <Social/Social.h>
#import <GooglePlus/GooglePlus.h>
#import <GoogleOpenSource/GoogleOpenSource.h>
#import "UIPlacePicker.h"
#import "FCOMapViewController.h"
#import "FCOMainTabBar.h"
#import <MessageUI/MessageUI.h>
#import <FBSDKGraphRequest.h>
#import <AssetsLibrary/AssetsLibrary.h>
//#import <FBSDKLoginManager.h>
#import <FBSDKLoginKit/FBSDKLoginManager.h>
#import <FBSDKAccessToken.h>
#import <Google/SignIn.h>
//#import <FBSDKShareLinkContent.h>
#import <FBSDKShareKit/FBSDKShareLinkContent.h>

static NSString *const kClientId = @"774527338502-mplqcehfrmdrojlb9k0tsb5kcnetn928.apps.googleusercontent.com";


@interface FCODetailViewController () <GUIPlayerViewDelegate, UIGestureRecognizerDelegate, GPPSignInDelegate, UIDocumentInteractionControllerDelegate, UIPlacePickerDelegate, FCOMapViewControllerDelegate, KINWebBrowserDelegate,MFMailComposeViewControllerDelegate, FBSDKSharingDelegate, GIDSignInDelegate, GIDSignInUIDelegate, FBSDKSharingDelegate, FCOCommentViewControllerDelegate>
@property (strong, nonatomic) GUIPlayerView *playerView;
@property (strong, nonatomic) IBOutlet UIView *childView;
@property (strong, nonatomic) NSMutableArray *comments;
@property (assign, nonatomic) BOOL keyboardIsShowing;

@property (strong, nonatomic) UIPlacePicker *picker;
@property (strong, nonatomic) UIPlace *place;

@property BOOL isShowing;
@property BOOL isVoteSelected;
//@property(nonatomic, readonly, retain) UITabBarController *tabBarController;


@end

@implementation FCODetailViewController

@synthesize playerView, imageMain;

# pragma mark - View Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];

//    UIEdgeInsets insets = _scrollView.contentInset;
//    insets.bottom = 50;
//    _scrollView.contentInset = insets;
    
    NSLog(@"callout # %@", self.calloutModel._id);
    NSLog(@"broadcast url %@", self.calloutModel.broadcast_url);
    
    // Do any additional setup after loading the view.
    //change font style in navigation bar
    [[UISegmentedControl appearance] setTitleTextAttributes:@{
                                                              NSForegroundColorAttributeName : [UIColor whiteColor]
                                                              } forState:UIControlStateNormal];
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"FederalEscort" size:21], NSFontAttributeName, [UIColor lightGrayColor], NSForegroundColorAttributeName, nil]];
    
    //hide barback item & color
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] init];
    barButton.title = @"";
    self.navigationController.navigationBar.topItem.backBarButtonItem = barButton;
    self.navigationController.navigationBar.tintColor = [UIColor lightGrayColor];
    [self callOutData];
    [self getUserPhoto];
    UITapGestureRecognizer* gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userTappedOnLink:)];
    [self.venueLabel setUserInteractionEnabled:YES];
    [self.venueLabel addGestureRecognizer:gesture];
    NSLog(@"callout user id %@", self.calloutModel.user_id);
    NSLog(@"callout id %@", self.calloutModel._id);
    NSLog(@"broadcast %@", self.calloutModel.broadcast_url);
    
    UITapGestureRecognizer *tapImage = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(calloutThumbnailImageViewTapped:)];
    [self.calloutImageView addGestureRecognizer:tapImage];
    self.calloutImageView.userInteractionEnabled = YES;
    
}


-(void)signIn:(GIDSignIn *)signIn didSignInForUser:(GIDGoogleUser *)user withError:(NSError *)error {
    if (error != nil) {
        NSLog(@"looks like we got a sign-in error: %@", error);
    } else {
        NSLog(@"Wow! our user signed in! %@", user);
    }
}

- (void)calloutThumbnailImageViewTapped:(UIGestureRecognizer *)gestureRecognizer {
    if (self.calloutModel.video != (id)[NSNull null] && _isShowing == YES) {
        [self getVideoCallout];
        self.calloutImageView.hidden = YES;
        self.playVideoLabel.hidden = YES;
        _isShowing = NO;
            NSLog(@"tapped!");
    }

}

- (void)callOutData {
    //user callout label
    [self getUserCalloutLabel];

    //category title label
    self.titleCategoryLabel.text = self.calloutModel.category;
    self.descpTextView.text = [NSString stringWithFormat:@"\"%@\"", self.calloutModel.desc];
    [self.descpTextView setFont:[UIFont fontWithName:@"HelveticaNeue-MediumItalic" size:13]];
    [self.descpTextView setContentOffset:CGPointMake(0.0, 0.0) animated:YES];
    self.dateLabel.text = self.calloutModel.details_date;
    NSLog(@"callout photo %@", self.calloutModel.photo);
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setDateFormat:@"HH:mm:ss"];
    NSDate *time = [formatter dateFromString: self.calloutModel.details_time];
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
    [timeFormatter setDateFormat:@"hh:mm a"];
    NSString *timex = [timeFormatter stringFromDate:time];

    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //[formatterx setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *date = [dateFormatter dateFromString: self.calloutModel.details_date];
    NSDateFormatter *dteFormatter = [[NSDateFormatter alloc] init];
    [dteFormatter setDateFormat:@"MMM. dd, yyyy"];
    NSString *convertedDate = [dteFormatter stringFromDate:date];
    
    
    NSDateFormatter *createdDateFormatter = [[NSDateFormatter alloc] init];
    //[formatterx setDateStyle:NSDateFormatterMediumStyle];
    [createdDateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *createdDate = [createdDateFormatter dateFromString: self.calloutModel.created_at];
    NSDateFormatter *creatdDateFormatter = [[NSDateFormatter alloc] init];
    [creatdDateFormatter setDateFormat:@"MMM. dd, yyyy"];
    NSString *convertedCreatedDate = [dteFormatter stringFromDate:createdDate];
    
    if (convertedDate == nil || timex == nil) {
        self.dateLabel.text = @"Anytime";
        self.timeLabel.text = @"Anytime";
    } else {
        self.timeLabel.text = timex;
        self.dateLabel.text = convertedDate;
    }
    self.createdAtLabel.text = convertedCreatedDate;
    self.venueLabel.text = self.calloutModel.details_venue;
    self.voteLabel.text = [NSString stringWithFormat:@"%@ VIEWS • %@ POINTS • %@ GOOD • %@ BAD • %@ COMMENTS", self.calloutModel.total_views, self.calloutModel.total_votes,  self.calloutModel.up , self.calloutModel.down ,self.calloutModel.total_comments];
}


- (void)viewWillAppear:(BOOL)animated {
    //[self hideTabBar:self.tabBarController];
    [super viewWillAppear:animated];
    NSLog(@"callout id %@", self.calloutModel._id);
    if (playerView.isPlaying) {
        [playerView pause];
     
        
    } else {
        if (self.calloutModel.video != (id)[NSNull null]) {
            //[self getVideoCallout];
            //self.calloutImageView.hidden = NO;
            self.playVideoLabel.hidden = NO;
            if (self.calloutModel.photo != (id)[NSNull null]) {
                 [self getCalloutPhoto];
            } else {
                 [self getCalloutImage];
            }
        } else if (self.calloutModel.photo != (id)[NSNull null]) {
            [self getCalloutPhoto];
            self.playVideoLabel.text = @"Note: No video uploaded";
            self.playVideoLabel.hidden = NO;
            //self.calloutImageView.hidden = NO;
        } else {
            [self getCalloutImage];
            if (self.calloutModel.video == (id)[NSNull null]) {
                self.playVideoLabel.text = @"Note: No video uploaded";
                self.playVideoLabel.hidden = NO;
            } else {
                 _isShowing = YES;
            }
            //self.calloutImageView.image = [UIImage imageNamed:@"callout_thumbnail"];
        }
        NSLog(@"video: %@", self.calloutModel.video);
        NSLog(@"photo: %@", self.calloutModel.photo);
        self.navigationController.interactivePopGestureRecognizer.delegate = self;
    }
    
    if (self.calloutModel.broadcast_url == (id)[NSNull null] || [self.calloutModel.broadcast_url  isEqual: @""] || [self.calloutModel.broadcast_url isEqual:@"http://"]) {
        [self.broadcastButton setEnabled:NO];
        [self.broadcastButton setTitle:@"   Broadcast" forState:UIControlStateDisabled];
        [self.broadcastButton setBackgroundColor:[UIColor colorWithRed:155.0f/255.0f green:3.0f/255.0f blue:21.0f/255.0f alpha:.1]];
        NSLog(@"broadcast url %@", self.calloutModel.broadcast_url);
    }
    
    if (self.calloutModel.ticket_url == (id)[NSNull null] || [self.calloutModel.ticket_url  isEqual: @""] || [self.calloutModel.ticket_url isEqual:@"http://"]) {
        [self.ticketButton setEnabled:NO];
        [self.ticketButton setTitle:@"   Ticket" forState:UIControlStateDisabled];
        [self.ticketButton setBackgroundColor:[UIColor colorWithRed:155.0f/255.0f green:3.0f/255.0f blue:21.0f/255.0f alpha:.1]];
        NSLog(@"ticket url %@", self.calloutModel.ticket_url);
    }
    else {
        [self.broadcastButton setEnabled:YES];
        [self.ticketButton setEnabled:YES];
    }
    
    NSLog(@"player view size width : %f", playerView.frame.size.width);
    NSLog(@"player view size height : %f", playerView.frame.size.height);
    
    
}

-(void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if ([self.navigationController.viewControllers indexOfObject:self]==NSNotFound) {
        [playerView clean];
    }
 
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




# pragma mark - Private Methods

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)] &&
        gestureRecognizer == self.navigationController.interactivePopGestureRecognizer) {
        return NO;
    }
    return YES;
}

- (void)setCalloutLabel:(NSString *)title action:(NSString *)callsout andSign:(NSString *)andSign for:(NSString *)forLabel {
    self.userCalloutLabel.text = title;
    UIColor *lightGray = [UIColor lightGrayColor];
    UIFont *helveticaNormal = [UIFont fontWithName:@"Helvetica" size:13];
    [self.userCalloutLabel setFontColor:lightGray string:callsout];
    [self.userCalloutLabel setFontColor:lightGray string:andSign];
    [self.userCalloutLabel setFont:helveticaNormal string:callsout];
    [self.userCalloutLabel setFont:helveticaNormal string:andSign];
    [self.userCalloutLabel setFont:helveticaNormal string:forLabel];
}

- (void)getUserCalloutLabel {
    NSString *checkString = [NSString stringWithFormat:@"%@ CALLS-OUT %@ & %@ for a %@ %@",self.calloutModel.user_first_name, self.calloutModel.fighter_a, self.calloutModel.fighter_b, [self.calloutModel.category uppercaseString], [self.calloutModel.match_type uppercaseString]];
    if (![checkString containsString:self.calloutModel.fighter_b]) {
        checkString = [NSString stringWithFormat:@"%@ CALLS-OUT %@ for a %@ %@",self.calloutModel.user_first_name, self.calloutModel.fighter_a, [self.calloutModel.category uppercaseString], [self.calloutModel.match_type uppercaseString]];
    } else if (![checkString containsString:self.calloutModel.fighter_a]) {
        checkString = [NSString stringWithFormat:@"%@ CALLS-OUT %@ for a %@ %@",self.calloutModel.user_first_name, self.calloutModel.fighter_b, [self.calloutModel.category uppercaseString], [self.calloutModel.match_type uppercaseString]];
    } else {
        checkString = [NSString stringWithFormat:@"%@ CALLS-OUT %@ & %@ for a %@ %@",self.calloutModel.user_first_name, self.calloutModel.fighter_a, self.calloutModel.fighter_b, [self.calloutModel.category uppercaseString], [self.calloutModel.match_type uppercaseString]];
    }
    self.userCalloutLabel.text = checkString;
}

- (void)currentTimeFormat:(NSString *)currentTime convertedString:(NSString *)convertedTime {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
   
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *time = [formatter dateFromString: currentTime];
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
    [timeFormatter setDateFormat:@"MMM. dd, yyyy"];
    convertedTime = [timeFormatter stringFromDate:time];
}

- (void)getCalloutPhoto {
    NSString *urlID = [NSString stringWithFormat:@"http://api.fightcallout.com/api/v1.0/uploads/%@", self.calloutModel.photo];
    NSLog(@"PHOTO URL : %@",urlID);
    NSURL *logoImageUrl = [NSURL URLWithString:urlID];
    __weak FCODetailViewController *selfRef = self;
    [self.calloutImageView setImageWithURLRequest:[NSURLRequest requestWithURL:logoImageUrl] placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        selfRef.calloutImageView.image = image;
        _isShowing = YES;
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        NSLog(@"error: %@", error);
    }];
}

- (void)getUserPhoto {
    NSString *urlID = [NSString stringWithFormat:@"http://api.fightcallout.com/api/v1.0/uploads/%@", self.calloutModel.user_photo];
    
    NSURL *logoImageUrl = [NSURL URLWithString:urlID];
    __weak FCODetailViewController *selfRef = self;
    [self.userImageView setImageWithURLRequest:[NSURLRequest requestWithURL:logoImageUrl] placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        selfRef.userImageView.image = image;
        _isShowing = YES;
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        NSLog(@"error: %@", error);
    }];
}

- (void)getVideoCallout {
        CGFloat width = [UIScreen mainScreen].bounds.size.width;
        playerView = [[GUIPlayerView alloc] initWithFrame:CGRectMake(0, 106, width, self.childView.bounds.size.height - 470)];
        [playerView setDelegate:self];
        [self.childView addSubview:playerView];
        //NSURL *URL = [NSURL URLWithString:@"http://download.blender.org/peach/bigbuckbunny_movies/BigBuckBunny_320x180.mp4"];
        //NSURL *url = [NSURL URLWithString:@"http://178.33.63.43/video/SWKFQ7JQ3LohDzfqmSgynw/1438768029/v55c1be71e54fc.mp4"];
        //NSURL *urlString = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"BenSaavaFightCallOut4" ofType:@"mp4"]];
    NSURL *urlString = [NSURL URLWithString:[NSString stringWithFormat:@"http://api.fightcallout.com/api/v1.0/uploads/%@.mp4", self.calloutModel.video]];
    self.videoURL = [urlString absoluteString];
    NSLog(@"video url %@", self.videoURL);
        [playerView setVideoURL:urlString];
        [playerView prepareAndPlayAutomatically:YES];
    
}

- (void)postVoteUp {
    FCOSessionModel *session = [FCOSessionModel sharedInstance];
    if (!session.isLoggedIn) {
        [self promptAlertView:@"Warning!!!" withSub:@"You must login to vote" withClose:@"OK"];
    } else {
        FCOUserModel *userModel = [session activeUser];
        NSLog(@"user model: %@", userModel._id);
        NSLog(@"callout id: %@", self.calloutModel._id);
        NSDictionary *params = @{
                                 @"tally": @"+1",
                                 @"user_id": userModel._id,
                                 @"callout_id": self.calloutModel._id
                                 };
        FCOHTTPClient *fcoHttpClient = [FCOHTTPClient sharedInstance];
        [fcoHttpClient POST:@"votes" parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
            [self promptCustomAlertView:@"Success!!!" withSub:@"You have voted successfully" withClose:nil];
             _voteUpButton.enabled = YES;
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            NSInteger statusCode = error.code;
            if (statusCode == -999) {
                [self promptAlertView:@"Check Connectivity!!!" withSub:@"The operation couldn't be completed" withClose:@"OK"];
            } else if (statusCode == -1009 || statusCode == -1004 || statusCode == -1003) {
                [self promptAlertView:@"Failed!!!" withSub:@"Please check your network connection" withClose:@"OK"];
            } else if (statusCode == -1011) {
                [self promptAlertView:@"Warning!!!" withSub:@"You can only vote once per callout!" withClose:@"OK"];
            }
            else {
                NSLog(@"error %@", error);
            }
             _voteUpButton.enabled = YES;
        }];
    }
}

- (void)postVoteDown {
    FCOSessionModel *session = [FCOSessionModel sharedInstance];
    
    if (!session.isLoggedIn) {
        [self promptAlertView:@"Warning!!!" withSub:@"You must login to vote" withClose:@"OK"];
    } else {
        FCOUserModel *userModel = [session activeUser];
        NSDictionary *params = @{
                                 @"tally": @"-1",
                                 @"user_id": userModel._id,
                                 @"callout_id": self.calloutModel._id
                                 };
        FCOHTTPClient *fcoHttpClient = [FCOHTTPClient sharedInstance];
        [fcoHttpClient POST:@"votes" parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
            [self promptCustomAlertView:@"Success!!!" withSub:@"You have voted successfully" withClose:nil];
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            NSInteger statusCode = error.code;
            if (statusCode == -999) {
                [self promptAlertView:@"Check Connectivity!!!" withSub:@"The operation couldn't be completed" withClose:@"OK"];
                _voteDownButton.enabled = YES;
            } else if (statusCode == -1009 || statusCode == -1004 || statusCode == -1003) {
                [self promptAlertView:@"Failed!!!" withSub:@"Please check your network connection" withClose:@"OK"];
            } else if (statusCode == -1011) {
                [self promptAlertView:@"Warning!!!" withSub:@"You can only vote once per callout!" withClose:@"OK"];
            } else {
                NSLog(@"error %@", error);
            }
            _voteDownButton.enabled = YES;
        }];
    }
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

- (void)promptCustomAlertView:(NSString *)title withSub:(NSString *)subtitle withClose:(NSString *)close {
    SCLAlertView *alert = [[SCLAlertView alloc] init];
    UIColor *color = [UIColor colorWithRed:103.0/255.0 green:10.0/255.0 blue:5.0/255.0 alpha:1.0];
    [alert addButton:@"Done" actionBlock:^(void) {
    [self updateCallouts];

    //[self.navigationController popViewControllerAnimated:YES];
    }];
    [alert showCustom:self image:[UIImage imageNamed:@"icon_punch"] color:color title:title     subTitle:subtitle closeButtonTitle:close duration:0.0f];
    [alert setTitleFontFamily:@"FederalEscort" withSize:24];
    [alert setBodyTextFontFamily:@"HelveticaNeue" withSize:13];
    alert.backgroundViewColor = [UIColor whiteColor];
    alert.backgroundType = Blur;
}

- (void)updateCallouts {
    NSString *URLaction = [NSString stringWithFormat:@"callouts/%@/edit", self.calloutModel._id];
    FCOHTTPClient *fcoHttpClient = [FCOHTTPClient sharedInstance];
    [fcoHttpClient GET:URLaction parameters:@"" success:^(NSURLSessionDataTask *task, id responseObject) {

        FCOCalloutModel *updateCalloutModel = [[FCOCalloutModel alloc] initWithDictionary:responseObject];
        
    self.voteLabel.text = [NSString stringWithFormat:@"%@ VIEWS • %@ POINTS • %@ GOOD • %@ BAD • %@ COMMENTS", updateCalloutModel.total_views, updateCalloutModel.total_votes,  updateCalloutModel.up , updateCalloutModel.down ,updateCalloutModel.total_comments];
        
        //[self.tableView reloadData];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSInteger statusCode = error.code;
        if (statusCode == -999) {
            [self promptAlertView:@"Check Connectivity!!!" withSub:@"The operation couldn't be completed" withClose:@"OK"];
        } else if (statusCode == -1009 || statusCode == -1004 || statusCode == -1003) {
            [self promptAlertView:@"Failed!!!" withSub:@"Please check your network connection" withClose:@"OK"];
        } else {
            NSLog(@"error %@", error);
        }
    }];
    
}


- (void)getCalloutImage {
    NSString *urlID = [NSString stringWithFormat:@"http://api.fightcallout.com/api/v1.0/uploads/%@", self.calloutModel.user_photo];
    
    NSURL *logoImageUrl = [NSURL URLWithString:urlID];
    __weak FCODetailViewController *selfRef = self;
    [self.userImageView setImageWithURLRequest:[NSURLRequest requestWithURL:logoImageUrl] placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        selfRef.calloutImageView.image = image;
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        NSLog(@"error: %@", error);
    }];
}

-(void)instaGramWallPost {
//    NSString *urlID = [NSString stringWithFormat:@"http://api.fightcallout.com/api/v1.0/uploads/%@", self.calloutModel.photo];
//    UIImage *imge = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:urlID]]];
//    
//    NSURL *instagramURL = [NSURL URLWithString:@"instagram://app"];
//    if([[UIApplication sharedApplication] canOpenURL:instagramURL]) //check for App is install or not
//    {  //[[UIApplication sharedApplication] openURL:instagramURL];
//        NSData *imageData = UIImagePNGRepresentation(imge); //convert image into .png format.
//        NSFileManager *fileManager = [NSFileManager defaultManager];//create instance of NSFileManager
//        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); //create an array and store result of our search for the documents directory in it
//        NSString *documentsDirectory = [paths objectAtIndex:0]; //create NSString object, that holds our exact path to the documents directory
//        NSString *fullPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"insta.igo"]]; //add our image to the path
//        [fileManager createFileAtPath:fullPath contents:imageData attributes:nil]; //finally save the path (image)
//        NSLog(@"image saved");
//        
//        CGRect rect = CGRectMake(0 ,0 , 0, 0);
//        UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, self.view.opaque, 0.0);
//        [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
//        UIGraphicsEndImageContext();
//        NSString *fileNameToSave = [NSString stringWithFormat:@"Documents/insta.igo"];
//        NSString  *jpgPath = [NSHomeDirectory() stringByAppendingPathComponent:fileNameToSave];
//        NSLog(@"jpg path %@",jpgPath);
//        NSString *newJpgPath = [NSString stringWithFormat:@"%@",jpgPath];
//        NSLog(@"with File path %@",newJpgPath);
//        NSURL *igImageHookFile = [[NSURL alloc]initFileURLWithPath:newJpgPath];
//        //NSURL *igImageHookFile = [NSURL URLWithString:newJpgPath];
//        NSLog(@"url Path %@",igImageHookFile);
//        [[UIApplication sharedApplication] openURL:igImageHookFile];
//        self.documentController.UTI = @"com.instagram.exclusivegram";
//        self.documentController = [self setupControllerWithURL:igImageHookFile usingDelegate:self];
//        self.documentController=[UIDocumentInteractionController interactionControllerWithURL:igImageHookFile];
//        NSString *caption = @"weeeee"; //settext as Default Caption
//        self.documentController.annotation=[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%@",caption],@"InstagramCaption", nil];
//        [self.documentController presentOpenInMenuFromRect:rect inView: self.view animated:YES];
//    }
//    else
//    {
//        NSLog (@"Instagram not found");
//        [self promptAlertView:@"Warning" withSub:@"Instagram not found please install it, then try again." withClose:@"OK"];
//    }
    
    UIImage *screenShot = self.calloutImageView.image;
    NSString *savePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Test.ig"];
    [UIImagePNGRepresentation(screenShot) writeToFile:savePath atomically:YES];
    
    CGRect rect = CGRectMake(0 ,0 , 0, 0);
    
    
    NSURL *instagramURL = [NSURL URLWithString:@"instagram://media?id=MEDIA_ID"];
    
    NSString *documentDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    // *.igo is exclusive to instagram
    NSString *saveImagePath = [documentDirectory stringByAppendingPathComponent:@"Image.igo"];
    NSData *imageData = UIImagePNGRepresentation(screenShot);
    [imageData writeToFile:saveImagePath atomically:YES];
    
    NSURL *imageURL=[NSURL fileURLWithPath:saveImagePath];
    self.documentController = [[UIDocumentInteractionController alloc]init];
    self.documentController.delegate=self;
    self.documentController.UTI=@"com.instagram.exclusivegram";
    [self.documentController setURL:imageURL];
    NSString *caption = @"weeeee"; //settext as Default Caption
    self.documentController.annotation=[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%@",caption],@"InstagramCaption", nil];

    if ([[UIApplication sharedApplication] canOpenURL:instagramURL]) {
        
        [self.documentController presentOpenInMenuFromRect: rect    inView: self.view animated: YES ];
        
    }
    else
    {
//        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[NSString stringWithFormat:NSLocalizedString(@"imageShareViewNoInstagramAccountAlertTitle", nil)] message:[NSString stringWithFormat:NSLocalizedString(@"imageShareViewNoInstagramAccountAlertMessage", nil)]delegate:nil cancelButtonTitle:[NSString stringWithFormat:NSLocalizedString(@"imageShareViewNoFacebookAccountAlertCancelButton", nil)]otherButtonTitles:nil, nil];
//
//        [alert show];
                NSLog (@"Instagram not found");
                [self promptAlertView:@"Warning" withSub:@"Instagram not found please install it, then try again." withClose:@"OK"];
        
    }
    
}

- (void)hideTabBar:(UITabBarController *) tabbarcontroller
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    
    for(UIView *view in tabbarcontroller.view.subviews)
    {
        if([view isKindOfClass:[UITabBar class]])
        {
            [view setFrame:CGRectMake(view.frame.origin.x, self.scrollView.bounds.size.height + 2, view.frame.size.width, view.frame.size.height)];
        }
        else
        {
            [view setFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, self.scrollView.bounds.size.height)];
        }
    }
    
    [UIView commitAnimations];
}


- (void)showTabBar:(UITabBarController *) tabbarcontroller
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    for(UIView *view in tabbarcontroller.view.subviews)
    {
        NSLog(@"%@", view);
        
        if([view isKindOfClass:[UITabBar class]])
        {
            [view setFrame:CGRectMake(view.frame.origin.x, self.scrollView.bounds.size.height, view.frame.size.width, view.frame.size.height)];
            
        }
        else
        {
            [view setFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, self.scrollView.bounds.size.height)];
        }
    }
    
    [UIView commitAnimations];
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


- (void)facebookVideoShared {
    NSString *contentTitle = [NSString stringWithFormat:@"%@ %@ CALLS-OUT %@ & %@ for a %@",self.calloutModel.user_first_name, self.calloutModel.user_last_name, self.calloutModel.fighter_a, self.calloutModel.fighter_b, self.calloutModel.match_type];
    
    NSString *userPhotoLink;
    if (self.calloutModel.photo != (id)[NSNull null]) {
        userPhotoLink = [NSString stringWithFormat:@"http://api.fightcallout.com/api/v1.0/uploads/%@", self.calloutModel.photo];
    } else {
        userPhotoLink = [NSString stringWithFormat:@"http://api.fightcallout.com/api/v1.0/uploads/%@", self.calloutModel.user_photo];
    }
    
    NSURL *videoURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://api.fightcallout.com/api/v1.0/uploads/%@.mp4", self.calloutModel.video]];
    
    
    FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
    content.imageURL = [NSURL URLWithString:userPhotoLink];
    content.contentTitle = contentTitle;
    content.contentDescription = @"Fight Call out App provides a platform for fighters, promoters and even fans to call out fighters for instant results. Fight Callout app users can now skip all of the middlemen and negotiations that may postpone or derail great potential matchups by \"calling out\" your opponent with a video at Fight Call Out App";
    content.contentURL = videoURL;
    
    FBSDKShareDialog *dialog = [[FBSDKShareDialog alloc] init];
    dialog.fromViewController = self;
    dialog.delegate = self;
    dialog.shareContent = content;
    dialog.mode = FBSDKShareDialogModeNative; // if you don't set this before canShow call, canShow would always return YES
    if (![dialog canShow]) {
        // fallback presentation when there is no FB app
        dialog.mode = FBSDKShareDialogModeFeedBrowser;
        NSLog(@"dialog not show");
    }
    [dialog show];

    
//    NSArray *permissions = [[NSArray alloc] initWithObjects:@"publish_actions" , nil];
//    FBSDKLoginManager *loginManager = [[FBSDKLoginManager alloc] init];
//    [loginManager logInWithPublishPermissions:permissions handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
//        if (!error) {
//            NSLog(@"result permission %@", result);
//             NSString *userPhotoLink;
//            if (self.calloutModel.photo != (id)[NSNull null]) {
//                userPhotoLink = [NSString stringWithFormat:@"http://api.fightcallout.com/api/v1.0/uploads/%@", self.calloutModel.photo];
//            } else {
//                userPhotoLink = [NSString stringWithFormat:@"http://api.fightcallout.com/api/v1.0/uploads/%@", self.calloutModel.user_photo];
//            }
//            
//            //NSString *userPhotoLink = [NSString stringWithFormat:@"http://api.fightcallout.com/api/v1.0/uploads/%@", self.calloutModel.user_photo];
//            NSURL *videoURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://api.fightcallout.com/api/v1.0/uploads/%@.mp4", self.calloutModel.video]];
//            NSDictionary *params = @{
//                                     @"message": contentTitle,
//                                     @"link": videoURL,//self.videoURL,
//                                     @"picture": userPhotoLink,//[NSURL URLWithString:@"https://www.t-nation.com/system/publishing/articles/291/original/Find-Your-Fight.jpg"],
//                                     @"description": @"Fight Call out App provides a platform for fighters, promoters and even fans to call out fighters for instant results. Fight Callout app users can now skip all of the middlemen and negotiations that may postpone or derail great potential matchups by \"calling out\" your opponent with a video at Fight Call Out App",
//                                     @"name": @"Fight Callout App"
//                                     };
//            /* make the API call */
//            FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc]
//                                          initWithGraphPath:@"/me/feed"
//                                          parameters:params
//                                          HTTPMethod:@"POST"];
//            [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection,
//                                                  id result,
//                                                  NSError *error) {
//                if (!error) {
//                    [self promptAlertView:@"Success!!!" withSub:@"Video Shared!" withClose:@"OK"];
//                    NSLog(@"fb not error result %@", result);
//                } else {
//                    NSLog(@"fb error %@", error);
//                }
//                // Handle the result
//            }];
//        } else {
//            NSLog(@"error permission %@", error.localizedDescription);
//        }
//    }];
}

- (void)facebookPhotoShared {
    NSString *contentTitle = [NSString stringWithFormat:@"%@ %@ CALLS-OUT %@ & %@ for a %@",self.calloutModel.user_first_name, self.calloutModel.user_last_name, self.calloutModel.fighter_a, self.calloutModel.fighter_b, self.calloutModel.match_type];
    
    NSURL *urlPhoto;
    NSURL *urlSite;
    if (self.calloutModel.photo == (id)[NSNull null]) {
        NSString *userPhoto  =  [NSString stringWithFormat:@"http://api.fightcallout.com/api/v1.0/uploads/%@", self.calloutModel.user_photo];
        NSURL *userURLPhoto = [NSURL URLWithString:userPhoto];
        urlPhoto  =  userURLPhoto;
        
    } else {
        NSString *calloutPhoto = [NSString stringWithFormat:@"http://api.fightcallout.com/api/v1.0/uploads/%@", self.calloutModel.photo];
        NSURL *calloutURLPhoto = [NSURL URLWithString:calloutPhoto];
        urlPhoto = calloutURLPhoto;
    }
    
    if (self.calloutModel.broadcast_url == (id)[NSNull null] || [self.calloutModel.broadcast_url isEqualToString:@""] || [self.calloutModel.broadcast_url isEqualToString:@"http://"]) {
        NSLog(@"there is no broadcast");
        urlSite = [NSURL URLWithString:@"http://www.epicentre.tv"];
    } else {
        urlSite = [NSURL URLWithString:self.calloutModel.broadcast_url];
        
    }
    
    FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
    content.imageURL = urlPhoto;
    content.contentTitle = contentTitle;
    content.contentDescription = @"Fight Call out App provides a platform for fighters, promoters and even fans to call out fighters for instant results. Fight Callout app users can now skip all of the middlemen and negotiations that may postpone or derail great potential matchups by \"calling out\" your opponent with a video at Fight Call Out App";
    content.contentURL = urlSite;
    
    FBSDKShareDialog *dialog = [[FBSDKShareDialog alloc] init];
    dialog.fromViewController = self;
    dialog.delegate = self;
    dialog.shareContent = content;
    dialog.mode = FBSDKShareDialogModeNative; // if you don't set this before canShow call, canShow would always return YES
    if (![dialog canShow]) {
        // fallback presentation when there is no FB app
        dialog.mode = FBSDKShareDialogModeFeedBrowser;
        NSLog(@"dialog not show");
    }
    [dialog show];

}

- (void)signInWillDispatch:(GIDSignIn *)signIn error:(NSError *)error {
    NSLog(@"stop animationg!!");
}

// Present a view that prompts the user to sign in with Google
- (void)signIn:(GIDSignIn *)signIn
presentViewController:(UIViewController *)viewController {
    [self presentViewController:viewController animated:YES completion:nil];
}

// Dismiss the "Sign in with Google" view
- (void)signIn:(GIDSignIn *)signIn
dismissViewController:(UIViewController *)viewController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)googlePlusShare {
    NSString *contentTitle = [NSString stringWithFormat:@"%@ %@ CALLS-OUT %@ & %@ for a %@",self.calloutModel.user_first_name, self.calloutModel.user_last_name, self.calloutModel.fighter_a, self.calloutModel.fighter_b, self.calloutModel.match_type];
    NSURL *urlSite;
    if (self.calloutModel.broadcast_url == (id)[NSNull null] || [self.calloutModel.broadcast_url isEqualToString:@""] || [self.calloutModel.broadcast_url isEqualToString:@"http://"]) {
        NSLog(@"there is no broadcast");
        urlSite = [NSURL URLWithString:@"http://www.epicentre.tv"];
    } else {
        urlSite = [NSURL URLWithString:self.calloutModel.broadcast_url];
        
    }
    
    GPPSignIn *signInn = [GPPSignIn sharedInstance];
    signInn.clientID = kClientId;
    
    //            GIDSignIn *signIn = [GIDSignIn sharedInstance];
    //            [signIn signIn];
    //            signIn.uiDelegate = self;
    //            signIn.delegate = self;
    //            signIn.allowsSignInWithWebView = YES;
    //            signIn.clientID = kClientId;
    //
    id<GPPShareBuilder> shareBuilder = [[GPPShare sharedInstance] shareDialog];
    //[shareBuilder attachImage:self.calloutImageView.image];
    
    
    NSURL *videoURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://api.fightcallout.com/api/v1.0/uploads/%@.mp4", self.calloutModel.video]];
    NSString *finalFillText;
    if (self.calloutModel.video != (id)[NSNull null]) {
        finalFillText = [NSString stringWithFormat:@"%@ \n \n Check Video: \n %@", contentTitle, videoURL];
    } else {
       // NSString *userPhoto  =  [NSString stringWithFormat:@"http://api.fightcallout.com/api/v1.0/uploads/%@", self.calloutModel.user_photo];
        finalFillText = contentTitle;
    }
    
    [shareBuilder setURLToShare:urlSite];
    [shareBuilder setPrefillText:finalFillText];
    [shareBuilder setContentDeepLinkID:@"rest=1234567"];
//  [shareBuilder setTitle:@"Fight Callout" description:@"Fight Call out App provides a platform for fighters, promoters and even fans to call out fighters for instant results. Fight Callout app users can now skip all of the middlemen and negotiations that may postpone or derail great potential matchups by \"calling out\" your opponent with a video at Fight Call Out App" thumbnailURL:[NSURL URLWithString:@"https://www.t-nation.com/system/publishing/articles/291/original/Find-Your-Fight.jpg"]];
    [shareBuilder open];
    
    //[self showGooglePlusShare:[NSURL URLWithString:@"http://www.epicentre.tv"]];
    
    
}

- (void)twitterShare {
    NSString *contentTitle = [NSString stringWithFormat:@"%@ %@ CALLS-OUT %@ & %@ for a %@",self.calloutModel.user_first_name, self.calloutModel.user_last_name, self.calloutModel.fighter_a, self.calloutModel.fighter_b, self.calloutModel.match_type];
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
        NSURL *urlSite;
        NSString *finalContent;
        if (self.calloutModel.broadcast_url == (id)[NSNull null] || [self.calloutModel.broadcast_url isEqualToString:@""] || [self.calloutModel.broadcast_url isEqualToString:@"http://"]) {
            NSLog(@"there is no broadcast");
            urlSite = [NSURL URLWithString:@"http://www.epicentre.tv"];
        } else {
            urlSite = [NSURL URLWithString:self.calloutModel.broadcast_url];
            
        }
        
        if (self.calloutModel.video == (id)[NSNull null]) {
            finalContent = [NSString stringWithFormat:@"%@ \n",contentTitle];
        } else {
            NSURL *videoURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://api.fightcallout.com/api/v1.0/uploads/%@.mp4", self.calloutModel.video]];
            finalContent = [contentTitle stringByAppendingString:[NSString stringWithFormat:@"\n \n Video: \n %@ \n", videoURL]];
            NSLog(@"final content url %@", finalContent);
        }
        
        
        SLComposeViewController *tweetSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        [tweetSheet setInitialText:finalContent];
        [tweetSheet addImage: self.calloutImageView.image]; //[UIImage imageNamed:@"http://api.fightcallout.com/api/v1.0/uploads/50.jpg"]];
        [tweetSheet addURL:urlSite];
        [self presentViewController:tweetSheet animated:YES completion:nil];
        tweetSheet.completionHandler = ^(SLComposeViewControllerResult result) {
            switch (result) {
                case SLComposeViewControllerResultCancelled:
                    NSLog(@"tweet cancelled");
                    break;
                case SLComposeViewControllerResultDone:
                    NSLog(@"tweet completed");
                    [self promptAlertView:@"Success!!!" withSub:@"Twitted Share!" withClose:@"OK"];
                default:
                    break;
            }
        };
    } else {
        [self promptAlertView:@"Warning!!!" withSub:@"You can't share a twitter right now, make sure your device has an internet connection and you have at least one Twitter account setup in your device setting" withClose:@"OK"];
    }
    
    NSLog(@"Hi its twitter");
}

//- (void)showGooglePlusShare:(NSURL*)shareURL {
//    
//    // Construct the Google+ share URL
//    NSURLComponents* urlComponents = [[NSURLComponents alloc]
//                                      initWithString:@"https://plus.google.com/share"];
//    urlComponents.queryItems = @[[[NSURLQueryItem alloc]
//                                  initWithName:@"url"
//                                  value:[shareURL absoluteString]]];
//    NSURL* url = [urlComponents URL];
//    
//    if ([SFSafariViewController class]) {
//        // Open the URL in SFSafariViewController (iOS 9+)
//        SFSafariViewController* controller = [[SFSafariViewController alloc]
//                                              initWithURL:url];
//        controller.delegate = self;
//        [self presentViewController:controller animated:YES completion:nil];
//    } else {
//        // Open the URL in the device's browser
//        [[UIApplication sharedApplication] openURL:url];
//    }
//}

#pragma mark - UIPlacePicker Delegate

-(void)placePickerDidCancel {
    [self hidePlacePicker];
    
    NSLog(@"taee");
}
-(void)hidePlacePicker{
    
    [self.picker dismissViewControllerAnimated:NO completion:^{
        CGPoint bottomOffset = CGPointMake(0, self.scrollView.contentSize.height - self.scrollView.bounds.size.height);
        [self.scrollView setContentOffset:bottomOffset animated:YES];
        //NSLog(@"test place %@", [self.picker getAddressWithCurrentLocation]);
    }];
}


- (void)placePickerDidSelectPlace:(UIPlace *)__place {
    self.place = __place;
    
    //[self.place setCompleteAddress:self.calloutModel.details_venue];
 
}


# pragma mark - UserTappedOnLink

- (void)userTappedOnLink:(UIGestureRecognizer *)gestureRecognizer {

    
    [self performSegueWithIdentifier:@"detailToMapView" sender:self];
    
    
    
}

# pragma mark - FCOMapViewController Delegate

-(void)mapViewDidCancel {
    [self dismissViewControllerAnimated:NO completion:nil];
}


# pragma mark - Google+ Delegate

- (void)finishedWithAuth:(GTMOAuth2Authentication *)auth error:(NSError *)error {
 
    if (error) {
        NSLog(@"google is error!");
    }
}

#pragma mark - GUI Player View Delegate Methods

- (void)playerWillEnterFullscreen {
    [[self navigationController] setNavigationBarHidden:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    [_scrollView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
    self.scrollView.scrollEnabled = NO;
    [self.imageViewTopLine setHidden:YES];
    [self hideTabBar:self.tabBarController];
    NSLog(@"to fullscreen");
}

- (void)playerWillLeaveFullscreen {
    [[self navigationController] setNavigationBarHidden:NO];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    //FCOMainTabBar *tabBar = [[FCOMainTabBar alloc] init];
    //[tabBar showTabBar:self.tabBarController];
        self.scrollView.scrollEnabled = YES;
    [self showTabBar:self.tabBarController];
    [self.imageViewTopLine setHidden:NO];
}

- (void)playerDidEndPlaying { 
    [playerView pause];
}

- (void)playerFailedToPlayToEnd {
    NSLog(@"Error: could not play video");
    [playerView clean];
}

# pragma mark - IBAction

- (IBAction)voteUpButtonPressed:(UIButton *)sender {
    _voteUpButton.enabled = NO;
     [self postVoteUp];
}

- (IBAction)voteDownButtonPressed:(UIButton *)sender {
    _voteDownButton.enabled = NO;
    [self postVoteDown];
}

- (IBAction)commentButtonPressed:(UIButton *)sender {
    [playerView pause];
    
    FCOSessionModel *session = [FCOSessionModel sharedInstance];
    
    if (!session.activeUser) {
        [self promptAlertView:@"Warning!!!" withSub:@"You must must login to view or add comment" withClose:@"OK"];
    } else {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        FCOCommentViewController *myController = (FCOCommentViewController *)[storyboard instantiateViewControllerWithIdentifier:@"commentView"];
        myController.calloutModel = self.calloutModel;
        myController.delegate = self;
        LGSemiModalNavViewController *semiModal = [[LGSemiModalNavViewController alloc]initWithRootViewController:myController];
        semiModal.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 170);
        
        NSLog(@"tableview height %d", (int)semiModal.view.frame.size.height);
        semiModal.backgroundShadeColor = [UIColor blackColor];
        semiModal.animationSpeed = 0.35f;
        semiModal.tapDismissEnabled = YES;
        semiModal.backgroundShadeAlpha = 0.3;
        semiModal.scaleTransform = CGAffineTransformMakeScale(1, 1);
        
        
        [self presentViewController:semiModal animated:YES completion:nil];
    }
}


- (void)saveToCameraRoll:(NSURL *)srcURL
{
    NSLog(@"srcURL: %@", srcURL);
    
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    ALAssetsLibraryWriteVideoCompletionBlock videoWriteCompletionBlock =
    ^(NSURL *newURL, NSError *error) {
        if (error) {
            NSLog( @"Error writing image with metadata to Photo Library: %@", error );
        } else {
            NSLog( @"Wrote image with metadata to Photo Library %@", newURL.absoluteString);
            //url_new  = newURL;
        }
    };
    
    if ([library videoAtPathIsCompatibleWithSavedPhotosAlbum:srcURL])
    {
        [library writeVideoAtPathToSavedPhotosAlbum:srcURL
                                    completionBlock:videoWriteCompletionBlock];
    }
}


- (IBAction)shareButtonPressed:(UIButton *)sender {
    NSLog(@"video url %@", self.videoURL);
    JMActionSheetCollectionItem *collectionItem = [[JMActionSheetCollectionItem alloc] init];
    NSMutableArray *collectionItems = [NSMutableArray new];
    JMCollectionItem *item = [[JMCollectionItem alloc] init];
    
    item.actionName = @"Facebook";
    item.actionImage = [UIImage imageNamed:@"facebook"];
    [collectionItems addObject:item];
    
    item = [[JMCollectionItem alloc] init];
    item.actionName = @"Twitter";
    item.actionImage = [UIImage imageNamed:@"twitter"];
    [collectionItems addObject:item];

    item = [[JMCollectionItem alloc] init];
    item.actionName = @"Google+";
    item.actionImage = [UIImage imageNamed:@"google+"];
    [collectionItems addObject:item];
    
    item = [[JMCollectionItem alloc] init];
    item.actionName = @"Instagram";
    item.actionImage = [UIImage imageNamed:@"instagram"];
    [collectionItems addObject:item];
    
    item = [[JMCollectionItem alloc] init];
    item.actionName = @"Mail";
    item.actionImage = [UIImage imageNamed:@"email"];
    [collectionItems addObject:item];
    
    collectionItem.elements = collectionItems;
    collectionItem.collectionActionBlock = ^(JMCollectionItem *selectedValue){
        NSLog(@"collectionItem selectedValue %@",selectedValue.actionName);

        NSString *contentTitle = [NSString stringWithFormat:@"%@ %@ CALLS-OUT %@ & %@ for a %@",self.calloutModel.user_first_name, self.calloutModel.user_last_name, self.calloutModel.fighter_a, self.calloutModel.fighter_b, self.calloutModel.match_type];
        
        if ([selectedValue.actionName isEqualToString:@"Facebook"]) {
            if (self.calloutModel.video == (id)[NSNull null]) {
                [self facebookPhotoShared];
            } else {
                [self facebookVideoShared];
                NSLog(@"Hi its facebook");
                NSLog(@"fb video url %@", self.videoURL);
            }
            
        } else if ([selectedValue.actionName isEqualToString:@"Twitter"]) {
            [self twitterShare];
        } else if ([selectedValue.actionName isEqualToString:@"Google+"]) {
            NSLog(@"Hi its google+");
            [self googlePlusShare];
        } else if ([selectedValue.actionName isEqualToString:@"Instagram"]) {
            NSLog(@"Hi its instagram");
            [self instaGramWallPost];
        } else if ([selectedValue.actionName isEqualToString:@"Mail"]) {
            if ([MFMailComposeViewController canSendMail])
            {
                
                NSURL *urlSite;
                if (self.calloutModel.broadcast_url == (id)[NSNull null] || [self.calloutModel.broadcast_url isEqualToString:@""] || [self.calloutModel.broadcast_url isEqualToString:@"http://"]) {
                    NSLog(@"there is no broadcast");
                    urlSite = [NSURL URLWithString:@"http://www.epicentre.tv"];
                } else {
                    urlSite = [NSURL URLWithString:self.calloutModel.broadcast_url];
                    
                }
                
                NSURL *videoURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://api.fightcallout.com/api/v1.0/uploads/%@.mp4", self.calloutModel.video]];
                NSString *finalFillText;
                if (self.calloutModel.video != (id)[NSNull null]) {
                    finalFillText = [NSString stringWithFormat:@"%@ \n \n Check Video: \n %@ \n \n Link: \n %@", contentTitle, videoURL, urlSite];
                } else {
                    // NSString *userPhoto  =  [NSString stringWithFormat:@"http://api.fightcallout.com/api/v1.0/uploads/%@", self.calloutModel.user_photo];
                    finalFillText = [NSString stringWithFormat:@"%@ \n \n Link: \n %@", contentTitle, urlSite];
                }
                
                MFMailComposeViewController *mail = [[MFMailComposeViewController alloc] init];
                mail.mailComposeDelegate = self;
                [mail setSubject:@"Fight Callout App"];
                [mail setMessageBody:finalFillText isHTML:NO];
                [mail setToRecipients:@[@""]];
                
                [self presentViewController:mail animated:YES completion:NULL];
            }
            else {
                [self promptAlertView:@"Warning!!!" withSub:@"This device cannot send email or make sure to configure your email first then try again" withClose:@"OK"];
                NSLog(@"This device cannot send email");
            }
        }

    };
    
    JMActionSheetDescription *desc = [[JMActionSheetDescription alloc] init];
    desc.actionSheetTintColor = [UIColor blackColor];

//    desc.actionSheetCancelButtonFont = [UIFont fontWithName:@"FederalEscort" size:16.0f];
//    desc.actionSheetOtherButtonFont = [UIFont fontWithName:@"FederalEscort" size:16.0f];
    desc.title = @"Share with. . .";
    desc.items = @[collectionItem];
    [JMActionSheet showActionSheetDescription:desc inViewController:self fromView:sender permittedArrowDirections:UIPopoverArrowDirectionDown];
}

- (UIDocumentInteractionController *) setupControllerWithURL: (NSURL*) fileURL usingDelegate: (id <UIDocumentInteractionControllerDelegate>) interactionDelegate {
    NSLog(@"file url %@",fileURL);
    UIDocumentInteractionController *interactionController = [UIDocumentInteractionController interactionControllerWithURL: fileURL];
    interactionController.delegate = interactionDelegate;
    
    return interactionController;
}


- (IBAction)broadcastButtonPressed:(UIButton *)sender {
     [playerView clean];
    UINavigationController *webBrowserNavigationController = [KINWebBrowserViewController navigationControllerWithWebBrowser];
    KINWebBrowserViewController *webBrowser = [webBrowserNavigationController rootWebBrowserViewController];
    [webBrowser setDelegate:self];
    webBrowser.progressColor = [UIColor redColor];
    webBrowser.tintColor = [UIColor lightGrayColor];
    webBrowser.barTintColor = [UIColor colorWithRed:18.0f/255.0f green:18.0f/255.0f blue:18.0f/255.0f alpha:1.0f];
    webBrowser.titleColor = [UIColor lightGrayColor];
    [self presentViewController:webBrowserNavigationController animated:YES completion:nil];
    [webBrowser loadURLString:self.calloutModel.broadcast_url];
}

- (IBAction)ticketButtonPressed:(UIButton *)sender {
     [playerView clean];
    UINavigationController *webBrowserNavigationController = [KINWebBrowserViewController navigationControllerWithWebBrowser];
    KINWebBrowserViewController *webBrowser = [webBrowserNavigationController rootWebBrowserViewController];
    [webBrowser setDelegate:self];
    webBrowser.progressColor = [UIColor redColor];
    webBrowser.tintColor = [UIColor lightGrayColor];
    webBrowser.barTintColor = [UIColor colorWithRed:18.0f/255.0f green:18.0f/255.0f blue:18.0f/255.0f alpha:1.0f];
    webBrowser.titleColor = [UIColor lightGrayColor];
    [self presentViewController:webBrowserNavigationController animated:YES completion:nil];
    [webBrowser loadURLString:self.calloutModel.ticket_url];

}



#pragma mark - KINWebBrowserDelegate Protocol Implementation

- (void)webBrowser:(KINWebBrowserViewController *)webBrowser didStartLoadingURL:(NSURL *)URL {
    NSLog(@"Started Loading URL : %@", URL);
}

- (void)webBrowser:(KINWebBrowserViewController *)webBrowser didFinishLoadingURL:(NSURL *)URL {
    NSLog(@"Finished Loading URL : %@", URL);
}

- (void)webBrowser:(KINWebBrowserViewController *)webBrowser didFailToLoadURL:(NSURL *)URL withError:(NSError *)error {
    NSLog(@"Failed To Load URL : %@ With Error: %@", URL, error);
}

- (void)webBrowserViewControllerWillDismiss:(KINWebBrowserViewController*)viewController {
    NSLog(@"View Controller will dismiss: %@", viewController);
    
}

#pragma mark - MFMailComposeControllerDelegate
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result) {
        case MFMailComposeResultSent:
            NSLog(@"You sent the email.");
            [self promptAlertView:@"Success!!!" withSub:@"Sent the email!" withClose:@"OK"];
            break;
        case MFMailComposeResultSaved:
            NSLog(@"You saved a draft of this email");
            break;
        case MFMailComposeResultCancelled:
            NSLog(@"You cancelled sending this email.");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail failed:  An error occurred when trying to compose this email");
            [self promptAlertView:@"Mail Failed!!!" withSub:@"An error occurred when trying to compose this email" withClose:@"OK"];
            break;
        default:
            NSLog(@"An error occurred when trying to compose this email");
            [self promptAlertView:@"Warning!!!" withSub:@"An error occurred when trying to compose this email" withClose:@"OK"];
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - FBSDKSharing Delegate

-(void)sharerDidCancel:(id<FBSDKSharing>)sharer {
     NSLog(@"SHARED CANCELED");
}

-(void)sharer:(id<FBSDKSharing>)sharer didCompleteWithResults:(NSDictionary *)results {
        NSLog(@"SHARED DONE= %@",results);
    if ([results count] != 0) {
        [self promptAlertView:@"Success!!!" withSub:@"Facebook Shared!" withClose:@"OK"]; 
    }
    
}

-(void)sharer:(id<FBSDKSharing>)sharer didFailWithError:(NSError *)error {
    NSLog(@"SHARED ERROR = %@",error);
    if (error) {
          [self promptAlertView:@"Warning!!!" withSub:@"Failed to shared facebook, Please try again later!" withClose:@"OK"];
    }
}


#pragma mark - FCOCommentViewControllerDelegate

- (void)didUpdateCallout {
    [self updateCallouts];
    NSLog(@"update callouts comment");
}

 #pragma mark - Navigation
 
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
     if ([segue.identifier isEqualToString:@"detailToMapView"]) {
         FCOMapViewController *mapVC = segue.destinationViewController;
         mapVC.delegate = self;
         mapVC.calloutModel = self.calloutModel;

     }
 }


@end
