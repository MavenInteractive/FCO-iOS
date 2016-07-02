//
//  FCOProfileViewController.h
//  fco
//
//  Created by Kryptonite on 6/9/15.
//  Copyright (c) 2015 Kryptonite. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FCOUserModel.h"

@interface FCOProfileViewController : UIViewController
@property (strong, nonatomic) FCOUserModel *activeUser;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

- (IBAction)editBarButtonPressed:(UIBarButtonItem *)sender;

@end
