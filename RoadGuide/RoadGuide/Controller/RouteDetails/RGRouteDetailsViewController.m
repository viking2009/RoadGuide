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
#import "UIImage+Localized.h"
#import "Flurry.h"
#import "SIAlertView.h"
#import "RGLanguage.h"

@interface RGRouteDetailsViewController () <UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundView;
@property (weak, nonatomic) IBOutlet UIImageView *routeView;
@property (weak, nonatomic) IBOutlet UIView *topHeader;
@property (weak, nonatomic) IBOutlet UIButton *topCityButton;
@property (weak, nonatomic) IBOutlet UIButton *aboutButton;
@property (weak, nonatomic) IBOutlet UIButton *infoButton;
@property (weak, nonatomic) IBOutlet UIView *bottomHeader;
@property (weak, nonatomic) IBOutlet UIButton *bottomCityButton;
@property (weak, nonatomic) IBOutlet UIButton *routeSelectButton;
@property (weak, nonatomic) IBOutlet UIButton *reverseRouteButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (assign, nonatomic) BOOL reverseRoute;

- (void)updateHeaders;
- (void)loadMap;
- (void)showError;

- (IBAction)routeSelectButtonAction:(id)sender;
- (IBAction)reverseRouteButtonAction:(id)sender;
- (IBAction)topCityButtonAction:(id)sender;
- (IBAction)bottomCityButtonAction:(id)sender;

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
    
    RGConfiguration *configuration = [RGConfiguration sharedConfiguration];
    self.activityIndicator.color = configuration.routeDetailsActivityIndicatorColor;
    
    [self.aboutButton setImage:[UIImage localizedImageNamed:@"routeDetails_button_about"] forState:UIControlStateNormal];
    [self.infoButton setImage:[UIImage localizedImageNamed:@"routeDetails_button_info"] forState:UIControlStateNormal];
    [self.routeSelectButton setImage:[UIImage localizedImageNamed:@"routeDetails_button_routeSelect"] forState:UIControlStateNormal];
    [self.reverseRouteButton setImage:[UIImage localizedImageNamed:@"routeDetails_button_reverseRoute"] forState:UIControlStateNormal];

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
    self.topHeader.backgroundColor = cityHeaderBackgroundColor;
    self.bottomHeader.backgroundColor = cityHeaderBackgroundColor;

    NSString *fromKey = self.reverseRoute ? @"to" : @"from";
    NSString *toKey = self.reverseRoute ? @"from" : @"to";
    NSDictionary *cityHeaderAttributes = configuration.cityHeaderAttributes;
    
    NSAttributedString *topCityTitle = [[NSAttributedString alloc] initWithString:self.routeInfo[toKey] attributes:cityHeaderAttributes];
    NSAttributedString *bottomCityTitle = [[NSAttributedString alloc] initWithString:self.routeInfo[fromKey] attributes:cityHeaderAttributes];
    
    [self.topCityButton setAttributedTitle:topCityTitle forState:UIControlStateNormal];
    [self.bottomCityButton setAttributedTitle:bottomCityTitle forState:UIControlStateNormal];
}

- (void)loadMap {
    RGConfiguration *configuration = [RGConfiguration sharedConfiguration];

    NSString *imageURL = self.reverseRoute ? self.routeInfo[@"toImageURL"] : self.routeInfo[@"fromImageURL"];
    
    if (imageURL) {
        __weak __typeof(self)weakSelf = self;
        
        self.routeView.image = nil;

        [self.activityIndicator startAnimating];
        self.reverseRouteButton.enabled = NO;

        NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:imageURL]];
        [self.routeView setImageWithURLRequest:urlRequest placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            
            if (strongSelf) {
                [strongSelf.activityIndicator stopAnimating];
                strongSelf.reverseRouteButton.enabled = YES;

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
                
                [UIView transitionWithView:strongSelf.routeView
                                  duration:configuration.fullscreenBannerFadeDuration
                                   options:UIViewAnimationOptionTransitionCrossDissolve
                                animations:^{
                                    strongSelf.routeView.image = image;
                                } completion:^(BOOL finished) {
                                    NSString *fromKey = strongSelf.reverseRoute ? @"to" : @"from";
                                    NSString *toKey = strongSelf.reverseRoute ? @"from" : @"to";
                                    
                                    NSMutableDictionary *routeInfo = [[NSMutableDictionary alloc] init];
                                    routeInfo[@"from"] = strongSelf.routeInfo[fromKey];
                                    routeInfo[@"to"] = strongSelf.routeInfo[toKey];

                                    [Flurry logEvent:@"RouteShown" withParameters:routeInfo];
                                }];
            }
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            
            if (strongSelf) {
                DLog(@"ERROR: %@", [error localizedDescription]);
                
                [strongSelf.activityIndicator stopAnimating];
                strongSelf.reverseRouteButton.enabled = YES;
                [strongSelf showError];
            }
        }];
    }
}

- (void)showError {
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:nil andMessage:RGLocalizedString(@"Unable to load data")];
    alertView.transitionStyle = SIAlertViewTransitionStyleFade;
    [alertView addButtonWithTitle:@"OK"
                             type:SIAlertViewButtonTypeDefault
                          handler:^(SIAlertView *alertView) {
                              DLog(@"OK Clicked");
                          }];
    [alertView show];
}

#pragma mark - IBActions

- (IBAction)routeSelectButtonAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)reverseRouteButtonAction:(id)sender {
    self.reverseRoute = !self.reverseRoute;
}

- (IBAction)topCityButtonAction:(id)sender {
    [self.scrollView setContentOffset:CGPointZero animated:YES];
}

- (IBAction)bottomCityButtonAction:(id)sender {
    CGPoint contentOffset = CGPointMake(0, self.scrollView.contentSize.height - self.scrollView.frame.size.height);
    [self.scrollView setContentOffset:contentOffset animated:YES];
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
