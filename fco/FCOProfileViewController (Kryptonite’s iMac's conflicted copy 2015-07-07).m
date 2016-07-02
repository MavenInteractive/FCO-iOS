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

@interface FCOProfileViewController () <UITableViewDataSource, UITableViewDelegate, FCOProfileTableViewCellDelegate, FCOProfileEditViewControllerDelegate>

@property (strong, nonatomic) NSMutableArray *callouts;
@property (strong, nonatomic) FCOCalloutModel *calloutModel;

@end

@implementation FCOProfileViewController


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
    
    FCOSessionModel *session = [FCOSessionModel sharedInstance];
  
    
    if (![session isLoggedIn]) {
        FCOHeaderViewWithImage *headerView = [FCOHeaderViewWithImage instantiateFromNib];
        [self.tabBarController setSelectedIndex:0];
        [session setToken:nil];
        [session setActiveUser:nil];
        headerView.firstNameLabel.text = @"";
        [headerView setUserDetails:nil];
        [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
    } else {
        FCOHeaderViewWithImage *headerView = [FCOHeaderViewWithImage instantiateFromNib];
        [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
        [self.tableView setParallaxHeaderView:headerView
                                         mode:VGParallaxHeaderModeTop
                                       height:370];
        self.activeUser = [session activeUser];
        [headerView setUserDetails:self.activeUser];
        self.callouts = [NSMutableArray array];
        [self getCallout];
    }

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
    
    NSDictionary *params = @{@"limit": @"5"
                             };
    
    FCOHTTPClient *fcoHttpClient = [FCOHTTPClient sharedInstance];
    [fcoHttpClient GET:urlAction parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        for (NSDictionary *calloutDictionary in  responseObject) {
            self.calloutModel = [[FCOCalloutModel alloc] initWithDictionary:calloutDictionary];
            [self.callouts addObject:self.calloutModel];
            
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
    
//    if (indexPath.section == 0) {
//        if (indexPath.row == 0) {
//            [self setCustomCellLabel:cell title:@"Conor McGregor CALLS-OUT Anyone for a sparring" action:@"CALLS-OUT" andSign:@"&" forLabel:@"for a"];
//            cell.userImageView.image = [UIImage imageNamed:@"profile_user_image"];
//        } else if (indexPath.row == 1) {
//            [self setCustomCellLabel:cell title:@"Conor McGregor CALLS-OUT Anderson Silva for a fight" action:@"CALLS-OUT" andSign:@"&" forLabel:@"for a"];
//            cell.userImageView.image = [UIImage imageNamed:@"profile_user_image"];
//        } else if (indexPath.row == 2) {
//            [self setCustomCellLabel:cell title:@"Conor McGregor CALLS-OUT Georges St-Pierre for a fight" action:@"CALLS-OUT" andSign:@"&" forLabel:@"for a"];
//            cell.userImageView.image = [UIImage imageNamed:@"profile_user_image"];
//        } else if (indexPath.row == 3) {
//            [self setCustomCellLabel:cell title:@"Conor McGregor CALLS-OUT Georges St-Pierre for a fight" action:@"CALLS-OUT" andSign:@"&" forLabel:@"for a"];
//            cell.userImageView.image = [UIImage imageNamed:@"profile_user_image"];
//        }
//      
//    }
    
    cell.delegate = self;
    

    if (self.callouts != nil && [self.callouts count] && self.calloutModel._id) {
        self.calloutModel = [self.callouts objectAtIndex:indexPath.row];
        cell.userCalloutLabel.text = [NSString stringWithFormat:@"%@ CALLS-OUT %@ for a fight",self.calloutModel.fighter_a, self.calloutModel.fighter_b];
    }
    
    return cell;
}

# pragma mark - FCOProfileTableView Delegate

- (void)customCell:(FCOProfileTableViewCell *)cell btnPressed:(UIButton *)btn {
    [self performSegueWithIdentifier:@"profileToDetailsSegue" sender:self];
}

# pragma mark - UITableView Delegate 

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIImage *myImage;
    UIImageView *imageView;
    
    FCOSessionModel *session = [FCOSessionModel sharedInstance];
    if (![session isLoggedIn] || [session token] == nil) {
        [self.tabBarController setSelectedIndex:0];
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
        UILabel *countLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0,self.tableView.frame.size.width - 15,41)];
        countLabel.textColor = [UIColor lightGrayColor];
        countLabel.text = @"37";
        countLabel.textAlignment = NSTextAlignmentRight;
        [countLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:15]];
        [imageView addSubview:myLabel];
        [imageView addSubview:countLabel];
    }
    return imageView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    FCOSessionModel *session = [FCOSessionModel sharedInstance];
    if (![session isLoggedIn]) {
        [self.tabBarController setSelectedIndex:0];
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

# pragma mark - FCOProfileEditViewController Delegate


- (void)didCancel {
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"profileToEditProfile"]) {
        FCOProfileEditViewController *profileEditVC = segue.destinationViewController;
        profileEditVC.delegate = self;
      
    }
    
}



@end
