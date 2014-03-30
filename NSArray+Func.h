//
//  NSArray+Func.h
//  test01
//
//  Created by dev on 11/8/13.
//  Copyright (c) 2013 dev. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (Func)

- (NSArray *) mapWithBlockIndexed:(id (^) (NSUInteger idx, id item))block;
- (NSArray *) map:(id (^) (id item))block;
- (id) reduce:(id (^) (id accumulator, id item))block withAccumulator:(id)accumulator;
- (id) reduce:(id (^) (id accumulator, id item))block;
- (NSArray *) filter:(BOOL (^) (NSUInteger idx, id item))block;

@end
