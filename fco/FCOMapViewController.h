//
//  FCOMapViewController.h
//  fco
//
//  Created by Kryptonite on 9/1/15.
//  Copyright (c) 2015 Kryptonite. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "FCOCalloutModel.h"

@protocol FCOMapViewControllerDelegate <NSObject>

- (void)mapViewDidCancel;

@end

@interface FCOMapViewController : UIViewController
@property (weak, nonatomic) id <FCOMapViewControllerDelegate> delegate;
@property (strong, nonatomic) IBOutlet MKMapView *myMapView;
@property (strong, nonatomic) FCOCalloutModel *calloutModel;
- (IBAction)cancel:(UIBarButtonItem *)sender;

@end
