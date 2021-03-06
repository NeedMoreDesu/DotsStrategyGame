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
#import "GameData.h"

#define DOTS_OFFSET 10
#define MAX_DOTS_IN_A_ROW 15
#define MAX_DOTS_IN_A_COLUMN 25
#define MIN_DOTS_IN_A_ROW 5
#define MIN_DOTS_IN_A_COLUMN 8

@interface MyScene()

@property SKNode *camera;
@property CGPoint lastTouchPosition;
@property BOOL itWasTapOnly;
@property SKNode *world;
@property SKNode *dotWorld;
@property double lastLenBetweenFingers;
@property NSMutableSet *touches;
@property NSMutableDictionary *bases;
@property long long lastX, lastY;
@property NSUInteger lastWidth, lastHeight;
@property Panels *panels;

@property SKEffectNode *blurNode;

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
    [self scrollToDDot:self.game.dotsReversed.firstObject];
}

-(void)createNewGame
{
    if ([self.game.isPlaying isEqualToNumber:@YES]) {
        return;
    }
    self.game = [DGame newObjectWithContext:[CoreData sharedInstance].mainMOC entity:nil];
    [self.game setup];
    [self.dotWorld.children enumerateObjectsUsingBlock:^(SKDot *dot, NSUInteger idx, BOOL *stop) {
        dot.game = self.game;
    }];
    [self.bases enumerateKeysAndObjectsUsingBlock:^(id key, SKNode *obj, BOOL *stop) {
        [obj removeFromParent];
    }];
    [self scrollToX:0 Y:0];
}

-(void)highlightDots:(NSArray*)dotsToHighlight shadowDots:(NSArray*)dotsToShadow
{
    NSSet *highlightXYset = [NSSet setWithArray:[dotsToHighlight map:^id(DDot *dot) {
        return dot.position.XY;
    }]];
    NSSet *shadowXYset = [NSSet setWithArray:[dotsToShadow map:^id(DDot *dot) {
        return dot.position.XY;
    }]];
    [self.dotWorld.children enumerateObjectsUsingBlock:^(SKDot *dot, NSUInteger idx, BOOL *stop) {
        NSArray *XY = dot.point.XY;
        [dot restore];
        if ([highlightXYset member:XY])
        {
            [dot highlight];
            DDot *ddot = [self.game dotWithPoint:dot.point];
            [ddot.baseAsOuter enumerateObjectsUsingBlock:^(DBase *dbase, NSUInteger idx, BOOL *stop) {
                SKShapeNode *base = self.bases[dbase.objectID];
                [SKDot highlight:base];
            }];
        }
        if ([shadowXYset member:XY]) {
            [dot shadow];
            DDot *ddot = [self.game dotWithPoint:dot.point];
            [ddot.baseAsOuter enumerateObjectsUsingBlock:^(DBase *dbase, NSUInteger idx, BOOL *stop) {
                SKShapeNode *base = self.bases[dbase.objectID];
                [SKDot shadow:base];
            }];
        }
    }];
}

-(void)scrollToX:(long long)x Y:(long long)y
{
    int additionX = 0;
    if (self.panels.historyActive) {
        additionX = (self.panels.history.size.width / (DOT_SIZE * self.world.xScale)) / 2;
    }
    self.camera.position = CGPointMake((x+additionX)*DOT_SIZE, y*DOT_SIZE);
    [self redrawDots];
}
-(void)scrollToXY:(NSArray*)XY
{
    long long x = ((NSNumber*)XY[0]).longLongValue;
    long long y = ((NSNumber*)XY[1]).longLongValue;
    [self scrollToX:x Y:y];
}
-(void)scrollToDPoint:(DPoint*)point
{
    [self scrollToXY:point.XY];
}
-(void)scrollToDDot:(DDot*)dot
{
    [self scrollToDPoint:dot.position];
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

-(void)updateEnvironment
{
    double dotSize    = DOT_SIZE;

    [self.game.capturingBases enumerateObjectsUsingBlock:^(DBase *base, NSUInteger idx, BOOL *stop) {
        DDot *trappingDot = base.outerDots.firstObject;
        if (self.bases[base.objectID]) {
            return;
        }
        double trappingX = trappingDot.position.x.longLongValue*dotSize;
        double trappingY = trappingDot.position.y.longLongValue*dotSize;
        double centralX = 0;
        double centralY = 0;
        for (int i = 0; i < base.outerDots.count; i++) {
            DDot *dot = base.outerDots[i];
            centralX += dot.position.x.longLongValue*dotSize;
            centralY += dot.position.y.longLongValue*dotSize;
        }
        centralX /= base.outerDots.count;
        centralY /= base.outerDots.count;
        
        SKShapeNode *node = [SKShapeNode new];
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathMoveToPoint(path, NULL,
                          trappingX - centralX,
                          trappingY - centralY);
        for (int i = 0; i < base.outerDots.count; i++) {
            DDot *dot = base.outerDots[i];
            CGPathAddLineToPoint(path, nil,
                                 dot.position.x.longLongValue*dotSize - centralX,
                                 dot.position.y.longLongValue*dotSize - centralY);
        }
        CGPathAddLineToPoint(path, nil,
                             trappingX - centralX,
                             trappingY - centralY);
        node.position = CGPointMake(centralX, centralY);
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
        
        self.bases[base.objectID] = node;
        [self.world addChild:node];
    }];
    
    [self.game stopWhenTurn:100 orNumberOfCapturedDotsExceeds:3];
    
    [self.panels updateScores];
}

-(int)requiredWidth
{
    double frameWidth = self.frame.size.width / self.world.xScale;
    int width = frameWidth/DOT_SIZE+DOTS_OFFSET;
    return width;
}

-(int)requiredHeight
{
    double frameHeight = self.frame.size.height / self.world.yScale;
    int height = frameHeight/DOT_SIZE+DOTS_OFFSET;
    return height;
}

-(void)redrawDots
{
    double frameWidth = self.frame.size.width / self.world.xScale;
    double frameHeigh = self.frame.size.height / self.world.yScale;
    double dotSize    = DOT_SIZE;
    double cameraX = self.camera.position.x;
    double cameraY = self.camera.position.y;
    long long centralNodeX = cameraX / dotSize;
    long long centralNodeY = cameraY / dotSize;
    int width = frameWidth/dotSize+DOTS_OFFSET;
    int height = frameHeigh/dotSize+DOTS_OFFSET;
    
    [self.dotWorld.children enumerateObjectsUsingBlock:^(SKDot *dot, NSUInteger idx, BOOL *stop) {
        [dot restore];
    }];
    [self.bases enumerateKeysAndObjectsUsingBlock:^(id key, SKShapeNode *base, BOOL *stop) {
        [SKDot restore:base];
    }];
    
    NSArray *arr = self.dotWorld.children;
    for (int i = arr.count; i < width*height; i++)
    { // add dots if we lack them
        SKDot *dot = [[SKDot alloc] init];
        dot.game = self.game;
        dot.theScene = self;
        [self.dotWorld addChild:dot];
    }
    
    arr = self.dotWorld.children;
    for (int i = arr.count-1; i >= width*height; i--)
    { // remove dots if we have more than we need
        SKDot *dot = arr[i];
        [dot removeFromParent];
    }
    
    arr = self.dotWorld.children;
    NSUInteger idx = 0;
    for (long long i = 0; i < width; i++) {
        for (long long j = 0; j < height; j++) {
            SKDot *node = arr[idx];
            idx++;
            NSNumber *x = [NSNumber numberWithLongLong:i+centralNodeX - (width - (width-1)/2 - 1)];
            NSNumber *y = [NSNumber numberWithLongLong:j+centralNodeY - (height - (height-1)/2 - 1)];
            [node setPointX:x Y:y];
        }
    }
    
    self.lastX = centralNodeX;
    self.lastY = centralNodeY;
    self.lastWidth = width;
    self.lastHeight = height;
    [self updateEnvironment];
}

-(void)dotsShiftToX:(long long)centralNodeX y:(long long)centralNodeY
{
    long long deltaX = self.lastX - centralNodeX;
    long long deltaY = self.lastY - centralNodeY;
    if (deltaX == 0 && deltaY == 0) {
        return;
    }
    
    double frameWidth = self.frame.size.width / self.world.xScale;
    double frameHeigh = self.frame.size.height / self.world.yScale;
    double dotSize    = DOT_SIZE;
    int width = frameWidth/dotSize+DOTS_OFFSET;
    int height = frameHeigh/dotSize+DOTS_OFFSET;
    int rightWidth = (width-1)/2;
    int leftWidth = width - rightWidth - 1;
    int topHeight = (height-1)/2;
    int bottomHeight = height - topHeight - 1;
    long long baseX = (centralNodeX/width)*width;
    long long baseY = (centralNodeY/height)*height;
    
    [self.dotWorld.children enumerateObjectsUsingBlock:^(SKDot *dot, NSUInteger idx, BOOL *stop) {
        long long x = dot.point.x.longLongValue;
        long long y = dot.point.y.longLongValue;
        // we may happen to run into huge (bug-driven) differences
        // so just running loops may hang our program forever
        x = baseX + (x % width);
        y = baseY + (y % height);
        while (x > centralNodeX+rightWidth) {
            x -= width;
        }
        while (x < centralNodeX-leftWidth) {
            x += width;
        }
        while (y > centralNodeY+topHeight) {
            y -= height;
        }
        while (y < centralNodeY-bottomHeight) {
            y += height;
        }
        if (dot.point.x.longLongValue != x ||
            dot.point.y.longLongValue != y)
        {
            [dot setPointX:[NSNumber numberWithLongLong:x]
                         Y:[NSNumber numberWithLongLong:y]];
        }
    }];
    
    self.lastX = centralNodeX;
    self.lastY = centralNodeY;
}

-(void)dotsResizeToWidth:(NSUInteger)width heigth:(NSUInteger)height
{
    int deltaWidth  = width - self.lastWidth;
    int deltaHeight = height - self.lastHeight;
    int addWidth  = deltaWidth/2;
    int addHeight = deltaHeight/2;

    int rightWidth = (self.lastWidth-1)/2;
    int leftWidth = self.lastWidth - rightWidth - 1;
    int topHeight = (self.lastHeight-1)/2;
    int bottomHeight = self.lastHeight - topHeight - 1;
    
    double dotSize = DOT_SIZE;
    double cameraX = self.camera.position.x;
    double cameraY = self.camera.position.y;
    long long centralNodeX = cameraX / dotSize;
    long long centralNodeY = cameraY / dotSize;

    if (addWidth != 0)
    {
        if (addWidth > 0)
        {
            for (long long i = centralNodeX+rightWidth+1; i <= centralNodeX+rightWidth+addWidth; i++) {
                for (long long j = centralNodeY-bottomHeight; j <= centralNodeY+topHeight; j++) {
                    SKDot *dot = [[SKDot alloc] init];
                    dot.game = self.game;
                    dot.theScene = self;
                    [self.dotWorld addChild:dot];
                    [dot setPointX:[NSNumber numberWithLongLong:i]
                                 Y:[NSNumber numberWithLongLong:j]];
                }
            }
            for (long long i = centralNodeX-leftWidth-addWidth; i <= centralNodeX-leftWidth-1; i++) {
                for (long long j = centralNodeY-bottomHeight; j <= centralNodeY+topHeight; j++) {
                    SKDot *dot = [[SKDot alloc] init];
                    dot.game = self.game;
                    dot.theScene = self;
                    [self.dotWorld addChild:dot];
                    [dot setPointX:[NSNumber numberWithLongLong:i]
                                 Y:[NSNumber numberWithLongLong:j]];
                }
            }
        }
        else
        {
            [self.dotWorld.children
             enumerateObjectsUsingBlock:^(SKDot *dot, NSUInteger idx, BOOL *stop) {
                 long long x = dot.point.x.longLongValue;
                 if ((x < centralNodeX-leftWidth-addWidth) ||
                     (x > centralNodeX+rightWidth+addWidth)){
                     [dot removeFromParent];
                 }
             }];
        }
        // we have resized width
        self.lastWidth += addWidth*2;
        rightWidth = (self.lastWidth-1)/2;
        leftWidth = self.lastWidth - rightWidth - 1;
    }
    
    if (addHeight != 0)
    {
        if (addHeight > 0)
        {
            for (long long j = centralNodeY+topHeight+1; j <= centralNodeY+topHeight+addHeight; j++) {
                for (long long i = centralNodeX-leftWidth; i <= centralNodeX+rightWidth; i++) {
                    SKDot *dot = [[SKDot alloc] init];
                    dot.game = self.game;
                    dot.theScene = self;
                    [self.dotWorld addChild:dot];
                    [dot setPointX:[NSNumber numberWithLongLong:i]
                                 Y:[NSNumber numberWithLongLong:j]];
                }
            }
            for (long long j = centralNodeY-bottomHeight-addHeight; j <= centralNodeY-bottomHeight-1; j++) {
                for (long long i = centralNodeX-leftWidth; i <= centralNodeX+rightWidth; i++) {
                    SKDot *dot = [[SKDot alloc] init];
                    dot.game = self.game;
                    dot.theScene = self;
                    [self.dotWorld addChild:dot];
                    [dot setPointX:[NSNumber numberWithLongLong:i]
                                 Y:[NSNumber numberWithLongLong:j]];
                }
            }
        }
        else
        {
            [self.dotWorld.children
             enumerateObjectsUsingBlock:^(SKDot *dot, NSUInteger idx, BOOL *stop) {
                 long long y = dot.point.y.longLongValue;
                 if ((y < centralNodeY-bottomHeight-addHeight) ||
                     (y > centralNodeY+topHeight+addHeight)){
                     [dot removeFromParent];
                 }
             }];
        }
        self.lastHeight += addHeight*2;
    }
}

-(void)scrollOrShift
{
    double frameWidth = self.frame.size.width / self.world.xScale;
    double frameHeigh = self.frame.size.height / self.world.yScale;
    double dotSize    = DOT_SIZE;
    double cameraX = self.camera.position.x;
    double cameraY = self.camera.position.y;
    long long centralNodeX = cameraX / dotSize;
    long long centralNodeY = cameraY / dotSize;
    int width = frameWidth/dotSize+DOTS_OFFSET;
    int height = frameHeigh/dotSize+DOTS_OFFSET;
    
    [self dotsResizeToWidth:width
                     heigth:height];
    [self dotsShiftToX:centralNodeX y:centralNodeY];
}

-(void)enableBlur
{
    [self.blurNode setShouldEnableEffects:YES];
}
-(void)disableBlur
{
    [self.blurNode setShouldEnableEffects:NO];
}

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        [GameData sharedInstance].frameSize = self.frame.size;
        
        self.touches = [NSMutableSet new];
        self.bases = [NSMutableDictionary new];

        self.blurNode = [SKEffectNode node];
        self.blurNode.shouldEnableEffects = YES;
        self.blurNode.shouldRasterize = YES;
        CIFilter *blur = [CIFilter filterWithName:@"CIGaussianBlur" keysAndValues:@"inputRadius", @3.0f, nil];
        self.blurNode.filter = blur;
        [self addChild:self.blurNode];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self disableBlur];
        });
        
        self.anchorPoint = CGPointMake(0.5, 0.5);
        self.world = [SKNode node];
        [self.blurNode addChild:self.world];
        
        self.camera = [SKNode node];
        self.camera.name = @"camera";
        [self.world addChild:self.camera];
        
        self.dotWorld = [SKNode node];
        self.dotWorld.name = @"dotWorld";
        [self.world addChild:self.dotWorld];
        
        self.backgroundColor = [SKColor whiteColor];
        
        [self getLastGameOrCreate];
        
        [self.world setScale:[self minScale]*0.8+[self maxScale]*0.2];

        self.panels = [[Panels alloc] init];
        self.panels.zPosition = 1000;
        self.panels.position = CGPointMake(-self.frame.size.width/2,
                                           -self.frame.size.height/2);
        [self addChild:self.panels];
        [self.panels updateScores];
        
        [self redrawDots];
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
    self.lastLenBetweenFingers = -5;
    [touches enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
        [self.touches addObject:obj];
    }];
    [self.touches enumerateObjectsUsingBlock:^(UITouch *obj, BOOL *stop) {
        if ((obj.phase == UITouchPhaseEnded) ||
            (obj.phase == UITouchPhaseCancelled))
            [self.touches removeObject:obj];
    }];
    if (self.touches.count == 1) {
        self.itWasTapOnly = YES;
        self.lastTouchPosition = [touch locationInNode:self];
    }
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.touches enumerateObjectsUsingBlock:^(UITouch *obj, BOOL *stop) {
        if ((obj.phase == UITouchPhaseEnded) ||
            (obj.phase == UITouchPhaseCancelled))
            [self.touches removeObject:obj];
    }];
    if (self.touches.count > 1) {
        double maxLenBetweenFingers = 0;
        NSArray *touchesArray = [self.touches allObjects];
        for (int i = 0; i < touchesArray.count; i++) {
            for (int j = 0; j < touchesArray.count; j++) {
                if(i==j) continue;
                UITouch *t1 = touchesArray[i];
                UITouch *t2 = touchesArray[j];
                CGPoint t1position = [t1 locationInNode:self];
                CGPoint t2position = [t2 locationInNode:self];
                double dist = sqrt( pow(t1position.x-t2position.x, 2)
                                   +pow(t1position.y-t2position.y, 2));
                maxLenBetweenFingers = MAX(dist, maxLenBetweenFingers);
            }
        }
        if(self.lastLenBetweenFingers > 0)
        {
            double scale = self.world.xScale * maxLenBetweenFingers / self.lastLenBetweenFingers;
            scale = MAX(scale, [self minScale]);
            scale = MIN(scale, [self maxScale]);
            [self.world setScale:scale];
            [self scrollOrShift];
            self.lastLenBetweenFingers = maxLenBetweenFingers;
        }
        else
        {
            if (self.lastLenBetweenFingers == -1)
            {
                self.lastLenBetweenFingers = maxLenBetweenFingers;
            } else
            {
                self.lastLenBetweenFingers++;
            }
        }
    }
    else
    {
        UITouch *touch = [touches anyObject];
        CGPoint oldPosition = self.lastTouchPosition;
        CGPoint newPosition = [touch locationInNode:self];
        if(self.lastLenBetweenFingers == -5)
        {
            self.camera.position = CGPointMake(self.camera.position.x
                                               + (-newPosition.x + oldPosition.x)/self.world.xScale,
                                               self.camera.position.y
                                               + (-newPosition.y + oldPosition.y)/self.world.yScale);
            
            [self scrollOrShift];
        }
        self.lastTouchPosition = newPosition;
        if (self.lastLenBetweenFingers > 0) {
            self.lastLenBetweenFingers = -1;
        }
        else
        {
            if (self.lastLenBetweenFingers > -5) {
                self.lastLenBetweenFingers--;
            }
        }
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
    if(self.itWasTapOnly && touches.count == 1)
    {
        UITouch *touch = [touches anyObject];
        NSArray *nodes = [self nodesAtPoint:[touch locationInNode:self]];
        [nodes enumerateObjectsUsingBlock:^(SKNode *node, NSUInteger idx, BOOL *stop) {
            if ([node isKindOfClass:[SKDot class]]) {
                SKDot *dotNode = (SKDot*)node;
                [dotNode makeTurn];
            }
        }];
        self.itWasTapOnly = NO;
    }

    [touches enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
        [self.touches removeObject:obj];
    }];
    [self redrawDots];
}

-(void)update:(CFTimeInterval)currentTime {
}

@end
