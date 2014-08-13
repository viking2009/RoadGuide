//
//  RGRouteListCell.m
//  RoadGuide
//
//  Created by Mykola Vyshynskyi on 8/13/14.
//  Copyright (c) 2014 Mykola Vyshynskyi. All rights reserved.
//

#import "RGRouteListCell.h"

@implementation RGRouteListCell

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    
    self.contentView.alpha = highlighted ? 0.8 : 1;
}

@end
