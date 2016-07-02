//
//  FCOCallIOutViewController.h
//  fco
//
//  Created by Kryptonite on 6/9/15.
//  Copyright (c) 2015 Kryptonite. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "DownPicker.h"
#import <TDSemiModal/TDDatePickerController.h>
#import "FCOCustomTimePickerViewController.h"
#import "FCOCustomDatePickerViewController.h"


@interface FCOCallIOutViewController : UIViewController <UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UITextField *matchTypeTextField;
@property (strong, nonatomic) IBOutlet UITextField *sportsTypeTextField;
@property (strong, nonatomic) DownPicker *matchTypeDownPicker;
@property (strong, nonatomic) DownPicker *sportsTypeDownPicker;


@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;

@property (strong, nonatomic) IBOutlet UITextField *venueTextField;
@property (strong, nonatomic) IBOutlet UITextField *dateTextField;
@property (strong, nonatomic) IBOutlet UITextField *timeTextField;
@property (strong, nonatomic) IBOutlet UITextField *broadcastingURLTextField;
@property (strong, nonatomic) IBOutlet UITextField *ticketingURLTextField;





// Fields

@property (strong, nonatomic) IBOutlet UITextField *fighterATextField;
@property (strong, nonatomic) IBOutlet UITextField *fighterBTextField;
@property (strong, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (strong, nonatomic) IBOutlet UILabel *placeholderLabel;
@property (strong, nonatomic) IBOutlet UIImageView *userImageView;

@property (strong, nonatomic) IBOutlet UIButton *takeUploadOfImageButton;
@property (strong, nonatomic) IBOutlet UIButton *recordOrUploadVideoButton;

@property (strong, nonatomic) IBOutlet UIButton *cancelButton;
@property (strong, nonatomic) IBOutlet UIButton *saveButton;
- (IBAction)cancelButtonPressed:(UIButton *)sender;
- (IBAction)saveButtonPressed:(UIButton *)sender;


- (IBAction)takeUploadOfImageButtonPressed:(UIButton *)sender;
- (IBAction)recordOrUploadVideoButtonPressed:(UIButton *)sender;


@property (strong, nonatomic) IBOutlet UIProgressView *progressView;




@end
