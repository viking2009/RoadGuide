//
//  RGSplashScreenViewController.m
//  RoadGuide
//
//  Created by Mykola Vyshynskyi on 8/13/14.
//  Copyright (c) 2014 Mykola Vyshynskyi. All rights reserved.
//

#import "RGSplashScreenViewController.h"
#import "RGConfiguration.h"
#import "UIImageView+AFNetworking.h"
#import "RGAppDelegate.h"

@interface RGSplashScreenViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

- (void)showFullscreenBannerIfNeeded;
- (void)showRouteList;
- (void)showRouteListDelayed;

@end

@implementation RGSplashScreenViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    RGConfiguration *configuration = [RGConfiguration sharedConfiguration];
    
    self.imageView.image = [UIImage imageNamed:@"Default"];
    self.activityIndicator.color = configuration.splashScreenActivityIndicatorColor;
    
    __weak __typeof(self)weakSelf = self;
    // MARK: update configuration
    [self.activityIndicator startAnimating];
    [configuration updateWithCompletion:^(NSDictionary *defaults, NSError *error) {
        if (error) {
            DLog(@"ERROR: %@", [error localizedDescription]);
        } else {
            DLog(@"defaults: %@", defaults);
        }
        
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        
        if (strongSelf) {
            [strongSelf.activityIndicator stopAnimating];
            [strongSelf showFullscreenBannerIfNeeded];
        }
    }];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

#pragma mark - Private

- (void)showFullscreenBannerIfNeeded {
    RGConfiguration *configuration = [RGConfiguration sharedConfiguration];
    NSString *imageURL = configuration.fullscreenBannerImageURL;
    
    if (configuration.fullscreenBannerEnabled && imageURL) {
        __weak __typeof(self)weakSelf = self;

        [self.activityIndicator startAnimating];
        NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:imageURL]];
        [self.imageView setImageWithURLRequest:urlRequest placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            
            if (strongSelf) {
                [strongSelf.activityIndicator stopAnimating];
                
                [UIView transitionWithView:strongSelf.imageView
                                  duration:configuration.fullscreenBannerFadeDuration
                                   options:UIViewAnimationOptionTransitionCrossDissolve
                                animations:^{
                                    strongSelf.imageView.image = image;
                                } completion:^(BOOL finished) {
                                    [strongSelf showRouteListDelayed];
                                }];
             }

        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            
            if (strongSelf) {
                DLog(@"ERROR: %@", [error localizedDescription]);

                [strongSelf.activityIndicator stopAnimating];
                [strongSelf showRouteList];
            }
        }];
    } else {
        [self showRouteList];
    }
}

- (void)showRouteList {
    [self performSegueWithIdentifier:@"showRouteList" sender:self];
}

- (void)showRouteListDelayed {
    RGConfiguration *configuration = [RGConfiguration sharedConfiguration];
    [self performSelector:@selector(showRouteList) withObject:nil afterDelay:configuration.fullscreenBannerShowTime];
}

@end
