//
//  FCOCategoryDetailsViewController.h
//  fco
//
//  Created by Kryptonite on 8/3/15.
//  Copyright (c) 2015 Kryptonite. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FCOCategoryModel.h"

@interface FCOCategoryDetailsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) FCOCategoryModel *calloutCategory;
- (IBAction)segmentedControlButton:(UISegmentedControl *)sender;


@end
