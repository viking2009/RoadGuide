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
@property (weak, nonatomic) IBOutlet UILabel *topLabel;
@property (weak, nonatomic) IBOutlet UILabel *bottomLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation RGRouteDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.backgroundView.image = [UIImage imageNamed:@"routeDetails_background"];
    self.scrollView.contentSize = self.backgroundView.image.size;

    RGConfiguration *configuration = [RGConfiguration sharedConfiguration];
    self.activityIndicator.color = configuration.routeDetailsActivityIndicatorColor;
    
    UIColor *cityHeaderBackgroundColor = configuration.cityHeaderBackgroundColor;
    NSDictionary *cityHeaderAttributes = configuration.cityHeaderAttributes;
    
    self.topLabel.backgroundColor = cityHeaderBackgroundColor;
    self.topLabel.attributedText = [[NSAttributedString alloc] initWithString:self.routeInfo[@"from"] attributes:cityHeaderAttributes];
    
    self.bottomLabel.backgroundColor = cityHeaderBackgroundColor;
    self.bottomLabel.attributedText = [[NSAttributedString alloc] initWithString:self.routeInfo[@"to"] attributes:cityHeaderAttributes];
    
    NSString *imageURL = self.routeInfo[@"imageURL"];

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
                                    CGRect routeViewFrame = strongSelf.routeView.frame;
                                    routeViewFrame.size = image.size;
                                    strongSelf.routeView.frame = routeViewFrame;
                                    
                                    strongSelf.scrollView.contentSize = routeViewFrame.size;
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

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGRect frame = self.backgroundView.frame;
    // Avoid scroll
    frame.origin.y = scrollView.contentOffset.y;
    // Add parallax
    CGFloat backgroundViewDiff = CGRectGetHeight(self.backgroundView.frame) - CGRectGetHeight(scrollView.frame);
    CGFloat trassaViewDiff = CGRectGetHeight(self.routeView.frame) - CGRectGetHeight(scrollView.frame);
    CGFloat scaleFactor = backgroundViewDiff / trassaViewDiff;
    NSInteger increment = scrollView.contentOffset.y * scaleFactor;
    frame.origin.y -= MIN(MAX(increment, 0), backgroundViewDiff);
    self.backgroundView.frame = frame;
}

@end
