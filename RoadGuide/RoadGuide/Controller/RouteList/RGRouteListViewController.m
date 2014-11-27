//
//  RGRouteListViewController.m
//  RoadGuide
//
//  Created by Mykola Vyshynskyi on 8/13/14.
//  Copyright (c) 2014 Mykola Vyshynskyi. All rights reserved.
//

#import "RGRouteListViewController.h"
#import "RGConfiguration.h"
//#import "UIImageView+AFNetworking.h"
#import "UIButton+AFNetworking.h"
#import "RGRouteListCell.h"
#import "RGLanguage.h"
#import "RGRouteDetailsViewController.h"
#import "Flurry.h"
#import "NSDictionary+Localized.h"

@interface RGRouteListViewController () <UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet UIImageView *backgroundView;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *languageButtons;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIButton *bannerView;

- (IBAction)changeLanguage:(id)sender;
- (IBAction)openSmallBannerLinkURL:(id)sender;

- (void)updateLanguageButtonsStates;
- (void)languageChanged:(NSNotification *)notification;

@end

@implementation RGRouteListViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(languageChanged:) name:RGLanguageDidChangeNotification object:nil];
    }
    
    return self;
}

- (void)dealloc {
    DLog();
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.backgroundView.image = [UIImage imageNamed:@"routeList_background"];
    
    [self updateLanguageButtonsStates];
    
    RGConfiguration *configuration = [RGConfiguration sharedConfiguration];
    NSString *imageURL = configuration.smallBannerImageURL;

    CGFloat bannerHeight = CGRectGetHeight(self.bannerView.frame);
    CGFloat additionalHeight = CGRectGetMaxY(self.bannerView.frame) - CGRectGetMaxY(self.collectionView.frame);

    // MARK: resize collection view while no banner image loaded
    CGRect collectionViewFrame = self.collectionView.frame;
    collectionViewFrame.size.height += additionalHeight;
    self.collectionView.frame = collectionViewFrame;

    // MARK: hide banner view while no banner image loaded
    CGRect bannerViewFrame = self.bannerView.frame;
    bannerViewFrame.origin.y = CGRectGetMaxY(bannerViewFrame);
    bannerViewFrame.size.height = 0;
    self.bannerView.frame = bannerViewFrame;
    
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

                                        // MARK: resize collection view
                                        CGRect collectionViewFrame = strongSelf.collectionView.frame;
                                        collectionViewFrame.size.height -= additionalHeight;
                                        strongSelf.collectionView.frame = collectionViewFrame;
                                        
                                        // MARK: resize banner view
                                        CGRect bannerViewFrame = strongSelf.bannerView.frame;
                                        bannerViewFrame.origin.y -= bannerHeight;
                                        bannerViewFrame.size.height = bannerHeight;
                                        strongSelf.bannerView.frame = bannerViewFrame;
                                    } completion:^(BOOL finished) {
                                        [Flurry logEvent:@"SmallBannerShown" withParameters:@{@"imageURL": configuration.smallBannerImageURL}];
                                    }];
                }
        } failure:^(NSError *error) {
            DLog(@"ERROR: %@", [error localizedDescription]);
        }];
    }
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // update state for downloaded maps
    [self.collectionView reloadData];
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if ([identifier isEqualToString:@"showRouteDetails"]) {
        NSIndexPath *indexPath = self.collectionView.indexPathsForSelectedItems.firstObject;
        if (indexPath) {
            RGConfiguration *configuration = [RGConfiguration sharedConfiguration];
            NSDictionary *route = configuration.routes[indexPath.section];
            NSString *imageURLKey = indexPath.item == 0 ? @"fromImageURL" : @"toImageURL";
            
            return ([[route localizedObjectForKey:imageURLKey] length] > 0);
        }
    }
    
    return NO;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showRouteDetails"]) {
        NSIndexPath *indexPath = self.collectionView.indexPathsForSelectedItems.firstObject;
        if (indexPath) {
            RGRouteDetailsViewController *routeDetails = segue.destinationViewController;

            RGConfiguration *configuration = [RGConfiguration sharedConfiguration];
            NSDictionary *route = configuration.routes[indexPath.section];

            NSMutableDictionary *routeInfo = [[NSMutableDictionary alloc] init];
            
            if (indexPath.item == 0) {
                routeInfo[@"from"] = [route[@"from"] uppercaseString];
                routeInfo[@"to"] = [route[@"to"] uppercaseString];
                routeInfo[@"fromImageURL"] = [route localizedObjectForKey:@"fromImageURL"];
                routeInfo[@"toImageURL"] = [route localizedObjectForKey:@"toImageURL"];
            } else {
                routeInfo[@"from"] = [route[@"to"] uppercaseString];
                routeInfo[@"to"] = [route[@"from"] uppercaseString];
                routeInfo[@"fromImageURL"] = [route localizedObjectForKey:@"toImageURL"];
                routeInfo[@"toImageURL"] = [route localizedObjectForKey:@"fromImageURL"];
            }
            
            routeDetails.routeInfo = routeInfo;
            
            NSMutableDictionary *routeInfoFlurry = [[NSMutableDictionary alloc] init];
            routeInfoFlurry[@"from"] = routeInfo[@"from"];
            routeInfoFlurry[@"to"] = routeInfo[@"to"];

            [Flurry logEvent:@"RouteSelected" withParameters:routeInfoFlurry];
        }
    }
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

#pragma mark - Private

- (void)updateLanguageButtonsStates {
    NSUInteger languageIndex = [[RGLanguage supportedLanguages] indexOfObject:[RGLanguage currentLanguage]];
    
    for (UIButton *button in self.languageButtons) {
        button.selected = (button.tag == languageIndex);
    }
}

#pragma mark - IBActions

- (IBAction)changeLanguage:(id)sender {
    UIButton *button = sender;
    
    NSArray *supportedLanguages = [RGLanguage supportedLanguages];
    if (button.tag < [supportedLanguages count]) {
        NSString *selectedLanguage = supportedLanguages[button.tag];
        [RGLanguage setCurrentLanguage:selectedLanguage];
    }
}

- (IBAction)openSmallBannerLinkURL:(id)sender {
    RGConfiguration *configuration = [RGConfiguration sharedConfiguration];
    NSString *linkURL = configuration.smallBannerLinkURL;

    if (configuration.smallBannerEnabled && linkURL) {
        [Flurry logEvent:@"SmallBannerClicked" withParameters:@{@"linkURL": linkURL}];

        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:linkURL]];
    }
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    RGConfiguration *configutation = [RGConfiguration sharedConfiguration];

    return [configutation.routesStrings count];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    RGConfiguration *configutation = [RGConfiguration sharedConfiguration];

    return [configutation.routesStrings[section] count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    RGRouteListCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:RGRouteListCellIdentifier forIndexPath:indexPath];
    
    RGConfiguration *configuration = [RGConfiguration sharedConfiguration];
    NSDictionary *route = configuration.routes[indexPath.section];

    // TODO: implement blur?
//    NSString *routeImageKey = (indexPath.item == 0 ? @"fromImageURL" : @"toImageURL");
//    NSURL *imageURL = [NSURL URLWithString:[route localizedObjectForKey:routeImageKey]];
//    NSURLRequest *imageRequest = [NSURLRequest requestWithURL:imageURL];
//    [cell enableBlur:![[UIImageView sharedImageCache] cachedImageForRequest:imageRequest]];
    
    cell.textLabel.attributedText = configuration.routesStrings[indexPath.section][indexPath.item];
    
    if ([route[@"route_eu"] length]) {
        cell.routeEuLabel.text = route[@"route_eu"];
        cell.routeEuLabel.hidden = NO;
    } else {
        cell.routeEuLabel.hidden = YES;
    }
    
    if ([route[@"route_ua"] length]) {
        cell.routeUaLabel.text = route[@"route_ua"];
        cell.routeUaLabel.hidden = NO;
    } else {
        cell.routeUaLabel.hidden = YES;
    }

    return cell;
}

#pragma mark - Notifications

- (void)languageChanged:(NSNotification *)notification {
    [self updateLanguageButtonsStates];
    
    [self.collectionView performSelector:@selector(reloadData) withObject:nil afterDelay:0.1];
}

@end
