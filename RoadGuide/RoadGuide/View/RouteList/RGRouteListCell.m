//
//  RGRouteListCell.m
//  RoadGuide
//
//  Created by Mykola Vyshynskyi on 8/13/14.
//  Copyright (c) 2014 Mykola Vyshynskyi. All rights reserved.
//

#import "RGRouteListCell.h"
#import "RGConfiguration.h"

@implementation RGRouteListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.routeEuLabel.layer.borderColor = [UIColor whiteColor].CGColor;
    self.routeEuLabel.layer.borderWidth = 0.5;
    self.routeEuLabel.layer.cornerRadius = 2.0;
    self.routeEuLabel.layer.masksToBounds = YES;
        
    self.routeUaLabel.layer.borderColor = [UIColor whiteColor].CGColor;
    self.routeUaLabel.layer.borderWidth = 0.5;
    self.routeUaLabel.layer.cornerRadius = 2.0;
    self.routeUaLabel.layer.masksToBounds = YES;
    
    RGConfiguration *configuration = [RGConfiguration sharedConfiguration];
    self.contentView.backgroundColor = configuration.routeCellBackgroundColor;
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    
    self.contentView.alpha = highlighted ? 0.8 : 1;
}

@end
