//
//  RGFadeReplaceSegue.m
//  RoadGuide
//
//  Created by Mykola Vyshynskyi on 8/13/14.
//  Copyright (c) 2014 Mykola Vyshynskyi. All rights reserved.
//

#import "RGFadeReplaceSegue.h"
#import "RGConfiguration.h"

@implementation RGFadeReplaceSegue

-(void) perform
{
    RGConfiguration *configuration = [RGConfiguration sharedConfiguration];

    UIViewController *destination = self.destinationViewController;
    UIViewController *source = self.sourceViewController;
//    [destination viewWillAppear:YES];
    
    destination.view.frame = source.view.frame;
    
    [UIView transitionFromView:source.view
                        toView:destination.view
                      duration:configuration.fullscreenBannerFadeDuration
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    completion:^(BOOL finished) {
                        UINavigationController *nav = source.navigationController;
                        [nav popViewControllerAnimated:NO];
                        [nav pushViewController:destination animated:NO];
                        
//                        [destination viewDidAppear:YES];
                    }
     ];
}

@end
