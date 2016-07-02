//
//  FCOEditCalloutViewController.h
//  fco
//
//  Created by Kryptonite on 7/14/15.
//  Copyright (c) 2015 Kryptonite. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FCOCalloutModel.h"
#import "FCOUserModel.h"

@protocol FCOEditCalloutViewControllerDelegate <NSObject>

- (void)didUpdate;
- (void)cancel;

@end

@interface FCOEditCalloutViewController : UIViewController <UITextFieldDelegate>

@property (weak, nonatomic) id <FCOEditCalloutViewControllerDelegate> delegate;
@property (strong, nonatomic) FCOCalloutModel *calloutModel;
@property (strong, nonatomic) FCOUserModel *userModel;

@property (strong, nonatomic) IBOutlet UIView *childView;
@property (strong, nonatomic) IBOutlet UILabel *titleCategoryLabel;
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UIImageView *calloutImageView;
@property (strong, nonatomic) IBOutlet UILabel *calloutLabel;
@property (strong, nonatomic) IBOutlet UITextView *textViewLabel;
@property (strong, nonatomic) IBOutlet UITextField *dateTextField;
@property (strong, nonatomic) IBOutlet UITextField *timeTextField;
@property (strong, nonatomic) IBOutlet UITextField *venueTextField;
@property (strong, nonatomic) IBOutlet UILabel *voteCountLabel;
@property (strong, nonatomic) IBOutlet UIButton *uploadImageButton;
@property (strong, nonatomic) IBOutlet UIButton *uploadVideoButton;
//@property (strong, nonatomic) IBOutlet UIButton *cancelButton;
//@property (strong, nonatomic) IBOutlet UIButton *updateButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *updateBarButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *cancelBarButton;

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
//@property (strong, nonatomic) IBOutlet UILabel *editCalloutLabel;
@property (strong, nonatomic) IBOutlet UITextField *broadcastTextField;
@property (strong, nonatomic) IBOutlet UITextField *ticketTextField;
@property (strong, nonatomic) IBOutlet UILabel *videoLabel;


//- (IBAction)cancelButtonPressed:(UIButton *)sender;
//- (IBAction)updateButtonPressed:(UIButton *)sender;
- (IBAction)cancelBarButtonPressed:(UIBarButtonItem *)sender;   
- (IBAction)updateBarButtonPressed:(UIBarButtonItem *)sender;
- (IBAction)uploadImageButtonPressed:(UIButton *)sender;
- (IBAction)uploadVideosButtonPressed:(UIButton *)sender;

@property (strong, nonatomic) IBOutlet UIProgressView *progressView;

@end
