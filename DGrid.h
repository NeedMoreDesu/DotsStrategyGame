//
//  DGrid.h
//  DotsStrategyGame
//
//  Created by baka on 4/6/14.
//  Copyright (c) 2014 baka. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DDot, DGame, DGrid, DPoint;

@interface DGrid : NSManagedObject

@property (nonatomic, retain) NSNumber * level;
@property (nonatomic, retain) DPoint *center;
@property (nonatomic, retain) NSOrderedSet *children;
@property (nonatomic, retain) DDot *dot;
@property (nonatomic, retain) DGame *game;
@property (nonatomic, retain) DGrid *root;
@end

@interface DGrid (CoreDataGeneratedAccessors)

- (void)insertObject:(DGrid *)value inChildrenAtIndex:(NSUInteger)idx;
- (void)removeObjectFromChildrenAtIndex:(NSUInteger)idx;
- (void)insertChildren:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeChildrenAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInChildrenAtIndex:(NSUInteger)idx withObject:(DGrid *)value;
- (void)replaceChildrenAtIndexes:(NSIndexSet *)indexes withChildren:(NSArray *)values;
- (void)addChildrenObject:(DGrid *)value;
- (void)removeChildrenObject:(DGrid *)value;
- (void)addChildren:(NSOrderedSet *)values;
- (void)removeChildren:(NSOrderedSet *)values;
@end
