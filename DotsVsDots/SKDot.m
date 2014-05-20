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

+(void)restore:(SKNode*)node
{
    [node removeActionForKey:@"highligh"];
    [node removeActionForKey:@"shadow"];
    node.xScale = 1.0;
    node.yScale = 1.0;
    node.alpha = 1.0;
}

+(void)highlight:(SKNode*)node
{
    [SKDot restore:node];
    SKAction *shrink = [SKAction scaleTo:0.9 duration:0.1];
    SKAction *highlight = [SKAction scaleTo:1.1 duration:0.2];
    SKAction *reverse = [SKAction scaleTo:1.0 duration:0.6];
    SKAction *sequence = [SKAction sequence:@[shrink, highlight, reverse]];
    
    [node runAction:sequence withKey:@"highligh"];
}

+(void)highlightBig:(SKNode*)node
{
    [SKDot restore:node];
    SKAction *shrink = [SKAction scaleTo:0.7 duration:0.1];
    SKAction *highlight = [SKAction scaleTo:1.7 duration:0.2];
    SKAction *reverse = [SKAction scaleTo:1.0 duration:0.6];
    SKAction *sequence = [SKAction sequence:@[shrink, highlight, reverse]];
    
    [node runAction:sequence withKey:@"highligh"];
}

+(void)shadow:(SKNode*)node
{
    [SKDot restore:node];
    SKAction *fadeOut = [SKAction fadeAlphaTo:0.2 duration:0.2];
    SKAction *wait = [SKAction waitForDuration:2];
    SKAction *reverse = [SKAction fadeInWithDuration:0.5];
    SKAction *sequence = [SKAction sequence:@[fadeOut, wait, reverse]];
    
    [node runAction:sequence withKey:@"shadow"];
}

-(void)restore
{
    [SKDot restore:self.dot];
}
-(void)highlight
{
    [SKDot highlightBig:self.dot];
}
-(void)shadow
{
    [SKDot shadow:self.dot];
}

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
