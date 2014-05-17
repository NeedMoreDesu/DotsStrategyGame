//
//  DGame.h
//  DotsStrategyGame
//
//  Created by cirno on 5/17/14.
//  Copyright (c) 2014 baka. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DBase, DDot, DGrid;

@interface DGame : NSManagedObject

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSNumber * isPlaying;
@property (nonatomic, retain) NSNumber * turn;
@property (nonatomic, retain) NSNumber * whoseTurn;
@property (nonatomic, retain) NSOrderedSet *bases;
@property (nonatomic, retain) DGrid *grid;
@property (nonatomic, retain) NSOrderedSet *dots;
@end

@interface DGame (CoreDataGeneratedAccessors)

- (void)insertObject:(DBase *)value inBasesAtIndex:(NSUInteger)idx;
- (void)removeObjectFromBasesAtIndex:(NSUInteger)idx;
- (void)insertBases:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeBasesAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInBasesAtIndex:(NSUInteger)idx withObject:(DBase *)value;
- (void)replaceBasesAtIndexes:(NSIndexSet *)indexes withBases:(NSArray *)values;
- (void)addBasesObject:(DBase *)value;
- (void)removeBasesObject:(DBase *)value;
- (void)addBases:(NSOrderedSet *)values;
- (void)removeBases:(NSOrderedSet *)values;
- (void)insertObject:(DDot *)value inDotsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromDotsAtIndex:(NSUInteger)idx;
- (void)insertDots:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeDotsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInDotsAtIndex:(NSUInteger)idx withObject:(DDot *)value;
- (void)replaceDotsAtIndexes:(NSIndexSet *)indexes withDots:(NSArray *)values;
- (void)addDotsObject:(DDot *)value;
- (void)removeDotsObject:(DDot *)value;
- (void)addDots:(NSOrderedSet *)values;
- (void)removeDots:(NSOrderedSet *)values;
@end
