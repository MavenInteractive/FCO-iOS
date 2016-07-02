//
//  FCOFooterViewComment.h
//  fco
//
//  Created by Kryptonite on 7/28/15.
//  Copyright (c) 2015 Kryptonite. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FCOFooterViewComment;
@protocol FCOFooterViewCommentDelegate <NSObject>

- (void)smileyButtonPressed:(FCOFooterViewComment *)footer button:(UIButton *)btn;

@end

@interface FCOFooterViewComment : UIView
@property (weak, nonatomic) id <FCOFooterViewCommentDelegate> delegate;
@property (strong, nonatomic) IBOutlet UIImageView *userImageView;
@property (strong, nonatomic) IBOutlet UITextField *commentTextField;
@property (strong, nonatomic) IBOutlet UIButton *smileyButton;
- (IBAction)smileyButtonPressed:(UIButton *)sender;


@end
