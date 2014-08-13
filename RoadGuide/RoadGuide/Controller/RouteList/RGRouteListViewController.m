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
#import "RGLanguage.h"

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
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.backgroundView.image = [UIImage imageNamed:@"routeList_background"];
    
    [self updateLanguageButtonsStates];
    
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
    
    cell.contentView.backgroundColor = configuration.routeCellBackgroundColor;
    cell.textLabel.attributedText = configuration.routesStrings[indexPath.section][indexPath.item];
    
    return cell;
}

#pragma mark - Notifications

- (void)languageChanged:(NSNotification *)notification {
    [self updateLanguageButtonsStates];
    
    [self.collectionView performSelector:@selector(reloadData) withObject:nil afterDelay:0.1];
}

@end
