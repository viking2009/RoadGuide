//
//  RGRouteListCell.h
//  RoadGuide
//
//  Created by Mykola Vyshynskyi on 8/13/14.
//  Copyright (c) 2014 Mykola Vyshynskyi. All rights reserved.
//

#import <UIKit/UIKit.h>

#define RGRouteListCellIdentifier @"RGRouteListCell"

@interface RGRouteListCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel *textLabel;
@property (weak, nonatomic) IBOutlet UILabel *routeEuLabel;
@property (weak, nonatomic) IBOutlet UILabel *routeUaLabel;

@end
