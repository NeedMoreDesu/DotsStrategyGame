//
//  MyScene.h
//  DotsVsDots
//

//  Copyright (c) 2014 baka. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "DGame+custom.h"

@interface MyScene : SKScene

@property DGame *game;

-(void)redrawDots;
-(void)createNewGame;
-(void)enableBlur;
-(void)disableBlur;

-(void)scrollToX:(long long)x Y:(long long)y;
-(void)scrollToXY:(NSArray*)XY;
-(void)scrollToDPoint:(DPoint*)point;
-(void)scrollToDDot:(DDot*)dot;

-(void)highlightDots:(NSArray*)highlightXYs shadowDots:(NSArray*)shadowXYs;

@end
