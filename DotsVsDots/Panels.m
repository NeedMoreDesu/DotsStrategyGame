//
//  Panels.m
//  DotsStrategyGame
//
//  Created by baka on 4/14/14.
//  Copyright (c) 2014 baka. All rights reserved.
//

#import "Panels.h"

@interface Panels()

@property NSMutableArray *capturedDotsNumberLabels;
@property SKSpriteNode *background;
@property SKSpriteNode *choiseTick;

@end

@implementation Panels

-(void)updateScores
{
    NSArray *scores = [self.game countCapturedDots];
//    self.background.size = CGSizeMake(self.scene.frame.size.width/3,
//                                      70);

    [self.capturedDotsNumberLabels enumerateObjectsUsingBlock:
     ^(SKLabelNode *label, NSUInteger idx, BOOL *stop) {
         label.text = [NSString stringWithFormat:@"%lu", (unsigned long)((NSSet*)scores[idx]).count];
         label.position = CGPointMake(70*(idx-([self.game numberOfPlayers]-1)/2.0),
                                      -70*0.8);
         if(self.game.whoseTurn.intValue == idx)
         {
             self.choiseTick.position = CGPointMake(label.position.x+5,
                                                    label.position.y+20);
         }
     }];
    if (![self.game.isPlaying isEqual:@YES]) {
        self.choiseTick.position = CGPointMake(9000, 0);
    }
}

-(instancetype)initWithDGame:(DGame*)game
{
    self = [super init];
    if(self)
    {
        self.game = game;
        self.userInteractionEnabled = YES;
        SKTexture *back = [SKTexture textureWithImageNamed:@"score_background"];
        SKSpriteNode *background = [SKSpriteNode spriteNodeWithTexture:back
                                                                  size:CGSizeMake(200, 120)];
        background.position = CGPointMake(0, -background.size.height/2);
        [self addChild:background];
        
        self.capturedDotsNumberLabels = [NSMutableArray new];
        for (int i = 0; i < [self.game numberOfPlayers]; i++) {
            SKLabelNode *label = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"]; //@"MarkerFelt-Thin"
            label.fontSize = 80;
            label.fontColor = [UIColor blackColor];
            if(i == 0)
                label.fontColor = [UIColor blueColor];
            if(i == 1)
                label.fontColor = [UIColor redColor];

            [self.capturedDotsNumberLabels addObject:label];
            [self addChild:label];
        }

        self.choiseTick = [SKSpriteNode spriteNodeWithImageNamed:@"score_choise"];
        [self addChild:self.choiseTick];
    }
    return self;
}

@end
