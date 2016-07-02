//
//  FCOCommentViewCell.h
//  fco
//
//  Created by Kryptonite on 7/24/15.
//  Copyright (c) 2015 Kryptonite. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NZLabel.h"

@interface FCOCommentViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *userImageView;
@property (strong, nonatomic) IBOutlet NZLabel *commentLabel;
@property (strong, nonatomic) IBOutlet UILabel *timeCreatedLabel;
@property (strong, nonatomic) IBOutlet UIImageView *dropDownImage;


@end
