//
//  FCOSearchResultTableController.h
//  fco
//
//  Created by Kryptonite on 8/12/15.
//  Copyright (c) 2015 Kryptonite. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FCOCalloutModel.h"

@class FCOSearchResultTableController;
@protocol FCOSearchResultTableControllerDelegate <NSObject>

- (void)searchController:(FCOSearchResultTableController *)searchController didSelectTableView:(UITableView *)tableView rowAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface FCOSearchResultTableController : UITableViewController
@property (weak, nonatomic) id <FCOSearchResultTableControllerDelegate> delegate;
@property (strong, nonatomic) FCOCalloutModel *calloutModel;
@property (strong, nonatomic) NSMutableArray *callouts;
@property (strong, nonatomic) NSString *searchString;

- (id)initWithDelegate:(id<FCOSearchResultTableControllerDelegate>)delegate;
@end
