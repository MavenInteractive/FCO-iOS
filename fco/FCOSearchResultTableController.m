//
//  FCOSearchResultTableController.m
//  fco
//
//  Created by Kryptonite on 8/12/15.
//  Copyright (c) 2015 Kryptonite. All rights reserved.
//

#import "FCOSearchResultTableController.h"
#import "FCOCallOutTableViewCell.h"
#import "FCODetailViewController.h"
#import "FCOHTTPClient.h"
#import "UIImageView+AFNetworking.h"

@interface FCOSearchResultTableController () 


@end

@implementation FCOSearchResultTableController

- (NSMutableArray *)callouts {
    if (!_callouts) {
        _callouts = [[NSMutableArray alloc] init];
    }
    return _callouts;
}


- (id)initWithDelegate:(id<FCOSearchResultTableControllerDelegate>)delegate {
    self = [super init];
    if (self) {
        self.delegate = delegate;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView setBackgroundColor:[UIColor blackColor]];
    
    UINib *nib = [UINib nibWithNibName:@"FCOCallOutTableViewCell" bundle:nil];
    [[self tableView] registerNib:nib forCellReuseIdentifier:@"FCOCallOutTableViewCell"];
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 60;
    [self.tableView setSeparatorColor:[UIColor blackColor]];
  
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
   //[self getCallout];
   //[self.callouts removeAllObjects];
    self.tableView.delegate = self;
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Private Methods

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

- (void)getCallout {
    FCOHTTPClient *fcoHttpClient = [FCOHTTPClient sharedInstance];
    [fcoHttpClient GET:@"callouts" parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        //NSMutableDictionary *calloutDict = [responseObject[@"category"]];
        // NSMutableArray *temp = [NSMutableArray array];
        for (NSDictionary *calloutDictionary in responseObject) {
            self.calloutModel = [[FCOCalloutModel alloc] initWithDictionary:calloutDictionary];
            [self.callouts addObject:self.calloutModel];
            
            NSLog(@"search callout %@", self.callouts);
        }
        [self.tableView reloadData];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"error %@", error);
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return self.callouts.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"FCOCallOutTableViewCell";
    FCOCallOutTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    
    if (self.callouts != nil && [self.callouts count]) {
        self.calloutModel = [self.callouts objectAtIndex:indexPath.row];
        NSString *checkString = [NSString stringWithFormat:@"%@ %@ CALLS-OUT %@ & %@ for a %@",self.calloutModel.user_first_name, self.calloutModel.user_last_name, self.calloutModel.fighter_a, self.calloutModel.fighter_b, self.calloutModel.match_type];
        NSLog(@"strinf %@", checkString);
        
        if (![checkString containsString:self.calloutModel.fighter_b]) {
            checkString = [NSString stringWithFormat:@"%@ %@ CALLS-OUT %@ for a %@", self.calloutModel.user_first_name, self.calloutModel.user_last_name, self.calloutModel.fighter_a, self.calloutModel.match_type];
            NSLog(@"checkString %@", checkString);
        } else if (![checkString containsString:self.calloutModel.fighter_a]) {
            checkString = [NSString stringWithFormat:@"%@ %@ CALLS-OUT %@ for a %@", self.calloutModel.user_first_name, self.calloutModel.user_last_name, self.calloutModel.fighter_b, self.calloutModel.match_type];
            NSLog(@"checkString %@", checkString);
        } else {
            checkString = [NSString stringWithFormat:@"%@ %@ CALLS-OUT %@ & %@ for a %@",self.calloutModel.user_first_name, self.calloutModel.user_last_name, self.calloutModel.fighter_a, self.calloutModel.fighter_b, self.calloutModel.match_type];
            NSLog(@"checkString %@", checkString);
        }
        cell.calloutLabel.text = checkString;
        [self getPhoto:cell];
    }
    
    
    UIColor *lightGray = [UIColor lightGrayColor];
    UIFont *helveticaNormal = [UIFont fontWithName:@"Helvetica" size:13];
    [cell.calloutLabel setFontColor:lightGray string:@"CALLS-OUT"];
    [cell.calloutLabel setFont:helveticaNormal string:@"CALLS-OUT"];
    [cell.calloutLabel setFontColor:lightGray string:@"for a"];
    [cell.calloutLabel setFont:helveticaNormal string:@"for a"];
    
           NSLog(@"count search %lu", (unsigned long)[self.callouts count]);
    return cell;
}


#pragma mark - TableView Delegate

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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
//    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//    FCODetailViewController *viewController = (FCODetailViewController *)[storyboard instantiateViewControllerWithIdentifier:@"DetailVC"];
//    [self presentViewController:viewController animated:YES completion:nil];
//    
    [self.delegate searchController:self didSelectTableView:tableView rowAtIndexPath:indexPath];
    
    
    NSLog(@"test!11!!");
    
}




#pragma mark - Navigation

//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//    if ([segue.identifier isEqualToString:@"searchToDetail"]) {
//        FCODetailViewController *detailVC = segue.destinationViewController;
//        
//    }
//}


@end
