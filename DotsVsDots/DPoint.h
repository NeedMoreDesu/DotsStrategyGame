//
//  DPoint.h
//  DotsStrategyGame
//
//  Created by baka on 4/15/14.
//  Copyright (c) 2014 baka. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DDot, DGrid;

@interface DPoint : NSManagedObject

@property (nonatomic, retain) NSNumber * x;
@property (nonatomic, retain) NSNumber * y;
@property (nonatomic, retain) DDot *dot;
@property (nonatomic, retain) DGrid *grid;

@end
