//
//  FCOCustomTimePickerViewController.h
//  fco
//
//  Created by Kryptonite on 7/16/15.
//  Copyright (c) 2015 Kryptonite. All rights reserved.
//

#import "TDSemiModalViewController.h"
#import <TDSemiModal/TDSemiModal.h>

@protocol FCOCustomTimePickerViewControllerDelegate;

@interface FCOCustomTimePickerViewController : TDSemiModalViewController

@property (weak) id<FCOCustomTimePickerViewControllerDelegate> delegate;
@property (weak) IBOutlet UIDatePicker* timePicker;
@property (weak) IBOutlet UIToolbar *toolbar;

-(IBAction)saveDateEdit:(id)sender;

-(IBAction)cancelDateEdit:(id)sender;

@end

@protocol FCOCustomTimePickerViewControllerDelegate <NSObject>

- (void)timePickerSetTime:(FCOCustomTimePickerViewController *)viewController;
- (void)timePickerCancel:(FCOCustomTimePickerViewController *)viewController;


@end
