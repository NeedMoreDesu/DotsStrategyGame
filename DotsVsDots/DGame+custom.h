//
//  DGame+custom.h
//  DotsVsDots
//
//  Created by baka on 3/30/14.
//  Copyright (c) 2014 baka. All rights reserved.
//

#import "DGame.h"
#import "DGrid+custom.h"
#import "DPoint+custom.h"
#import "DDot+custom.h"

@interface DGame (custom)

-(void)setup;

-(DDot*)dotWithPoint:(DPoint*)point;

-(BOOL)dotIsCaptured:(DDot*)dot;
-(BOOL)pointIsCaptured:(DPoint*)point;
-(BOOL)dotIsOccupied:(DDot*)dot;
-(BOOL)pointIsOccupied:(DPoint*)point;

-(DDot*)makeTurn:(DPoint*)point;
-(NSArray*)capturingBases;
-(NSArray*)countCapturedDots;
-(int)numberOfPlayers;

-(void)surrender;
-(void)offerADraw;
-(DGame*)gameByCopyingTurns:(int)turn;

-(BOOL)stopWhenTurn:(int)turn orNumberOfCapturedDotsExceeds:(int)capturedDotsFromSinglePlayer;

@end
