//
//  DBase+custom.m
//  DotsStrategyGame
//
//  Created by baka on 4/10/14.
//  Copyright (c) 2014 baka. All rights reserved.
//

#import "DBase+custom.h"

@implementation DBase (custom)

- (void)addInnerDotsObject:(DDot *)value;
{
    NSMutableOrderedSet* tempSet = [self mutableOrderedSetValueForKey:@"innerDots"];
    [tempSet addObject:value];
}

- (void)addOuterDotsObject:(DDot *)value;
{
    NSMutableOrderedSet* tempSet = [self mutableOrderedSetValueForKey:@"outerDots"];
    [tempSet addObject:value];
}

@end
