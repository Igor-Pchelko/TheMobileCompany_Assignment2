//
//  CountryPolygon.h
//  Assignment2
//
//  Created by Igor Pchelko on 20/02/16.
//  Copyright © 2016 Igor Pchelko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "MapProjection.h"

@interface CountryPolygon : NSObject

- (instancetype)initWithCountryName:(NSString*)anCountryName coordinates:(NSArray*)coords;

- (void)buildPathWithMapProjection:(id<MapProjection>)mapProjection;
- (NSString *)countryName;
- (CGPathRef)path;
- (BOOL)pathContainsCoordinate:(CGPoint)geo;

@end
