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


@interface FCOMainViewController ()
@property (strong, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *loginBarButtonItem;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *callouts;
@property (strong, nonatomic) NSMutableArray *callout;
@property (strong, nonatomic) NSMutableArray *calloutCategory;
@property (strong, nonatomic) FCOCalloutModel *calloutModel;
@property (strong, nonatomic) FCOUserModel *userModel;

@property (strong, nonatomic) NSString *fight;


@end

@implementation FCOMainViewController

- (NSMutableArray *)callouts {
    if (!_callouts) {
        _callouts = [[NSMutableArray alloc] init];
    }
    return _callouts;
}

# pragma mark - View Life Cycle

- (void)viewWillAppear:(BOOL)animated {
      [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
    FCOSessionModel *session = [FCOSessionModel sharedInstance];
    
    if (session.isLoggedIn) {
        self.loginBarButtonItem.title = @"Logout";
    }
    self.callouts = [NSMutableArray array];
    [self getCallout];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view
    [self tabBarFontName];
    [self setSegmentedControlFontColor];
    UINib *nib = [UINib nibWithNibName:@"FCOCallOutTableViewCell" bundle:nil];
    [[self tableView] registerNib:nib forCellReuseIdentifier:@"FCOCallOutTableViewCell"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



# pragma mark - IBAction

- (IBAction)loginBarButtonItemPressed:(UIBarButtonItem *)sender {
    if ([self.navigationItem.leftBarButtonItem.title isEqualToString:@"Logout"]) {
        
        FCOSessionModel *session = [FCOSessionModel sharedInstance];
        [session setToken:nil];
        [session setActiveUser:nil];
        self.navigationItem.leftBarButtonItem.title= @"Login";
        [self.tableView reloadData];
        return;
    }
    [self performSegueWithIdentifier:@"mainToLoginSegue" sender:self];
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

- (void)setCustomCellLabel:(FCOCallOutTableViewCell *)cell title:(NSString *)title action:(NSString *)callsout andSign:(NSString *)andSign {
    cell.calloutLabel.text = title;
    UIColor *lightGray = [UIColor lightGrayColor];
    UIFont *helveticaNormal = [UIFont fontWithName:@"Helvetica" size:13];
    [cell.calloutLabel setFontColor:lightGray string:callsout];
    [cell.calloutLabel setFontColor:lightGray string:andSign];
    [cell.calloutLabel setFont:helveticaNormal string:callsout];
    [cell.calloutLabel setFont:helveticaNormal string:andSign];
}

- (void)getCallout {
    
    
    NSDictionary *params = @{
                             @"sort":@"-created_at"
                             };
    
    FCOHTTPClient *fcoHttpClient = [FCOHTTPClient sharedInstance];
    [fcoHttpClient GET:@"callouts" parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        
        //NSMutableDictionary *calloutDict = [responseObject[@"category"]];
        
        for (NSDictionary *calloutDictionary in responseObject) {
            self.calloutModel = [[FCOCalloutModel alloc] initWithDictionary:calloutDictionary];
            [self.callouts addObject:self.calloutModel];
        }
        [self.tableView reloadData];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"error %@", error);
    }];
}

#pragma mark - TableView Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.callouts count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"FCOCallOutTableViewCell";
    FCOCallOutTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if (cell == nil) {
        // Load the top-level objects from the custom cell XIB.
//        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"FCOCallOutTableViewCell" owner:nil options:nil];
//        // Grab a pointer to the first object (presumably the custom cell, as that's all the XIB should contain).
//        cell = [topLevelObjects objectAtIndex:0];
    }
    
    cell.delegate = self;
//    [self setCustomCellLabel:cell title:@"King CALLS-OUT Mike Tyson & Floyd Mayweather Jr. for a fight" action:@"CALLS-OUT" andSign:@"&"];
//     cell.userImageView.image = [UIImage imageNamed:@"callout_king"];
//    if (indexPath.section == 0) {
//        if (indexPath.row == 1) {
//            [self setCustomCellLabel:cell title:@"Manny Pacquiao CALLS-OUT Floyd Mayweather Jr. for a sparring" action:@"CALLS-OUT" andSign:@"&"];
//            cell.userImageView.image = [UIImage imageNamed:@"callout_user_thumbnail"];
//        } else if (indexPath.row == 2) {
//            [self setCustomCellLabel:cell title:@"Mike Tyson CALLS-OUT Floyd Mayweather Jr. for a sparring" action:@"CALLS-OUT" andSign:@"&"];
//            cell.userImageView.image = [UIImage imageNamed:@"callout_mitetyson"];
//        } else if (indexPath.row == 3) {
//            [self setCustomCellLabel:cell title:@"Mcoy Rosales CALLS-OUT Zairus Kyle & Bluefritz Lumbab for a fight" action:@"CALLS-OUT" andSign:@"&"];
//            cell.userImageView.image = [UIImage imageNamed:@"callout_user_thumbnail"];
//        }
//    } else if (indexPath.section == 1) {
//        if (indexPath.row == 1) {
//            [self setCustomCellLabel:cell title:@"Conor McGregor CALLS-OUT anyone for a sparring" action:@"CALLS-OUT" andSign:@"&"];
//            cell.userImageView.image = [UIImage imageNamed:@"callout_user_thumbnail"];
//        } else if (indexPath.row == 2) {
//            [self setCustomCellLabel:cell title:@"Dennis Siver CALLS-OUT Conor McGregor for a fight" action:@"CALLS-OUT" andSign:@"&"];
//            cell.userImageView.image = [UIImage imageNamed:@"callout_user_thumbnail"];
//        } else if (indexPath.row == 3) {
//            [self setCustomCellLabel:cell title:@"Dana White CALLS-OUT Anderson Silva & Georges St-Pierre for a fight" action:@"CALLS-OUT" andSign:@"&"];
//            cell.userImageView.image = [UIImage imageNamed:@"callout_user_thumbnail"];
//        }
//    }
    
    if (self.callouts != nil && [self.callouts count]) {
        self.calloutModel = [self.callouts objectAtIndex:indexPath.row];
        cell.calloutLabel.text = [NSString stringWithFormat:@"%@ CALLS-OUT %@ for a fight",self.calloutModel.fighter_a, self.calloutModel.fighter_b];
    }
    return cell;
}

# pragma mark - TableView Delegate

//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
//    if (section == 0) {
//        UIImage *myImage = [UIImage imageNamed:@"callout_titlebg"];
//        UIImageView *imageView = [[UIImageView alloc] initWithImage:myImage];
//        imageView.frame = CGRectMake(0,0,self.tableView.frame.size.width,40);
//    
//        UILabel *myLabel = [[UILabel alloc] initWithFrame:CGRectMake(10,0,150,41)];
//        myLabel.textColor = [UIColor lightGrayColor];
//        myLabel.text = @"Boxing";
//        [myLabel setFont:[UIFont fontWithName:@"FederalEscort" size:20]];
//        [imageView addSubview:myLabel];
//        return imageView;
//    } else if (section == 1){
//        UIImage *myImage = [UIImage imageNamed:@"callout_titlebg"];
//        UIImageView *imageView = [[UIImageView alloc] initWithImage:myImage];
//        imageView.frame = CGRectMake(0,0,self.tableView.frame.size.width,40);
//    
//        UILabel *myLabel = [[UILabel alloc] initWithFrame:CGRectMake(10,0,150,41)];
//        myLabel.textColor = [UIColor lightGrayColor];
//        myLabel.text = @"UFC";
//        [myLabel setFont:[UIFont fontWithName:@"FederalEscort" size:20]];
//        [imageView addSubview:myLabel];
//        return imageView;
//    } else {
//        UIImage *myImage = [UIImage imageNamed:@"callout_titlebg"];
//        UIImageView *imageView = [[UIImageView alloc] initWithImage:myImage];
//        imageView.frame = CGRectMake(0,0,self.tableView.frame.size.width,40);
//       
//        UILabel *myLabel = [[UILabel alloc] initWithFrame:CGRectMake(10,0,150,41)];
//        myLabel.textColor = [UIColor lightGrayColor];
//        myLabel.text = @"Karate";
//        [myLabel setFont:[UIFont fontWithName:@"FederalEscort" size:20]];
//        [imageView addSubview:myLabel];
//        return imageView;
//    }
//}

//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
//    return 45;
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


# pragma mark - FCOLoginViewController Delegate

- (void)didCancel {
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"mainToLoginSegue"]) {
        FCOLoginViewController *loginVC = segue.destinationViewController;
        loginVC.delegate = self;
    }
}


# pragma mark - FCOCallOutTableviewCell Delegate

-(void)customCell:(FCOCallOutTableViewCell *)cell btnPressed:(UIButton *)btn {
    [self performSegueWithIdentifier:@"mainToDetailSegue" sender:self];
}

@end
