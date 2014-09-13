//
//  RGInfoViewController.m
//  RoadGuide
//
//  Created by Mykola Vyshynskyi on 9/13/14.
//  Copyright (c) 2014 Mykola Vyshynskyi. All rights reserved.
//

#import "RGInfoViewController.h"
#import "UIImage+Localized.h"
#import "Flurry.h"
#import "RGLanguage.h"

@interface RGInfoViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *backgroundView;
@property (weak, nonatomic) IBOutlet UIImageView *infoView;

@end

@implementation RGInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.backgroundView.image = [UIImage imageNamed:@"routeList_background"];
    self.infoView.image = [UIImage localizedImageNamed:@"info_background"];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [Flurry logEvent:@"InfoShown" withParameters:@{RGSettingsLanguageKey: [RGLanguage currentLanguage]}];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

@end
