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
#import "RGRouteListCell.h"

@interface RGRouteListViewController () <UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet UIImageView *backgroundView;
@property (weak, nonatomic) IBOutlet UIButton *bannerView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

- (IBAction)openSmallBannerLinkURL:(id)sender;

@end

@implementation RGRouteListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.backgroundView.image = [UIImage imageNamed:@"routeList_background"];
    
    RGConfiguration *configuration = [RGConfiguration sharedConfiguration];
    NSString *imageURL = configuration.smallBannerImageURL;

    if (configuration.smallBannerEnabled && imageURL) {
        __weak __typeof(self)weakSelf = self;

        NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:imageURL]];
        [self.bannerView setBackgroundImageForState:UIControlStateNormal withURLRequest:urlRequest placeholderImage:nil success:^(NSHTTPURLResponse *response, UIImage *image) {
                __strong __typeof(weakSelf)strongSelf = weakSelf;
                
                if (strongSelf) {
                    [UIView transitionWithView:strongSelf.bannerView
                                      duration:configuration.fullscreenBannerFadeDuration
                                       options:UIViewAnimationOptionTransitionCrossDissolve
                                    animations:^{
                                        [strongSelf.bannerView setBackgroundImage:image forState:UIControlStateNormal];
                                    } completion:^(BOOL finished) {

                                    }];
                }

        } failure:^(NSError *error) {
            // TODO: hide banner, resize collection view
        }];
    }
}

//-(UIStatusBarStyle)preferredStatusBarStyle {
//    return UIStatusBarStyleLightContent;
//}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

#pragma mark - IBActions

- (IBAction)openSmallBannerLinkURL:(id)sender {
    RGConfiguration *configuration = [RGConfiguration sharedConfiguration];
    NSString *linkURL = configuration.smallBannerLinkURL;

    if (configuration.smallBannerEnabled && linkURL) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:linkURL]];
    }
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 10;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 2;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    RGRouteListCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:RGRouteListCellIdentifier forIndexPath:indexPath];
    
    cell.textLabel.text = [NSString stringWithFormat:@"<%i, %i", indexPath.section + 1, indexPath.item + 1];
    
    return cell;
}

@end
