//
//  RGRouteDetailsViewController.m
//  RoadGuide
//
//  Created by Mykola Vyshynskyi on 8/13/14.
//  Copyright (c) 2014 Mykola Vyshynskyi. All rights reserved.
//

#import "RGRouteDetailsViewController.h"
#import "UIImageView+AFNetworking.h"
#import "RGConfiguration.h"

@interface RGRouteDetailsViewController () <UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundView;
@property (weak, nonatomic) IBOutlet UIImageView *routeView;
@property (weak, nonatomic) IBOutlet UIButton *topHeader;
@property (weak, nonatomic) IBOutlet UIButton *bottomHeader;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (assign, nonatomic) BOOL reverseRoute;

- (void)updateHeaders;
- (void)loadMap;

- (IBAction)goBack:(id)sender;
- (IBAction)showReverseRoute:(id)sender;

@end

@implementation RGRouteDetailsViewController

- (void)dealloc {
    DLog();
    
    self.scrollView.delegate = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
        
    self.backgroundView.image = [UIImage imageNamed:@"routeDetails_background"];
    
    // MARK: resize background view
    CGRect backgroundViewFrame = self.backgroundView.frame;
    backgroundViewFrame.size = self.backgroundView.image.size;
    self.backgroundView.frame = backgroundViewFrame;
    
//    self.scrollView.contentSize = self.backgroundView.image.size;

    RGConfiguration *configuration = [RGConfiguration sharedConfiguration];
    self.activityIndicator.color = configuration.routeDetailsActivityIndicatorColor;
    
    [self updateHeaders];
    [self loadMap];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

#pragma mark - Private

- (void)setReverseRoute:(BOOL)reverseRoute {
    if (_reverseRoute != reverseRoute) {
        _reverseRoute = reverseRoute;
        
        [self updateHeaders];
        [self loadMap];
    }
}

- (void)updateHeaders {
    RGConfiguration *configuration = [RGConfiguration sharedConfiguration];

    UIColor *cityHeaderBackgroundColor = configuration.cityHeaderBackgroundColor;
    NSDictionary *cityHeaderAttributes = configuration.cityHeaderAttributes;
    
    NSString *fromKey = self.reverseRoute ? @"to" : @"from";
    NSString *toKey = self.reverseRoute ? @"from" : @"to";

    NSAttributedString *topHeaderTitle = [[NSAttributedString alloc] initWithString:self.routeInfo[toKey] attributes:cityHeaderAttributes];
    NSAttributedString *bottomHeaderTitle = [[NSAttributedString alloc] initWithString:self.routeInfo[fromKey] attributes:cityHeaderAttributes];
    
    self.topHeader.backgroundColor = cityHeaderBackgroundColor;
    self.bottomHeader.backgroundColor = cityHeaderBackgroundColor;

    [self.topHeader setAttributedTitle:topHeaderTitle forState:UIControlStateNormal];
    [self.bottomHeader setAttributedTitle:bottomHeaderTitle forState:UIControlStateNormal];
}

- (void)loadMap {
    RGConfiguration *configuration = [RGConfiguration sharedConfiguration];

    NSString *imageURL = self.reverseRoute ? self.routeInfo[@"toImageURL"] : self.routeInfo[@"fromImageURL"];
    
    if (imageURL) {
        __weak __typeof(self)weakSelf = self;
        
        [self.activityIndicator startAnimating];
        NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:imageURL]];
        [self.routeView setImageWithURLRequest:urlRequest placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            
            if (strongSelf) {
                [strongSelf.activityIndicator stopAnimating];
                
                [UIView transitionWithView:strongSelf.routeView
                                  duration:configuration.fullscreenBannerFadeDuration
                                   options:UIViewAnimationOptionTransitionCrossDissolve
                                animations:^{
                                    strongSelf.routeView.image = image;
                                } completion:^(BOOL finished) {
                                    // MARK: resize route view
                                    CGRect routeViewFrame = strongSelf.routeView.frame;
                                    routeViewFrame.origin.y = strongSelf.scrollView.scrollIndicatorInsets.top;
                                    routeViewFrame.size = image.size;
                                    strongSelf.routeView.frame = routeViewFrame;
                                    
                                    // MARK: adjust content size
                                    CGSize contentSize = routeViewFrame.size;
                                    contentSize.height += strongSelf.scrollView.scrollIndicatorInsets.top + strongSelf.scrollView.scrollIndicatorInsets.bottom;
                                    strongSelf.scrollView.contentSize = contentSize;
                                    
                                    // Bug #95 End of route displayed
                                    strongSelf.scrollView.contentOffset = CGPointMake(0, strongSelf.scrollView.contentSize.height - strongSelf.scrollView.frame.size.height);
                                }];
            }
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            
            if (strongSelf) {
                DLog(@"ERROR: %@", [error localizedDescription]);
                
                [strongSelf.activityIndicator stopAnimating];
            }
        }];
    }
}

#pragma mark - IBActions

- (IBAction)goBack:(id)sender {
//    [self dismissViewControllerAnimated:YES completion:NULL];
    [self showReverseRoute:sender];
}

- (IBAction)showReverseRoute:(id)sender {
    self.reverseRoute = !self.reverseRoute;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGRect frame = self.backgroundView.frame;
    
    // Avoid scroll
    frame.origin.y = scrollView.contentOffset.y;
    
    // Add parallax
    CGFloat backgroundViewDiff = CGRectGetHeight(self.backgroundView.frame) - CGRectGetHeight(scrollView.frame);
    CGFloat routeViewDiff = CGRectGetHeight(self.routeView.frame) + scrollView.scrollIndicatorInsets.top + scrollView.scrollIndicatorInsets.bottom - CGRectGetHeight(scrollView.frame);
    CGFloat scaleFactor = backgroundViewDiff / routeViewDiff;
    
    NSInteger increment = scrollView.contentOffset.y * scaleFactor;
    frame.origin.y -= MIN(MAX(increment, 0), backgroundViewDiff);
    
    self.backgroundView.frame = frame;
}

@end
