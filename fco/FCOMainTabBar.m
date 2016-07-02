//
//  FCOMainTabBar.m
//  fco
//
//  Created by Kryptonite on 6/9/15.
//  Copyright (c) 2015 Kryptonite. All rights reserved.
//

#import "FCOMainTabBar.h"
#import "FCOMainViewController.h"
#import "FCOSessionModel.h"
#import "FCOLoginViewController.h"
#import "FCOCategoryViewController.h"
#import "FCOCallIOutViewController.h"
#import "FCOSessionModel.h"
#import "FCOUserModel.h"
#import "FCOHTTPClient.h"
#import <SCLAlertView-Objective-C/SCLAlertView.h>


@interface FCOMainTabBar () <UITabBarControllerDelegate, FCOLoginViewControllerDelegate>

@property (strong, nonatomic) FCOCalloutModel *calloutModel;
@property (nonatomic) NSInteger statsCode;

@end

@implementation FCOMainTabBar

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UITabBarItem *item0 = self.tabBar.items[0];
    UIImage *punch = [self loadImageNamed:@"icon_callout_punch"];
    item0.image = [punch imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    item0.selectedImage = [punch imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    UITabBarItem *item1 = self.tabBar.items[1];
    UIImage *home = [self loadImageNamed:@"icon_home"];
    UIImage *home_selected = [self loadImageNamed:@"icon_home_selected"];
    item1.image = [home imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    item1.selectedImage = [home_selected imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];

    UITabBarItem *item2 = self.tabBar.items[2];
    UIImage *category = [self loadImageNamed:@"icon_category"];
    UIImage *category_selected = [self loadImageNamed:@"icon_category_selected"];
    item2.image = [category imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    item2.selectedImage = [category_selected imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal ];
    
    UITabBarItem *item3 = self.tabBar.items[3];
    UIImage *profile = [self loadImageNamed:@"icon_profile"];
    UIImage *profile_selected = [self loadImageNamed:@"icon_profile_selected"];
    item3.image = [profile imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    item3.selectedImage = [profile_selected imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal ];
    self.selectedIndex = 1;

}

- (UIImage *)loadImageNamed:(NSString *)imageName
{
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    CGFloat screenHeight = MAX(screenSize.width, screenSize.height);
    CGFloat const IPHONE_4_SCREEN_HEIGHT = 480;
    UIImage *image = [UIImage imageNamed:imageName];
    if(screenHeight == IPHONE_4_SCREEN_HEIGHT) {
        CGFloat const xScale = .85333333;//x conversion ratio from iPhone 6's 375 pts width screen to iPhone 4's 320 pts width screen
        CGFloat const yScale = .99964018;//y conversion ratio from iPhone 6's 667 pts height screen to iPhone 4's 480 pts height screen
        CGSize newSize = CGSizeMake(xScale * image.size.width, yScale * image.size.height);
        UIGraphicsBeginImageContextWithOptions(newSize, NO, 0);
        
        [image drawInRect:(CGRect){0, 0, newSize}];
        UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return resizedImage;
    }
    return image;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
 //   [self getCallout];
    self.statsCode = 0;
    NSLog(@"statsCode %li", (long)self.statsCode);

//    [self.callout removeAllObjects];
    
}

#pragma mark - Private Methods
- (void)getCallout {
    FCOSessionModel *session = [FCOSessionModel sharedInstance];
    FCOUserModel *activeUser = [session activeUser];
    NSString *urlAction = [NSString stringWithFormat:@"users/%@/callouts", activeUser._id];
    NSDictionary *params = @{@"limit": @"5",
                             @"sort" : @"-updated_at"
                             };
    FCOHTTPClient *fcoHttpClient = [FCOHTTPClient sharedInstance];
    [fcoHttpClient GET:urlAction parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        NSString* ErrorResponse = [[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding];
        NSLog(@"israelisrael %@",ErrorResponse);
        
        NSInteger statusCode = error.code;
        if (statusCode == -999) {
            NSLog(@"error code -999");
        } else if (statusCode == -1009 || statusCode == -1004 || statusCode == -1003) {
            NSLog(@"error code -1009 -1004 -1003");
            self.statsCode = -10003;
        } else if (statusCode == -1011) {

            NSLog(@"error code -1011 no token");
            self.statsCode = -1011;
        }
        else {
            NSLog(@"error %@", error);
        }
    }];
}

- (void)promptCustomAlertView:(NSString *)title withSub:(NSString *)subtitle withClose:(NSString *)close {
    SCLAlertView *alert = [[SCLAlertView alloc] init];
    UIColor *color = [UIColor colorWithRed:103.0/255.0 green:10.0/255.0 blue:5.0/255.0 alpha:1.0];
    [alert addButton:@"Login" actionBlock:^(void) {
    [self performSegueWithIdentifier:@"mainViewToLoginSegue" sender:self];
    }];
    
    [alert showCustom:self image:[UIImage imageNamed:@"icon_punch"] color:color title:title     subTitle:subtitle closeButtonTitle:close duration:0.0f];
    [alert setTitleFontFamily:@"FederalEscort" withSize:24];
    [alert setBodyTextFontFamily:@"HelveticaNeue" withSize:13];
    alert.backgroundViewColor = [UIColor whiteColor];
    alert.backgroundType = Blur;
}

# pragma mark - UITabBarController Delegate
- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    FCOSessionModel *session = [FCOSessionModel sharedInstance];
    if (![session isLoggedIn] || self.statsCode == -10003) {
        if ([item isEqual:[self.tabBar.items objectAtIndex:0]]) {
           [self performSegueWithIdentifier:@"mainViewToLoginSegue" sender:self];
        } else if ([item isEqual:[self.tabBar.items objectAtIndex:1]]) {
            [self performSegueWithIdentifier:@"mainViewToLoginSegue" sender:self];
              [self.tabBarController setSelectedIndex:1];
        } else if ([item isEqual:[self.tabBar.items objectAtIndex:2]]) {
            [self performSegueWithIdentifier:@"mainViewToLoginSegue" sender:self];
        } else if ([item isEqual:[self.tabBar.items objectAtIndex:3]]) {
            [self performSegueWithIdentifier:@"mainViewToLoginSegue" sender:self];
        } else {
            if ([item isEqual:[self.tabBar.items objectAtIndex:0]]) {
            }
        }
    } else if (self.statsCode == -1011 && self.statsCode == 999) {
        [self promptCustomAlertView:@"Error!" withSub:@"Session Expired, Please re-log again" withClose:nil];
        NSLog(@"tokken error");
    }
}

# pragma mark - FCOLoginViewControllerView Delegate
-(void)loginDidCancel {
    self.selectedIndex = 1;
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"mainViewToLoginSegue"]) {
        FCOLoginViewController *loginVC = segue.destinationViewController;
        loginVC.delegate = self;
    }
}


@end
