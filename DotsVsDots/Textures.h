//
//  Sprites.h
//  DotsStrategyGame
//
//  Created by baka on 4/8/14.
//  Copyright (c) 2014 baka. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SpriteKit/SpriteKit.h>

@interface Textures : NSObject

+ (instancetype)sharedInstance;

@property SKTexture *spaceshipTexture;

@end
