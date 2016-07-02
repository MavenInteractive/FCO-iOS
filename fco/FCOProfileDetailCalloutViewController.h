//
//  FCOProfileDetailCalloutViewController.h
//  fco
//
//  Created by Kryptonite on 7/14/15.
//  Copyright (c) 2015 Kryptonite. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NZLabel.h"
#import "FCOCalloutModel.h"
#import "FCOEditCalloutViewController.h"
#import <KINWebBrowser/KINWebBrowserViewController.h>

@protocol FCOProfileDetailCalloutViewControllerDelegate <NSObject>

- (void)updateCallout;

@end

@interface FCOProfileDetailCalloutViewController : UIViewController <FCOEditCalloutViewControllerDelegate, KINWebBrowserDelegate>
@property (weak, nonatomic) id <FCOProfileDetailCalloutViewControllerDelegate> delegate;
@property (strong, nonatomic) IBOutlet UILabel *titleCategoryLabel;
@property (strong, nonatomic) IBOutlet UIImageView *userImageView;
@property (strong, nonatomic) IBOutlet UIImageView *calloutImageView;
@property (strong, nonatomic) IBOutlet NZLabel *userCalloutLabel;
@property (strong, nonatomic) FCOCalloutModel *calloutModel;
@property (strong, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (strong, nonatomic) IBOutlet UITextView *descpTextView;
@property (strong, nonatomic) IBOutlet UILabel *dateLabel;
@property (strong, nonatomic) IBOutlet UILabel *timeLabel;
@property (strong, nonatomic) IBOutlet UILabel *venueLabel;
@property (strong, nonatomic) IBOutlet UILabel *voteLabel;
@property (strong, nonatomic) IBOutlet UILabel *createdAtLabel;
@property (strong, nonatomic) UIDocumentInteractionController *documentController;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIImageView *imageViewTopLine;



@property (strong, nonatomic) IBOutlet UIButton *broadcastButton;
@property (strong, nonatomic) IBOutlet UIButton *ticketButton;

@property (strong, nonatomic) IBOutlet UILabel *playerVideoLabel;


@property (strong, nonatomic) IBOutlet UIButton *voteUpButton;
@property (strong, nonatomic) IBOutlet UIButton *voteDownButton;


- (IBAction)voteUpButtonPressed:(UIButton *)sender;
- (IBAction)voteDownButtonPressed:(UIButton *)sender;
- (IBAction)editBarButtonItemPressed:(UIBarButtonItem *)sender;
- (IBAction)commentButtonPressed:(UIButton *)sender;
- (IBAction)shareButtonPressed:(UIButton *)sender;
- (IBAction)broadcastButtonPressed:(UIButton *)sender;
- (IBAction)ticketButtonPressed:(UIButton *)sender;



@end
