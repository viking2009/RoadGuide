//
//  NSDictionary+Localized.m
//  RoadGuide
//
//  Created by Mykola Vyshynskyi on 8/13/14.
//  Copyright (c) 2014 Mykola Vyshynskyi. All rights reserved.
//

#import "NSDictionary+Localized.h"
#import "RGLanguage.h"

@implementation NSDictionary (Localized)

- (id)localizedObjectForKey:(id)aKey {
    if ([aKey isKindOfClass:[NSString class]]) {
        NSString *localizedKey = [NSString stringWithFormat:@"%@_%@", aKey, [RGLanguage currentLanguage]];
        id localizedObject = self[localizedKey];
        
        if (localizedObject) {
            return localizedObject;
        }
    }
    
    return [self objectForKey:aKey];
}

@end
