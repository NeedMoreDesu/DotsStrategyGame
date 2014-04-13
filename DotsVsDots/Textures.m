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
        shared.backgroundTextures =
        @[[SKTexture textureWithImageNamed:@"dot_background_1"],
          [SKTexture textureWithImageNamed:@"dot_background_2"],
          [SKTexture textureWithImageNamed:@"dot_background_3"],
          [SKTexture textureWithImageNamed:@"dot_background_4"],
          [SKTexture textureWithImageNamed:@"dot_background_5"]];
        shared.redDots =
        @[[SKTexture textureWithImageNamed:@"dot_red_dot_1"],
          [SKTexture textureWithImageNamed:@"dot_red_dot_2"],
          [SKTexture textureWithImageNamed:@"dot_red_dot_3"],
          [SKTexture textureWithImageNamed:@"dot_red_dot_4"],
          [SKTexture textureWithImageNamed:@"dot_red_dot_5"]];
        shared.blueDots =
        @[[SKTexture textureWithImageNamed:@"dot_blue_dot_1"],
          [SKTexture textureWithImageNamed:@"dot_blue_dot_2"],
          [SKTexture textureWithImageNamed:@"dot_blue_dot_3"],
          [SKTexture textureWithImageNamed:@"dot_blue_dot_4"],
          [SKTexture textureWithImageNamed:@"dot_blue_dot_5"]];
    });
    return shared;
}

@end
