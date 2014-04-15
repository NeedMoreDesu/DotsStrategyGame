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

- (void)addBasesObject:(DDot *)value;
{
    NSMutableOrderedSet* tempSet = [self mutableOrderedSetValueForKey:@"bases"];
    [tempSet addObject:value];
}

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

-(BOOL)dotIsCaptured:(DDot*)dot
{
    __block BOOL isCaptured = NO;
    [dot.baseAsInner enumerateObjectsUsingBlock:^(DBase *base, NSUInteger idx, BOOL *stop) {
        DDot *someDot = base.outerDots.firstObject;
        if([someDot.belongsTo isEqual:dot.belongsTo])
            return;
        if ([self dotIsCaptured:someDot]) {
            return;
        }
        if ([base.isCapturing isEqual:@YES]) {
            isCaptured = YES;
        }
    }];
    return isCaptured;
}

-(BOOL)pointIsCaptured:(DPoint*)point
{
    DDot *dot = [self dotWithPoint:point];
    return [self dotIsCaptured:dot];
}

-(BOOL)dotIsOccupied:(DDot*)dot
{
    return (dot != nil &&
            dot.belongsTo != nil);
}

-(BOOL)pointIsOccupied:(DPoint*)point
{
    DDot *dot = [self dotWithPoint:point];
    return [self dotIsOccupied:dot];
}

-(void)nextTurn
{
    self.turn = [NSNumber numberWithLong:self.turn.longValue+1];
    self.whoseTurn = [NSNumber numberWithShort:(self.whoseTurn.shortValue+1) % [self numberOfPlayers]];
}

-(NSArray*)capturingBases
{
    NSArray *capturingBases = [self.bases.array filter:^BOOL(NSUInteger idx, DBase *base) {
        return [[base isCapturing] isEqual:@YES];
    }];
    
    return capturingBases;
}

-(NSArray*)countCapturedDots
{
    NSArray *capturingBases = [self capturingBases];
    NSMutableArray *capturedDots = [NSMutableArray new];
    while (capturedDots.count < [self numberOfPlayers]) {
        [capturedDots addObject:[NSMutableSet new]];
    }
    [capturingBases enumerateObjectsUsingBlock:^(DBase *base, NSUInteger idx, BOOL *stop) {
        DDot *someDot = base.outerDots.firstObject;
        if([self dotIsCaptured:someDot])
            return;
        [base.innerDots enumerateObjectsUsingBlock:^(DDot *dot, NSUInteger idx, BOOL *stop) {
            if ([dot.belongsTo isEqual:someDot.belongsTo]) {
                return;
            }
            if (![self dotIsOccupied:dot]) {
                return;
            }
            NSMutableSet *captured = capturedDots[someDot.belongsTo.intValue];
            [captured addObject:dot];
        }];
    }];
    return capturedDots;
}

-(DDot*)makeTurn:(DPoint*)point
{
    if (![self.isPlaying isEqual:@YES]) {
        return [self dotWithPoint:point];
    }
    if([self pointIsOccupied:point])
        return [self dotWithPoint:point];

    if([self pointIsCaptured:point])
        return [self dotWithPoint:point];

    DDot *dot = [self getOrCreateDotWithPoint:point];
    
    dot.belongsTo = self.whoseTurn;
    dot.turn = self.turn;
    dot.date = [NSDate date];
    
    [self tryToCaptureWith:dot];
    
    [self nextTurn];
    
    NSArray *lastDots =
    [self.managedObjectContext
     fetchObjectsForEntityName:@"DDot"
     sortDescriptors:@[@[@"turn", @NO]]
     limit:[self numberOfPlayers]-1
     predicate:nil];
    
    [lastDots enumerateObjectsUsingBlock:^(DDot *dot, NSUInteger idx, BOOL *stop) {
        [dot.baseAsInner enumerateObjectsUsingBlock:^(DBase *base, NSUInteger idx, BOOL *stop) {
            DDot *firstDot = base.outerDots.firstObject;
            if (firstDot.belongsTo != self.whoseTurn) {
                return;
            }
            base.isCapturing = @YES;
        }];
    }];
    
    return dot;
}

-(void)tryToCaptureWith:(DDot*)startingDot
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
        if ([self pointIsCaptured:dot.position]) {
            return 0;
        }
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
        if([lastState isEqual:@3])
        { // there is only one way out from target point
            return 0;
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
        return;
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
    
    [basesPaths mapWithBlockIndexed:^id(NSUInteger idx, NSArray *path) {
        DBase *base = [DBase newObjectWithContext:self.managedObjectContext entity:nil];
        [self addBasesObject:base];
        NSMutableSet *pathPoints = [NSMutableSet new];
        NSArray *XY = path.firstObject;
        NSNumber *x = XY[0], *y = XY[1];
        __block long long
        left = x.longLongValue, right = x.longLongValue,
        top = y.longLongValue, bottom = y.longLongValue;
        NSMutableDictionary *nextPointDictionary = [NSMutableDictionary new];
        __block NSArray *lastXY, *firstXY;
        [path enumerateObjectsUsingBlock:^(NSArray *XY, NSUInteger idx, BOOL *stop) {
            [point setXY:XY];
            DDot *dot = [self dotWithPoint:point];
            [base addOuterDotsObject:dot];
            NSNumber *x = XY[0], *y = XY[1];
            long long xll = x.longLongValue, yll = y.longLongValue;
            if (xll < left) {
                left = xll;
            }
            if (right < xll) {
                right = xll;
            }
            if (yll < bottom) {
                bottom = yll;
            }
            if (top < yll) {
                top = yll;
            }
            [pathPoints addObject:XY];
            if (lastXY) {
                nextPointDictionary[lastXY] = XY;
            } else
            {
                firstXY = XY;
            }
            lastXY = XY;
        }];
        nextPointDictionary[lastXY] = firstXY;
        
        NSMutableSet *innerDots = [NSMutableSet new];
        
        __block int(^weakGetInnerDots)(NSArray *XY, int direction);
        __block int(^getInnerDots)(NSArray *XY, int direction) = ^(NSArray *XY, int direction) {
            if ([pathPoints containsObject:XY]) {
                return 0;
            }
            if ([innerDots containsObject:XY]) {
                return 0;
            }
            NSNumber *x = XY[0], *y = XY[1];
            long long xll = x.longLongValue, yll = y.longLongValue;
            // if it is out of range of max points, then it is clearly not inside
            if (xll < left) {
                return 1;
            }
            if (right < xll) {
                return 1;
            }
            if (yll < bottom) {
                return 1;
            }
            if (top < yll) {
                return 1;
            }
            [innerDots addObject:XY];
            for(int i = 0; i < 8; i++)
            {
                int resultingDirection = (i + direction) % 8;
                if (resultingDirection%2 == 0) {
                    NSArray *moveXY1 = movementArray[(resultingDirection-1+8)%8];
                    NSArray *moveXY2 = movementArray[(resultingDirection+1+8)%8];
                    NSArray *currXY1 = [[point setXY:XY] addXY:moveXY1];
                    NSArray *currXY2 = [[point setXY:XY] addXY:moveXY2];
                    if([pathPoints containsObject:currXY1] &&
                       [pathPoints containsObject:currXY2] &&
                       ([nextPointDictionary[currXY1] isEqual: currXY2] ||
                        [nextPointDictionary[currXY2] isEqual: currXY1]))
                    {  // no diagonal fall-through
                        continue;
                    }
                }
                NSArray *moveXY = movementArray[resultingDirection];
                NSArray *currXY = [[point setXY:XY] addXY:moveXY];
                
                int resultValue = weakGetInnerDots(currXY, resultingDirection);
                if (resultValue == 1) {
                    return 1;
                }
            }
            return 0;
        };
        weakGetInnerDots = getInnerDots;
        for(int i = 0; i < 8; i++)
        {
            NSArray *moveXY = movementArray[i];
            NSArray *currXY = [[point setXY:XY] addXY:moveXY];
            if ([pathPoints containsObject:currXY]) {
                continue;
            }

            int resultValue = getInnerDots(currXY, i);
            if (resultValue == 0) {
                break;
            }
            [innerDots removeAllObjects];
        }
        [innerDots enumerateObjectsUsingBlock:^(NSArray *XY, BOOL *stop) {
            [point setXY:XY];
            DDot *dot = [self getOrCreateDotWithPoint:point];
            if (dot.belongsTo != nil &&
                ![self dotIsCaptured:dot]) {
                base.isCapturing = @YES;
            }
            [dot.baseAsInner enumerateObjectsUsingBlock:^(DBase *base, NSUInteger idx, BOOL *stop) {
                if (!base.isCapturing) {
                    // there can't be any sort of wannabe-bases inside our base
                    [self.managedObjectContext deleteObject:base];
                }
            }];
            [dot.baseAsOuter enumerateObjectsUsingBlock:^(DBase *base, NSUInteger idx, BOOL *stop) {
                if (!base.isCapturing) {
                    // kill non-capturing bases with fire
                    [self.managedObjectContext deleteObject:base];
                }
            }];
            [base addInnerDotsObject:dot];
        }];
        return base;
    }];
    
    point = nil;
}

-(void)setup
{
    self.isPlaying = @YES;
    self.turn = @0;
    self.whoseTurn = @0;
    self.grid = [DGrid newObjectWithContext:self.managedObjectContext entity:nil];
    [self.grid setup];
}

-(BOOL)stopWhenTurn:(int)turn orNumberOfCapturedDotsExceeds:(int)capturedDotsFromSinglePlayer
{
    NSArray *capturedDots = [self countCapturedDots];
    int idx = 0;
    for (NSSet *dots in capturedDots) {
        if(capturedDotsFromSinglePlayer <= dots.count)
        {
            self.isPlaying = @NO;
            self.whoseTurn = [NSNumber numberWithShort:idx];
            return YES;
        }
        idx++;
    }
    
    if (turn <= self.turn.intValue) {
        self.isPlaying = @NO;
        int maxCapturedDots = 0;
        for (NSSet *dots in capturedDots) {
            if(maxCapturedDots < dots.count)
            {
                maxCapturedDots = dots.count;
                self.whoseTurn = [NSNumber numberWithShort:idx];
            }
            if (maxCapturedDots == dots.count) {
                self.whoseTurn = nil;
            }
            idx++;
        }
        return YES;
    }
    
    return NO;
}

@end
