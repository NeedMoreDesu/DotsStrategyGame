//
//  Grid+custom.h
//  DotsVsDots
//
//  Created by baka on 3/23/14.
//  Copyright (c) 2014 baka. All rights reserved.
//

#import "DGrid.h"
#import "DDot+custom.h"
#import "DPoint+custom.h"

@interface DGrid (custom)

- (DDot*)dotAtPoint:(DPoint*)point lastGrid:(DGrid**)grid;
- (DDot*)getOrCreateDotAtPoint:(DPoint*)point lastGrid:(DGrid**)grid;

- (void)setupStartingGrid;

@end
