//
//  DPoint+custom.h
//  DotsVsDots
//
//  Created by baka on 3/23/14.
//  Copyright (c) 2014 baka. All rights reserved.
//

#import "DPoint.h"

@interface DPoint (custom)

- (BOOL)equal:(DPoint*)point;
- (DPoint*)setX:(NSNumber*)x Y:(NSNumber*)y;
- (DPoint*)setWithPoint:(DPoint*)point;

@end
