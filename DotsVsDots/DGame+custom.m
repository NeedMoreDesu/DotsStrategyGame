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
    return ([self dotWithPoint:point] != nil);
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
    dot.date = [NSDate date];
    
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
