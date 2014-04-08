//
//  Sprites.m
//  DotsStrategyGame
//
//  Created by baka on 4/8/14.
//  Copyright (c) 2014 baka. All rights reserved.
//

#import "Textures.h"

@implementation Textures

+(instancetype)sharedInstance
{
    static Textures *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[self alloc] init];
        shared.spaceshipTexture = [SKTexture textureWithImageNamed:@"Spaceship.png"];
    });
    return shared;
}

@end
