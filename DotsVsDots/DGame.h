//
//  DGame.h
//  DotsStrategyGame
//
//  Created by baka on 5/9/14.
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
@property (nonatomic, retain) NSSet *lastDots;
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
- (void)addLastDotsObject:(DDot *)value;
- (void)removeLastDotsObject:(DDot *)value;
- (void)addLastDots:(NSSet *)values;
- (void)removeLastDots:(NSSet *)values;

@end
