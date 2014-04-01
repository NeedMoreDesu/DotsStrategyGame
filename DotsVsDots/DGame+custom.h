//
//  DGame+custom.h
//  DotsVsDots
//
//  Created by baka on 3/30/14.
//  Copyright (c) 2014 baka. All rights reserved.
//

#import "DGame.h"
#import "DGrid+custom.h"
#import "DPoint+custom.h"
#import "DDot+custom.h"

@interface DGame (custom)

-(DDot*)dotWithPoint:(DPoint*)point;
-(BOOL)isOccupied:(DPoint*)point;

-(DDot*)makeTurn:(DPoint*)point;

@end
