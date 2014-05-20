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
#import "MyScene.h"

@interface SKDot : SKSpriteNode

-(instancetype)init;

-(void)setPointX:(NSNumber*)x Y:(NSNumber*)y;
-(void)makeTurn;

-(void)highlight;
-(void)shadow;
-(void)restore;
+(void)highlight:(SKNode*)node;
+(void)shadow:(SKNode*)node;
+(void)restore:(SKNode*)node;

@property DGame *game;
@property MyScene *theScene;
@property (nonatomic, strong) DPoint *point;

@end
