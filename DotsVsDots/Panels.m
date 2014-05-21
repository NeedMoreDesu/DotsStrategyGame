//
//  Panels.m
//  DotsStrategyGame
//
//  Created by baka on 4/14/14.
//  Copyright (c) 2014 baka. All rights reserved.
//

#import "Panels.h"
#import "GameData.h"
#import "MyScene.h"
#import "HistoryLabel.h"

@interface Panels()

@property NSMutableArray *capturedDotsNumberLabels;
@property SKSpriteNode *background;
@property SKSpriteNode *choiseTick;

@property SKSpriteNode *optionsButton;
@property SKSpriteNode *player2placeholder;
@property SKSpriteNode *player1placeholder;
@property SKSpriteNode *showHistoryButton;
@property SKSpriteNode *hideHistoryButton;
@property SKSpriteNode *createGameButton;
@property SKSpriteNode *offerDrawButton;
@property SKSpriteNode *surrenderButton;

@property SKSpriteNode *leftBottom;

@property SKEffectNode *blurNode;

@property SKLabelNode *player1scores;
@property SKLabelNode *player2scores;

@property SKLabelNode *gameOverStateLabelTop;
@property SKLabelNode *gameOverStateLabelBottom;

@property NSMutableArray *historyLabels;
@property double historyOffset;
@property CGPoint historyScrollingLocation;
@property int slowingDown;

@property SKNode *touchesBeganNode;

@end

@implementation Panels

-(DGame*)game
{
    MyScene *scene = (MyScene*)self.scene;
    return scene.game;
}

-(void)updateScores
{
    NSArray *scores = [self.game countCapturedDots];
    
    self.player1scores.text = [NSString stringWithFormat:@"%lu",
                               (unsigned long)((NSSet*)scores[0]).count];
    self.player2scores.text = [NSString stringWithFormat:@"%lu",
                               (unsigned long)((NSSet*)scores[1]).count];
    if ([self.game.isPlaying isEqualToNumber:@NO]) {
        if ([self.game.gameOverWithDrawByArgeement isEqualToNumber:@YES]) {
            self.gameOverStateLabelTop.fontColor =
            self.gameOverStateLabelBottom.fontColor =
            [UIColor colorWithRed:0.
                            green:0.
                             blue:0.
                            alpha:0.5];
            self.gameOverStateLabelTop.text = @"Draw";
            self.gameOverStateLabelBottom.text = @"Draw by agreement";
        } else if ([self.game.gameOverWithSurrender isEqualToNumber:@YES]) {
            if([self.game.gameOverResult isEqualToNumber:@0])
            {
                self.gameOverStateLabelTop.fontColor =
                self.gameOverStateLabelBottom.fontColor =
                [UIColor colorWithRed:0.
                                green:0.
                                 blue:1.
                                alpha:0.5];
                self.gameOverStateLabelTop.text = @"Blue wins!";
                self.gameOverStateLabelBottom.text = @"Enemy surrendered";
            } else {
                self.gameOverStateLabelTop.fontColor =
                self.gameOverStateLabelBottom.fontColor =
                [UIColor colorWithRed:1.
                                green:0.
                                 blue:0.
                                alpha:0.5];
                self.gameOverStateLabelTop.text = @"Red wins!";
                self.gameOverStateLabelBottom.text = @"Enemy surrendered";
            }
        } else if ([self.game.gameOverWithCapture isEqualToNumber:@YES]) {
            if([self.game.gameOverResult isEqualToNumber:@0])
            {
                self.gameOverStateLabelTop.fontColor =
                self.gameOverStateLabelBottom.fontColor =
                [UIColor colorWithRed:0.
                                green:0.
                                 blue:1.
                                alpha:0.5];
                self.gameOverStateLabelTop.text = @"Blue wins!";
                self.gameOverStateLabelBottom.text = @"Capture victory";
            } else {
                self.gameOverStateLabelTop.fontColor =
                self.gameOverStateLabelBottom.fontColor =
                [UIColor colorWithRed:1.
                                green:0.
                                 blue:0.
                                alpha:0.5];
                self.gameOverStateLabelTop.text = @"Red wins!";
                self.gameOverStateLabelBottom.text = @"Capture victory";
            }
        } else {
            if (self.game.gameOverResult == nil) {
                self.gameOverStateLabelTop.fontColor =
                self.gameOverStateLabelBottom.fontColor =
                [UIColor colorWithRed:0.
                                green:0.
                                 blue:0.
                                alpha:0.5];
                self.gameOverStateLabelTop.text = @"Draw";
                self.gameOverStateLabelBottom.text = @"Turns limit";
            } else if([self.game.gameOverResult isEqualToNumber:@0])
            {
                self.gameOverStateLabelTop.fontColor =
                self.gameOverStateLabelBottom.fontColor =
                [UIColor colorWithRed:0.
                                green:0.
                                 blue:1.
                                alpha:0.5];
                self.gameOverStateLabelTop.text = @"Blue wins!";
                self.gameOverStateLabelBottom.text = @"Turns limit";
            } else {
                self.gameOverStateLabelTop.fontColor =
                self.gameOverStateLabelBottom.fontColor =
                [UIColor colorWithRed:1.
                                green:0.
                                 blue:0.
                                alpha:0.5];
                self.gameOverStateLabelTop.text = @"Red wins!";
                self.gameOverStateLabelBottom.text = @"Turns limit";
            }
        }
    } else
    {
        self.gameOverStateLabelTop.text = @"";
        self.gameOverStateLabelBottom.text = @"";
    }
    
    if ([self.game.isPlaying isEqualToNumber:@NO]) {
        self.player1placeholder.color = [UIColor clearColor];
        self.player2placeholder.color = [UIColor clearColor];
    } else if ([self.game.whoseTurn isEqualToNumber:@0]) {
        self.player1placeholder.color = [UIColor colorWithRed:0.
                                                        green:0.
                                                         blue:1.
                                                        alpha:0.4];
        self.player2placeholder.color = [UIColor clearColor];
    } else
    {
        self.player1placeholder.color = [UIColor clearColor];
        self.player2placeholder.color = [UIColor colorWithRed:1.
                                                        green:0.
                                                         blue:0.
                                                        alpha:0.4];
    }
    
    if (self.game.dots.count < self.historyLabels.count) {
        self.historyOffset = MAX((int)self.game.dots.count-(int)self.historyLabels.count, self.historyOffset);
        self.historyOffset = MIN(0, self.historyOffset);
    } else {
        self.historyOffset = MAX(0, self.historyOffset);
        self.historyOffset = MIN((int)self.game.dots.count-(int)self.historyLabels.count, self.historyOffset);
    }
    NSArray *dots = self.game.dotsReversed;
    int offset = self.historyOffset;
    [self.historyLabels enumerateObjectsUsingBlock:^(HistoryLabel *label, NSUInteger idx, BOOL *stop) {
        if (offset+idx < dots.count) {
            label.dot = dots[offset+idx];
        } else {
            label.dot = nil;
        }
    }];
}

-(void)updateUI
{
    if([self.game.isPlaying isEqualToNumber:@NO])
    {
        self.createGameButton.texture = nil;
        self.offerDrawButton.texture = [GameData sharedInstance].crossed;
        self.surrenderButton.texture = [GameData sharedInstance].crossed;
    } else
    {
        self.createGameButton.texture = [GameData sharedInstance].crossed;
        self.offerDrawButton.texture = nil;
        self.surrenderButton.texture = nil;
        if ([self.game voted]) {
            self.offerDrawButton.texture = [GameData sharedInstance].crossed;
        }
    }
}

-(instancetype)init
{
    self = [super init];
    
    if(self)
    {
        self.userInteractionEnabled = YES;
        self.name = @"Panels";
        
        double frameWidth = [GameData sharedInstance].frameSize.width;
        double frameHeight = [GameData sharedInstance].frameSize.height;
        
        self.blurNode = [SKEffectNode node];
        self.blurNode.shouldEnableEffects = YES;
        self.blurNode.shouldRasterize = YES;
        CIFilter *blur = [CIFilter filterWithName:@"CIGaussianBlur" keysAndValues:@"inputRadius", @3.0f, nil];
        self.blurNode.filter = blur;
        [self addChild:self.blurNode];
        
        self.panels = [SKSpriteNode spriteNodeWithTexture:
                       [GameData sharedInstance].panels];
        self.panels.position = CGPointMake(frameWidth - self.panels.size.width/2+1,
                                           frameHeight - self.panels.size.height/2+1);
        [self.blurNode addChild:self.panels];
        
        self.history = [SKSpriteNode spriteNodeWithTexture:
                        [GameData sharedInstance].self.history];
        self.history.position = CGPointMake(frameWidth - self.history.size.width/2+1,
                                            frameHeight - self.panels.size.height*0.5 - self.history.size.height/2+1);
        [self.blurNode addChild:self.history];
        
        self.gameOverStateLabelTop = [SKLabelNode labelNodeWithFontNamed:@"MarkerFelt-Wide"];
        self.gameOverStateLabelBottom = [SKLabelNode labelNodeWithFontNamed:@"MarkerFelt-Thin"];
        self.gameOverStateLabelTop.position = CGPointMake(frameWidth/2, frameHeight*0.75);
        self.gameOverStateLabelBottom.position = CGPointMake(frameWidth/2, frameHeight*0.25);
        self.gameOverStateLabelTop.fontSize = [GameData sharedInstance].gameOverTopLabelSize;
        self.gameOverStateLabelBottom.fontSize = [GameData sharedInstance].gameOverBottomLabelSize;
        [self addChild:self.gameOverStateLabelTop];
        [self addChild:self.gameOverStateLabelBottom];
        
        self.options = [SKSpriteNode spriteNodeWithTexture:
                        [GameData sharedInstance].optionsMenu];
        self.options.position = CGPointMake(-frameWidth/2, frameHeight/2);
        [self addChild:self.options];
        
        self.leftBottom = [SKSpriteNode
                           spriteNodeWithColor:[UIColor clearColor]
                           size:CGSizeMake(0, 0)];
        self.leftBottom.position = CGPointMake(-100, -100);
        [self addChild:self.leftBottom];
        
        // panels
        
        self.optionsButton =
        [SKSpriteNode
         spriteNodeWithColor:[UIColor clearColor]
         size:CGSizeMake(self.panels.size.width*0.29, self.panels.size.height*0.5)];
        self.optionsButton.position = CGPointMake(self.panels.size.width*0.35,
                                                  self.panels.size.height*0.24);
        [self.panels addChild:self.optionsButton];
        
        self.player2placeholder =
        [SKSpriteNode
         spriteNodeWithColor:[UIColor clearColor]
         size:CGSizeMake(self.panels.size.width*0.29, self.panels.size.height*0.5)];
        self.player2placeholder.position = CGPointMake(self.panels.size.width*0.045,
                                                       self.panels.size.height*0.24);
        [self.panels addChild:self.player2placeholder];
        
        self.player1placeholder =
        [SKSpriteNode
         spriteNodeWithColor:[UIColor clearColor]
         size:CGSizeMake(self.panels.size.width*0.30, self.panels.size.height*0.5)];
        self.player1placeholder.position = CGPointMake(self.panels.size.width*(0.043-0.3),
                                                       self.panels.size.height*0.245);
        [self.panels addChild:self.player1placeholder];
        
        self.showHistoryButton =
        [SKSpriteNode
         spriteNodeWithColor:[UIColor clearColor]
         size:CGSizeMake(self.panels.size.width*0.9, self.panels.size.height*0.32)];
        self.showHistoryButton.position = CGPointMake(self.panels.size.width*0.045,
                                                      self.panels.size.height*(0.24-0.43));
        [self.panels addChild:self.showHistoryButton];
        
        // history
        
        self.hideHistoryButton =
        [SKSpriteNode
         spriteNodeWithColor:[UIColor clearColor]
         size:CGSizeMake(self.history.size.width*0.87, self.history.size.height*0.06)];
        self.hideHistoryButton.position = CGPointMake(self.history.size.width*0.055, self.history.size.height*0.447);
        [self.history addChild:self.hideHistoryButton];
        
        
        self.createGameButton =
        [SKSpriteNode
         spriteNodeWithColor:[UIColor clearColor]
         size:CGSizeMake(self.options.size.width*0.77, self.options.size.height*0.15)];
        self.createGameButton.position = CGPointMake(self.options.size.width*(-0.05),
                                                     self.options.size.height*0.15);
        [self.options addChild:self.createGameButton];
        
        self.offerDrawButton =
        [SKSpriteNode
         spriteNodeWithColor:[UIColor clearColor]
         size:CGSizeMake(self.options.size.width*0.77, self.options.size.height*0.15)];
        self.offerDrawButton.position = CGPointMake(self.options.size.width*(-0.05),
                                                    self.options.size.height*(0.15-0.15));
        [self.options addChild:self.offerDrawButton];
        
        self.surrenderButton =
        [SKSpriteNode
         spriteNodeWithColor:[UIColor clearColor]
         size:CGSizeMake(self.options.size.width*0.77, self.options.size.height*0.15)];
        self.surrenderButton.position = CGPointMake(self.options.size.width*(-0.05),
                                                    self.options.size.height*(0.15-0.3));
        [self.options addChild:self.surrenderButton];
        
        self.historyActive = YES;
        self.optionsActive = YES;
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self hideOptions];
        });
        
        self.player1scores = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
        self.player2scores = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
        self.player1scores.fontColor = [UIColor blueColor];
        self.player2scores.fontColor = [UIColor redColor];
        
        self.player1scores.verticalAlignmentMode =
        self.player2scores.verticalAlignmentMode =
        SKLabelVerticalAlignmentModeCenter;
        
        self.player1scores.fontSize =
        self.player2scores.fontSize =
        [GameData sharedInstance].scoreFontSize;
        
        [self.player1placeholder addChild:self.player1scores];
        [self.player2placeholder addChild:self.player2scores];
        
        self.historyLabels = [NSMutableArray new];
        double width  = self.history.size.width * (-0.3);
        double height = self.hideHistoryButton.position.y-self.history.size.height*0.065;
        CGPoint point = CGPointMake(width, height);
        CGPoint convertedPoint = [self convertPoint:point fromNode:self.history];
        
        // 0 - self.history.size.height/2
        while (convertedPoint.y > 0) {
            HistoryLabel *node = [HistoryLabel labelNodeWithFontNamed:@"AmericanTypewriter-Condensed"];
            node.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
            node.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
            node.position = CGPointMake(width, height);
            node.fontSize = [GameData sharedInstance].historyFontSize;
            
            [self.historyLabels addObject:node];
            [self.history addChild:node];
            
            height -= self.history.size.height*0.059;
            point = CGPointMake(width, height);
            convertedPoint = [self convertPoint:point fromNode:self.history];
        }
        self.historyOffset = 0;
        
        [self updateScores];
    }
    return self;
}

-(void)enableBlur
{
    [self.blurNode setShouldEnableEffects:YES];
}
-(void)disableBlur
{
    [self.blurNode setShouldEnableEffects:NO];
}

-(void)hideOptions
{
    double y = arc4random_uniform(3000)/1000.0-1;
    double x = -2;
    x *= [GameData sharedInstance].frameSize.width;
    y *= [GameData sharedInstance].frameSize.height;
    
    [self.options runAction:[SKAction moveTo:CGPointMake(x, y) duration:0.5]];
    
    [self disableBlur];
    MyScene *scene = (MyScene*)self.scene;
    [scene disableBlur];
    
    self.optionsActive = NO;
}
-(void)showOptions
{
    double x = [GameData sharedInstance].frameSize.width / 2;
    double y = [GameData sharedInstance].frameSize.height / 2;
    
    [self.options runAction:[SKAction moveTo:CGPointMake(x, y) duration:0.3]];
    
    [self enableBlur];
    MyScene *scene = (MyScene*)self.scene;
    [scene enableBlur];
    
    [self updateUI];
    
    self.optionsActive = YES;
}
-(void)hideHistory
{
    double y = -2 * [GameData sharedInstance].frameSize.height;
    double x = self.history.position.x;
    
    [self.history runAction:[SKAction moveTo:CGPointMake(x, y) duration:0.5]];
    
    self.historyActive = NO;
}
-(void)showHistory
{
    double x = [GameData sharedInstance].frameSize.width - self.history.size.width/2;
    double y = [GameData sharedInstance].frameSize.height -
    self.panels.size.height*0.5 - self.history.size.height/2;
    
    [self.history runAction:[SKAction moveTo:CGPointMake(x, y) duration:0.3]];
    
    self.historyActive = YES;
}

-(BOOL)passableNode:(SKNode*)node
{
    return node != self.panels
    && node != self.history
    && node != self.options;
}

-(BOOL)passableNodes:(NSArray*)array
{
    for (SKNode *node in array) {
        if (![self passableNode:node]) {
            return NO;
        }
    }
    return YES;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    
    SKNode *node = [self nodeAtPoint:[touch locationInNode:self]];
    NSArray *nodes = [self nodesAtPoint:[touch locationInNode:self]];
    if ([self passableNodes:nodes]) {
        if (self.optionsActive) {
            return;
        }
        [self.parent touchesBegan:touches withEvent:event];
    } else
    {
        self.touchesBeganNode = node;
        self.slowingDown = 5;
    }
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.optionsActive) {
        return;
    }
    UITouch *touch = [touches anyObject];
    
    NSArray *nodes = [self nodesAtPoint:[touch locationInNode:self]];
    if ([self passableNodes:nodes]) {
        [self.parent touchesMoved:touches withEvent:event];
    }
    
    __block BOOL haveHistory = NO;
    [nodes enumerateObjectsUsingBlock:^(SKNode *node, NSUInteger idx, BOOL *stop) {
        if (node == self.history) {
            haveHistory = YES;
        }
    }];
    if (haveHistory) {
        CGPoint touchLocation = [touch locationInNode:self];
        if (self.slowingDown > 0)
        {
            self.slowingDown--;
        } else {
            double dist = touchLocation.y - self.historyScrollingLocation.y;
            self.historyOffset += dist*([GameData isiPad]?0.018:0.03);
            
            [self updateScores];
        }
        self.historyScrollingLocation = touchLocation;
    }
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.optionsActive) {
        return;
    }
    UITouch *touch = [touches anyObject];
    
    NSArray *nodes = [self nodesAtPoint:[touch locationInNode:self]];
    if ([self passableNodes:nodes]) {
        [self.parent touchesCancelled:touches withEvent:event];
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    
    __block SKNode *node = [self nodeAtPoint:[touch locationInNode:self]];
    NSArray *nodes = [self nodesAtPoint:[touch locationInNode:self]];
    if ([self passableNodes:nodes]) {
        if (self.optionsActive) {
            if (node != self.options)
                [self hideOptions];
            return;
        }
        [self.parent touchesEnded:touches withEvent:event];
    } else
    {
        MyScene *scene = (MyScene*)self.scene;
        if (node != self.touchesBeganNode)
        {
            return;
        }
        if (node == self.createGameButton) {
            [scene createNewGame];
            [self updateScores];
            if (!self.createGameButton.texture) {
                [self hideOptions];
            }
        }
        if (node == self.offerDrawButton) {
            [self.game offerADraw];
            [self updateScores];
            if (!self.offerDrawButton.texture) {
                [self hideOptions];
            }
        }
        if (node == self.surrenderButton) {
            [self.game surrender];
            [self updateScores];
            if (!self.surrenderButton.texture) {
                [self hideOptions];
            }
        }
        // history hides/shows aren't valid when blurred
        if (self.optionsActive) {
            if (node != self.options)
                [self hideOptions];
            return;
        }
        if (node == self.optionsButton) {
            [self showOptions];
        }
        if (node == self.hideHistoryButton) {
            if (self.historyActive) {
                [self hideHistory];
            }
        }
        if (node == self.showHistoryButton) {
            if (!self.historyActive) {
                [self showHistory];
            }
        }
        __block BOOL historyLabel = NO;
        [nodes enumerateObjectsUsingBlock:^(SKNode *node1, NSUInteger idx, BOOL *stop) {
            if([node1 isKindOfClass:[HistoryLabel class]])
            {
                node = node1;
                historyLabel = YES;
            }
        }];
        if (historyLabel) {
            HistoryLabel *label = (HistoryLabel*)node;
            DDot *ourDot = label.dot;
            [scene scrollToDDot:ourDot];
            
            NSArray *dotsToShadow = [self.game.dotsReversed filter:^BOOL(NSUInteger idx, DDot *dot) {
                return dot.turn.intValue > ourDot.turn.intValue;
            }];
            [scene highlightDots:@[ourDot] shadowDots:dotsToShadow];
        }
    }
    
}

@end
