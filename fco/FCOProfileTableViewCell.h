//
//  FCOProfileTableViewCell.h
//  fco
//
//  Created by Kryptonite on 6/24/15.
//  Copyright (c) 2015 Kryptonite. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NZLabel.h"

//@class FCOProfileTableViewCell;
//@protocol FCOProfileTableViewCellDelegate <NSObject>
//
//- (void)customCell:(FCOProfileTableViewCell *)cell btnPressed:(UIButton *)btn;
//
//@end

@interface FCOProfileTableViewCell : UITableViewCell
//@property (weak, nonatomic) id <FCOProfileTableViewCellDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIImageView *userImageView;
@property (strong, nonatomic) IBOutlet NZLabel *userCalloutLabel;



@end
