//
//  RGConfiguration.h
//  RoadGuide
//
//  Created by Mykola Vyshynskyi on 8/12/14.
//  Copyright (c) 2014 Mykola Vyshynskyi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RGConfiguration : NSObject

+ (instancetype)sharedConfiguration;

- (void)updateWithCompletion:(void (^)(NSDictionary *defaults, NSError *error))completion;

@end
