//
//  MapModel.h
//  Assignment2
//
//  Created by Igor Pchelko on 20/02/16.
//  Copyright © 2016 Igor Pchelko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface MapModel : NSObject

@property (strong, nonatomic) NSMutableArray *countryPolygones;

+ (instancetype) sharedInstance;
- (void) buildProjectionWithScale:(NSUInteger)scale;
- (CGSize) mapSize;
// This method implementation is naive iteration through all county polygons. It's not recommended to use it often.
- (NSString*) countryNameFromGeo:(CGPoint)geo;
- (BOOL) checkIfCountryName:(NSString*)countryName hasGeo:(CGPoint)geo;
- (CGPoint) projectionWithGeo:(CGPoint)geoCoord;

@end
