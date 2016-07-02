//
//  FCOCustomDatePickerViewController.h
//  fco
//
//  Created by Kryptonite on 8/14/15.
//  Copyright (c) 2015 Kryptonite. All rights reserved.
//

#import "TDSemiModalViewController.h"
#import <TDSemiModal/TDSemiModal.h>

@protocol FCOCustomDatePickerViewControllerDelegate;

@interface FCOCustomDatePickerViewController : TDSemiModalViewController

@property (weak) id <FCOCustomDatePickerViewControllerDelegate> delegate;
@property (weak) IBOutlet UIDatePicker* datePicker;
@property (weak) IBOutlet UIToolbar *toolbar;

-(IBAction)saveDateEdit:(id)sender;
-(IBAction)cancelDateEdit:(id)sender;
@end

@protocol FCOCustomDatePickerViewControllerDelegate <NSObject>

- (void)datePickerSetDate:(FCOCustomDatePickerViewController *)viewController;
- (void)datePickerCancel:(FCOCustomDatePickerViewController *)viewController;

@end
