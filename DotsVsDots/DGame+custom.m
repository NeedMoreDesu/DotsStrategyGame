//
//  DGame+custom.m
//  DotsVsDots
//
//  Created by baka on 3/30/14.
//  Copyright (c) 2014 baka. All rights reserved.
//

#import "DGame+custom.h"

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
    DGrid *lastGrid = self.grid;
    DDot *dot = [self.grid getOrCreateDotAtPoint:point lastGrid:&lastGrid];
    self.grid = lastGrid;
    
    dot.belongsTo = self.whoseTurn;
    dot.turn = self.turn;
    dot.date = [NSDate date];
    
    [self tryToCaptureWith:dot];
    
    [self nextTurn];
    
    return dot;
}

-(DBase*)tryToCaptureWith:(DDot*)startingDot
{
    NSMutableDictionary *pointToState = [NSMutableDictionary new];
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
    
    NSMutableArray *pathArray = [NSMutableArray new];
    
    __block int(^dfs)(DPoint* point, int direction) = ^(DPoint* point, int direction) {
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
        if([state isEqual:@3])
        { // target point
            return 1;
        }
        if(!state || [state isEqual:@0])
        { // not visited
            pointToState[point.XY] = @1;
        }
        for(int i = 0; i < 8; i++)
        {
            int resultingDirection = (i + direction - 3 + 8) % 8;
//            int restrictedDirection = (direction + 4) % 8;
//            if (restrictedDirection == resultingDirection) continue;
            [point setXY: [dot.position addXY: movementArray[resultingDirection]]];
            
            int resultValue = dfs(point, resultingDirection);
            if (resultValue == 1) {
                return 1;
            }
        }
    
        pointToState[@[point.x, point.y]] = @2;
        return 0;
    };
    
    pointToState[startingDot.position.XY] = @2;
    
    NSArray *alliedDotsAroundArray =
    [movementArray map:^id(NSArray *XY) {
        [point setWithPoint:startingDot.position];
        [point setXY: [point addXY:XY]];
        DDot *dot = [self dotWithPoint: point];
        if (!dot)
            return @NO;
        if (dot.belongsTo.shortValue != startingDot.belongsTo.shortValue)
            return @NO;
        return @YES;
    }];
    
    for (int i = 0; i < 8; i++) {
        if (((NSNumber*)alliedDotsAroundArray[i]).boolValue) {
            int leftmostInThisGroup = i;
            for (int j = 0; j < 8; j++) {
                int idx = (i+j)%8;
                if (!((NSNumber*)alliedDotsAroundArray[idx]).boolValue)
                {
                    if (idx%2 == 0) {
                        continue;
                    }
                    break;
                }
                pointToState[[startingDot.position addXY: movementArray[idx]]] = @0;
            }
            for (int j = 0; j < 8; j++) {
                int idx = (i-j+16)%8;
                if (!((NSNumber*)alliedDotsAroundArray[idx]).boolValue)
                {
                    if (idx%2 == 0) {
                        continue;
                    }
                    break;
                }
                leftmostInThisGroup = idx;
                pointToState[[startingDot.position addXY: movementArray[idx]]] = @0;
            }
            for (int j = 0; j < 8; j++) {
                int idx = (i+j)%8;
                if(![pointToState[[startingDot.position addXY: movementArray[idx]]] isEqual: @0] &&
                   ((NSNumber*)alliedDotsAroundArray[idx]).boolValue)
                {
                    pointToState[[startingDot.position addXY: movementArray[idx]]] = @3;
                }
            }
            // at this point we have our set dot as 2, starting dots as 0, targets as 3
            [point setWithPoint:startingDot.position];
            [point setXY: [point addXY:movementArray[leftmostInThisGroup]]];
            dfs(point, leftmostInThisGroup);
        }
    }

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
