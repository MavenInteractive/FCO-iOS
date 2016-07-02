//
//  JGAnimationView.h
//  JGAnimationView
//
//  Created by Jesiree Anne Geverola on 9/3/14.
//  Source: http://fuzionpro.com/2014/04/02/ios-custom-activity-indicator/
//

#import <UIKit/UIKit.h>

@interface JGAnimationView : UIControl {
  
  UIImageView *imageView; // For displaying the images in the view
  BOOL isAnimating; // To check whether the image is animating or not
  int status; // For setting the status of the imageView
  
}

@property (readwrite, nonatomic) CGFloat speed;
@property (readwrite, nonatomic) CGFloat duration;
@property (nonatomic, strong) NSArray *images; // To hold the array of images
- (void)startAnimating;
- (void)stopAnimating;
- (BOOL)isAnimating;
- (void)doInit;


@end
