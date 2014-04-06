//
//  SKDot.h
//  DotsVsDots
//
//  Created by baka on 4/1/14.
//  Copyright (c) 2014 baka. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "DPoint+custom.h"
#import "DGame+custom.h"

@interface SKDot : SKSpriteNode

-(instancetype)init;

-(void)setPointX:(NSNumber*)x Y:(NSNumber*)y;
-(void)makeTurn;

@property DGame *game;
@property (nonatomic, strong) DPoint *point;

@end
