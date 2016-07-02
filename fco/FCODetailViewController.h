//
//  FCODetailViewController.h
//  fco
//
//  Created by Kryptonite on 6/18/15.
//  Copyright (c) 2015 Kryptonite. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NZLabel.h"
#import "FCOCalloutModel.h"
#import <KINWebBrowser/KINWebBrowserViewController.h>

@interface FCODetailViewController : UIViewController

@property (strong, nonatomic) IBOutlet UILabel *titleCategoryLabel;
@property (strong, nonatomic) IBOutlet UIImageView *userImageView;
@property (strong, nonatomic) IBOutlet NZLabel *userCalloutLabel;
@property (strong, nonatomic) FCOCalloutModel *calloutModel;
@property (strong, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (strong, nonatomic) IBOutlet UITextView *descpTextView;
@property (strong, nonatomic) IBOutlet UILabel *dateLabel;
@property (strong, nonatomic) IBOutlet UILabel *timeLabel;
@property (strong, nonatomic) IBOutlet UILabel *venueLabel;
@property (strong, nonatomic) IBOutlet UILabel *voteLabel;
@property (strong, nonatomic) IBOutlet UILabel *createdAtLabel;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;
@property (strong, nonatomic) IBOutlet UIImageView *calloutImageView;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) UIDocumentInteractionController *documentController;
@property (strong, nonatomic) UIImageView *imageMain;
@property (strong, nonatomic) IBOutlet UIImageView *imageViewTopLine;

@property (strong, nonatomic) IBOutlet UIButton *broadcastButton;
@property (strong, nonatomic) IBOutlet UIButton *ticketButton;

@property (strong, nonatomic)  NSString *catDescp;

@property (strong, nonatomic) IBOutlet UILabel *playVideoLabel;

- (IBAction)broadcastButtonPressed:(UIButton *)sender;
- (IBAction)ticketButtonPressed:(UIButton *)sender;


@property (strong, nonatomic) IBOutlet UIButton *voteUpButton;
@property (strong, nonatomic) IBOutlet UIButton *voteDownButton;


//Handle Video url
@property (strong, nonatomic) NSString *videoURL;

- (IBAction)voteUpButtonPressed:(UIButton *)sender;
- (IBAction)voteDownButtonPressed:(UIButton *)sender;
- (IBAction)commentButtonPressed:(UIButton *)sender;
- (IBAction)shareButtonPressed:(UIButton *)sender;

//Twitter Sharing

@property (strong, nonatomic) NSString *imageString;
@property (strong, nonatomic) NSString *urlString;

@end
