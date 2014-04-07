//
//  DPoint+custom.m
//  DotsVsDots
//
//  Created by baka on 3/23/14.
//  Copyright (c) 2014 baka. All rights reserved.
//

#import "DPoint+custom.h"

@implementation DPoint (custom)

- (BOOL)equal:(DPoint*)point
{
    return ((self.x.longLongValue == point.x.longLongValue) &&
            (self.y.longLongValue == point.y.longLongValue));
}

- (DPoint*)setX:(NSNumber*)x Y:(NSNumber*)y
{
    self.x = x;
    self.y = y;
    return self;
}

- (DPoint*)setWithPoint:(DPoint*)point
{
    self.x = point.x;
    self.y = point.y;
    return self;
}

- (NSArray*)XY
{
    return @[self.x, self.y];
}

- (NSArray*)addXY:(NSArray*)XY
{
    NSNumber *directionX = XY[0];
    NSNumber *directionY = XY[1];
    NSNumber *x = [NSNumber numberWithLongLong:
                   self.x.longLongValue
                   + directionX.longLongValue];
    NSNumber *y = [NSNumber numberWithLongLong:
                   self.y.longLongValue
                   + directionY.longLongValue];
    return @[x, y];
}

- (DPoint*)setXY:(NSArray*)XY
{
    self.x = XY[0];
    self.y = XY[1];
    return self;
}

@end
