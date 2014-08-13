//
//  RGSplashScreenViewController.m
//  RoadGuide
//
//  Created by Mykola Vyshynskyi on 8/13/14.
//  Copyright (c) 2014 Mykola Vyshynskyi. All rights reserved.
//

#import "RGSplashScreenViewController.h"
#import "RGConfiguration.h"

@interface RGSplashScreenViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

- (UIImage *)launchImage;

@end

@implementation RGSplashScreenViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.imageView.image = [self launchImage];
    
    // MARK: update configuration
    [[RGConfiguration sharedConfiguration] updateWithCompletion:^(NSDictionary *defaults, NSError *error) {
        if (error) {
            DLog(@"ERROR: %@", [error localizedDescription]);
        } else {
            DLog(@"defaults: %@", defaults);
        }
    }];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

#pragma mark - Private

- (UIImage*)launchImage {
    if ([UIScreen mainScreen].bounds.size.height == 568.0) {
        // Use Retina 4 launch image
        return [UIImage imageNamed:@"Default-568h@2x.png"];
    } else {
        // Use Retina 3.5 launch image
        return [UIImage imageNamed:@"Default.png"];
    }
}

@end
