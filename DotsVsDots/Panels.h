//
//  Panels.h
//  DotsStrategyGame
//
//  Created by baka on 4/14/14.
//  Copyright (c) 2014 baka. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "DGame+custom.h"

@interface Panels : SKNode

-(void)updateScores;
-(instancetype)init;

@property BOOL historyActive;
@property BOOL optionsActive;

@property SKSpriteNode *panels;
@property SKSpriteNode *history;
@property SKSpriteNode *options;

@end
