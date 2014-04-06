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
        NSNumber *state = pointToState[@[point.x, point.y]];
        if([state isEqual:@1])
        {
            if(dot == startingDot)
            {
                return 1;
            }
            return 0;
        }
        if([state isEqual:@2])
        {   // shouldn't happen
            return 0;
        }
        if(!state) pointToState[@[point.x, point.y]] = @1;
        for(int i = 0; i < 8; i++)
        {
            int resultingDirection = (i + direction - 3 + 8) % 8;
            int restrictedDirection = (direction + 4) % 8;
            if (restrictedDirection == resultingDirection) continue;
            NSNumber *directionX = movementArray[resultingDirection][0];
            NSNumber *directionY = movementArray[resultingDirection][1];
            NSNumber *originalX  = dot.position.x;
            NSNumber *originalY  = dot.position.y;
            NSNumber *x = [NSNumber numberWithLongLong:
                           originalX.longLongValue
                           + directionX.longLongValue];
            NSNumber *y = [NSNumber numberWithLongLong:
                           originalY.longLongValue
                           + directionY.longLongValue];
            point.x = x;
            point.y = y;
            
            int resultValue = dfs(point, resultingDirection);
            if (resultValue == 1) {
                return 1;
            }
        }
    
        pointToState[@[point.x, point.y]] = @2;
        return 0;
    };
    
    dfs(point, 0);
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
