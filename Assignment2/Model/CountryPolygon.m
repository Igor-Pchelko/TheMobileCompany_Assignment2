//
//  CountryPolygon.m
//  Assignment2
//
//  Created by Igor Pchelko on 20/02/16.
//  Copyright © 2016 Igor Pchelko. All rights reserved.
//

#import "CountryPolygon.h"

@interface CountryPolygon ()
{
    CGPathRef path;
}

@property (copy, nonatomic) NSString *countryName;
@property (strong, nonatomic) NSArray *geoCoordinates;

@end

@implementation CountryPolygon

- (instancetype)initWithCountryName:(NSString*)anCountryName coordinates:(NSArray*)coords
{
    self = [super init];
    
    if (self != nil)
    {
        self.geoCoordinates = coords;
        self.countryName = [anCountryName copy];
    }
    
    return self;
}

- (void)dealloc
{
    if (path != NULL) CGPathRelease(path);
}

- (NSString *)countryName
{
    return _countryName;
}

- (void)buildPathWithMapProjection:(id<MapProjection>)mapProjection
{
    if (path != NULL) CGPathRelease(path);
    path = NULL;
    
    CGMutablePathRef mutablePath = CGPathCreateMutable();
    BOOL isFirst = YES;
    
    for (id coord in self.geoCoordinates)
    {
        double xCoord = [[coord objectAtIndex:0] doubleValue];
        double yCoord = [[coord objectAtIndex:1] doubleValue];
        
        CGPoint mapCoord = [mapProjection projectionWithGeo:CGPointMake(xCoord, yCoord)];
        
        if (isFirst)
        {
            CGPathMoveToPoint(mutablePath, NULL, mapCoord.x, mapCoord.y);
            isFirst = NO;
        }
        else
        {
            CGPathAddLineToPoint(mutablePath, NULL, mapCoord.x, mapCoord.y);
        }
    }
    
    CGPathCloseSubpath(mutablePath);
    path = mutablePath;
}

- (CGPathRef)path
{
    CGPathRetain(path);
    return path;
}

- (BOOL)pathContainsCoordinate:(CGPoint)geo
{
    NSUInteger count = self.geoCoordinates.count;
    BOOL oddNodes = NO;
    double xi, yi;
    double xj, yj;

    id coordj = [self.geoCoordinates objectAtIndex:count-1];
    xj = [[coordj objectAtIndex:0] doubleValue];
    yj = [[coordj objectAtIndex:1] doubleValue];

    for (id coord in self.geoCoordinates)
    {
        xi = [[coord objectAtIndex:0] doubleValue];
        yi = [[coord objectAtIndex:1] doubleValue];
        
        if ((
               ((yi < geo.y) && (yj >= geo.y))
            || ((yj < geo.y) && (yi >= geo.y)) )

            && ((xi <= geo.x) || (xj <= geo.x))
            )
        {
            oddNodes ^= (xi + (geo.y - yi) / (yj - yi) * (xj - xi)) < geo.x;
        }
        
        xj = xi;
        yj = yi;
    }
    
    return oddNodes;
}
    
@end
