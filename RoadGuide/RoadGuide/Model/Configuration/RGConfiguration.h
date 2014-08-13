//
//  RGConfiguration.h
//  RoadGuide
//
//  Created by Mykola Vyshynskyi on 8/12/14.
//  Copyright (c) 2014 Mykola Vyshynskyi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RGConfiguration : NSObject

// MARK: helpers
@property (nonatomic, readonly) BOOL fullscreenBannerEnabled;
@property (nonatomic, readonly) NSString *fullscreenBannerImageURL;
@property (nonatomic, readonly) NSTimeInterval fullscreenBannerFadeDuration;
@property (nonatomic, readonly) NSTimeInterval fullscreenBannerShowTime;

+ (instancetype)sharedConfiguration;

- (id)objectForKeyedSubscript:(id)key NS_AVAILABLE(10_8, 6_0);

- (void)updateWithCompletion:(void (^)(NSDictionary *defaults, NSError *error))completion;

@end
