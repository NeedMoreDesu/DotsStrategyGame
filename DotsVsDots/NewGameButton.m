//
//  NewGame.m
//  DotsStrategyGame
//
//  Created by dev on 4/15/14.
//  Copyright (c) 2014 baka. All rights reserved.
//

#import "NewGameButton.h"
#import "MyScene.h"

@implementation NewGameButton

-(instancetype)init
{
    self = [super initWithImageNamed:@"new_game"];
    if (self != nil) {
//        self.position = CGPointMake(self.size.width*-1/2, self.size.height*-1/2);
        self.userInteractionEnabled = YES;
    }
    return self;
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    MyScene *scene = (MyScene*)self.scene;
    [scene createNewGame];
}

@end
