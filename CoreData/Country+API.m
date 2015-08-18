//
//  Country+API.m
//  CoreData
//
//  Created by Rostyslav Kobizsky on 8/11/15.
//  Copyright (c) 2015 Rostyslav Kobizsky. All rights reserved.
//

#import "Country+API.h"
#import "NSManagedObject+ActiveRecord.h"
#import <RestKit/CoreData.h>

@implementation Country (API)

+ (Country *)countryWithDictionary:(NSDictionary *)dictionary
                         inContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([self class])];
    NSString *name = dictionary[@"name"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name == %@", name];
    request.predicate = predicate;
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
    NSError *error;
    NSArray *results = [context executeFetchRequest:request error:&error];

    if (error) {
        return nil;
    }
    
    Country *country = results.firstObject;
    if (!country) {
        country = [NSEntityDescription insertNewObjectForEntityForName:@"Country"
                                                inManagedObjectContext:context];
        country.name = name;
    }
    
    country.capital = dictionary[@"capital"];
    NSString *regionName = dictionary[@"region"];
    country.region = [Region findFirstByAttribute:@"name" withValue:regionName inContext:context];
    country.population = dictionary[@"population"];
    country.area = dictionary[@"area"];
    country.subregion = dictionary[@"subregion"];
    country.alpha2Code = dictionary[@"alpha2Code"];
    
    
    NSArray *latlng = dictionary[@"latlng"];
    if (latlng.count == 2) {
        country.latitude = latlng.firstObject;
        country.longitude = latlng.lastObject;
    }
    
    return country;
}

+ (RKEntityMapping *)mappingInStore:(RKManagedObjectStore *)store {
    RKEntityMapping *mapping = [RKEntityMapping mappingForEntityForName:NSStringFromClass([self class]) inManagedObjectStore:store];
    
    [mapping addAttributeMappingsFromDictionary: @{@"name": @"name",
                                                   @"capital": @"capital",
                                                   @"population": @"population",
                                                   @"area": @"area",
                                                   @"subregion": @"subregion",
                                                   @"alpha2Code": @"alpha2Code"
                                                   }];
    [mapping setIdentificationAttributes:@[@"name"]];
    return mapping;
}

@end
