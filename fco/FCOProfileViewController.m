//
//  FCOProfileViewController.m
//  fco
//
//  Created by Kryptonite on 6/9/15.
//  Copyright (c) 2015 Kryptonite. All rights reserved.
//

#import "FCOProfileViewController.h"
#import "FCOProfileTableViewCell.h"
#import "FCOHeaderViewWithImage.h"
#import "UIScrollView+VGParallaxHeader.h"
#import "FCOHTTPClient.h"
#import "FCOSessionModel.h"
#import "FCOProfileEditViewController.h"
#import "FCOCalloutModel.h"
#import "FCOProfileDetailCalloutViewController.h"
#import "UIImageView+AFNetworking.h"
#import <SCLAlertView-Objective-C/SCLAlertView.h>


@interface FCOProfileViewController () <UITableViewDataSource, UITableViewDelegate, FCOProfileEditViewControllerDelegate, FCOProfileDetailCalloutViewControllerDelegate>

@property (strong, nonatomic) NSMutableArray *callouts;
@property (strong, nonatomic) NSMutableArray *totalCallouts;
@property (strong, nonatomic) FCOCalloutModel *totalCalloutModel;
@property (strong, nonatomic) FCOCalloutModel *calloutModel;
@property (strong, nonatomic) UILabel *countLabel;

@property BOOL isFinishLoading;

@end

@implementation FCOProfileViewController

- (NSMutableArray *)callouts {
    if (!_callouts) {
        _callouts = [[NSMutableArray alloc] init];
    }
    return _callouts;
}

- (NSMutableArray *)totalCallouts {
    if (!_totalCallouts) {
        _totalCallouts = [[NSMutableArray alloc]init];
    }
    return _totalCallouts;
}

#pragma mark - View Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
   
    // Do any additional setup after loading the view.
    [self.navigationItem.rightBarButtonItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"Helvetica-Bold" size:15], NSFontAttributeName, nil] forState:UIControlStateNormal];
    
    [[UISegmentedControl appearance] setTitleTextAttributes:@{
                                                              NSForegroundColorAttributeName : [UIColor whiteColor]
                                                              } forState:UIControlStateNormal];
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"FederalEscort" size:21], NSFontAttributeName, [UIColor lightGrayColor], NSForegroundColorAttributeName, nil]];
     [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
    UINib *nib = [UINib nibWithNibName:@"FCOProfileTableViewCell" bundle:nil];
    [[self tableView] registerNib:nib forCellReuseIdentifier:@"FCOProfileTableViewCell"];
   
    
//    headerView.userImageView.layer.borderWidth = 5.0f;
//    headerView.userImageView.layer.borderColor = [UIColor lightGrayColor].CGColor;

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self getTotalCallout];
    [self getCallout];
    [self.totalCallouts removeAllObjects];
    [self.callouts removeAllObjects];
    
    
    FCOSessionModel *session = [FCOSessionModel sharedInstance];
    self.activeUser = [session activeUser];
    
    if (!session.isLoggedIn) {
        FCOHeaderViewWithImage *headerView = [FCOHeaderViewWithImage instantiateFromNib];
        [self.tabBarController setSelectedIndex:1];
        //[session setToken:nil];
        headerView.firstNameLabel.text = @"";
        [headerView setUserDetails:nil];
        [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
    } else {
        [super viewDidLoad];
        FCOHeaderViewWithImage *headerView = [FCOHeaderViewWithImage instantiateFromNib];
        [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
        [self.tableView setParallaxHeaderView:headerView
                                         mode:VGParallaxHeaderModeTop
                                       height:370];
        [headerView setUserDetails:self.activeUser];

        [self.tableView reloadData];
    }
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

# pragma mark - IBAction

- (IBAction)editBarButtonPressed:(UIBarButtonItem *)sender {
    [self performSegueWithIdentifier:@"profileToEditProfile" sender:self];
}


# pragma mark - Private Methods

- (void)getCallout {
    
    FCOSessionModel *session = [FCOSessionModel sharedInstance];
    FCOUserModel *activeUser = [session activeUser];
    NSString *urlAction = [NSString stringWithFormat:@"users/%@/callouts", activeUser._id];
    
    NSDictionary *params = @{@"limit": @"5",
                             @"sort" : @"-updated_at"
                             };
    FCOHTTPClient *fcoHttpClient = [FCOHTTPClient sharedInstance];
    [fcoHttpClient GET:urlAction parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        for (NSDictionary *calloutDictionary in  responseObject) {
            self.calloutModel = [[FCOCalloutModel alloc] initWithDictionary:calloutDictionary];
            [self.callouts addObject:self.calloutModel];
            NSLog(@"self callouts %@", self.callouts);
        }
        [self.tableView reloadData];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSInteger statusCode = error.code;
        NSLog(@"%zd statuscode", statusCode);
        if (statusCode == -999 || statusCode == -1011) {
            [self promptExpiredToken:@"Error!!!" withSub:@"Session Expired Please Re-log" withClose:nil];
        }
    }];
}

- (void)promptExpiredToken:(NSString *)title withSub:(NSString *)subtitle withClose:(NSString *)close {
    SCLAlertView *alert = [[SCLAlertView alloc] init];
    UIColor *color = [UIColor colorWithRed:103.0/255.0 green:10.0/255.0 blue:5.0/255.0 alpha:1.0];
    [alert addButton:@"Re-Log" actionBlock:^(void) {
        [self performSegueWithIdentifier:@"userProfileToLoginSegue" sender:self];
    }];
    
    [alert showCustom:self image:[UIImage imageNamed:@"icon_punch"] color:color title:title     subTitle:subtitle closeButtonTitle:close duration:0.0f];
    [alert setTitleFontFamily:@"FederalEscort" withSize:24];
    [alert setBodyTextFontFamily:@"HelveticaNeue" withSize:13];
    alert.backgroundViewColor = [UIColor whiteColor];
    alert.backgroundType = Blur;
}

- (void)getTotalCallout {
    FCOSessionModel *session = [FCOSessionModel sharedInstance];
    FCOUserModel *activeUser = [session activeUser];
    NSString *urlAction = [NSString stringWithFormat:@"users/%@/callouts", activeUser._id];
    
    FCOHTTPClient *fcoHttpClient = [FCOHTTPClient sharedInstance];
    [fcoHttpClient GET:urlAction parameters:@"" success:^(NSURLSessionDataTask *task, id responseObject) {
        for (NSDictionary *calloutDictionary in  responseObject) {
            self.totalCalloutModel = [[FCOCalloutModel alloc] initWithDictionary:calloutDictionary];
            [self.totalCallouts addObject:self.totalCalloutModel];
            NSLog(@"self callouts %@", self.totalCallouts);
            _isFinishLoading = YES;
        }
        [self.tableView reloadData];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
    }];
}

- (void)setCustomCellLabel:(FCOProfileTableViewCell *)cell title:(NSString *)title action:(NSString *)callsout andSign:(NSString *)andSign forLabel:(NSString *)forLabel {
    cell.userCalloutLabel.text = title;
    UIColor *lightGray = [UIColor lightGrayColor];
    UIFont *helveticaNormal = [UIFont fontWithName:@"Helvetica" size:14];
    [cell.userCalloutLabel setFontColor:lightGray string:callsout];
    [cell.userCalloutLabel setFontColor:lightGray string:andSign];
    [cell.userCalloutLabel setFont:helveticaNormal string:callsout];
    [cell.userCalloutLabel setFont:helveticaNormal string:andSign];
    [cell.userCalloutLabel setFont:helveticaNormal string:forLabel];
}

- (void)promptCustomAlertView:(NSString *)title withSub:(NSString *)subtitle withClose:(NSString *)close {
    SCLAlertView *alert = [[SCLAlertView alloc] init];
    UIColor *color = [UIColor colorWithRed:103.0/255.0 green:10.0/255.0 blue:5.0/255.0 alpha:1.0];
    [alert addButton:@"Done" actionBlock:^(void) {
        
       // NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        
            //[self.callouts removeObjectAtIndex:indexPath.row];
    }];
    
    [alert showCustom:self image:[UIImage imageNamed:@"icon_punch"] color:color title:title     subTitle:subtitle closeButtonTitle:close duration:0.0f];
    [alert setTitleFontFamily:@"FederalEscort" withSize:24];
    [alert setBodyTextFontFamily:@"HelveticaNeue" withSize:13];
    alert.backgroundViewColor = [UIColor whiteColor];
    alert.backgroundType = Blur;
}

# pragma mark - UITableView Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.callouts count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"FCOProfileTableViewCell";
    FCOProfileTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    FCOSessionModel *session = [FCOSessionModel sharedInstance];
    FCOUserModel *userModel = [session activeUser];
    
    NSString *urlID = [NSString stringWithFormat:@"http://api.fightcallout.com/api/v1.0/uploads/%@", userModel.photo];
    
    if (self.callouts != nil && [self.callouts count]) {        
        self.calloutModel = [self.callouts objectAtIndex:indexPath.row];        
        NSString *checkString = [NSString stringWithFormat:@"CALLS-OUT %@ & %@ for a %@",self.calloutModel.fighter_a, self.calloutModel.fighter_b, self.calloutModel.match_type];
        NSLog(@"strinf %@", checkString);
        
        if (![checkString containsString:self.calloutModel.fighter_b]) {
        checkString = [NSString stringWithFormat:@"CALLS-OUT %@ for a %@", self.calloutModel.fighter_a, self.calloutModel.match_type];
            NSLog(@"checkString %@", checkString);
        } else if (![checkString containsString:self.calloutModel.fighter_a]) {
        checkString = [NSString stringWithFormat:@"CALLS-OUT %@ for a %@", self.calloutModel.fighter_b, self.calloutModel.match_type];
            NSLog(@"checkString %@", checkString);
        } else {
        checkString = [NSString stringWithFormat:@"CALLS-OUT %@ & %@ for a %@", self.calloutModel.fighter_a, self.calloutModel.fighter_b, self.calloutModel.match_type];
        }
        cell.userCalloutLabel.text = checkString;
        
        NSURL *logoImageUrl = [NSURL URLWithString:urlID];
        [cell.userImageView setImageWithURLRequest:[NSURLRequest requestWithURL:logoImageUrl] placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
            cell.userImageView.image = image;
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
            NSLog(@"error: %@", error);
        }];
        
    }
    
    UIColor *lightGray = [UIColor lightGrayColor];
    UIFont *helveticaNormal = [UIFont fontWithName:@"Helvetica" size:13];
    
    [cell.userCalloutLabel setFontColor:lightGray string:@"CALLS-OUT"];
    [cell.userCalloutLabel setFont:helveticaNormal string:@"CALLS-OUT"];
    [cell.userCalloutLabel setFontColor:lightGray string:@"for a"];
    [cell.userCalloutLabel setFont:helveticaNormal string:@"for a"];
    
    return cell;
}

//# pragma mark - FCOProfileTableView Delegate
//
//- (void)customCell:(FCOProfileTableViewCell *)cell btnPressed:(UIButton *)btn {
//    [self performSegueWithIdentifier:@"profileToDetailsSegue" sender:self];
//}

# pragma mark - UITableView Delegate 

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIImage *myImage;
    UIImageView *imageView;
    
    FCOSessionModel *session = [FCOSessionModel sharedInstance];
 
    if (![session isLoggedIn] || [session token] == nil) {
        [self.tabBarController setSelectedIndex:1];
        [session setToken:nil];
        [session setActiveUser:nil];
    } else {
        myImage = [UIImage imageNamed:@"callout_titlebg"];
        imageView = [[UIImageView alloc] initWithImage:myImage];
        imageView.frame = CGRectMake(0,0,self.tableView.frame.size.width,40);
        UILabel *myLabel = [[UILabel alloc] initWithFrame:CGRectMake(10,0,150,41)];
        myLabel.textColor = [UIColor lightGrayColor];
        myLabel.text = @"Call outs";
        [myLabel setFont:[UIFont fontWithName:@"FederalEscort" size:20]];
        _countLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0,self.tableView.frame.size.width - 15,41)];
        _countLabel.textColor = [UIColor lightGrayColor];
        _countLabel.text = [NSString stringWithFormat:@"%d", (int)self.totalCallouts.count];
        _countLabel.textAlignment = NSTextAlignmentRight;
        [_countLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:15]];
        [imageView addSubview:myLabel];
        [imageView addSubview:_countLabel];
        
    }
   
    return imageView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    FCOSessionModel *session = [FCOSessionModel sharedInstance];
    if (![session isLoggedIn]) {
        [self.tabBarController setSelectedIndex:1];
        [session setToken:nil];
        return 0;
    }
    return 45;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    // Remove seperator inset
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    // Prevent the cell from inheriting the Table View's margin settings
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    
    // Explictly set cell's layout margins
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"profileToProfileDetailSegue" sender:indexPath];
}

# pragma mark - FCOProfileEditViewController Delegate


- (void)didCancel {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)updateCallout {
    [self.tableView reloadData];
            [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
}

- (void)didUpdate {

    //[self.presentedViewController dismissViewControllerAnimated:NO completion:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
}


-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    _isFinishLoading = NO;
    if (!_isFinishLoading) {
        NSLog(@"is finish loading");
        _isFinishLoading = NO;
        return YES;
    } else {
        NSLog(@"not finish loading");
        return NO;
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        self.calloutModel = [self.callouts objectAtIndex:indexPath.row];
        
        NSString *urlAction = [NSString stringWithFormat:@"callouts/%@", self.calloutModel._id];
        NSLog(@"callout id %@", urlAction);
        FCOHTTPClient *fcoHttpClient = [FCOHTTPClient sharedInstance];
        [fcoHttpClient DELETE:urlAction parameters:@"" success:^(NSURLSessionDataTask *task, id responseObject) {
                NSLog(@"success delete %@", responseObject);
                _countLabel.text = [NSString stringWithFormat:@"%d", (int)self.totalCallouts.count];
                [self getTotalCallout];
                [self getCallout];
                [self.callouts removeAllObjects];
                [self.totalCallouts removeAllObjects];
                [self.tableView reloadData];
                NSLog(@"countlabel %@", _countLabel);
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            NSLog(@"delete error: %@", error);
        }];
        [self.callouts removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"profileToEditProfile"]) {
        FCOProfileEditViewController *profileEditVC = segue.destinationViewController;
        profileEditVC.delegate = self;
    } else if ([segue.identifier isEqualToString:@"profileToProfileDetailSegue"]) {
        FCOProfileDetailCalloutViewController *fcoDetailVC = segue.destinationViewController;
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        FCOCalloutModel *selectedModel = [self.callouts objectAtIndex:indexPath.row];
        fcoDetailVC.delegate = self;
        fcoDetailVC.calloutModel = selectedModel;
        NSLog(@"cell row %ld", (long)indexPath.row);
    }
}


@end
