//
//  MercatorProjection.m
//  Assignment2
//
//  Created by Igor Pchelko on 21/02/16.
//  Copyright © 2016 Igor Pchelko. All rights reserved.
//

#import "MercatorProjection.h"

@interface MercatorProjection ()

@property (assign, nonatomic) NSUInteger scale;
@property (assign, nonatomic) double mercatorOffset;
@property (assign, nonatomic) double mercatorRadius;

@end

@implementation MercatorProjection

- (void) setupProjectionWithScale:(NSUInteger)scale
{
    self.scale = scale;
    self.mercatorOffset = 1 << (scale-1);
    self.mercatorRadius = self.mercatorOffset / M_PI;
}

- (CGSize) getProjectionSize
{
    double size = 1 << self.scale;
    return CGSizeMake(size, size);
}

- (CGPoint) projectionWithGeo:(CGPoint)geoCoord
{
    CGPoint projection;
    projection.x = round(self.mercatorOffset + self.mercatorRadius * geoCoord.x * M_PI / 180.0);
    double siny = sinf(geoCoord.y * M_PI / 180.0);
    projection.y = round(self.mercatorOffset - self.mercatorRadius * logf((1 + siny) / (1 - siny)) / 2.0);
    return projection;
}

- (CGPoint) geoWithProjection:(CGPoint)projectionCoord
{
    CGPoint geo;
    geo.x = (M_PI / 2.0 - 2.0 * atan(exp((round(projectionCoord.y) - self.mercatorOffset) / self.mercatorRadius))) * 180.0 / M_PI;
    geo.y = ((round(projectionCoord.x) - self.mercatorOffset) / self.mercatorRadius) * 180.0 / M_PI;
    return geo;
}

@end
