//
//  RGRouteListViewController.m
//  RoadGuide
//
//  Created by Mykola Vyshynskyi on 8/13/14.
//  Copyright (c) 2014 Mykola Vyshynskyi. All rights reserved.
//

#import "RGRouteListViewController.h"
#import "RGConfiguration.h"
#import "UIButton+AFNetworking.h"

@interface RGRouteListViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *backgroundView;

@end

@implementation RGRouteListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.backgroundView.image = [UIImage imageNamed:@"routeList_background"];
}

//-(UIStatusBarStyle)preferredStatusBarStyle {
//    return UIStatusBarStyleLightContent;
//}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

#pragma mark - Private

@end
