//
//  MyScene.m
//  DotsVsDots
//
//  Created by baka on 3/23/14.
//  Copyright (c) 2014 baka. All rights reserved.
//

#import "MyScene.h"

@interface MyScene()

@property SKNode *camera;
@property CGPoint lastTouchPosition;

@end

@implementation MyScene

-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        
        self.anchorPoint = CGPointMake(0.5, 0.5);
        SKNode *myWorld = [SKNode node];
        [self addChild:myWorld];
        
        self.camera = [SKNode node];
        self.camera.name = @"camera";
        [myWorld addChild:self.camera];
        
        
        self.backgroundColor = [SKColor colorWithRed:0.15 green:0.15 blue:0.3 alpha:1.0];
        
        
        
        
        SKLabelNode *myLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
        
        myLabel.text = @"Hello, World!";
        myLabel.fontSize = 30;
        myLabel.position = CGPointMake(CGRectGetMidX(self.frame),
                                       CGRectGetMidY(self.frame));
        
        [myWorld addChild:myLabel];

        self.camera.position = myLabel.position;
        
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

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
}

@end
