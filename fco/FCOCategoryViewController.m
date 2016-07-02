//
//  FCOCategoryViewController.m
//  fco
//
//  Created by Kryptonite on 6/9/15.
//  Copyright (c) 2015 Kryptonite. All rights reserved.
//

#import "FCOCategoryViewController.h"
#import "FCOCategoryViewCell.h"
#import "FCOSessionModel.h"
#import "FCOHTTPClient.h"
#import "FCOCategoryDetailsViewController.h"

@interface FCOCategoryViewController ()

@property (strong, nonatomic) FCOCategoryModel *categoryModel;
@property (strong, nonatomic) NSMutableArray *calloutCategory;

@end

@implementation FCOCategoryViewController

-(NSMutableArray *)calloutCategory {
    if (!_calloutCategory) {
        _calloutCategory = [[NSMutableArray alloc]init];
    }
    return _calloutCategory;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[UISegmentedControl appearance] setTitleTextAttributes:@{
                                                              NSForegroundColorAttributeName : [UIColor whiteColor]
                                                              } forState:UIControlStateNormal];
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"FederalEscort" size:21], NSFontAttributeName, [UIColor lightGrayColor], NSForegroundColorAttributeName, nil]];
    
    UINib *nib = [UINib nibWithNibName:@"FCOCategoryViewCell" bundle:nil];
    [[self tableView] registerNib:nib forCellReuseIdentifier:@"FCOCategoryViewCell"];
    [self getcalloutCategory];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
    FCOSessionModel *session = [FCOSessionModel sharedInstance];
    if (!session.isLoggedIn) {
        [self.tabBarController setSelectedIndex:1];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


# pragma mark - UITableView Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.calloutCategory count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"FCOCategoryViewCell";
    FCOCategoryViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if (cell == nil) {
        // Load the top-level objects from the custom cell XIB.
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"FCOCategoryViewCell" owner:nil options:nil];
        // Grab a pointer to the first object (presumably the custom cell, as that's all the XIB should contain).
        cell = [topLevelObjects objectAtIndex:0];
    }
    
    if (self.calloutCategory != nil && [self.calloutCategory count]) {
        self.categoryModel = [self.calloutCategory objectAtIndex:indexPath.row];
        cell.categoryNameLabel.text = self.categoryModel.desc;
        cell.badgeLabel.text = @"";
    }
    return cell;
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

# pragma mark - UITableViewController Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"categoryToCategoryDetails" sender:self];
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController isKindOfClass:[FCOCategoryDetailsViewController class]]) {
        FCOCategoryDetailsViewController *fcoCategoryDetailVC = segue.destinationViewController ;
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        FCOCategoryModel *selectedCategory = [self.calloutCategory objectAtIndex:indexPath.row];
        fcoCategoryDetailVC.calloutCategory = selectedCategory;
    }
}


@end
