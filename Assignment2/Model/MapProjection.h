//
//  MapProjection.h
//  Assignment2
//
//  Created by Igor Pchelko on 21/02/16.
//  Copyright © 2016 Igor Pchelko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol MapProjection <NSObject>

@required
- (void) setupProjectionWithScale:(NSUInteger)scale;
- (CGSize) getProjectionSize;

- (CGPoint) projectionWithGeo:(CGPoint)geoCoord;
- (CGPoint) geoWithProjection:(CGPoint)projectionCoord;

@end