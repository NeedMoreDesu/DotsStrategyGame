//
//  SKDot.m
//  DotsVsDots
//
//  Created by baka on 4/1/14.
//  Copyright (c) 2014 baka. All rights reserved.
//

#import "SKDot.h"
#import "CoreData.h"
#import "DDot+custom.h"
#import "DGame+custom.h"
#import "MyScene.h"
#import "GameData.h"

@interface SKDot()

@property SKSpriteNode *dot;

@end

@implementation SKDot

-(void)changeAccordingToDDot:(DDot*)dot
{
    if ([self.game dotIsOccupied:dot]) {
        if (dot.belongsTo.shortValue == 0) {
            NSArray *textures = [GameData sharedInstance].blueDots;
            SKTexture *texture = textures[(dot.position.x.intValue+2*dot.position.y.intValue)
                                          %textures.count];
            self.dot.texture = texture;
            self.dot.size = self.dot.texture.size;
        }
        if (dot.belongsTo.shortValue == 1) {
            NSArray *textures = [GameData sharedInstance].redDots;
            SKTexture *texture = textures[(dot.position.x.intValue+2*dot.position.y.intValue)
                                          %textures.count];
            self.dot.texture = texture;
            self.dot.size = self.dot.texture.size;
        }
    }
    else
    {
        self.dot.texture = nil;
    }
}

-(void)makeTurn
{
    DDot *dot = [self.game makeTurn:self.point];
    [self changeAccordingToDDot:dot];
    [self.theScene redrawDots];
}

-(void)setPointX:(NSNumber*)x Y:(NSNumber*)y
{
    [self.point setX:x Y:y];
    self.position = CGPointMake(x.longLongValue*DOT_SIZE, y.longLongValue*DOT_SIZE);
    DDot *dot = [self.game dotWithPoint:self.point];

    NSArray *textures = [GameData sharedInstance].backgroundTextures;
    SKTexture *texture = textures[(self.point.x.intValue+2*self.point.y.intValue)
                                  % textures.count];
    self.texture = texture;
    self.size = self.texture.size;
    [self changeAccordingToDDot:dot];
}

-(instancetype)init
{
    self = [super init];
    if(self)
    {
        self.name = @"dot";
        self.dot = [[SKSpriteNode alloc] init];
        self.dot.zPosition = 10;
        [self addChild:self.dot];
        self.point = [DPoint temporaryObjectWithContext:[CoreData sharedInstance].mainMOC entity:nil];
    }
    return self;
}

@end
