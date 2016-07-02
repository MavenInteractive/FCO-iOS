//
//  FCOCommentViewController.m
//  fco
//
//  Created by Kryptonite on 7/20/15.
//  Copyright (c) 2015 Kryptonite. All rights reserved.
//

#import "FCOCommentViewController.h"
#import "FCOCommentViewCell.h"
#import "FCOHeaderViewComment.h"
#import "FCOFooterViewComment.h"
#import <IQKeyboardManager/IQKeyboardManager.h>
#import <IQKeyboardManager/IQKeyboardReturnKeyHandler.h>
#import <IQUIView+IQKeyboardToolbar.h>
#import <AFNetworking/UIImageView+AFNetworking.h>
#import "FCOHTTPClient.h"
#import "FCOCommentModel.h"
#import "FCOSessionModel.h"
#import <SCLAlertView-Objective-C/SCLAlertView.h>

@interface FCOCommentViewController () <FCOHeaderViewCommentDelegate, FCOFooterViewCommentDelegate, UIScrollViewDelegate, UITextFieldDelegate>

@property (strong, nonatomic) FCOHeaderViewComment *headerView;
@property (strong, nonatomic) FCOFooterViewComment *footerView;
@property (strong, nonatomic) NSMutableArray *comments;

@property (strong, nonatomic) NSString *firstName;

@property (strong, nonatomic) NSString *timex;
@property BOOL isClickTextField;
@property BOOL isScrollingStart;

@end

@implementation FCOCommentViewController
{
    IQKeyboardReturnKeyHandler *returnKeyHandler;
}

- (NSMutableArray *)comments {
    if (!_comments) {
        _comments = [[NSMutableArray alloc]init];
    }
    return _comments;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

   
    
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardDidShowNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
    returnKeyHandler = nil;
}


- (void)keyboardWillShow:(NSNotification*)aNotification {
    self.tableView.scrollEnabled = NO;
    _isClickTextField = YES;
   // self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.tableView.bounds.size.width, 0.01f)];
    
    NSLog(@"keyboard is shown!");

}

- (void)keyboardWillHide:(NSNotification*)aNotification {
    self.tableView.scrollEnabled = YES;
    _isClickTextField = NO;
    [self.tableView scrollRectToVisible:CGRectMake(0, self.tableView.contentSize.height - self.tableView.bounds.size.height, self.tableView.bounds.size.width, self.tableView.bounds.size.height) animated:YES];
    [self.tableView reloadData];
     NSLog(@"keyboard is not shown!");
    NSLog(@"return comment counts :%lu", (unsigned long)[self.comments count]);
    
    returnKeyHandler = [[IQKeyboardReturnKeyHandler alloc] initWithViewController:self];
    [_footerView.commentTextField addRightButtonOnKeyboardWithText:@"Send" target:self action:@selector(doneAction:) shouldShowPlaceholder:NO];

}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    
    
    UINib *nib = [UINib nibWithNibName:@"FCOCommentViewCell" bundle:nil];
    [[self tableView] registerNib:nib forCellReuseIdentifier:@"FCOCommentViewCell"];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 60;
    [[IQKeyboardManager sharedManager] setEnable:YES];
    [[IQKeyboardManager sharedManager] setKeyboardDistanceFromTextField:0];
    //[[IQKeyboardManager sharedManager] disableToolbarInViewControllerClass:[FCOCommentViewController class]];
    [[IQKeyboardManager sharedManager] setShouldShowTextFieldPlaceholder:NO];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
    
    ////////////////////////////////
    
    
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
    NSLog(@"calloutmodel test1 %@", self.calloutModel._id);
    [self getComment];
    [self.comments removeAllObjects];
    
    returnKeyHandler = [[IQKeyboardReturnKeyHandler alloc] initWithViewController:self];
    [_footerView.commentTextField addRightButtonOnKeyboardWithText:@"Send" target:self action:@selector(doneAction:) shouldShowPlaceholder:NO];

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.tableView scrollRectToVisible:CGRectMake(0, self.tableView.contentSize.height - self.tableView.bounds.size.height, self.tableView.bounds.size.width, self.tableView.bounds.size.height) animated:YES];
    //    NSInteger rows = [self.tableView numberOfRowsInSection:0];
    //    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:rows-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];

 
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)doneAction:(UIBarButtonItem *)barButton
{
    //[_footerView.commentTextField resignFirstResponder];
    
    barButton.enabled = NO;
    
    if ([_footerView.commentTextField.text length] == 0) {
        [self promptAlertView:@"Warning!!!" withSub:@"comment must be set before sending" withClose:@"OK"];
        [_footerView.commentTextField resignFirstResponder];
    } else {
        
        FCOSessionModel *session = [FCOSessionModel sharedInstance];
        self.userModel = [session activeUser];
        
        NSDictionary *params = @{@"user_id": self.userModel._id,
                                 @"callout_id": self.calloutModel._id,
                                 @"details": _footerView.commentTextField.text,
                                 @"status": @"A"
                                 };
        FCOHTTPClient *fcoHttpClient = [FCOHTTPClient sharedInstance];
        [fcoHttpClient POST:@"comments" parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
            _footerView.commentTextField.text = @"";
            [self getComment];
            [self.comments removeAllObjects];
            returnKeyHandler = [[IQKeyboardReturnKeyHandler alloc] initWithViewController:self];
            barButton.enabled = YES;
            [_footerView.commentTextField endEditing:YES];
            [_footerView.commentTextField addRightButtonOnKeyboardWithText:@"Send" target:self action:@selector(doneAction:) shouldShowPlaceholder:NO];
            [self.tableView scrollRectToVisible:CGRectMake(0, self.tableView.contentSize.height - self.tableView.bounds.size.height, self.tableView.bounds.size.width, self.tableView.bounds.size.height) animated:YES];
            [self.delegate didUpdateCallout];
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            NSLog(@"add comment error: %@", error);
        }];
    }
    NSLog(@"active user %@", self.userModel._id);
    NSLog(@"callout id %@", self.calloutModel._id);
}

- (void)getComment {
    
    NSString *urlAction =[NSString stringWithFormat:@"callouts/%@", self.calloutModel._id];
    NSLog(@"url action %@", urlAction);
    FCOHTTPClient *fcoHttpClient = [FCOHTTPClient sharedInstance];
    [fcoHttpClient GET:urlAction parameters:@"" success:^(NSURLSessionDataTask *task, id responseObject) {
        NSLog(@"test comment %@", responseObject[@"category"][@"description"]);
        NSMutableArray *comments = [responseObject objectForKey:@"comment"];
        for (NSDictionary *comment in comments) {
            self.commentModel = [[FCOCommentModel alloc] initWithDictionary:comment];
            [self.comments addObject:self.commentModel];
            NSLog(@"comment: %@", self.commentModel.details);
            NSLog(@"updated at: %@", self.commentModel.updated_at);
        }
        [self.tableView reloadData];
        NSLog(@"comment count: %lu", (unsigned long)self.comments.count);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSInteger statusError = error.code;
        if (statusError == -1011) {
            [self promptAlertView:@"Error!!!" withSub:@"Token Expired. Please re-log" withClose:@"Done"];
            NSLog(@"comment error test: %@", error);
        }

    }];
    
}

-(void)updateCellLabel:(UILabel *)label fromComment:(FCOCommentModel *)comment{
    UIColor *darkGray = [UIColor darkGrayColor];
    UIFont *helveticaBold = [UIFont fontWithName:@"HelveticaNeue-Bold" size:13];
    NSMutableAttributedString * attrString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@ ",comment.user_firstName,comment.user_lastName] attributes:@{NSForegroundColorAttributeName:darkGray,NSFontAttributeName:helveticaBold}];
    [attrString appendAttributedString:[[NSAttributedString alloc] initWithString:comment.details]];
    label.attributedText = attrString;
}

# pragma mark - UITableView Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSLog(@"count %lu", (unsigned long)self.comments.count);
    return [self.comments count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"FCOCommentViewCell";
    FCOCommentViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    

    if (!cell) {
        cell = [[FCOCommentViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    if (self.comments != nil && [self.comments count]) {
        
        
        returnKeyHandler = [[IQKeyboardReturnKeyHandler alloc] initWithViewController:self];
        [_footerView.commentTextField addRightButtonOnKeyboardWithText:@"Send" target:self action:@selector(doneAction:) shouldShowPlaceholder:NO];
        
        FCOCommentModel *commentModel = [self.comments objectAtIndex:indexPath.row];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateStyle:NSDateFormatterMediumStyle];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSDate *time = [formatter dateFromString: commentModel.updated_at];
        NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
        [timeFormatter setDateFormat:@"hh:mm a"];
        _timex = [timeFormatter stringFromDate:time];
        NSLog(@"updated string: %@", _timex);
        cell.timeCreatedLabel.text = _timex;
        
        if (commentModel.user_firstName.length && commentModel.user_lastName.length && commentModel.user_photo) {
            
            [self updateCellLabel:cell.commentLabel fromComment:commentModel];
            [self getPhoto:cell withModel:commentModel];
            
        } else {
            NSString *urlAction = [NSString stringWithFormat:@"comments/%@", commentModel._id];
            NSLog(@"url action comment: %@", urlAction);
            FCOHTTPClient *fcoHttpClient = [FCOHTTPClient sharedInstance];
            [fcoHttpClient GET:urlAction parameters:@"" success:^(NSURLSessionDataTask *task, id responseObject) {
                //self.commentModel = [[FCOCommentModel alloc]initWithDictionary:responseObject];
                NSLog(@"first name: %@", self.commentModel.user_firstName);
                NSLog(@"photo: %@", self.commentModel.user_photo);
                
                [commentModel updateWithDictionary:responseObject];
                // [self getPhoto:cell];
                
                NSLog(@"comment model %@", responseObject);
                if ([commentModel.user_firstName containsString:@"null"] && [commentModel.user_lastName containsString:@"null"]) {
                    commentModel.user_firstName = @"";
                    commentModel.user_lastName = @"";
                } else {
                    
                    FCOCommentViewCell *cell = (FCOCommentViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
               
                    if (cell){
                        [self.tableView beginUpdates];
                        
                        [self getPhoto:cell withModel:commentModel];
                        
                        [self updateCellLabel:cell.commentLabel fromComment:commentModel];
                       // [self.tableView scrollRectToVisible:CGRectMake(0, self.tableView.contentSize.height - self.tableView.bounds.size.height, self.tableView.bounds.size.width, self.tableView.bounds.size.height) animated:YES];
                        

                        returnKeyHandler = [[IQKeyboardReturnKeyHandler alloc] initWithViewController:self];
                        [_footerView.commentTextField addRightButtonOnKeyboardWithText:@"Send" target:self action:@selector(doneAction:) shouldShowPlaceholder:NO];
                          [self.tableView endUpdates];
                    }
                   
                }
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                NSLog(@"user model error %@", error);
            }];
        }
            _isClickTextField = YES;
        NSLog(@"test test %@", self.commentModel.details);
    }
    return cell;
}

# pragma mark - Private Methods

- (void)getPhoto:(FCOCommentViewCell *)cell withModel:(FCOCommentModel *)commentModel {
    NSString *urlID = [NSString stringWithFormat:@"http://api.fightcallout.com/api/v1.0/uploads/%@", commentModel.user_photo];
    NSLog(@"urlID %@", urlID);
    NSURL *logoImageUrl = [NSURL URLWithString:urlID];
    [cell.userImageView setImageWithURLRequest:[NSURLRequest requestWithURL:logoImageUrl] placeholderImage:[UIImage imageNamed:@"callout_thumbnail"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        cell.userImageView.image = image;
        NSLog(@"%@", cell.userImageView.image);
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        NSLog(@"error: %@", error);
    }];
}


- (void)getUserInfo {
    NSString *urlAction = [NSString stringWithFormat:@"users/%@/edit", self.commentModel.user_id];
    FCOHTTPClient *fcoHttpClient = [FCOHTTPClient sharedInstance];
    [fcoHttpClient GET:urlAction parameters:@"" success:^(NSURLSessionDataTask *task, id responseObject) {
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
    }];
    
}

- (void)promptAlertView:(NSString *)title withSub:(NSString *)subtitle withClose:(NSString *)close {
    
    SCLAlertView *alert = [[SCLAlertView alloc] init];
    UIColor *color = [UIColor colorWithRed:103.0/255.0 green:10.0/255.0 blue:5.0/255.0 alpha:1.0];
    
    [alert showCustom:self image:[UIImage imageNamed:@"icon_punch"] color:color title:title     subTitle:subtitle closeButtonTitle:close duration:0.0f];
    [alert setTitleFontFamily:@"FederalEscort" withSize:24];
    [alert setBodyTextFontFamily:@"HelveticaNeue" withSize:13];
    alert.backgroundViewColor = [UIColor whiteColor];
    alert.backgroundType = Blur;
}

# pragma mark  - UITextFieldDelegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
//    if (_footerView.commentTextField == textField) {
//        [self getComment];
//        [self.comments removeAllObjects];
//        NSLog(@"return comment counts :%lu", (unsigned long)[self.comments count]);
//    }
    [_footerView.commentTextField resignFirstResponder];
    NSLog(@"textfiel return");
    return YES;
}

# pragma mark - UITableView Delegate


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    // Remove seperator inset
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    // Prevent the cell from inheriting the Table View's margin settings
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    // Explictly set cell's layout margins
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {

    NSArray *nibContents = [[NSBundle mainBundle] loadNibNamed:@"FCOFooterViewComment" owner:nil options:nil];
    _footerView = [nibContents firstObject];
    _footerView.commentTextField.delegate = self;
    
    
    returnKeyHandler = [[IQKeyboardReturnKeyHandler alloc] initWithViewController:self];
    [_footerView.commentTextField addRightButtonOnKeyboardWithText:@"Send" target:self action:@selector(doneAction:) shouldShowPlaceholder:NO];
    
    NSLog(@"test footer");
    FCOSessionModel *session = [FCOSessionModel sharedInstance];
    FCOUserModel *userModel = [session activeUser];
    
    NSString *urlID = [NSString stringWithFormat:@"http://api.fightcallout.com/api/v1.0/uploads/%@", userModel.photo];
    NSURL *logoImageUrl = [NSURL URLWithString:urlID];
    __weak FCOCommentViewController *selfRef = self;
    [_footerView.userImageView setImageWithURLRequest:[NSURLRequest requestWithURL:logoImageUrl] placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        selfRef.footerView.userImageView.image = image;
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        NSLog(@"error: %@", error);
    }];
    //_footerView.userImageView.image = [UIImage imageNamed:@"callout_king"];
    _footerView.delegate = self;
    return _footerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 50;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    if (_comments.count <= 7 || _comments.count == 0) {
        NSArray *nibContents = [[NSBundle mainBundle] loadNibNamed:nil owner:nil options:nil];
        _headerView = [nibContents firstObject];
    } else if (_comments.count >= 8) {
        NSInteger count = _comments.count - 8;
        NSArray *nibContents = [[NSBundle mainBundle] loadNibNamed:@"FCOHeaderViewComment" owner:nil options:nil];
        _headerView = [nibContents firstObject];
        
//        if (count == 0) {
//            [_headerView.button setTitle:[NSString stringWithFormat:@" View earlier comments"] forState:UIControlStateNormal];
//        } else {
//          [_headerView.button setTitle:[NSString stringWithFormat:@" View %lu earlier comments", (unsigned long)count] forState:UIControlStateNormal];
//        }
//        _headerView.delegate = self;
    }
    return _headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    if (_comments.count <= 7 || _comments.count == 0) {
        return 0;
    }
//        else if (_comments.count >= 8 && _isClickTextField == NO) {
//            //_isClickTextField = YES;
//        NSLog(@"table height tsehe");
//        return 35;
//    }
    return 0;
}

#pragma mark - UIScrollView Delegate

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate)
    {
        if (_isScrollingStart)
        {
            _isScrollingStart=NO;
            [self scrollingStopped];
        }
    }
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    if (_isScrollingStart)
    {
        _isScrollingStart=NO;
        [self scrollingStopped];
    }
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    _isScrollingStart=YES;
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    _isScrollingStart=YES;
}
-(void)scrollingStopped {
    NSLog(@"Scrolling stopped");
}


# pragma mark - FCOHeaderViewComment Delegate

-(void)buttonPressed:(FCOHeaderViewComment *)header btnPressed:(UIButton *)btn {

    //[_headerView.button setHidden:YES];
  //  [self.view endEditing:YES];
     [self.tableView scrollRectToVisible:CGRectMake(0, 0, self.tableView.bounds.size.width, self.tableView.bounds.size.height) animated:YES];
//    [self getComment];
//    [self.comments removeAllObjects];
    //[self.tableView reloadData];
    NSLog(@"it works!");

}

# pragma mark - FCOFooterViewComment Delegate

- (void)smileyButtonPressed:(FCOFooterViewComment *)footer button:(UIButton *)btn {
    NSLog(@"footer!!");
    //[_footerView.commentTextField becomeFirstResponder];
    
}



/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
