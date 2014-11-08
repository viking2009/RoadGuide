//
//  RGConfiguration.h
//  RoadGuide
//
//  Created by Mykola Vyshynskyi on 8/12/14.
//  Copyright (c) 2014 Mykola Vyshynskyi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RGConfiguration : NSObject

// MARK: Ads helpers
@property (nonatomic, readonly) BOOL fullscreenBannerEnabled;
@property (nonatomic, readonly) NSString *fullscreenBannerImageURL;
@property (nonatomic, readonly) NSTimeInterval fullscreenBannerFadeDuration;
@property (nonatomic, readonly) NSTimeInterval fullscreenBannerShowTime;

@property (nonatomic, readonly) BOOL smallBannerEnabled;
@property (nonatomic, readonly) NSString *smallBannerImageURL;
@property (nonatomic, readonly) NSString *smallBannerLinkURL;

// MARK: Routes helpers
@property (nonatomic, readonly) NSArray *routes;
@property (nonatomic, readonly) NSArray *routesStrings;

// MARK: Cities helpers
@property (nonatomic, readonly) NSArray *cities;
- (NSString *)cityTitleAtIndex:(NSUInteger)index;

// MARK: Language helpers
@property (nonatomic, readonly) NSString *defaultLanguage;
@property (nonatomic, readonly) NSString *currentLanguage;

// MARK: Design helpers
@property (nonatomic, readonly) UIColor *splashScreenActivityIndicatorColor;
@property (nonatomic, readonly) UIColor *routeCellBackgroundColor;
@property (nonatomic, readonly) NSDictionary *routeAttributes;
@property (nonatomic, readonly) NSDictionary *lengthAttributes;
@property (nonatomic, readonly) NSDictionary *transitAttributes;
@property (nonatomic, readonly) UIColor *routeDetailsActivityIndicatorColor;
@property (nonatomic, readonly) UIColor *cityHeaderBackgroundColor;
@property (nonatomic, readonly) NSDictionary *cityHeaderAttributes;

// MARK: Stats
@property (nonatomic, readonly) NSString *flurryApiKey;

// MARK: About helper
@property (nonatomic, readonly) NSString *aboutImageURL;

// MARK: Info helper
@property (nonatomic, readonly) NSString *infoImageURL;

+ (instancetype)sharedConfiguration;

- (id)objectForKeyedSubscript:(id)key NS_AVAILABLE(10_8, 6_0);

- (void)incrementLaunchCount;
- (void)updateWithCompletion:(void (^)(NSDictionary *defaults, NSError *error))completion;

@end
