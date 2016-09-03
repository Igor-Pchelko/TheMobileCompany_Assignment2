//
//  MapModel.m
//  Assignment2
//
//  Created by Igor Pchelko on 20/02/16.
//  Copyright © 2016 Igor Pchelko. All rights reserved.
//

#import "MapModel.h"
#import "CountryPolygon.h"
#import "MercatorProjection.h"

@interface MapModel()

@property (strong, nonatomic) id<MapProjection> mapProjection;

@end

@implementation MapModel


+ (instancetype)sharedInstance
{
    static MapModel *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}


- (instancetype)init
{
    self = [super init];
    
    if (self != nil)
    {
        self.countryPolygones = [NSMutableArray arrayWithCapacity:10];
        self.mapProjection = [[MercatorProjection alloc] init];
        [self readFromJsonFile];
    }
    
    return self;
}

- (void)readFromJsonFile
{
    [self.countryPolygones removeAllObjects];
    
    NSString* path = [[NSBundle mainBundle] pathForResource:@"countries"
                                                     ofType:@"json"];
 
    NSError *error = nil;

    NSInputStream *inputStream = [[NSInputStream alloc] initWithFileAtPath:path];
    [inputStream open];
    id jsonObject = [NSJSONSerialization JSONObjectWithStream:inputStream
                                                      options:0
                                                        error:&error];
    [inputStream close];
    
    NSArray *features = [jsonObject valueForKeyPath:@"features"];
    
    for (id feature in features)
    {
        NSString *countryName = [feature valueForKeyPath:@"properties.name"];
        id geometry = [feature valueForKey:@"geometry"];
        id geometryType = [geometry valueForKey:@"type"];
        
        if ([geometryType isEqualToString:@"Polygon"])
        {
            id geometryCoordinates = [geometry valueForKey:@"coordinates"];

            for (id coordinates in geometryCoordinates)
            {
                CountryPolygon *countryPolygon = [[CountryPolygon alloc] initWithCountryName:countryName coordinates:coordinates];
                [self.countryPolygones addObject:countryPolygon];
            }
        }
        else if ([geometryType isEqualToString:@"MultiPolygon"])
        {
            id geometryCoordinates = [geometry valueForKey:@"coordinates"];
            
            for (id coordinatesLevel0 in geometryCoordinates)
            {
                for (id coordinatesLevel1 in coordinatesLevel0)
                {
                    CountryPolygon *countryPolygon = [[CountryPolygon alloc] initWithCountryName:countryName coordinates:coordinatesLevel1];
                    [self.countryPolygones addObject:countryPolygon];
                }
            }
        }
        else
        {
            NSLog(@"Unsupported geometryType: %@", geometryType);
        }
    }
}

- (void)buildProjectionWithScale:(NSUInteger)scale
{
    [self.mapProjection setupProjectionWithScale:scale];
    
    for (CountryPolygon *countryPolygon in self.countryPolygones)
    {
        [countryPolygon buildPathWithMapProjection:self.mapProjection];
    }
}

- (CGSize)mapSize
{
    return [self.mapProjection getProjectionSize];
}

- (NSString*)countryNameFromGeo:(CGPoint)geoCoord
{
    for (CountryPolygon *countryPolygon in self.countryPolygones)
    {
        if ([countryPolygon pathContainsCoordinate:geoCoord])
        {
            return countryPolygon.countryName;
        }
    }
    
    return @"Unknown";
}

- (BOOL)checkIfCountryName:(NSString*)countryName hasGeo:(CGPoint)geoCoord
{
    for (CountryPolygon *countryPolygon in self.countryPolygones)
    {
        if ([countryPolygon.countryName isEqualToString:countryName]
            && [countryPolygon pathContainsCoordinate:geoCoord])
        {
            return YES;
        }
    }
    
    return NO;
}

- (CGPoint) projectionWithGeo:(CGPoint)geoCoord
{
    return [self.mapProjection projectionWithGeo:geoCoord];
}

@end
