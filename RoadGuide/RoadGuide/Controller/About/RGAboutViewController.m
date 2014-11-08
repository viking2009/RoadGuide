//
//  RGAboutViewController.m
//  RoadGuide
//
//  Created by Mykola Vyshynskyi on 9/4/14.
//  Copyright (c) 2014 Mykola Vyshynskyi. All rights reserved.
//

#import "RGAboutViewController.h"
#import "UIImage+Localized.h"
#import "Flurry.h"
#import "RGLanguage.h"
#import "RGConfiguration.h"
#import "UIImageView+AFNetworking.h"

@interface RGAboutViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *backgroundView;
@property (weak, nonatomic) IBOutlet UIImageView *infoView;
@property (weak, nonatomic) IBOutlet UIButton *routeSelectButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

- (void)loadImage;

- (IBAction)routeSelectButtonAction:(id)sender;

@end

@implementation RGAboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.backgroundView.image = [UIImage imageNamed:@"routeList_background"];
    [self.routeSelectButton setImage:[UIImage localizedImageNamed:@"routeDetails_button_routeSelect"] forState:UIControlStateNormal];
    
    [self loadImage];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)loadImage {
    RGConfiguration *configuration = [RGConfiguration sharedConfiguration];
    
    NSString *imageURL = [configuration aboutImageURL];
    
    if (imageURL) {
        __weak __typeof(self)weakSelf = self;
        
        self.infoView.image = nil;
        
        [self.activityIndicator startAnimating];
        
        NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:imageURL]];
        [self.infoView setImageWithURLRequest:urlRequest placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            
            if (strongSelf) {
                [strongSelf.activityIndicator stopAnimating];
                
                [UIView transitionWithView:strongSelf.infoView
                                  duration:configuration.fullscreenBannerFadeDuration
                                   options:UIViewAnimationOptionTransitionCrossDissolve
                                animations:^{
                                    strongSelf.infoView.image = image;
                                } completion:^(BOOL finished) {
                                    [Flurry logEvent:@"AboutShown" withParameters:@{RGSettingsLanguageKey: [RGLanguage currentLanguage]}];
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

- (IBAction)routeSelectButtonAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

@end
