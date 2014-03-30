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

-(BOOL)isOccupied:(DPoint*)point
{
    DGrid *lastGrid = self.grid;
    BOOL occupied = [self.grid dotAtPoint:point lastGrid:&lastGrid] != nil;
    self.grid = lastGrid;
    return occupied;
}

-(void)nextTurn
{
    self.turn = [NSNumber numberWithLong:self.turn.longValue+1];
    self.whoseTurn = [NSNumber numberWithShort:(self.whoseTurn.shortValue+1) % [self numberOfPlayers]];
}

-(DDot*)makeTurn:(DPoint*)point
{
    if([self isOccupied:point])
        return nil;
    DGrid *lastGrid = self.grid;
    DDot *dot = [self.grid getOrCreateDotAtPoint:point lastGrid:&lastGrid];
    self.grid = lastGrid;
    dot.belongsTo = self.whoseTurn;
    dot.turn = self.turn;
    [self nextTurn];
    
    return dot;
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
