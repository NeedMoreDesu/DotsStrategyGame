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
#import "Textures.h"

@interface SKDot()

@end

@implementation SKDot

-(void)changeAccordingToDDot:(DDot*)dot
{
    if ([self.game isOccupied:dot.position]) {
        if (dot.belongsTo.shortValue == 0) {
            self.color = [UIColor blueColor];
            if (dot.baseAsOuter.count > 0) {
                self.color = [UIColor colorWithRed:0.5 green:0.5 blue:1.0 alpha:1.0];
            }
            if (dot.baseAsInner.count > 0) {
                self.color = [UIColor colorWithRed:0.0 green:0.0 blue:0.5 alpha:1.0];
            }
            return;
        }
        if (dot.belongsTo.shortValue == 1) {
            self.color = [UIColor redColor];
            if (dot.baseAsOuter.count > 0) {
                self.color = [UIColor colorWithRed:1.0 green:0.5 blue:0.5 alpha:1.0];
            }
            if (dot.baseAsInner.count > 0) {
                self.color = [UIColor colorWithRed:0.5 green:0.0 blue:0.0 alpha:1.0];
            }
            return;
        }
    }
    else
    {
        self.color = [UIColor whiteColor];
        if (dot.baseAsInner.count > 0) {
            self.color = [UIColor blackColor];
        }
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
    self.position = CGPointMake(x.longLongValue*DOT_SIZE, y.longLongValue*DOT_SIZE);
    DDot *dot = [self.game dotWithPoint:self.point];
    [self changeAccordingToDDot:dot];
}

-(instancetype)init
{
    self = [super init];
    if(self)
    {
        self.size = CGSizeMake(DOT_SIZE-DOT_INSET, DOT_SIZE-DOT_INSET);
        self.color = [UIColor whiteColor];
        self.name = @"dot";
        self.point = [DPoint temporaryObjectWithContext:[CoreData sharedInstance].mainMOC entity:nil];
    }
    return self;
}

@end
