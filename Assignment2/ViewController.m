//
//  ViewController.m
//  Assignment2
//
//  Created by Igor Pchelko on 20/02/16.
//  Copyright © 2016 Igor Pchelko. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import "ViewController.h"
#import "MapView.h"
#import "MapModel.h"

@interface ViewController () <UIScrollViewDelegate, CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UILabel *countryName;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (copy, nonatomic) CLLocation *lastLocation;
@property (copy, nonatomic) NSString *lastCountryName;

@property (strong, nonatomic) MapView *mapView;
@property (strong, nonatomic) UIImageView *locationMarkView;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters; // 100 m
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
    {
        [self.locationManager requestAlwaysAuthorization];
    }
    
    [self.locationManager startUpdatingLocation];

    // Setup map model
    MapModel *mapModel = [MapModel sharedInstance];
    [mapModel buildProjectionWithScale:12];
    CGSize mapSize = [mapModel mapSize];
    
    // Init content view
    self.mapView = [[MapView alloc] initWithFrame:CGRectMake(0, 0, mapSize.width, mapSize.height)];
    self.mapView.backgroundColor = [UIColor whiteColor];
    [self.scrollView addSubview:self.mapView];
    
    // Setup location mark
    self.locationMarkView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"redCircle"]];
    [self.locationMarkView setFrame:CGRectMake(0, 0, 40, 40)];
    [self.mapView addSubview:self.locationMarkView];
//    self.locationMarkView.hidden = YES;
    
    // Setup content size
    self.scrollView.contentSize = self.mapView.frame.size;
    
    // Gestures
    UITapGestureRecognizer *doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewDoubleTapped:)];
    doubleTapRecognizer.numberOfTapsRequired = 2;
    doubleTapRecognizer.numberOfTouchesRequired = 1;
    [self.scrollView addGestureRecognizer:doubleTapRecognizer];
    
    UITapGestureRecognizer *twoFingerTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewTwoFingerTapped:)];
    twoFingerTapRecognizer.numberOfTapsRequired = 1;
    twoFingerTapRecognizer.numberOfTouchesRequired = 2;
    [self.scrollView addGestureRecognizer:twoFingerTapRecognizer];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    CGRect scrollViewFrame = self.scrollView.frame;
    CGFloat scaleWidth = scrollViewFrame.size.width * 0.5 / self.scrollView.contentSize.width;
    CGFloat scaleHeight = scrollViewFrame.size.height * 0.5 / self.scrollView.contentSize.height;
    CGFloat minScale = MIN(scaleWidth, scaleHeight);
    self.scrollView.minimumZoomScale = minScale;
    
    self.scrollView.maximumZoomScale = 2.0f;
    self.scrollView.zoomScale = 1; //minScale;
    
    [self centerScrollViewContents];
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:@"Error"
                                 message:@"Failed to Get Your Location"
                                 preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* okAction = [UIAlertAction
                               actionWithTitle:@"OK"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action)
                               {
                                   
                               }];
    [alert addAction:okAction]; // add action to uialertcontroller
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    bool isNeedUpdate = NO;
    
    if (self.lastLocation == nil)
    {
        self.lastLocation = newLocation;
        isNeedUpdate = YES;
    }
    else
    {
        const float kSignificantMoveDistance = 100; // distance in meters
        if ([self.lastLocation distanceFromLocation:newLocation] > kSignificantMoveDistance)
        {
            self.lastLocation = newLocation;
            isNeedUpdate = YES;
        }
    }
    
    MapModel *mapModel = [MapModel sharedInstance];
    CGPoint currentLocation = CGPointMake(newLocation.coordinate.longitude, newLocation.coordinate.latitude);
    
    if (isNeedUpdate)
    {
        if (self.lastCountryName == nil || [self.lastCountryName isEqualToString:@"Unknown"])
        {
            self.lastCountryName = [mapModel countryNameFromGeo:currentLocation];
        }
        else
        {
            if (![mapModel checkIfCountryName:self.lastCountryName hasGeo:currentLocation])
            {
                self.lastCountryName = [mapModel countryNameFromGeo:currentLocation];
            }
        }
        
        self.countryName.text = [NSString stringWithFormat:@"Country name: %@", self.lastCountryName];
    }
    
    CGPoint pos = [mapModel projectionWithGeo:currentLocation];
    self.locationMarkView.center = pos;
}

- (void)centerScrollViewContents
{
    CGSize boundsSize = self.scrollView.bounds.size;
    CGRect contentsFrame = self.mapView.frame;
    
    if (contentsFrame.size.width < boundsSize.width)
    {
        contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0f;
    }
    else
    {
        contentsFrame.origin.x = 0.0f;
    }
    
    if (contentsFrame.size.height < boundsSize.height)
    {
        contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0f;
    }
    else
    {
        contentsFrame.origin.y = 0.0f;
    }
    
    self.mapView.frame = contentsFrame;
}

- (void)scrollViewDoubleTapped:(UITapGestureRecognizer*)recognizer
{
    CGPoint pointInView = [recognizer locationInView:self.mapView];
    
    CGFloat newZoomScale = self.scrollView.zoomScale * 1.5f;
    newZoomScale = MIN(newZoomScale, self.scrollView.maximumZoomScale);
    
    CGSize scrollViewSize = self.scrollView.bounds.size;
    
    CGFloat w = scrollViewSize.width / newZoomScale;
    CGFloat h = scrollViewSize.height / newZoomScale;
    CGFloat x = pointInView.x - (w / 2.0f);
    CGFloat y = pointInView.y - (h / 2.0f);
    
    CGRect rectToZoomTo = CGRectMake(x, y, w, h);
    
    [self.scrollView zoomToRect:rectToZoomTo animated:YES];
}

- (void)scrollViewTwoFingerTapped:(UITapGestureRecognizer*)recognizer
{
    // Zoom out slightly, capping at the minimum zoom scale specified by the scroll view
    CGFloat newZoomScale = self.scrollView.zoomScale / 1.5f;
    newZoomScale = MAX(newZoomScale, self.scrollView.minimumZoomScale);
    [self.scrollView setZoomScale:newZoomScale animated:YES];
}

- (UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    // Return the view that you want to zoom
    return self.mapView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    CGFloat scale = 1.0 / self.scrollView.zoomScale;
    self.locationMarkView.transform = CGAffineTransformScale(CGAffineTransformIdentity, scale, scale);
    
    // The scroll view has zoomed, so you need to re-center the contents
    [self centerScrollViewContents];
}

@end
