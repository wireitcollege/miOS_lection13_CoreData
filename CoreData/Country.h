//
//  Country.h
//  CoreData
//
//  Created by Rostyslav Kobizsky on 8/13/15.
//  Copyright (c) 2015 Rostyslav Kobizsky. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Country : NSManagedObject

@property (nonatomic, retain) NSString * capital;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * population;
@property (nonatomic, retain) NSString * region;
@property (nonatomic, retain) NSString * subregion;
@property (nonatomic, retain) NSNumber * area;
@property (nonatomic, retain) NSString * alpha2Code;

@end
