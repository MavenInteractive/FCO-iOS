//
//  FCOHeaderViewWithImage.h
//  fco
//
//  Created by Kryptonite on 6/24/15.
//  Copyright (c) 2015 Kryptonite. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FCOUserModel.h"

@interface FCOHeaderViewWithImage : UIView
@property (weak, nonatomic) IBOutlet UIImageView *userImageView;
@property (strong, nonatomic) IBOutlet UILabel *userNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *firstNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *lastNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *roleLabel;
@property (strong, nonatomic) IBOutlet UILabel *sportsTypeLabel;
@property (strong, nonatomic) IBOutlet UILabel *gender;
@property (strong, nonatomic) FCOUserModel *userModel;

+ (instancetype)instantiateFromNib;
- (void)setUserDetails:(FCOUserModel *)user;


@end
