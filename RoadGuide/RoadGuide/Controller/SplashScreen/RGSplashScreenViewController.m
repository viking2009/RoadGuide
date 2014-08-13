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

- (void)showFullscreenBannerIfNeeded;
- (void)showRouteList;
- (void)showRouteListDelayed;

@end

@implementation RGSplashScreenViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.imageView.image = [UIImage imageNamed:@"Default"];
    
    __weak __typeof(self)weakSelf = self;
    // MARK: update configuration
    [[RGConfiguration sharedConfiguration] updateWithCompletion:^(NSDictionary *defaults, NSError *error) {
        if (error) {
            DLog(@"ERROR: %@", [error localizedDescription]);
        } else {
            DLog(@"defaults: %@", defaults);
        }
        
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        
        if (strongSelf) {
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

        NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:imageURL]];
        [self.imageView setImageWithURLRequest:urlRequest placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            
            if (strongSelf) {
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
