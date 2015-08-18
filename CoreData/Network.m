//
//  Network.m
//  CoreData
//
//  Created by Rostyslav Kobizsky on 8/18/15.
//  Copyright (c) 2015 Rostyslav Kobizsky. All rights reserved.
//

#import "Network.h"
#import "Country.h"
#import "NSManagedObjectContext+MainContext.h"
#import "Country+API.h"

static NSString *const kBaseURL = @"https://restcountries.eu/rest/v1";

@implementation Network

+ (instancetype)layer
{
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (void)getCountries:(void(^)(id result))completion {
    NSURL *url = [NSURL URLWithString:[kBaseURL stringByAppendingPathComponent:@"all"]];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSData *data = [NSData dataWithContentsOfURL:url];
        if (completion) {
            if (data.length) {
                NSError *error = nil;
                NSArray *objects = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
                if (!error) {
                    NSManagedObjectContext *context = [NSManagedObjectContext mainContext];
                    NSMutableArray *countries = [@[] mutableCopy];
                    for (NSDictionary *dictionary in objects) {
                        Country *country = [Country countryWithDictionary:dictionary inContext:context];
                        [countries addObject:country];
                    }
                    if (![context save:&error]) {
                        NSLog(@"%@", error);
                        dispatch_async(dispatch_get_main_queue(), ^{
                            completion(error);
                        });
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completion(countries);
                    });
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completion(error);
                    });
                }
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSError *error = [NSError errorWithDomain:@"com.CoreData.Network"
                                                         code:9999
                                                     userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"Data length is Zero", nil)}];
                    completion(error);
                });
            }
        }
    });
}

@end
