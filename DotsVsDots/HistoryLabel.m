//
//  HistoryLabel.m
//  DotsStrategyGame
//
//  Created by dev on 5/19/14.
//  Copyright (c) 2014 baka. All rights reserved.
//

#import "HistoryLabel.h"
#import "DPoint+custom.h"

@implementation HistoryLabel

-(void)setDot:(DDot *)dot
{
    _dot = dot;
    if (self.dot) {
        self.text = [NSString stringWithFormat:@"%@: [%@, %@]", self.dot.turn, self.dot.position.x, self.dot.position.y];
        self.fontColor = self.dot.turn.intValue%2==0 ? [UIColor blueColor] : [UIColor redColor];
    } else {
        self.text = @"----------";
        self.fontColor = [UIColor blackColor];
    }
}

@end
