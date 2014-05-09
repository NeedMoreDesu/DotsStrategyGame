//
//  DDot.h
//  DotsStrategyGame
//
//  Created by baka on 5/9/14.
//  Copyright (c) 2014 baka. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DBase, DGame, DGrid, DPoint;

@interface DDot : NSManagedObject

@property (nonatomic, retain) NSNumber * belongsTo;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSNumber * turn;
@property (nonatomic, retain) NSOrderedSet *baseAsInner;
@property (nonatomic, retain) NSOrderedSet *baseAsOuter;
@property (nonatomic, retain) DGrid *grid;
@property (nonatomic, retain) DPoint *position;
@property (nonatomic, retain) DGame *lastDotsInverse;
@end

@interface DDot (CoreDataGeneratedAccessors)

- (void)insertObject:(DBase *)value inBaseAsInnerAtIndex:(NSUInteger)idx;
- (void)removeObjectFromBaseAsInnerAtIndex:(NSUInteger)idx;
- (void)insertBaseAsInner:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeBaseAsInnerAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInBaseAsInnerAtIndex:(NSUInteger)idx withObject:(DBase *)value;
- (void)replaceBaseAsInnerAtIndexes:(NSIndexSet *)indexes withBaseAsInner:(NSArray *)values;
- (void)addBaseAsInnerObject:(DBase *)value;
- (void)removeBaseAsInnerObject:(DBase *)value;
- (void)addBaseAsInner:(NSOrderedSet *)values;
- (void)removeBaseAsInner:(NSOrderedSet *)values;
- (void)insertObject:(DBase *)value inBaseAsOuterAtIndex:(NSUInteger)idx;
- (void)removeObjectFromBaseAsOuterAtIndex:(NSUInteger)idx;
- (void)insertBaseAsOuter:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeBaseAsOuterAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInBaseAsOuterAtIndex:(NSUInteger)idx withObject:(DBase *)value;
- (void)replaceBaseAsOuterAtIndexes:(NSIndexSet *)indexes withBaseAsOuter:(NSArray *)values;
- (void)addBaseAsOuterObject:(DBase *)value;
- (void)removeBaseAsOuterObject:(DBase *)value;
- (void)addBaseAsOuter:(NSOrderedSet *)values;
- (void)removeBaseAsOuter:(NSOrderedSet *)values;
@end
