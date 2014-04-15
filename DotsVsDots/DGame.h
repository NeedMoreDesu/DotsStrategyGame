//
//  DGame.h
//  DotsStrategyGame
//
//  Created by dev on 4/15/14.
//  Copyright (c) 2014 baka. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DBase, DGrid;

@interface DGame : NSManagedObject

@property (nonatomic, retain) NSNumber * isPlaying;
@property (nonatomic, retain) NSNumber * turn;
@property (nonatomic, retain) NSNumber * whoseTurn;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSOrderedSet *bases;
@property (nonatomic, retain) DGrid *grid;
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
@end
