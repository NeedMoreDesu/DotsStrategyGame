//
//  DDot.h
//  DotsStrategyGame
//
//  Created by baka on 4/6/14.
//  Copyright (c) 2014 baka. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DBase, DGrid, DPoint;

@interface DDot : NSManagedObject

@property (nonatomic, retain) NSNumber * belongsTo;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSNumber * turn;
@property (nonatomic, retain) DGrid *grid;
@property (nonatomic, retain) DPoint *position;
@property (nonatomic, retain) DBase *baseAsOuter;
@property (nonatomic, retain) DBase *baseAsInner;

@end
