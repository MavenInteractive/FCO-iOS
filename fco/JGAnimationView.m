//
//  JGAnimationView.m
//  JGAnimationView
//
//  Created by Jesiree Anne Geverola on 9/3/14.
//
//

#import "JGAnimationView.h"

@implementation JGAnimationView

- (id)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    [self doInit];
  }
  return self;
}

- (void)doInit
{
  self.speed = 0.33;
  self.duration = 2.0;
  imageView = [[UIImageView alloc]initWithFrame:self.bounds];
  _images = [NSArray array];
  [self addSubview:imageView];
  isAnimating = NO;
  [self setHidden:YES];
}

- (void)startAnimating
{
  
  if (isAnimating) {
    return;
  }
  
  isAnimating = YES;
  status = 0;
  
  [self setHidden:NO];
  [imageView setImage:[self.images objectAtIndex:0]];
  
//  [NSTimer scheduledTimerWithTimeInterval:0
//                                   target:self
//                                 selector:@selector(updateAnimation)
//                                 userInfo:nil
//                                  repeats:NO];
  [self updateAnimation];
}

- (void)updateAnimation
{
  [imageView setAnimationImages:self.images];
  [imageView setAnimationDuration:self.duration];
  [imageView startAnimating];
}

- (BOOL)isAnimating
{
  return isAnimating;
}

- (void)stopAnimating
{
	isAnimating = NO;
  
  [imageView stopAnimating];
  [self setHidden:YES];
//	[imageView setAnimationImages:nil];
//  [imageView setImage:nil];
}

- (void)setImages:(NSArray *)images {
  _images = images;
  [imageView setImage:[self.images objectAtIndex:0]];
}

@end