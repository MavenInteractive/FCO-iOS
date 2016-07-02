//
//  FCOCallOutTableViewCell.h
//  fco
//
//  Created by Kryptonite on 6/9/15.
//  Copyright (c) 2015 Kryptonite. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NZLabel.h"

//@class FCOCallOutTableViewCell;
//@protocol FCOCallOutTableViewCell <NSObject>
//
//@optional
//- (void)customCell:(FCOCallOutTableViewCell *)cell btnPressed:(UIButton *)btn;
//@end

@interface FCOCallOutTableViewCell : UITableViewCell
//@property (nonatomic, assign) id <FCOCallOutTableViewCell> delegate;
@property (strong, nonatomic) IBOutlet NZLabel *calloutLabel;
@property (weak, nonatomic) IBOutlet UIImageView *userImageView;

@end



