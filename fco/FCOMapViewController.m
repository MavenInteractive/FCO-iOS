//
//  FCOMapViewController.m
//  fco
//
//  Created by Kryptonite on 9/1/15.
//  Copyright (c) 2015 Kryptonite. All rights reserved.
//

#import "FCOMapViewController.h"
#import "FCOAnnotation.h"


@interface FCOMapViewController ()

@end

@implementation FCOMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSLog(@"callout details venue %@", self.calloutModel.details_venue);
    
    NSString *lat = [NSString stringWithFormat:@"%@", self.calloutModel.latitude];
    NSString *lon = [NSString stringWithFormat:@"%@", self.calloutModel.longitude];
    
    float latt = [lat floatValue];
    float lonn = [lon floatValue];
    
    
    MKCoordinateRegion myRegion;
    
    //Center
    CLLocationCoordinate2D center;
    center.latitude = latt; //51.434703;
    center.longitude = lonn; //-0.213428;
    
    //Span
    MKCoordinateSpan span;
    span.latitudeDelta = 0.01f;
    span.longitudeDelta = 0.01f;
    
    myRegion.center = center;
    myRegion.span = span;
    
    //Set our mapview
    [self.myMapView setRegion:myRegion animated:YES];
    
    // Annotation
    CLLocationCoordinate2D wimbLocation;
    wimbLocation.latitude = latt; //51.434703;;
    wimbLocation.longitude = lonn; //-0.213428;
    
    FCOAnnotation *myAnnotation = [[FCOAnnotation alloc] init];
    myAnnotation.coordinate = wimbLocation;
    myAnnotation.title = @"Venue Location...";
    myAnnotation.subtitle = self.calloutModel.details_venue;
        self.myMapView.showsUserLocation = YES;
    [self.myMapView addAnnotation:myAnnotation];
    
    
}


- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
        
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
    }
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cancel:(UIBarButtonItem *)sender {
    [self.delegate mapViewDidCancel];
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
