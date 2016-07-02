//
//  FCOMainViewController.m
//  fco
//
//  Created by Kryptonite on 6/9/15.
//  Copyright (c) 2015 Kryptonite. All rights reserved.
//

#import "FCOMainViewController.h"
#import "FCOCallOutTableViewCell.h"
#import "FCOSessionModel.h"
#import "FCOHTTPClient.h"
#import "FCOHeaderViewWithImage.h"
#import "FCOCalloutModel.h"
#import "FCOCategoryModel.h"
#import "FCODetailViewController.h"
#import <AFNetworking/UIImageView+AFNetworking.h>
#import <SCLAlertView-Objective-C/SCLAlertView.h>
#import "FCOSearchResultTableController.h"


@interface FCOMainViewController () <UISearchResultsUpdating, UISearchBarDelegate, UISearchControllerDelegate, UIScrollViewDelegate, FCOSearchResultTableControllerDelegate>
@property (strong, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *loginBarButtonItem;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *searchCallouts;
@property (strong, nonatomic) NSMutableArray *mostViewed;
@property (strong, nonatomic) NSMutableArray *highestRanked;
@property (strong, nonatomic) NSMutableArray *calloutCategory;
@property (strong, nonatomic) FCOCalloutModel *calloutModel;
@property (strong, nonatomic) FCOUserModel *userModel;
@property (strong, nonatomic) FCOCategoryModel *categoryModel;
@property (strong, nonatomic) NSString *fight;
@property (nonatomic, strong) UISearchController *searchController;
@property (strong, nonatomic) FCOSearchResultTableController *searchResultController;
@property (strong, nonatomic) FCOMainViewController *mainVC;

@property (strong, nonatomic) NSMutableArray *sportsType;
@property (strong, nonatomic) NSString *selectedSportType;


@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property BOOL isEndRefreshing;
@property BOOL isStartRereshing;



@end

@implementation FCOMainViewController 
@synthesize segmentedControl;

- (NSMutableArray *)searchCallouts {
    if (!_searchCallouts) {
        _searchCallouts = [[NSMutableArray alloc] init];
    }
    return _searchCallouts;
}

-(NSMutableArray *)sportsType {
    if (!_sportsType) {
        _sportsType = [[NSMutableArray alloc] init];
    }
    return _sportsType;
}

# pragma mark - View Life Cycle

- (void)viewWillAppear:(BOOL)animated {
     // [self getCategories];
    FCOSessionModel *session = [FCOSessionModel sharedInstance];
    
    if (self.searchController.active == YES) {
        [self.searchController setActive:NO];
       self.tableView.contentInset = UIEdgeInsetsMake( (self.navigationController.navigationBar.frame.origin.y - 20), 0, 0, 0);
        NSLog(@"search controller is inactive!");
    } else {
       self.tableView.contentInset = UIEdgeInsetsMake( (self.navigationController.navigationBar.frame.origin.y - 20), 0, 0, 0);
         [self.searchController.searchBar becomeFirstResponder];    }
    
    
    
    if (!session.isLoggedIn) {
        self.navigationItem.leftBarButtonItem.title = @"Login";
        [session setToken:nil];
        [session setActiveUser:nil];
        [self sortedMostViewed];
        [self sortedHighestRanked];
        [self getSearchCallout];
        [self.highestRanked removeAllObjects];
        [self.mostViewed removeAllObjects];
        [self.searchCallouts removeAllObjects];
        NSLog(@"not logged in");
        
    } else {
        [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
        [segmentedControl setSelectedSegmentIndex:0];
        self.loginBarButtonItem.title = @"Logout";
        [self sortedMostViewed];
        [self sortedHighestRanked];
        [self.mostViewed removeAllObjects];
        [self.highestRanked removeAllObjects];
          [self.tableView reloadData];
    }
    
    
    
    [self initializeSearchController];
//    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
//                                   initWithTarget:self
//                                   action:@selector(tapped)];
    [self getSearchCallout];
    [self.searchCallouts removeAllObjects];
   // NSLog(@"search callout count %lu", (unsigned long)self.searchCallouts.count);
    //self.tableView.contentInset = UIEdgeInsetsMake( (self.navigationController.navigationBar.frame.origin.y - 20), 0, 0, 0);
    [self.tableView reloadData];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view
    

    
    [self tabBarFontName];
    [self setSegmentedControlFontColor];
    
    UINib *nib = [UINib nibWithNibName:@"FCOCallOutTableViewCell" bundle:nil];
    [[self tableView] registerNib:nib forCellReuseIdentifier:@"FCOCallOutTableViewCell"];
    
    self.mostViewed = [NSMutableArray array];
    self.highestRanked = [NSMutableArray array];
    //self.calloutCategory = [NSMutableArray array];
    

    //[self sortedMostViewed];
    
    [self.tableView reloadData];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 60;
    //NSLog(@"sorted most view %@", self.mostViewed);
    
    _refreshControl = [[UIRefreshControl alloc] init];
    [_refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:_refreshControl];
    
    

//  NSMutableArray *items = [[self.sportsType filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(desc == %@)", self.selectedSportType]]mutableCopy];
//  FCOCategoryModel *selectedCategory = (FCOCategoryModel *)[items firstObject];
//    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
//    [dict setObject:selectedCategory._id forKey:@"category_id"];
//    self.selectedSportType = [dict objectForKey:@"category_id"];
//    NSLog(@"sports type %@",self.selectedSportType);
    

    
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

# pragma mark - Initializations

- (void)initializeSearchController {
    self.searchResultController = [[FCOSearchResultTableController alloc] initWithDelegate:self];
    self.searchController  = [[UISearchController alloc] initWithSearchResultsController:self.searchResultController];
    self.searchController.searchResultsUpdater = self;
    [self.searchController.searchBar sizeToFit];
    self.tableView.tableHeaderView = nil;
    // we want to be the delegate for our filtered table so didSelectRowAtIndexPath is called for both tables
    //self.resultsTableController.tableView.delegate = self;
    self.searchController.delegate = self;
    self.searchController.dimsBackgroundDuringPresentation = NO;
    self.searchController.searchBar.delegate = self; // so we can monitor text changes + others
    
    self.searchController.searchBar.barTintColor = [UIColor clearColor];
    self.searchController.searchBar.tintColor = [UIColor grayColor];
    self.definesPresentationContext = YES;
   // [self setSearchHidden:YES animated:YES];
    

    [self.tableView reloadData];
}


# pragma mark - IBAction

- (IBAction)loginBarButtonItemPressed:(UIBarButtonItem *)sender {
    if ([self.navigationItem.leftBarButtonItem.title isEqualToString:@"Logout"]) {
        
        FCOSessionModel *session = [FCOSessionModel sharedInstance];
        [session setToken:nil];
        [session setActiveUser:nil];
        self.navigationItem.leftBarButtonItem.title= @"Login";
        [self performSegueWithIdentifier:@"mainToLoginSegue" sender:self];
        [self.tableView reloadData];
        return;
    }
    [self performSegueWithIdentifier:@"mainToLoginSegue" sender:self];
}

- (IBAction)segmentedControlAction:(UISegmentedControl *)sender {
    if (sender.selectedSegmentIndex == 0) {
        [self sortedMostViewed];
        [self.mostViewed removeAllObjects];
        [self.tableView reloadData];
         NSLog(@"most viewed");
    } else if (sender.selectedSegmentIndex == 1) {
        [self sortedHighestRanked];
        [self searchCallouts];
        [self.highestRanked removeAllObjects];
        [self.tableView reloadData];
         NSLog(@"highest ranked");
    }
    [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
}

- (IBAction)searchBarButtonItemPressed:(UIBarButtonItem *)sender {
    if (self.tableView) {
           self.tableView.contentInset = UIEdgeInsetsMake( (self.navigationController.navigationBar.frame.origin.y - 65), 0, 0, 0); 
    }

    [self.searchController setActive:YES];
    self.tableView.tableHeaderView = self.searchController.searchBar;
    [self.searchController.searchBar becomeFirstResponder];
    [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];

}

- (void)tapped {
    NSLog(@"tap cancel");
    [self.searchController setActive:NO];
}


#pragma mark - FCOSearchResultTableController Delegate
- (void)searchController:(FCOSearchResultTableController *)searchController didSelectTableView:(UITableView *)tableView rowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.searchCallouts != nil && [self.searchCallouts count]) {
        FCOCalloutModel *selectedModel = (tableView == self.tableView) ?
        self.searchCallouts[indexPath.row] : self.searchResultController.callouts[indexPath.row];
        FCODetailViewController *detailVC = [self.storyboard instantiateViewControllerWithIdentifier:@"DetailVC"];
        detailVC.calloutModel = selectedModel;
        [self.navigationController pushViewController:detailVC animated:YES];
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
        NSLog(@"test!!!");
    }
}

#pragma mark - UIScrollView Delegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
   // NSLog(@"sss");
}

#pragma mark - UISearchBarDelegate
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    NSLog(@"%@", searchBar.text);
   // [searchBar resignFirstResponder];
   // [self getSearchCallout:searchBar.text];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    self.tableView.tableHeaderView = nil;
    [self.searchController setActive:YES];
self.tableView.contentInset = UIEdgeInsetsMake( (self.navigationController.navigationBar.frame.origin.y + 44), 0, 0, 0);
    [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];

  // self.tableView.contentInset = UIEdgeInsetsMake( (self.navigationController.navigationBar.frame.origin.y + 100), 0, 0, 0);
   
}



#pragma mark - UISearchResultsUpdating

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    NSString *searchText = searchController.searchBar.text;
    NSMutableArray *searchResults = self.searchCallouts;
    NSString *strippedString = [searchText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    NSArray *searchItems = nil;
    if (strippedString.length > 0) {
        searchItems = [strippedString componentsSeparatedByString:@" "];
    }
    NSMutableArray *andMatchPredicate = [NSMutableArray array];
    for (NSString *searchString in searchItems) {
        NSMutableArray *searchItemsPredicate = [NSMutableArray array];
        
        
        NSExpression *lhs = [NSExpression expressionForKeyPath:@"fighter_a"];
        NSExpression *rhs = [NSExpression expressionForConstantValue:searchString];
        NSPredicate *finalPredicate = [NSComparisonPredicate
                                       predicateWithLeftExpression:lhs
                                       rightExpression:rhs
                                       modifier:NSDirectPredicateModifier
                                       type:NSContainsPredicateOperatorType
                                       options:NSCaseInsensitivePredicateOption];
        [searchItemsPredicate addObject:finalPredicate];
        
        NSExpression *lhs2 = [NSExpression expressionForKeyPath:@"fighter_b"];
        NSExpression *rhs2 = [NSExpression expressionForConstantValue:searchString];
        NSPredicate *finalPredicate2 = [NSComparisonPredicate
                                       predicateWithLeftExpression:lhs2
                                       rightExpression:rhs2
                                       modifier:NSDirectPredicateModifier
                                       type:NSContainsPredicateOperatorType
                                       options:NSCaseInsensitivePredicateOption];
        [searchItemsPredicate addObject:finalPredicate2];
        
        
        NSExpression *lhs3 = [NSExpression expressionForKeyPath:@"match_type"];
        NSExpression *rhs3 = [NSExpression expressionForConstantValue:searchString];
        NSPredicate *finalPredicate3 = [NSComparisonPredicate
                                        predicateWithLeftExpression:lhs3
                                        rightExpression:rhs3
                                        modifier:NSDirectPredicateModifier
                                        type:NSContainsPredicateOperatorType
                                        options:NSCaseInsensitivePredicateOption];
        [searchItemsPredicate addObject:finalPredicate3];
        
        
//        NSExpression *lhs4 = [NSExpression expressionForKeyPath:@"user.first_name"];
//        NSExpression *rhs4 = [NSExpression expressionForConstantValue:searchString];
//        NSPredicate *finalPredicate4 = [NSComparisonPredicate
//                                        predicateWithLeftExpression:lhs4
//                                        rightExpression:rhs4
//                                        modifier:NSDirectPredicateModifier
//                                        type:NSContainsPredicateOperatorType
//                                        options:NSCaseInsensitivePredicateOption];
//        [searchItemsPredicate addObject:finalPredicate4];
        
        
        NSCompoundPredicate *orMatchPredicates = [NSCompoundPredicate orPredicateWithSubpredicates:searchItemsPredicate];
        [andMatchPredicate addObject:orMatchPredicates];

    }
    NSCompoundPredicate *finalCompoundPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:andMatchPredicate];
    searchResults = [[searchResults filteredArrayUsingPredicate:finalCompoundPredicate] mutableCopy];
    
    FCOSearchResultTableController *tb = (FCOSearchResultTableController *)self.searchController.searchResultsController;
    tb.callouts = searchResults;
    [tb.tableView reloadData];

}

#pragma mark - UISearchControllerDelegate

- (void)presentSearchController:(UISearchController *)searchController {
   // [self.tableView setContentOffset:CGPointMake(0.0, self.tableView.tableHeaderView.frame.size.height) animated:YES];

}

- (void)willPresentSearchController:(UISearchController *)searchController {
    // do something before the search controller is presented
   
}

- (void)didPresentSearchController:(UISearchController *)searchController {
    // do something after the search controller is presented
    
}

- (void)willDismissSearchController:(UISearchController *)searchController {
    // do something before the search controller is dismissed
    NSLog(@"dismiss 1");
}

- (void)didDismissSearchController:(UISearchController *)searchController {
    // do something after the search controller is dismissed
      self.tableView.contentInset = UIEdgeInsetsMake( (self.navigationController.navigationBar.frame.origin.y - 20), 0, 0, 0);
   NSLog(@"dismiss 2");

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


- (void)sortedMostViewed {
    
        NSDictionary *params = @{
                                 @"sort": @"-created_at",//@"-total_views",
                                 @"limit":@"20"
                                 };
        FCOHTTPClient *fcoHttpClient = [FCOHTTPClient sharedInstance];
        [fcoHttpClient GET:@"callouts" parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
            
            //NSMutableDictionary *calloutDict = [responseObject[@"category"]];
            // NSMutableArray *temp = [NSMutableArray array];
            for (NSDictionary *calloutDictionary in responseObject) {
                self.calloutModel = [[FCOCalloutModel alloc] initWithDictionary:calloutDictionary];
                
                if (self.calloutModel != nil) {
               [self.mostViewed addObject:self.calloutModel];
                    [self.tableView reloadData];
                }
             [_refreshControl endRefreshing];
            }
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            NSString* ErrorResponse = [[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding];
            NSLog(@"%@",ErrorResponse);
            
            
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
    NSDictionary *params = @{
                             @"sort":@"-total_votes",
                             @"limit":@"20"
                             };
    FCOHTTPClient *fcoHttpClient = [FCOHTTPClient sharedInstance];
    [fcoHttpClient GET:@"callouts" parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        
        //NSMutableDictionary *calloutDict = [responseObject[@"category"]];
        // NSMutableArray *temp = [NSMutableArray array];
        for (NSDictionary *calloutDictionary in responseObject) {
            self.calloutModel = [[FCOCalloutModel alloc] initWithDictionary:calloutDictionary];
            
            if (self.calloutModel != nil) {
                [self.highestRanked addObject:self.calloutModel];
                    [self.tableView reloadData];

            }
            [_refreshControl endRefreshing];
        }

    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        NSString* ErrorResponse = [[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding];
        NSLog(@"%@",ErrorResponse);
        
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

- (void)getcalloutCategory {
    FCOHTTPClient *fcoHttpClient = [FCOHTTPClient sharedInstance];
    [fcoHttpClient GET:@"categories" parameters:@"" success:^(NSURLSessionDataTask *task, id responseObject) {
        
        //NSMutableDictionary *calloutDict = [responseObject[@"category"]];
        // NSMutableArray *temp = [NSMutableArray array];
        for (NSDictionary *calloutDictionary in responseObject) {
            self.categoryModel = [[FCOCategoryModel alloc] initWithDictionary:calloutDictionary];
            [self.calloutCategory addObject:self.categoryModel];
        }
        [self.tableView reloadData];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"error %@", error);
    }];
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

- (void)setSearchHidden:(BOOL)hidden animated:(BOOL)animated {
    UISearchBar *searchBar = self.searchController.searchBar;
    CGFloat searchBarHeight = searchBar.frame.size.height;
    
    CGFloat offset = (hidden)? -searchBarHeight : searchBarHeight;
    NSTimeInterval duration = (animated)? 0.3 : 0.0;
    
    [UIView animateWithDuration:duration animations:^{
        searchBar.frame = CGRectOffset(searchBar.frame, 0.0, offset);
        self.tableView.frame = UIEdgeInsetsInsetRect(self.tableView.frame, UIEdgeInsetsMake(offset, 0, 0, 0));
    } completion:^(BOOL finished) {if (!hidden) [searchBar becomeFirstResponder];}];
}

- (void)getSearchCallout {
    FCOHTTPClient *fcoHttpClient = [FCOHTTPClient sharedInstance];
    [fcoHttpClient GET:@"callouts" parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        //NSMutableDictionary *calloutDict = [responseObject[@"category"]];
        // NSMutableArray *temp = [NSMutableArray array];
        for (NSDictionary *calloutDictionary in responseObject) {
            self.calloutModel = [[FCOCalloutModel alloc] initWithDictionary:calloutDictionary];
            
            if (self.calloutModel != nil) {
            [self.searchCallouts addObject:self.calloutModel];
                
            }
  
           // NSLog(@"search callout %@", self.searchCallouts);
        }
        [self.tableView reloadData];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"error %@", error);
    }];
}

- (void)getCategories {
    FCOHTTPClient *fcoHttpClient = [FCOHTTPClient sharedInstance];
    [fcoHttpClient GET:@"categories" parameters:@"" success:^(NSURLSessionDataTask *task, id responseObject) {
        // NSMutableArray *temp = [NSMutableArray array];
        for (NSDictionary *categoryDictionary in responseObject) {
            FCOCategoryModel *category = [[FCOCategoryModel alloc] initWithDictionary:categoryDictionary];
            [self.sportsType addObject:category.desc];
            //  [temp addObject:category.desc];
        }
        [self.tableView reloadData];
        NSLog(@"sports type %@", self.sportsType);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSInteger statusError = error.code;
        if (statusError == 400) {
            NSLog(@"need hedear!!");
        }
        NSLog(@"error %@", error);
    }];
}
//    NSUInteger index = self.calloutModel.category_id.integerValue - 1;
//    if (index < self.sportsType.count) {
//
//        self.catDesc = [self.sportsType objectAtIndex:index];
//        NSLog(@"catdesc %@",self.catDesc);
//    }

//- (void)segmentedTwoFighter:(NSString *)checkString {
//    checkString = [NSString stringWithFormat:@"%@ %@ CALLS-OUT %@ & %@ for a %@",self.calloutModel.user_first_name, self.calloutModel.user_last_name, self.calloutModel.fighter_a, self.calloutModel.fighter_b, self.calloutModel.match_type];
//}
//
//- (void)segmentedFighterA:(NSString *)checkString {
//    checkString = [NSString stringWithFormat:@"%@ %@ CALLS-OUT %@ for a %@", self.calloutModel.user_first_name, self.calloutModel.user_last_name, self.calloutModel.fighter_a, self.calloutModel.match_type];
//}
//
//- (void)segmentedFighterB:(NSString *)checkString {
//    checkString = [NSString stringWithFormat:@"%@ %@ CALLS-OUT %@ for a %@", self.calloutModel.user_first_name, self.calloutModel.user_last_name, self.calloutModel.fighter_b, self.calloutModel.match_type];
//}


#pragma mark - TableView Data Source

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
    
    if (cell == nil) {
// Load the top-level objects from the custom cell XIB.
//        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"FCOCallOutTableViewCell" owner:nil options:nil];
//        // Grab a pointer to the first object (presumably the custom cell, as that's all the XIB should contain).
//        cell = [topLevelObjects objectAtIndex:0];
//        
//         cell = [[FCOCallOutTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault   reuseIdentifier:CellIdentifier];
    }

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

//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
//    
//        self.categoryModel = [self.calloutCategory objectAtIndex:section];
//    
//        UIImage *myImage = [UIImage imageNamed:@"callout_titlebg"];
//        UIImageView *imageView = [[UIImageView alloc] initWithImage:myImage];
//        imageView.frame = CGRectMake(0,0,self.tableView.frame.size.width,40);
//    
//        UILabel *myLabel = [[UILabel alloc] initWithFrame:CGRectMake(10,0,230,41)];
//        myLabel.textColor = [UIColor lightGrayColor];
//        myLabel.text = self.categoryModel.desc;
//        [myLabel setFont:[UIFont fontWithName:@"FederalEscort" size:20]];
//        [imageView addSubview:myLabel];
//        return imageView;
//}
//
//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
//    return 45;
//
//}

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

    
    if ([self shouldPerformSegueWithIdentifier:@"mainToDetailSegue" sender:nil]) {
        [self performSegueWithIdentifier:@"mainToDetailSegue" sender:nil];
    }

}


# pragma mark - FCOLoginViewController Delegate
- (void)loginDidCancel {
    [self dismissViewControllerAnimated:YES completion:nil];
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
    if ([segue.identifier isEqualToString:@"mainToLoginSegue"]) {
        FCOLoginViewController *loginVC = segue.destinationViewController;
        loginVC.delegate = self;
    } else if ([segue.identifier isEqualToString:@"mainToDetailSegue"]) {
        FCODetailViewController *fcoDetailVC = segue.destinationViewController;
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        FCOCalloutModel *selectedModel;
        if (segmentedControl.selectedSegmentIndex == 0) {
        selectedModel = [self.mostViewed objectAtIndex:indexPath.row];
        } else if (segmentedControl.selectedSegmentIndex == 1) {
            selectedModel = [self.highestRanked objectAtIndex:indexPath.row];
        }
            fcoDetailVC.calloutModel = selectedModel;
        NSLog(@"check model %@", fcoDetailVC.calloutModel);
    } else if ([segue.destinationViewController isKindOfClass:[FCOSearchResultTableController class]]) {
        FCOSearchResultTableController *searchResultVC = segue.destinationViewController;
        searchResultVC.searchString = self.searchString;
    }
}

//# pragma mark - FCOCallOutTableviewCell Delegate
//
//-(void)customCell:(FCOCallOutTableViewCell *)cell btnPressed:(UIButton *)btn {
//    
//
//    //NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
//    [self performSegueWithIdentifier:@"mainToDetailSegue" sender:btn];
//    //NSLog(@"selected row: %d", indexPath.row);

//

//}


@end
