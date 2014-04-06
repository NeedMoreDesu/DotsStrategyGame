//
//  SKDot.m
//  DotsVsDots
//
//  Created by baka on 4/1/14.
//  Copyright (c) 2014 baka. All rights reserved.
//

#import "SKDot.h"
#import "CoreData.h"
#import "DDot+custom.h"
#import "DGame+custom.h"
#import "MyScene.h"

@interface SKDot()

@end

@implementation SKDot

-(void)changeAccordingToDDot:(DDot*)dot
{
    if (dot) {
        self.texture = nil;
        if (dot.belongsTo.shortValue == 0) {
            self.color = [UIColor blueColor];
            return;
        }
        self.color = [UIColor redColor];
    }
    else
    {
        self.texture = [SKTexture textureWithImageNamed:@"Spaceship.png"];
    }
}

-(void)makeTurn
{
    DDot *dot = [self.game makeTurn:self.point];
    [self changeAccordingToDDot:dot];
}

-(void)setPointX:(NSNumber*)x Y:(NSNumber*)y
{
    [self.point setX:x Y:y];
    self.position = CGPointMake(x.longLongValue*self.size.width, y.longLongValue*self.size.height);
    DDot *dot = [self.game dotWithPoint:self.point];
    [self changeAccordingToDDot:dot];
}

-(instancetype)init
{
    self = [super init];
    if(self)
    {
        self.size = CGSizeMake(DOT_SIZE, DOT_SIZE);
        self.texture = [SKTexture textureWithImageNamed:@"Spaceship.png"];
        self.color = [UIColor redColor];
        self.name = @"dot";
        self.point = [DPoint temporaryObjectWithContext:[CoreData sharedInstance].mainMOC entity:nil];
    }
    return self;
}

@end
