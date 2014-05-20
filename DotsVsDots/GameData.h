//
//  Sprites.h
//  DotsStrategyGame
//
//  Created by baka on 4/8/14.
//  Copyright (c) 2014 baka. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SpriteKit/SpriteKit.h>

@interface GameData : NSObject

+ (instancetype)sharedInstance;
+ (BOOL)isiPad;

@property NSArray *backgroundTextures;
@property NSArray *redDots;
@property NSArray *blueDots;

@property SKTexture *panels;
@property SKTexture *optionsMenu;
@property SKTexture *history;

@property SKTexture *crossed;

@property CGSize frameSize;

@property double scoreFontSize;
@property double historyFontSize;
@property double gameOverTopLabelSize;
@property double gameOverBottomLabelSize;

@end
