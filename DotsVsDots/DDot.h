//
//  DDot.h
//  DotsVsDots
//
//  Created by baka on 3/23/14.
//  Copyright (c) 2014 baka. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DGrid, DPoint;

@interface DDot : NSManagedObject

@property (nonatomic, retain) NSNumber * belongsTo;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSNumber * move;
@property (nonatomic, retain) DGrid *grid;
@property (nonatomic, retain) DPoint *position;

@end
