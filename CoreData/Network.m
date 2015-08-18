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
#import <RestKit/RestKit.h>

static NSString *const kBaseURL = @"https://restcountries.eu/rest/v1";

@interface Network ()

@property (nonatomic, strong) RKObjectManager *manager;

@end

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

- (RKObjectManager *)manager {
    if (!_manager) {
        _manager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:kBaseURL]];
        _manager.managedObjectStore = [RKManagedObjectStore defaultStore];
        _manager.requestSerializationMIMEType = RKMIMETypeJSON;
        [self setupDescriptors];
    }
    return _manager;
}

static NSString *const kGetCountriesPath = @"all";

- (void)setupDescriptors {
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor
                                                responseDescriptorWithMapping:[Country mappingInStore:[RKManagedObjectStore defaultStore]]
                                                                                            method:RKRequestMethodGET
                                                                                       pathPattern:kGetCountriesPath
                                                                                           keyPath:nil
                                                statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [self.manager addResponseDescriptor:responseDescriptor];
}

- (void)getCountries:(void(^)(id result))completion
{
    [self.manager getObjectsAtPath:kGetCountriesPath parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        if (completion) {
            completion(mappingResult.array);
        }
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        if (completion) {
            completion(error);
        }
    }];
}

@end
