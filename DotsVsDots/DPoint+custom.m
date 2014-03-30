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

@end
