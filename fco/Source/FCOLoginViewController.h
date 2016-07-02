//
//  FCOLoginViewController.h
//  fco
//
//  Created by kryptonite on 6/1/15.
//  Copyright (c) 2015 Kryptonite. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FCOLoginContainerView.h"
#import "FCOAlertViewController.h"

@class FCOLoginViewController;
@protocol FCOLoginViewControllerDelegate <NSObject>

@required
- (void)loginDidCancel;

@end
@interface FCOLoginViewController : UIViewController <FCOLoginContainerViewDelegate, FCOAlertViewControllerDelegate>
@property (weak, nonatomic) id <FCOLoginViewControllerDelegate> delegate;

@end
