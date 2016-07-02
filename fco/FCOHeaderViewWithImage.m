//
//  FCOHeaderViewWithImage.m
//  fco
//
//  Created by Kryptonite on 6/24/15.
//  Copyright (c) 2015 Kryptonite. All rights reserved.
//

#import "FCOHeaderViewWithImage.h"
#import "FCORoleModel.h"
#import "FCOHTTPClient.h"
#import "FCOSessionModel.h"
#import <AFNetworking/UIImageView+AFNetworking.h>


@implementation FCOHeaderViewWithImage

+ (instancetype)instantiateFromNib {
    NSArray *views = [[NSBundle mainBundle] loadNibNamed:[NSString stringWithFormat:@"%@", [self class]] owner:nil options:nil];
    return [views firstObject];
}

- (void)setUserDetails:(FCOUserModel *)user {
    FCOSessionModel *session = [FCOSessionModel sharedInstance];
    FCOUserModel *userModel = [session activeUser];
    NSLog(@"user model %@", userModel);
    
    NSString *urlID = [NSString stringWithFormat:@"http://api.fightcallout.com/api/v1.0/uploads/%@", userModel.photo];
    
    NSURL *logoImageUrl = [NSURL URLWithString:urlID];
    __weak FCOHeaderViewWithImage *selfRef = self;
    [self.userImageView setImageWithURLRequest:[NSURLRequest requestWithURL:logoImageUrl] placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        selfRef.userImageView.image = image;
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        NSLog(@"error: %@", error);
    }];
    
    self.firstNameLabel.text = [user.first_name uppercaseString];
    self.lastNameLabel.text = [user.last_name uppercaseString];
    self.userNameLabel.text = [user.username uppercaseString];

    if (user.gender == (id)[NSNull null]) {
        self.gender.text = [@"Male" uppercaseString];
    } else {
        self.gender.text = [user.gender uppercaseString];
    }
    
    self.roleLabel.text = [userModel.role_desc uppercaseString];
    self.sportsTypeLabel.text = [userModel.category_desc uppercaseString];
    self.gender.text = [userModel.country_desc uppercaseString];
}

@end
