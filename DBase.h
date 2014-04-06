//
//  DBase.h
//  DotsStrategyGame
//
//  Created by baka on 4/6/14.
//  Copyright (c) 2014 baka. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DDot;

@interface DBase : NSManagedObject

@property (nonatomic, retain) NSOrderedSet *outerDots;
@property (nonatomic, retain) NSSet *innerDots;
@end

@interface DBase (CoreDataGeneratedAccessors)

- (void)insertObject:(DDot *)value inOuterDotsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromOuterDotsAtIndex:(NSUInteger)idx;
- (void)insertOuterDots:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeOuterDotsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInOuterDotsAtIndex:(NSUInteger)idx withObject:(DDot *)value;
- (void)replaceOuterDotsAtIndexes:(NSIndexSet *)indexes withOuterDots:(NSArray *)values;
- (void)addOuterDotsObject:(DDot *)value;
- (void)removeOuterDotsObject:(DDot *)value;
- (void)addOuterDots:(NSOrderedSet *)values;
- (void)removeOuterDots:(NSOrderedSet *)values;
- (void)addInnerDotsObject:(DDot *)value;
- (void)removeInnerDotsObject:(DDot *)value;
- (void)addInnerDots:(NSSet *)values;
- (void)removeInnerDots:(NSSet *)values;

@end
