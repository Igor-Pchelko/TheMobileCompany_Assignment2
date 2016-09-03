//
//  MapView.m
//  Assignment2
//
//  Created by Igor Pchelko on 20/02/16.
//  Copyright © 2016 Igor Pchelko. All rights reserved.
//

#import "MapView.h"
#import "MapModel.h"
#import "CountryPolygon.h"

@implementation MapView

-(void) drawRect: (CGRect) rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();

    CGContextSetStrokeColorWithColor(ctx,[UIColor blackColor].CGColor);
    CGContextSetFillColorWithColor(ctx, [UIColor colorWithRed:0.0f green:0.8f blue:0.0f alpha:0.7f].CGColor);
    CGContextSetLineJoin(ctx, kCGLineJoinRound);
    CGContextSetLineWidth(ctx, 2.0);

    for (CountryPolygon *countryPolygon in [[MapModel sharedInstance] countryPolygones] )
    {
        CGPathRef path = [countryPolygon path];

        // Draw path
        CGContextAddPath(ctx, path);
        CGContextDrawPath(ctx, kCGPathFillStroke);
        
        // Release path
        CGPathRelease(path);        
    }
}

@end
