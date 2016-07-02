//
//  FCOCategoryDetailsViewController.m
//  fco
//
//  Created by Kryptonite on 8/3/15.
//  Copyright (c) 2015 Kryptonite. All rights reserved.
//

#import "FCOCategoryDetailsViewController.h"
#import <AFNetworking/UIImageView+AFNetworking.h>
#import <SCLAlertView-Objective-C/SCLAlertView.h>
#import "FCOCallOutTableViewCell.h"
#import "FCOHTTPClient.h"
#import "FCOCalloutModel.h"
#import "FCODetailViewController.h"

@interface FCOCategoryDetailsViewController ()

@property (strong, nonatomic) FCOCalloutModel *calloutModel;
@property (strong, nonatomic) NSMutableArray *mostViewed;
@property (strong, nonatomic) NSMutableArray *highestRanked;

@property (strong, nonatomic) UIRefreshControl *refreshControl;

@end

@implementation FCOCategoryDetailsViewController
@synthesize segmentedControl;

- (NSMutableArray *)mostViewed {
    if (!_mostViewed) {
        _mostViewed = [[NSMutableArray alloc] init];
    }
    return _mostViewed;
}

- (NSMutableArray *)highestRanked {
    if (!_highestRanked) {
        _highestRanked = [[NSMutableArray alloc] init];
    }
    return _highestRanked;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self tabBarFontName];
    [self setSegmentedControlFontColor];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 60;
    //hide barback item & color
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] init];
    barButton.title = @"";
    self.navigationController.navigationBar.topItem.backBarButtonItem = barButton;
    self.navigationController.navigationBar.tintColor = [UIColor lightGrayColor];
    
    UINib *nib = [UINib nibWithNibName:@"FCOCallOutTableViewCell" bundle:nil];
    [[self tableView] registerNib:nib forCellReuseIdentifier:@"FCOCallOutTableViewCell"];
    
    _refreshControl = [[UIRefreshControl alloc] init];
    [_refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:_refreshControl];
    
}




- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self sortedMostViewed];;
    [self.mostViewed removeAllObjects];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

# pragma mark - IBAction

- (IBAction)segmentedControlButton:(UISegmentedControl *)sender {
    if (sender.selectedSegmentIndex == 0) {
        [self sortedMostViewed];
        [self.tableView reloadData];
        NSLog(@"most viewed");
        
    } else if (sender.selectedSegmentIndex == 1) {
        [self sortedHighestRanked];
        [self.tableView reloadData];
        NSLog(@"highest ranked");
    }
    [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
}

# pragma mark - UITableView Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (segmentedControl.selectedSegmentIndex == 0) {
        return [self.mostViewed count];
    } else if (segmentedControl.selectedSegmentIndex == 1) {
        return [self.highestRanked count];
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"FCOCallOutTableViewCell";
    FCOCallOutTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if (segmentedControl.selectedSegmentIndex == 0) {
        if (self.mostViewed != nil && [self.mostViewed count]) {
            self.calloutModel = [self.mostViewed objectAtIndex:indexPath.row];
            NSString *checkString = [NSString stringWithFormat:@"%@ CALLS-OUT %@ & %@ for a %@ %@",self.calloutModel.user_first_name, self.calloutModel.fighter_a, self.calloutModel.fighter_b, [self.calloutModel.category uppercaseString], [self.calloutModel.match_type uppercaseString]];
            NSLog(@"strinf %@", checkString);
            
            if (![checkString containsString:self.calloutModel.fighter_b]) {
                checkString = [NSString stringWithFormat:@"%@ CALLS-OUT %@ for a %@ %@", self.calloutModel.user_first_name, self.calloutModel.fighter_a, [self.calloutModel.category uppercaseString], [self.calloutModel.match_type uppercaseString]];
                NSLog(@"checkString %@", checkString);
            } else if (![checkString containsString:self.calloutModel.fighter_a]) {
                checkString = [NSString stringWithFormat:@"%@ CALLS-OUT %@ for a %@ %@", self.calloutModel.user_first_name, self.calloutModel.fighter_b, [self.calloutModel.category uppercaseString], [self.calloutModel.match_type uppercaseString]];
                NSLog(@"checkString %@", checkString);
            } else {
                checkString = [NSString stringWithFormat:@"%@ CALLS-OUT %@ & %@ for a %@ %@",self.calloutModel.user_first_name, self.calloutModel.fighter_a, self.calloutModel.fighter_b, [self.calloutModel.category uppercaseString], [self.calloutModel.match_type uppercaseString]];
                NSLog(@"checkString %@", checkString);
            }
            cell.calloutLabel.text = checkString;
            [self getPhoto:cell];
            [self.highestRanked removeAllObjects];
        }
    } else if (segmentedControl.selectedSegmentIndex == 1) {
        if (self.highestRanked != nil && [self.highestRanked count]) {
            self.calloutModel = [self.highestRanked objectAtIndex:indexPath.row];
            NSString *checkString = [NSString stringWithFormat:@"%@ CALLS-OUT %@ & %@ for a %@ %@",self.calloutModel.user_first_name, self.calloutModel.fighter_a, self.calloutModel.fighter_b, [self.calloutModel.category uppercaseString], [self.calloutModel.match_type uppercaseString]];
            NSLog(@"strinf %@", checkString);
            
            if (![checkString containsString:self.calloutModel.fighter_b]) {
                checkString = [NSString stringWithFormat:@"%@ CALLS-OUT %@ for a %@ %@", self.calloutModel.user_first_name, self.calloutModel.fighter_a, [self.calloutModel.category uppercaseString], [self.calloutModel.match_type uppercaseString]];
                NSLog(@"checkString %@", checkString);
            } else if (![checkString containsString:self.calloutModel.fighter_a]) {
                checkString = [NSString stringWithFormat:@"%@ CALLS-OUT %@ for a %@ %@", self.calloutModel.user_first_name, self.calloutModel.fighter_b, [self.calloutModel.category uppercaseString], [self.calloutModel.match_type uppercaseString]];
                NSLog(@"checkString %@", checkString);
            } else {
                checkString = [NSString stringWithFormat:@"%@ CALLS-OUT %@ & %@ for a %@ %@",self.calloutModel.user_first_name, self.calloutModel.fighter_a, self.calloutModel.fighter_b, [self.calloutModel.category uppercaseString], [self.calloutModel.match_type uppercaseString]];
                NSLog(@"checkString %@", checkString);
            }
            cell.calloutLabel.text = checkString;
            [self getPhoto:cell];
            [self.mostViewed removeAllObjects];
        }
    }
    UIColor *lightGray = [UIColor lightGrayColor];
    UIFont *helveticaNormal = [UIFont fontWithName:@"Helvetica" size:13];
    [cell.calloutLabel setFontColor:lightGray string:@"CALLS-OUT"];
    [cell.calloutLabel setFont:helveticaNormal string:@"CALLS-OUT"];
    [cell.calloutLabel setFontColor:lightGray string:@"for a"];
    [cell.calloutLabel setFont:helveticaNormal string:@"for a"];
    NSLog(@"count %lu", (unsigned long)[self.highestRanked count]);
    NSLog(@"count %lu", (unsigned long)[self.mostViewed count]);
    return cell;
}


# pragma mark - TableView Delegate

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

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {

        UIImage *myImage = [UIImage imageNamed:@"callout_titlebg"];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:myImage];
        imageView.frame = CGRectMake(0,0,self.tableView.frame.size.width,40);

        UILabel *myLabel = [[UILabel alloc] initWithFrame:CGRectMake(10,0,280,41)];
        myLabel.textColor = [UIColor lightGrayColor];
        myLabel.text = self.calloutCategory.desc;
        [myLabel setFont:[UIFont fontWithName:@"FederalEscort" size:24]];
        [imageView addSubview:myLabel];
        return imageView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 45;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([self shouldPerformSegueWithIdentifier:@"categoryDetailsToCalloutDetails" sender:nil]) {
        [self performSegueWithIdentifier:@"categoryDetailsToCalloutDetails" sender:nil];
    }
    
}

# pragma mark - Private Methods


- (void)tabBarFontName {
    [[UISegmentedControl appearance] setTitleTextAttributes:@{
                                                              NSForegroundColorAttributeName : [UIColor whiteColor]
                                                              } forState:UIControlStateNormal];
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"FederalEscort" size:21], NSFontAttributeName, [UIColor lightGrayColor], NSForegroundColorAttributeName, nil]];}


- (void)setSegmentedControlFontColor {
    NSDictionary *attributes1 = [NSDictionary dictionaryWithObjectsAndKeys:
                                 [UIFont fontWithName:@"HelveticaNeue-Medium" size:12], NSFontAttributeName,
                                 [UIColor whiteColor], NSForegroundColorAttributeName, nil];
    NSDictionary *attributes2 = [NSDictionary dictionaryWithObjectsAndKeys:
                                 [UIFont fontWithName:@"HelveticaNeue-Medium" size:12], NSFontAttributeName,
                                 [UIColor lightGrayColor], NSForegroundColorAttributeName, nil];
    [self.segmentedControl setTitleTextAttributes:attributes1 forState:UIControlStateSelected];
    [self.segmentedControl setTitleTextAttributes:attributes2 forState:UIControlStateNormal];
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

- (void)sortedMostViewed {
    NSString *categoryID = [NSString stringWithFormat:@"category_id:%@", self.calloutCategory._id];
    NSLog(@"callout category id %@", categoryID);
    NSDictionary *params = @{
                            @"q": categoryID,
                            @"sort": @"-created_at",
                            @"limit": @"20"
                             };
    FCOHTTPClient *fcoHttpClient = [FCOHTTPClient sharedInstance];
    [fcoHttpClient GET:@"callouts" parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        for (NSDictionary *calloutDictionary in responseObject) {
            self.calloutModel = [[FCOCalloutModel alloc] initWithDictionary:calloutDictionary];
            
            if (self.calloutModel != nil) {
                [self.mostViewed addObject:self.calloutModel];
         
                [self.tableView reloadData];
            }
                   [_refreshControl endRefreshing];
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSInteger statusCode = error.code;
        if (statusCode == -999) {
            [self promptAlertView:@"Check Connectivity!!!" withSub:@"The operation couldn't be completed" withClose:@"OK"];
             [_refreshControl endRefreshing];
        } else if (statusCode == -1009 || statusCode == -1004 || statusCode == -1003) {
            [self promptAlertView:@"Failed!!!" withSub:@"Please check your network connection" withClose:@"OK"];
             [_refreshControl endRefreshing];
        } else {
            NSLog(@"error %@", error);
             [_refreshControl endRefreshing];
        }
    }];
}

- (void)sortedHighestRanked {
    NSString *categoryID = [NSString stringWithFormat:@"category_id:%@", self.calloutCategory._id];
    NSLog(@"callout category id %@", categoryID);
    NSDictionary *params = @{
                             @"q": categoryID,
                             @"sort":@"-total_votes",
                             @"limit":@"20"
                             };
    FCOHTTPClient *fcoHttpClient = [FCOHTTPClient sharedInstance];
    [fcoHttpClient GET:@"callouts" parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        for (NSDictionary *calloutDictionary in responseObject) {
            self.calloutModel = [[FCOCalloutModel alloc] initWithDictionary:calloutDictionary];
            if (self.calloutModel != nil) {
            [self.highestRanked addObject:self.calloutModel];
       
                [self.tableView reloadData];
            }
                      [_refreshControl endRefreshing];

        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSInteger statusCode = error.code;
        if (statusCode == -999) {
            [self promptAlertView:@"Check Connectivity!!!" withSub:@"The operation couldn't be completed" withClose:@"OK"];
             [_refreshControl endRefreshing];
        } else if (statusCode == -1009 || statusCode == -1004 || statusCode == -1003) {
            [self promptAlertView:@"Failed!!!" withSub:@"Please check your network connection" withClose:@"OK"];
             [_refreshControl endRefreshing];
        } else {
            NSLog(@"error %@", error);
             [_refreshControl endRefreshing];
        }
    }];
    
}

- (void)getPhoto:(FCOCallOutTableViewCell *)cell {
    NSString *urlID = [NSString stringWithFormat:@"http://api.fightcallout.com/api/v1.0/uploads/%@", self.calloutModel.user_photo];
    NSLog(@"urlID %@", urlID);
    NSURL *logoImageUrl = [NSURL URLWithString:urlID];
    [cell.userImageView setImageWithURLRequest:[NSURLRequest requestWithURL:logoImageUrl] placeholderImage:[UIImage imageNamed:@"callout_thumbnail"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        cell.userImageView.image = image;
        NSLog(@"%@", cell.userImageView.image);
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        NSLog(@"error: %@", error);
    }];
}

- (void)refresh:(UIRefreshControl *)refreshControl {
    [self refreshTableView];
}

- (void)refreshTableView {
    [self sortedMostViewed];
    [self sortedHighestRanked];
    [self.mostViewed removeAllObjects];
    [self.highestRanked removeAllObjects];
}



#pragma mark - Navigation

-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    NSLog(@"taee");
    
    if (self.refreshControl.refreshing) {
        return NO;
    } else {
        return YES;
    }
}



- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"categoryDetailsToCalloutDetails"]) {
        FCODetailViewController *fcoDetailVC = segue.destinationViewController;
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        FCOCalloutModel *selectedModel;
        if (segmentedControl.selectedSegmentIndex == 0) {
            selectedModel = [self.mostViewed objectAtIndex:indexPath.row];
        } else if (segmentedControl.selectedSegmentIndex == 1) {
            selectedModel = [self.highestRanked objectAtIndex:indexPath.row];
        }
        fcoDetailVC.calloutModel = selectedModel;
    }

}



@end
