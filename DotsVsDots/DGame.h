//
//  DGame.h
//  DotsVsDots
//
//  Created by baka on 3/30/14.
//  Copyright (c) 2014 baka. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DGrid;

@interface DGame : NSManagedObject

@property (nonatomic, retain) NSNumber * turn;
@property (nonatomic, retain) NSNumber * whoseTurn;
@property (nonatomic, retain) NSNumber * isPlaying;
@property (nonatomic, retain) DGrid *grid;

@end
