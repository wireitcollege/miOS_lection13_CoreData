//
//  NSManagedObjectContext+MainContext.m
//  CoreData
//
//  Created by Rostyslav Kobizsky on 8/18/15.
//  Copyright (c) 2015 Rostyslav Kobizsky. All rights reserved.
//

#import "NSManagedObjectContext+MainContext.h"
#import "AppDelegate.h"

@implementation NSManagedObjectContext (MainContext)

+ (NSManagedObjectContext *)mainContext {
    return [(AppDelegate *)[UIApplication sharedApplication].delegate managedObjectContext];
}

@end
