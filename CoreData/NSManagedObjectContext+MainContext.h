//
//  NSManagedObjectContext+MainContext.h
//  CoreData
//
//  Created by Rostyslav Kobizsky on 8/18/15.
//  Copyright (c) 2015 Rostyslav Kobizsky. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObjectContext (MainContext)

+ (NSManagedObjectContext *)mainContext;

@end
