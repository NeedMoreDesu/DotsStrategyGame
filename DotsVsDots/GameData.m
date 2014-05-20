//
//  Sprites.m
//  DotsStrategyGame
//
//  Created by baka on 4/8/14.
//  Copyright (c) 2014 baka. All rights reserved.
//

#import "GameData.h"

@implementation GameData

+(instancetype)sharedInstance
{
    static GameData *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[self alloc] init];
        NSMutableArray *backgroundTextures = [NSMutableArray new];
        NSMutableArray *redDots = [NSMutableArray new];
        NSMutableArray *blueDots = [NSMutableArray new];
        SKTextureAtlas *atlas = [SKTextureAtlas atlasNamed:@"Dots"];
        [atlas.textureNames enumerateObjectsUsingBlock:^(NSString *name, NSUInteger idx, BOOL *stop) {
            SKTexture *texture = [atlas textureNamed:name];
            if ([name hasPrefix:@"dot_background"])
            {
                [backgroundTextures addObject:texture];
            }
            if ([name hasPrefix:@"dot_blue_dot"])
            {
                [blueDots addObject:texture];
            }
            if ([name hasPrefix:@"dot_red_dot"])
            {
                [redDots addObject:texture];
            }
        }];
        shared.backgroundTextures = backgroundTextures;
        shared.redDots = redDots;
        shared.blueDots = blueDots;
        
        shared.panels = [SKTexture textureWithImageNamed:@"panels"];
        shared.optionsMenu = [SKTexture textureWithImageNamed:@"options_menu"];
        shared.history = [SKTexture textureWithImageNamed:@"history"];
        shared.crossed = [SKTexture textureWithImageNamed:@"crossed"];
        shared.scoreFontSize = [GameData isiPad]?100:50;
        shared.historyFontSize = [GameData isiPad]?40:20;
        shared.gameOverTopLabelSize = [GameData isiPad]?100:50;
        shared.gameOverBottomLabelSize = [GameData isiPad]?80:40;
    });
    return shared;
}

+(BOOL)isiPad
{
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
    {
        return YES; /* Device is iPad */
    }
    return NO;
}

@end
