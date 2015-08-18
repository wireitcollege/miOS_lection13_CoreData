//
//  Network.h
//  CoreData
//
//  Created by Rostyslav Kobizsky on 8/18/15.
//  Copyright (c) 2015 Rostyslav Kobizsky. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Network : NSObject

+ (instancetype)layer;
- (void)getCountries:(void(^)(id result))completion;

@end
