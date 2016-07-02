//
//  FCOMainViewController.h
//  fco
//
//  Created by Kryptonite on 6/9/15.
//  Copyright (c) 2015 Kryptonite. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FCOLoginViewController.h"
#import "FCOCallOutTableViewCell.h"

@interface FCOMainViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, FCOLoginViewControllerDelegate>
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) NSString *searchString;

- (IBAction)searchBarButtonItemPressed:(UIBarButtonItem *)sender;

@end
