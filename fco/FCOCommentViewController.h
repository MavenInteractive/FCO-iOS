//
//  FCOCommentViewController.h
//  fco
//
//  Created by Kryptonite on 7/20/15.
//  Copyright (c) 2015 Kryptonite. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FCOCalloutModel.h"
#import "FCOCommentModel.h"
#import "FCOUserModel.h"

@protocol FCOCommentViewControllerDelegate <NSObject>

-(void)didUpdateCallout;

@end


@interface FCOCommentViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) id <FCOCommentViewControllerDelegate> delegate;

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) FCOCalloutModel *calloutModel;
@property (strong, nonatomic) FCOCalloutModel *commentCalloutModel;
@property (strong, nonatomic) FCOCommentModel *commentModel;
@property (strong, nonatomic) FCOUserModel *userModel;

@end
