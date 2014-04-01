//
//  MyScene.m
//  DotsVsDots
//
//  Created by baka on 3/23/14.
//  Copyright (c) 2014 baka. All rights reserved.
//

#import "MyScene.h"
#import "CoreData.h"
#import "SKDot.h"

@interface MyScene()

@property SKNode *camera;
@property CGPoint lastTouchPosition;
@property SKNode *nodeAtPointOnKeyDown;
@property SKNode *world;

@end

@implementation MyScene

-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        
        self.anchorPoint = CGPointMake(0.5, 0.5);
        self.world = [SKNode node];
        [self addChild:self.world];
        
        self.camera = [SKNode node];
        self.camera.name = @"camera";
        [self.world addChild:self.camera];
        
        self.backgroundColor = [SKColor colorWithRed:0.15 green:0.15 blue:0.3 alpha:1.0];
        
        self.game = [DGame newObjectWithContext:[CoreData sharedInstance].mainMOC entity:nil];
        
        for (int i = 0; i<10; i++) {
            for (int j = 0; j<10; j++) {
                SKDot *dotNode = [[SKDot alloc] init];
                dotNode.game = self.game;
                [dotNode setPointX:[NSNumber numberWithLongLong:i]
                                 Y:[NSNumber numberWithLongLong:j]];
                [self.world addChild:dotNode];
            }
        }

    }
    return self;
}

- (void)didSimulatePhysics
{
    [self centerOnNode: [self childNodeWithName: @"//camera"]];
}

- (void) centerOnNode: (SKNode *) node
{
    CGPoint cameraPositionInScene = [node.scene convertPoint:node.position fromNode:node.parent];
    node.parent.position = CGPointMake(node.parent.position.x - cameraPositionInScene.x,                                       node.parent.position.y - cameraPositionInScene.y);
}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    self.lastTouchPosition = [touch locationInNode:self];
    self.nodeAtPointOnKeyDown = [self nodeAtPoint:self.lastTouchPosition];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint oldPosition = self.lastTouchPosition;
    CGPoint newPosition = [touch locationInNode:self];
    NSLog(@"%f %f; %f %f", oldPosition.x, oldPosition.y, newPosition.x, newPosition.y);
    self.camera.position = CGPointMake(self.camera.position.x - newPosition.x + oldPosition.x,
                                       self.camera.position.y - newPosition.y + oldPosition.y);
    self.lastTouchPosition = newPosition;
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    self.lastTouchPosition = [touch locationInNode:self];
    SKNode *node = [self nodeAtPoint:self.lastTouchPosition];
    
    if(node == self.nodeAtPointOnKeyDown)
    {
        if ([node isKindOfClass:[SKDot class]]) {
            SKDot *dotNode = (SKDot*)node;
            [dotNode makeTurn];
        }
    }
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
}

@end
