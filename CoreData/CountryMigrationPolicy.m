//
//  CountryMigrationPolicy.m
//  CoreData
//
//  Created by Rostyslav Kobizsky on 8/13/15.
//  Copyright (c) 2015 Rostyslav Kobizsky. All rights reserved.
//

#import "CountryMigrationPolicy.h"
#import "Country.h"
#import "Region.h"

@implementation CountryMigrationPolicy

- (BOOL)beginEntityMapping:(NSEntityMapping *)mapping manager:(NSMigrationManager *)manager error:(NSError *__autoreleasing *)error {
    
    NSMutableDictionary *userInfo = [@{} mutableCopy];
    userInfo[@"regions"] = [@{} mutableCopy];
    manager.userInfo = userInfo;
    
    return YES;
}

- (BOOL)createDestinationInstancesForSourceInstance:(Country *)sCountry
                                      entityMapping:(NSEntityMapping *)mapping
                                            manager:(NSMigrationManager *)manager
                                              error:(NSError *__autoreleasing *)error
{
    NSManagedObjectContext *destinationContext = [manager destinationContext];
    NSString *destinationEntityName = [mapping destinationEntityName];
    
    Country *dCountry = [NSEntityDescription insertNewObjectForEntityForName:destinationEntityName
                                                      inManagedObjectContext:destinationContext];
    
    dCountry.name       = sCountry.name;
    dCountry.capital    = sCountry.capital;
    dCountry.latitude   = sCountry.latitude;
    dCountry.longitude  = sCountry.longitude;
    dCountry.population = sCountry.population;
    
    NSString *regionName = [sCountry valueForKey:@"region"];
    
    NSMutableDictionary *regions = manager.userInfo[@"regions"];
    
    Region *region = regions[regionName];
    if (!region) {
        region = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([Region class])
                                               inManagedObjectContext:destinationContext];
        region.name = regionName;
        regions[regionName] = region;
    }
    
    dCountry.region = region;
    
    [manager associateSourceInstance:sCountry
             withDestinationInstance:dCountry
                    forEntityMapping:mapping];

    return YES;
}

@end
