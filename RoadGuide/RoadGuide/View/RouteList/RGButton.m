//
//  RGButton.m
//  RoadGuide
//
//  Created by Mykola Vyshynskyi on 8/13/14.
//  Copyright (c) 2014 Mykola Vyshynskyi. All rights reserved.
//

#import "RGButton.h"
#import "RGConfiguration.h"

@implementation RGButton

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    
    if (selected) {
        RGConfiguration *configuration = [RGConfiguration sharedConfiguration];
        NSDictionary *routeAttributes = configuration.routeAttributes;
        UIColor *borderColor = routeAttributes[NSForegroundColorAttributeName] ? : [UIColor redColor];
        
        self.layer.borderColor = borderColor.CGColor;
        self.layer.borderWidth = 1.f;
    } else {
        self.layer.borderColor = nil;
    }
}

@end
