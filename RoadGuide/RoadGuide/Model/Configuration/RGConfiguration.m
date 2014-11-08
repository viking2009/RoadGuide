//
//  RGConfiguration.m
//  RoadGuide
//
//  Created by Mykola Vyshynskyi on 8/12/14.
//  Copyright (c) 2014 Mykola Vyshynskyi. All rights reserved.
//

#import "RGConfiguration.h"
#import "NSUserDefaults+GroundControl.h"
#import "AFURLResponseSerialization.h"
#import "RGLanguage.h"
#import "NSDictionary+Localized.h"
#import "ColorUtils.h"

static NSString * const RGConfigurationURL = @"https://docs.google.com/uc?export=download&id=0B4pWLbcPaUi6WjN1LXlBUkRQcEU";

#define kLaunchCount @"LaunchCount"

@interface RGConfiguration ()

@property (nonatomic, readwrite) NSArray *routes;
@property (nonatomic, readwrite) NSArray *routesStrings;
@property (nonatomic, readwrite) NSArray *cities;

- (void)languageChanged:(NSNotification *)notification;

@end

@implementation RGConfiguration

+ (instancetype)sharedConfiguration {
    static RGConfiguration *_sharedConfiguration = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedConfiguration = [[self alloc] init];
    });
    
    return _sharedConfiguration;
}

- (id)init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(languageChanged:) name:RGLanguageDidChangeNotification object:nil];
    }
    
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Ads helpers

- (BOOL)fullscreenBannerEnabled {
    return [self[@"Ads.fullscreenBanner.enabled"] boolValue];
}

- (NSString *)fullscreenBannerImageURL {
    if ([UIScreen mainScreen].bounds.size.height == 568.0) {
        return self[@"Ads.fullscreenBanner.tallImageURL"];
    } else {
        return self[@"Ads.fullscreenBanner.imageURL"];
    }
}

- (NSTimeInterval)fullscreenBannerFadeDuration {
    return [self[@"Ads.fullscreenBanner.fadeDuration"] doubleValue];
}

- (NSTimeInterval)fullscreenBannerShowTime {
    return [self[@"Ads.fullscreenBanner.showTime"] doubleValue];
}

- (BOOL)smallBannerEnabled {
    return [self[@"Ads.smallBanner.enabled"] boolValue];
}

- (NSString *)smallBannerImageURL {
    return self[@"Ads.smallBanner.imageURL"];
}

- (NSString *)smallBannerLinkURL {
    return self[@"Ads.smallBanner.linkURL"];
}

#pragma mark - Routes helpers

- (NSArray *)routes {
    if (!_routes) {
        // MARK: cache routes
        NSMutableArray *routes = [[NSMutableArray alloc] init];
        
        for (NSDictionary *routeConfiguration in self[@"Routes"]) {
            NSMutableDictionary *route = [routeConfiguration mutableCopy];
            
            route[@"from"] = [self cityTitleAtIndex:[route[@"from"] integerValue]];
            route[@"to"] = [self cityTitleAtIndex:[route[@"to"] integerValue]];

            NSMutableArray *transit = [[NSMutableArray alloc] init];
            for (NSString *transitConfiguration in route[@"transit"]) {
                NSUInteger index = [transitConfiguration integerValue];
                NSString *cityTitle = [self cityTitleAtIndex:index];

                [transit addObject:cityTitle];
            }
            route[@"transit"] = transit;
            
            [routes addObject:route];
        }
        
        _routes = routes;
    }
    
    return _routes;
}

- (NSArray *)routesStrings {
    if (!_routesStrings) {
        NSMutableArray *routesStrings = [[NSMutableArray alloc] init];
        
        NSDictionary *routeAttributes = self.routeAttributes;
        NSDictionary *lengthAttributes = self.lengthAttributes;
        NSDictionary *transitAttributes = self.transitAttributes;
        
        for (NSDictionary *route in self.routes) {
            NSString *from = [route[@"from"] uppercaseString];
            NSString *to = [route[@"to"] uppercaseString];
            
            NSString *lengthFrom = [NSString stringWithFormat:@"%@ %@\n", route[@"length"], [RGLanguage localizedStringForKey:@"km"]];
            NSAttributedString *lengthFromA = [[NSAttributedString alloc] initWithString:lengthFrom attributes:lengthAttributes];

            // MARK: first route
            NSString *routeFrom = [NSString stringWithFormat:@"%@-%@ ", from, to];
            NSAttributedString *routeFromA = [[NSAttributedString alloc] initWithString:routeFrom attributes:routeAttributes];

            NSString *transitFrom = [route[@"transit"] componentsJoinedByString:@" - "];
            NSAttributedString *transitFromA = [[NSAttributedString alloc] initWithString:transitFrom attributes:transitAttributes];
            
            NSMutableAttributedString *routeFromString = [[NSMutableAttributedString alloc] init];
            [routeFromString appendAttributedString:routeFromA];
            [routeFromString appendAttributedString:lengthFromA];
            [routeFromString appendAttributedString:transitFromA];
            
            // MARK: second route
            NSString *routeTo = [NSString stringWithFormat:@"%@-%@ ", to, from];
            NSAttributedString *routeToA = [[NSAttributedString alloc] initWithString:routeTo attributes:routeAttributes];
            
            NSString *transitTo = [[[route[@"transit"] reverseObjectEnumerator] allObjects] componentsJoinedByString:@" - "];
            NSAttributedString *transitToA = [[NSAttributedString alloc] initWithString:transitTo attributes:transitAttributes];
            
            NSMutableAttributedString *routeToString = [[NSMutableAttributedString alloc] init];
            [routeToString appendAttributedString:routeToA];
            [routeToString appendAttributedString:lengthFromA];
            [routeToString appendAttributedString:transitToA];
            
            // MARK: add routes to group
            NSMutableArray *routeGroup = [[NSMutableArray alloc] init];
            [routeGroup addObject:routeFromString];
            [routeGroup addObject:routeToString];
            
            // MARK: add group
            [routesStrings addObject:routeGroup];
        }
        
        _routesStrings = routesStrings;
    }
    
    return _routesStrings;
}

#pragma mark - Cities helpers

- (NSArray *)cities {
    if (!_cities) {
        // MARK: cache cities
        NSMutableArray *cities = [[NSMutableArray alloc] init];
        
        for (NSDictionary *city in self[@"Cities"]) {
            NSString *cityTitle = [city localizedObjectForKey:@"title"];

            if (cityTitle) {
                [cities addObject:cityTitle];
            }
        }
        
        _cities = cities;
    }
    
    return _cities;
}

- (NSString *)cityTitleAtIndex:(NSUInteger)index {
    if (index < [self.cities count]) {
        return self.cities[index];
    }
    
    return @"undefined";
}

#pragma mark - Language helpers

- (NSString *)defaultLanguage {
    return self[@"Language.default"];
}

- (NSString *)currentLanguage {
    return self[RGSettingsLanguageKey];
}

#pragma mark - Design helpers

- (UIColor *)splashScreenActivityIndicatorColor {
    return [UIColor colorWithString:self[@"Design.SplashScreen.activityIndicatorColor"]] ? : [UIColor blackColor];
}

- (UIColor *)routeCellBackgroundColor {
    return [UIColor colorWithString:self[@"Design.RouteList.RouteCell.backgroundColor"]];
}

- (NSDictionary *)routeAttributes {
    NSDictionary *routeLabel = self[@"Design.RouteList.RouteCell.routeLabel"];
    
    NSString *fontName = routeLabel[@"fontName"];
    CGFloat fontSize = [routeLabel[@"fontSize"] floatValue];
    UIFont *routeFont = [UIFont fontWithName:fontName size:fontSize] ? : [UIFont boldSystemFontOfSize:fontSize];
    
    UIColor *textColor = [UIColor colorWithString:routeLabel[@"textColor"]];
    
    return @{NSFontAttributeName: routeFont, NSForegroundColorAttributeName : textColor};
}

- (NSDictionary *)lengthAttributes {
    NSDictionary *lengthLabel = self[@"Design.RouteList.RouteCell.lengthLabel"];
    
    NSString *fontName = lengthLabel[@"fontName"];
    CGFloat fontSize = [lengthLabel[@"fontSize"] floatValue];
    UIFont *lengthFont = [UIFont fontWithName:fontName size:fontSize] ? : [UIFont italicSystemFontOfSize:fontSize];
    
    UIColor *textColor = [UIColor colorWithString:lengthLabel[@"textColor"]];
    
    return @{NSFontAttributeName: lengthFont, NSForegroundColorAttributeName : textColor};
}

- (NSDictionary *)transitAttributes {
    NSDictionary *transitLabel = self[@"Design.RouteList.RouteCell.transitLabel"];
    
    NSString *fontName = transitLabel[@"fontName"];
    CGFloat fontSize = [transitLabel[@"fontSize"] floatValue];
    UIFont *transitFont = [UIFont fontWithName:fontName size:fontSize] ? : [UIFont systemFontOfSize:fontSize];
    
    UIColor *textColor = [UIColor colorWithString:transitLabel[@"textColor"]];
    
    return @{NSFontAttributeName: transitFont, NSForegroundColorAttributeName : textColor};
}

- (UIColor *)routeDetailsActivityIndicatorColor {
    return [UIColor colorWithString:self[@"Design.RouteDetails.activityIndicatorColor"]] ? : [UIColor whiteColor];
}

- (UIColor *)cityHeaderBackgroundColor {
    return [UIColor colorWithString:self[@"Design.RouteDetails.CityHeader.backgroundColor"]];
}

- (NSDictionary *)cityHeaderAttributes {
    NSDictionary *cityLabel = self[@"Design.RouteDetails.CityHeader.cityLabel"];
    
    NSString *fontName = cityLabel[@"fontName"];
    CGFloat fontSize = [cityLabel[@"fontSize"] floatValue];
    UIFont *cityFont = [UIFont fontWithName:fontName size:fontSize] ? : [UIFont boldSystemFontOfSize:fontSize];
    
    UIColor *textColor = [UIColor colorWithString:cityLabel[@"textColor"]];
    
    return @{NSFontAttributeName: cityFont, NSForegroundColorAttributeName : textColor, NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle)};
}

- (NSString *)flurryApiKey {
    return self[@"Stats.Flurry.apiKey"];
}

#pragma mark - Public

- (id)objectForKeyedSubscript:(id)key {
    return [[NSUserDefaults standardUserDefaults] valueForKeyPath:key];
}

- (void)incrementLaunchCount {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSInteger launchCount = [userDefaults integerForKey:kLaunchCount];
    if (!launchCount) {
        NSURL *configURL = [[NSBundle mainBundle] URLForResource:@"Config" withExtension:@"plist"];
        NSDictionary *config = [NSDictionary dictionaryWithContentsOfURL:configURL];
        
        [userDefaults setValuesForKeysWithDictionary:config];
    }
    
    launchCount++;
    
    [userDefaults setInteger:launchCount forKey:kLaunchCount];
    [userDefaults synchronize];
    
    DLog(@"%@: %li", kLaunchCount, (long)launchCount);
}

- (void)updateWithCompletion:(void (^)(NSDictionary *defaults, NSError *error))completion {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        AFPropertyListResponseSerializer *serializer = [AFPropertyListResponseSerializer serializer];
        serializer.acceptableContentTypes = [NSSet setWithObjects:@"text/xml", @"text/plain", nil];
        
        userDefaults.responseSerializer = serializer;
    });
    
    NSURL *configURL = [NSURL URLWithString:RGConfigurationURL];
    [userDefaults registerDefaultsWithURL:configURL success:^(NSDictionary *dDefaults) {
        if (completion) {
            completion(dDefaults, nil);
        }
    } failure:^(NSError *dError) {
        if (completion) {
            completion(nil, dError);
        }
    }];
}

#pragma mark - Notifications

- (void)languageChanged:(NSNotification *)notification {
    // remove cache
    self.routes = nil;
    self.routesStrings = nil;
    self.cities = nil;
}

@end
