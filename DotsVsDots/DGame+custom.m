//
//  DGame+custom.m
//  DotsVsDots
//
//  Created by baka on 3/30/14.
//  Copyright (c) 2014 baka. All rights reserved.
//

#import "DGame+custom.h"
#import "DBase+custom.h"

@implementation DGame (custom)

-(int)numberOfPlayers
{
    return 2;
}

-(DDot*)dotWithPoint:(DPoint*)point
{
    DGrid *lastGrid = self.grid;
    DDot *dot = [self.grid dotAtPoint:point lastGrid:&lastGrid];
    self.grid = lastGrid;
    return dot;
}

-(DDot*)getOrCreateDotWithPoint:(DPoint*)point
{
    DGrid *lastGrid = self.grid;
    DDot *dot = [self.grid getOrCreateDotAtPoint:point lastGrid:&lastGrid];
    self.grid = lastGrid;
    return dot;
}

-(BOOL)isOccupied:(DPoint*)point
{
    DDot *dot = [self dotWithPoint:point];
    return (dot != nil);
}

-(void)nextTurn
{
    self.turn = [NSNumber numberWithLong:self.turn.longValue+1];
    self.whoseTurn = [NSNumber numberWithShort:(self.whoseTurn.shortValue+1) % [self numberOfPlayers]];
}

-(DDot*)makeTurn:(DPoint*)point
{
    if([self isOccupied:point])
        return [self dotWithPoint:point];
    
    DDot *dot = [self getOrCreateDotWithPoint:point];
    
    dot.belongsTo = self.whoseTurn;
    dot.turn = self.turn;
    dot.date = [NSDate date];
    
    [self tryToCaptureWith:dot];
    
    [self nextTurn];
    
    return dot;
}

-(DBase*)tryToCaptureWith:(DDot*)startingDot
{
    __block NSMutableDictionary *pointToState = [NSMutableDictionary new];
    DPoint *point = [DPoint newObjectWithContext:self.managedObjectContext entity:nil];
    [point setWithPoint:startingDot.position];
    
    NSArray *movementArray = @[@[@-1, @-1],
                               @[@-1,@0],
                               @[@-1,@1],
                               @[@0 ,@1],
                               @[@1 ,@1],
                               @[@1 ,@0],
                               @[@1,@-1],
                               @[@0,@-1]];
    
    __block NSMutableArray *pathArray = [NSMutableArray new];

    __block __weak int(^weakDFS)(DPoint* point, int direction, NSNumber *lastState);
    __block int(^dfs)(DPoint* point, int direction, NSNumber *lastState) =
    ^(DPoint* point, int direction, NSNumber *lastState) {
        DDot *dot = [self dotWithPoint:point];
        if (!dot)
            return 0;
        if (dot.belongsTo.shortValue != startingDot.belongsTo.shortValue)
            return 0;
        NSNumber *state = pointToState[point.XY];
        if([state isEqual:@1])
        { // opened point
            return 0;
        }
        if([state isEqual:@2])
        { // closed point
            return 0;
        }
        if([state isEqual:@4] && [lastState isEqual:@3])
        { // central point from target point
            [pathArray addObject:dot.position.XY];
            return 1;
        }
        if ([state isEqual:@4])
        { // just hit central spot
            return 0;
        }
        if(!state || [state isEqual:@0])
        { // not visited
            pointToState[point.XY] = @1;
        }
        for(int i = 0; i < 8; i++)
        {
            int resultingDirection = (i + direction - 3 + 8) % 8;
            [point setXY: [dot.position addXY: movementArray[resultingDirection]]];
            
            int resultValue = weakDFS(point, resultingDirection, state);
            if (resultValue == 1) {
                [pathArray addObject:dot.position.XY];
                return 1;
            }
        }
    
        pointToState[@[point.x, point.y]] = @2;
        return 0;
    };
    weakDFS = dfs;
    
    NSArray *alliedDotsAroundArray =
    [movementArray map:^id(NSArray *XY) {
        [point setWithPoint:startingDot.position];
        [point setXY: [point addXY:XY]];
        DDot *dot = [self dotWithPoint: point];
        if (!dot)
            return [NSNull null];
        if (dot.belongsTo.shortValue != startingDot.belongsTo.shortValue)
            return [NSNull null];
        return dot.position.XY;
    }];
    
    NSMutableArray *groups = [NSMutableArray new];
    NSMutableArray *groupInitialVectors = [NSMutableArray new];
    NSMutableArray *group = [NSMutableArray new];
    for (int i = 0; i < 8; i++) {
        if (![alliedDotsAroundArray[i] isKindOfClass:[NSNull class]]) {
            if(group.count == 0)
                [groupInitialVectors addObject:[NSNumber numberWithChar:i]];
            [group addObject:alliedDotsAroundArray[i]];
        } else
        {
            if(i%2==0) continue;
            if(group.count > 0)
                [groups addObject:group];
            group = [NSMutableArray new];
        }
    }
    if(group.count > 0)
    {
        NSArray *firstGroup = groups.firstObject;
        if(firstGroup &&
           group.lastObject == alliedDotsAroundArray[7] &&
           (firstGroup.firstObject == alliedDotsAroundArray[0] ||
            firstGroup.firstObject == alliedDotsAroundArray[1]))
        {
            [group addObjectsFromArray:firstGroup];
            groups[0] = group;
            groupInitialVectors[0] = groupInitialVectors[groupInitialVectors.count-1];
            [groupInitialVectors removeLastObject];
        }
        else
        {
            [groups addObject:group];
        }
    }
    // Group creation finished
    
    if (groups.count < 2) {
        // need at least two separate groups to make a connection
        return nil;
    }
    
    int(^groupDFS)(NSUInteger idx) = ^(NSUInteger idx) {
        pointToState = [NSMutableDictionary new];
        pointToState[startingDot.position.XY] = @4;
        
        NSArray *group = groups[idx];
        [group enumerateObjectsUsingBlock:^(NSArray *XY, NSUInteger idx, BOOL *stop) {
            pointToState[XY] = @0;
        }];
        [groups enumerateObjectsUsingBlock:^(NSArray *targetGroup, NSUInteger idx, BOOL *stop) {
            if(targetGroup != group)
            {
                [targetGroup enumerateObjectsUsingBlock:^(NSArray *XY, NSUInteger idx, BOOL *stop) {
                    pointToState[XY] = @0;
                }];
                pointToState[targetGroup.lastObject] = @3; // rightmost
            }
        }];
        [point setXY:group.firstObject]; // leftmost
        NSNumber *initialVectorNum = groupInitialVectors[idx];
        return dfs(point, initialVectorNum.charValue, @0);
    };
    
    NSMutableArray *remainingGroups = [NSMutableArray arrayWithArray:groups];
    NSMutableArray *basesPaths = [NSMutableArray new];
    
    while (true) {
        __block BOOL wasStopped = NO;
        [remainingGroups enumerateObjectsUsingBlock:^(NSArray *group, NSUInteger idx, BOOL *stop) {
            if ([group isKindOfClass:[NSNull class]]) {
                return;
            }
            int result = groupDFS(idx);
            if (result != 0)
            {
                NSMutableArray *paths = [NSMutableArray new];
                while (true) {
                    [paths addObject:pathArray];
                    NSArray *lastTargetPoint = pathArray[1];
                    pathArray = [NSMutableArray new];
                    __block NSUInteger groupIndex;
                    [groups enumerateObjectsUsingBlock:^(NSArray *group, NSUInteger idx, BOOL *stop) {
                        if([group.lastObject isEqual:lastTargetPoint])
                        {
                            groupIndex = idx;
                            *stop = YES;
                        }
                    }];
                    if (groupIndex == idx) {
                        break;
                    }
                    result = groupDFS(groupIndex);
                    remainingGroups[groupIndex] = [NSNull null];
                }
                __block int maxPath = 0, maxPathIdx = 0;
                [paths enumerateObjectsUsingBlock:^(NSArray *path, NSUInteger idx, BOOL *stop) {
                    if (path.count > maxPath) {
                        maxPath = path.count;
                        maxPathIdx = idx;
                    }
                }];
                [basesPaths addObject:paths[maxPathIdx]];
                *stop = YES;
                wasStopped = YES;
            }
            remainingGroups[idx] = [NSNull null];
        }];
        if (!wasStopped)
        {
            break;
        }
    }
    
    NSLog(@"%@", basesPaths);
    
    [basesPaths mapWithBlockIndexed:^id(NSUInteger idx, NSArray *path) {
        DBase *base = [DBase newObjectWithContext:self.managedObjectContext entity:nil];
        [path enumerateObjectsUsingBlock:^(NSArray *XY, NSUInteger idx, BOOL *stop) {
            [point setXY:XY];
            DDot *dot = [self getOrCreateDotWithPoint:point];
            [base addOuterDotsObject:dot];
        }];
        return base;
    }];
    
//    for (int i = 0; i < 8; i++) {
//        if (((NSNumber*)alliedDotsAroundArray[i]).boolValue) {
//            int leftmostInThisGroup = i;
//            for (int j = 0; j < 8; j++) {
//                int idx = (i+j)%8;
//                if (!((NSNumber*)alliedDotsAroundArray[idx]).boolValue)
//                {
//                    if (idx%2 == 0) {
//                        continue;
//                    }
//                    break;
//                }
//                pointToState[[startingDot.position addXY: movementArray[idx]]] = @0;
//            }
//            for (int j = 0; j < 8; j++) {
//                int idx = (i-j+16)%8;
//                if (!((NSNumber*)alliedDotsAroundArray[idx]).boolValue)
//                {
//                    if (idx%2 == 0) {
//                        continue;
//                    }
//                    break;
//                }
//                leftmostInThisGroup = idx;
//                pointToState[[startingDot.position addXY: movementArray[idx]]] = @0;
//            }
//            for (int j = 0; j < 8; j++) {
//                int idx = (i+j)%8;
//                if(![pointToState[[startingDot.position addXY: movementArray[idx]]] isEqual: @0] &&
//                   ((NSNumber*)alliedDotsAroundArray[idx]).boolValue)
//                {
//                    pointToState[[startingDot.position addXY: movementArray[idx]]] = @3;
//                }
//            }
//            // at this point we have our set dot as 2, starting dots as 0, targets as 3
//            [point setWithPoint:startingDot.position];
//            [point setXY: [point addXY:movementArray[leftmostInThisGroup]]];
//            dfs(point, leftmostInThisGroup);
//        }
//    }

    point = nil;
    
    return nil;
}

-(void)awakeFromInsert
{
    self.isPlaying = @YES;
    self.turn = @0;
    self.whoseTurn = @0;
    self.grid = [DGrid newObjectWithContext:self.managedObjectContext entity:nil];
}

-(void)stop
{
    self.isPlaying = @NO;
}

@end
