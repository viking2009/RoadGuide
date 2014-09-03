//
//  RGAboutViewController.m
//  RoadGuide
//
//  Created by Mykola Vyshynskyi on 9/4/14.
//  Copyright (c) 2014 Mykola Vyshynskyi. All rights reserved.
//

#import "RGAboutViewController.h"
#import "UIImage+Localized.h"

@interface RGAboutViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *backgroundView;
@property (weak, nonatomic) IBOutlet UIImageView *infoView;

@end

@implementation RGAboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.backgroundView.image = [UIImage imageNamed:@"routeList_background"];
    
    UIImage *infoImage = [UIImage localizedImageNamed:@"about_background"];
    CGRect infoViewFrame = self.infoView.frame;
    infoViewFrame.size.height = infoImage.size.height;
    self.infoView.frame = infoViewFrame;
    self.infoView.image = infoImage;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

@end
