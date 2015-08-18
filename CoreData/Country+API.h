//
//  Country+API.h
//  CoreData
//
//  Created by Rostyslav Kobizsky on 8/11/15.
//  Copyright (c) 2015 Rostyslav Kobizsky. All rights reserved.
//

#import "Country.h"

@class RKEntityMapping;
@class RKManagedObjectStore;

@interface Country (API)

+ (Country *)countryWithDictionary:(NSDictionary *)dictionary
                         inContext:(NSManagedObjectContext *)context;
+ (RKEntityMapping *)mappingInStore:(RKManagedObjectStore *)store;

@end
