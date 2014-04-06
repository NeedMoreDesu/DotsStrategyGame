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

#define FRAME_SCALE 0.7

@interface MyScene()

@property SKNode *camera;
@property CGPoint lastTouchPosition;
@property BOOL itWasTapOnly;
@property SKNode *world;
@property double lastLenBetweenFingers;
@property NSMutableSet *touches;

@end

@implementation MyScene

-(void)createDots
{
    double frameWidth = self.frame.size.width / self.world.xScale;
    double frameHeigh = self.frame.size.height / self.world.yScale;
    double dotSize    = DOT_SIZE;
    double cameraX = self.camera.position.x;
    double cameraY = self.camera.position.y;
    long long centralNodeX = cameraX / dotSize;
    long long centralNodeY = cameraY / dotSize;

    [self.world enumerateChildNodesWithName:@"dot" usingBlock:^(SKNode *node, BOOL *stop) {
        SKDot *dot = (SKDot*)node;
        long long x = dot.point.x.longLongValue;
        long long y = dot.point.y.longLongValue;
        if ((ABS((x-centralNodeX)*dotSize) > frameWidth*FRAME_SCALE) ||
            (ABS((y-centralNodeY)*dotSize) > frameHeigh*FRAME_SCALE))
        {
            [node removeFromParent];
            node = nil;
        }
    }];
    
    __block long long smallestX, biggestX, smallestY, biggestY;
    __block BOOL dotsExistedBefore = NO;
    [self.world enumerateChildNodesWithName:@"dot" usingBlock:^(SKNode *node, BOOL *stop) {
        SKDot *dot = (SKDot*)node;
        long long x = dot.point.x.longLongValue;
        long long y = dot.point.y.longLongValue;
        smallestX = x;
        biggestX = x;
        smallestY = y;
        biggestY = y;
        dotsExistedBefore = YES;
        *stop = YES;
    }];
        
    [self.world enumerateChildNodesWithName:@"dot" usingBlock:^(SKNode *node, BOOL *stop) {
        SKDot *dot = (SKDot*)node;
        long long x = dot.point.x.longLongValue;
        long long y = dot.point.y.longLongValue;
        if (smallestX > x)
            smallestX = x;
        if (biggestX < x)
            biggestX = x;
        if (smallestY > y)
            smallestY = y;
        if (biggestY < y)
            biggestY = y;
    }];
    
    void(^dotCreationBlock)(long long i, long long j) = ^(long long i, long long j) {
        if (!(dotsExistedBefore &&
              smallestX <= i && i <= biggestX &&
              smallestY <= j && j <= biggestY))
        {
            SKDot *dotNode = [[SKDot alloc] init];
            dotNode.game = self.game;
            [dotNode setPointX:[NSNumber numberWithLongLong:i]
                             Y:[NSNumber numberWithLongLong:j]];
            [self.world addChild:dotNode];
        }
    };
    
    for (long long i = 0; (i*dotSize) < frameWidth*FRAME_SCALE; i++) {
        for (long long j = 0; (j*dotSize) < frameHeigh*FRAME_SCALE; j++) {
            dotCreationBlock(i+centralNodeX,j+centralNodeY);
            if(i != 0)
            {
                dotCreationBlock(-i+centralNodeX,j+centralNodeY);
                if (j != 0) {
                    dotCreationBlock(-i+centralNodeX,-j+centralNodeY);
                }
            }
            if(j != 0)
            {
                dotCreationBlock(i+centralNodeX,-j+centralNodeY);
            }
        }
    }
    
}

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        
        self.touches = [NSMutableSet new];
        
        self.anchorPoint = CGPointMake(0.5, 0.5);
        self.world = [SKNode node];
        [self addChild:self.world];
        
        self.camera = [SKNode node];
        self.camera.name = @"camera";
        [self.world addChild:self.camera];
        
        self.backgroundColor = [SKColor colorWithRed:0.15 green:0.15 blue:0.3 alpha:1.0];
        
        self.game = [DGame newObjectWithContext:[CoreData sharedInstance].mainMOC entity:nil];
        
        [self.world setScale:0.5];

        [self createDots];
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
    self.itWasTapOnly = YES;
    self.lastLenBetweenFingers = -1;
    [touches enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
        [self.touches addObject:obj];
    }];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.touches enumerateObjectsUsingBlock:^(UITouch *obj, BOOL *stop) {
        if ((obj.phase == UITouchPhaseEnded) ||
            (obj.phase == UITouchPhaseCancelled))
            [self.touches removeObject:obj];
    }];
    if (self.touches.count > 1) {
        double lenBetweenFingers = 0;
        NSArray *touchesArray = [self.touches allObjects];
        for (int i = 0; i < touchesArray.count; i++) {
            for (int j = 0; j < touchesArray.count; j++) {
                if(i==j) continue;
                UITouch *t1 = touchesArray[i];
                UITouch *t2 = touchesArray[j];
                CGPoint t1position = [t1 locationInNode:self];
                CGPoint t2position = [t2 locationInNode:self];
                lenBetweenFingers += sqrt( pow(t1position.x-t2position.x, 2)
                                          +pow(t1position.y-t2position.y, 2));
            }
        }
        lenBetweenFingers /= touches.count;
        if(self.lastLenBetweenFingers > 0)
        {
            double scale = self.world.xScale * self.lastLenBetweenFingers / lenBetweenFingers;
            scale = MAX(scale, 0.15);
            scale = MIN(scale, 1);
            [self.world setScale:scale];
            [self createDots];
        }
        self.lastLenBetweenFingers = lenBetweenFingers;
    }
    else
    {
        if(self.lastLenBetweenFingers < 0)
        {
            UITouch *touch = [touches anyObject];
            CGPoint oldPosition = self.lastTouchPosition;
            CGPoint newPosition = [touch locationInNode:self];
            [self.camera runAction:
             [SKAction repeatAction:
              [SKAction sequence:@[[SKAction moveByX:
                                    (-newPosition.x + oldPosition.x)/self.world.xScale/3
                                                   y:
                                    (-newPosition.y + oldPosition.y)/self.world.yScale/3
                                            duration:0.1],
                                   [SKAction runBlock:^{
                  [self createDots];
              }]
                                   ]]
                              count:5]];
            self.lastTouchPosition = newPosition;
        }
        self.lastLenBetweenFingers = -1;
    }
    self.itWasTapOnly = NO;
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [touches enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
        [self.touches removeObject:obj];
    }];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [touches enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
        [self.touches removeObject:obj];
    }];

    if(self.itWasTapOnly)
    {
        SKNode *node = [self nodeAtPoint:self.lastTouchPosition];
        if ([node isKindOfClass:[SKDot class]]) {
            SKDot *dotNode = (SKDot*)node;
            [dotNode makeTurn];
        }
        self.itWasTapOnly = NO;
    }
}

-(void)update:(CFTimeInterval)currentTime {
//    [self.world enumerateChildNodesWithName:@"dot" usingBlock:^(SKNode *node, BOOL *stop) {
//        BOOL unseenHorizontally = (ABS(node.position.x - self.camera.position.x)*self.world.xScale
//                                   > self.frame.size.width/2);
//        BOOL unseenVertically   = (ABS(node.position.y - self.camera.position.y)*self.world.yScale
//                                   > self.frame.size.height/2);
//        if (unseenHorizontally || unseenVertically) {
//            [node removeFromParent];
//            node = nil;
//        }
//    }];
    /* Called before each frame is rendered */
}

@end
