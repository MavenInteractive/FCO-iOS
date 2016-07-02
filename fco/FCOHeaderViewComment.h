//
//  FCOHeaderViewComment.h
//  fco
//
//  Created by Kryptonite on 7/28/15.
//  Copyright (c) 2015 Kryptonite. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FCOHeaderViewComment;

@protocol FCOHeaderViewCommentDelegate <NSObject>

- (void)buttonPressed:(FCOHeaderViewComment *)header btnPressed:(UIButton *)btn;

@end

@interface FCOHeaderViewComment : UIView
@property (assign, nonatomic) id <FCOHeaderViewCommentDelegate> delegate;

@property (strong, nonatomic) IBOutlet UIButton *button;
- (IBAction)buttonPressed:(UIButton *)sender;

@end
