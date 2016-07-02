//
//  FCOLoginContainerView.h
//  fco
//
//  Created by delmarz on 6/14/15.
//  Copyright (c) 2015 Kryptonite. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FCOLoginContainerViewDelegate <NSObject>

- (void)presentViewController;

@end
@interface FCOLoginContainerView : UIView
@property (weak, nonatomic) id <FCOLoginContainerViewDelegate> delegate;
- (IBAction)forgotButtonPressed:(UIButton *)sender;

@end
