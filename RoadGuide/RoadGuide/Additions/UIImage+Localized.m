//
//  UIImage+Localized.m
//  RoadGuide
//
//  Created by Mykola Vyshynskyi on 9/4/14.
//  Copyright (c) 2014 Mykola Vyshynskyi. All rights reserved.
//

#import "UIImage+Localized.h"
#import "RGLanguage.h"

@implementation UIImage (Localized)

+ (UIImage *)localizedImageNamed:(NSString *)name {
    if ([name isKindOfClass:[NSString class]]) {
        NSString *localizedName = [NSString stringWithFormat:@"%@_%@", name, [RGLanguage currentLanguage]];
        UIImage *localizedImage = [UIImage imageNamed:localizedName];
        
        if (localizedImage) {
            return localizedImage;
        }
    }
    
    return [self imageNamed:name];
}

@end
