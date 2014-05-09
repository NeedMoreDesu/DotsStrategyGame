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
#import "DBase+custom.h"
#import "Panels.h"
#import "NewGameButton.h"

#define DOTS_OFFSET 10
#define MAX_DOTS_IN_A_ROW 15
#define MAX_DOTS_IN_A_COLUMN 20
#define MIN_DOTS_IN_A_ROW 5
#define MIN_DOTS_IN_A_COLUMN 8

@interface MyScene()

@property SKNode *camera;
@property CGPoint lastTouchPosition;
@property BOOL itWasTapOnly;
@property SKNode *world;
@property double lastLenBetweenFingers;
@property NSMutableSet *touches;
@property NSMutableArray *dots;
@property NSMutableDictionary *bases;
@property long long lastX, lastY;
@property Panels *panels;

@end

@implementation MyScene

-(void)getLastGameOrCreate
{
    NSArray *fetch = [[CoreData sharedInstance].mainMOC
                      fetchObjectsForEntityName:@"DGame"
                      sortDescriptors:@[@[@"date", @NO]]
                      limit:1
                      predicate:nil];
    self.game = fetch.firstObject;
    if (self.game == nil) {
        [self createNewGame];
    }
}

-(void)createNewGame
{
    self.game = [DGame newObjectWithContext:[CoreData sharedInstance].mainMOC entity:nil];
    [self.game setup];
    self.panels.game = self.game;
    [self.dots enumerateObjectsUsingBlock:^(NSArray *column, NSUInteger idx, BOOL *stop) {
        [column enumerateObjectsUsingBlock:^(SKDot *dot, NSUInteger idx, BOOL *stop) {
            dot.game = self.game;
        }];
    }];
    [self.bases enumerateKeysAndObjectsUsingBlock:^(id key, SKNode *obj, BOOL *stop) {
        [obj removeFromParent];
    }];
    [self redrawDots];
}

-(double)minScale
{
    return
    MIN(self.frame.size.width  / (MAX_DOTS_IN_A_ROW    * DOT_SIZE),
        self.frame.size.height / (MAX_DOTS_IN_A_COLUMN * DOT_SIZE));
}

-(double)maxScale
{
    return
    MIN(self.frame.size.width  / (MIN_DOTS_IN_A_ROW    * DOT_SIZE),
        self.frame.size.height / (MIN_DOTS_IN_A_COLUMN * DOT_SIZE));
}

-(NSUInteger)dotsWidth
{
    return self.dots.count;
}

-(NSUInteger)dotsHeight
{
    NSMutableArray *row = self.dots.firstObject;
    if (!row) {
        return 0;
    }
    return row.count;
}

-(SKDot*)dotsGetX:(NSUInteger)x y:(NSUInteger)y
{
    if ([self dotsWidth] <= x) {
        return nil;
    }
    NSMutableArray *row = self.dots[x];
    if (row.count <= y) {
        return nil;
    }
    return row[y];
}

-(void)dotsSetX:(NSUInteger)x y:(NSUInteger)y node:(SKDot*)node
{
    while ([self dotsWidth] <= x) {
        [self.dots addObject:[NSMutableArray new]];
    }
    NSMutableArray *row = self.dots[x];
    while (row.count <= y) {
        [row addObject:node];
    }
}

-(void)updateEnvironment
{
    double dotSize    = DOT_SIZE;

    [self.game.capturingBases enumerateObjectsUsingBlock:^(DBase *base, NSUInteger idx, BOOL *stop) {
        DDot *trappingDot = base.outerDots.lastObject;
        if (self.bases[trappingDot.position.XY]) {
            return;
        }
        SKShapeNode *node = [SKShapeNode new];
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathMoveToPoint(path, 0,
                          trappingDot.position.x.longLongValue*dotSize,
                          trappingDot.position.y.longLongValue*dotSize);
        for (int i = 0; i < base.outerDots.count; i++) {
            DDot *dot = base.outerDots[i];
            CGPathAddLineToPoint(path, nil,
                                 dot.position.x.longLongValue*dotSize,
                                 dot.position.y.longLongValue*dotSize);
        }
        node.path = path;
        node.fillColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
        node.strokeColor = [UIColor blackColor];
        if (trappingDot.belongsTo.shortValue == 0) {
            node.fillColor = [UIColor colorWithRed:0 green:0 blue:1 alpha:0.3];
            node.strokeColor = [UIColor colorWithRed:0 green:0 blue:1 alpha:1];
        }
        if (trappingDot.belongsTo.shortValue == 1) {
            node.fillColor = [UIColor colorWithRed:1 green:0 blue:0 alpha:0.3];
            node.strokeColor = [UIColor colorWithRed:1 green:0 blue:0 alpha:1];
        }
        node.zPosition = 20;
        
        self.bases[trappingDot.position.XY] = node;
        [self.world addChild:node];
    }];
    
    if ([self.game stopWhenTurn:100 orNumberOfCapturedDotsExceeds:3])
    {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Ta-daa!"
                              message: [NSString stringWithFormat:@"Player %@ wins!", self.game.whoseTurn]
                              delegate:nil
                              cancelButtonTitle:@"Yay!"
                              otherButtonTitles:nil];
        if (!self.game.whoseTurn) {
            alert = [[UIAlertView alloc]
                     initWithTitle:@"Duh!"
                     message:@"We have a draw here!"
                     delegate:nil
                     cancelButtonTitle:@"Okay. =("
                     otherButtonTitles:nil];
            
        }
        [alert show];
    }
    
    [self.panels updateScores];
}

-(void)redrawDots
{
    double dotSize    = DOT_SIZE;
    double cameraX = self.camera.position.x;
    double cameraY = self.camera.position.y;
    long long centralNodeX = cameraX / dotSize;
    long long centralNodeY = cameraY / dotSize;
    
    for (NSUInteger i = 0; i < [self dotsWidth]; i++) {
        for (NSUInteger j = 0; j < [self dotsHeight]; j++) {
            SKDot *node = [self dotsGetX:i y:j];
            [node setPointX:[NSNumber numberWithLongLong:i+centralNodeX-[self dotsWidth]/2]
                          Y:[NSNumber numberWithLongLong:j+centralNodeY-[self dotsHeight]/2]];
        }
    }
    [self updateEnvironment];
}

-(void)dotsShiftToX:(long long)x y:(long long)y
{
    long long
    shiftX = self.lastX - x,
    shiftY = self.lastY - y;
    if (shiftX == 0 && shiftY == 0) {
        return;
    }
    self.lastX = x;
    self.lastY = y;
    [self redrawDots];
}

-(void)dotsResizeToX:(NSUInteger)x y:(NSUInteger)y
             centerX:(long long)centerX
             centerY:(long long)centerY
{
    if ([self dotsWidth] == x &&
        [self dotsHeight] == y) {
        return;
    }
    while (x < [self dotsWidth])
    {
        [self.dots.lastObject enumerateObjectsUsingBlock:^(SKDot *dot, NSUInteger idx, BOOL *stop) {
            [dot removeFromParent];
        }];
        [self.dots removeLastObject];
    }
    while (x > [self dotsWidth]) {
        [self.dots addObject:[NSMutableArray new]];
    }
    [self.dots enumerateObjectsUsingBlock:^(NSMutableArray *row, NSUInteger i, BOOL *stop) {
        while (y < row.count)
        {
            SKDot *dot = row.lastObject;
            [dot removeFromParent];
            [row removeLastObject];
        }
        while (y > row.count) {
            SKDot *dot = [[SKDot alloc] init];
            dot.game = self.game;
            dot.theScene = self;
            [self.world addChild:dot];
            [row addObject:dot];
        }
    }];
    [self redrawDots];
}

-(void)createDots
{
    double frameWidth = self.frame.size.width / self.world.xScale;
    double frameHeigh = self.frame.size.height / self.world.yScale;
    double dotSize    = DOT_SIZE;
    double cameraX = self.camera.position.x;
    double cameraY = self.camera.position.y;
    long long centralNodeX = cameraX / dotSize;
    long long centralNodeY = cameraY / dotSize;
    
    [self dotsResizeToX:frameWidth/dotSize+DOTS_OFFSET
                      y:frameHeigh/dotSize+DOTS_OFFSET
                centerX:centralNodeX
                centerY:centralNodeY];
    [self dotsShiftToX:centralNodeX y:centralNodeY];
}

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        
        self.touches = [NSMutableSet new];
        self.dots = [NSMutableArray new];
        self.bases = [NSMutableDictionary new];
        
        self.anchorPoint = CGPointMake(0.5, 0.5);
        self.world = [SKNode node];
        [self addChild:self.world];
        
        self.camera = [SKNode node];
        self.camera.name = @"camera";
        [self.world addChild:self.camera];
        
        self.backgroundColor = [SKColor whiteColor];
        
        [self getLastGameOrCreate];
        
        [self.world setScale:[self minScale]*0.8+[self maxScale]*0.2];

        [self createDots];
        
        self.panels = [[Panels alloc] initWithDGame:self.game];
        self.panels.zPosition = 1000;
        self.panels.position = CGPointMake(0, self.frame.size.height/2);
        [self addChild:self.panels];
        [self.panels updateScores];
        
        NewGameButton *newGameButton = [[NewGameButton alloc] init];
        newGameButton.position = CGPointMake(-self.frame.size.width/2+newGameButton.size.width/2,
                                             +self.frame.size.height/2-newGameButton.size.height/2);
        newGameButton.zPosition = 1000;
        [self addChild:newGameButton];
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
    node.parent.position = CGPointMake(node.parent.position.x - cameraPositionInScene.x,
                                       node.parent.position.y - cameraPositionInScene.y);
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
            double scale = self.world.xScale * lenBetweenFingers / self.lastLenBetweenFingers;
            scale = MAX(scale, [self minScale]);
            scale = MIN(scale, [self maxScale]);
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
            self.camera.position = CGPointMake(self.camera.position.x
                                               + (-newPosition.x + oldPosition.x)/self.world.xScale,
                                               self.camera.position.y
                                               + (-newPosition.y + oldPosition.y)/self.world.yScale);
            
            [self createDots];
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
    [self redrawDots];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [touches enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
        [self.touches removeObject:obj];
    }];

    if(self.itWasTapOnly)
    {
        NSArray *nodes = [self nodesAtPoint:self.lastTouchPosition];
        [nodes enumerateObjectsUsingBlock:^(SKNode *node, NSUInteger idx, BOOL *stop) {
            if ([node isKindOfClass:[SKDot class]]) {
                SKDot *dotNode = (SKDot*)node;
                [dotNode makeTurn];
            }
        }];
        self.itWasTapOnly = NO;
    }
    [self redrawDots];
}

-(void)update:(CFTimeInterval)currentTime {
}

@end
