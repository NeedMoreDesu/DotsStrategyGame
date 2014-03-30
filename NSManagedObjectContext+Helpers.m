/// Copyright © 2013 NeedMoreDesu desu@horishniy.org.ua
//
/// This program is free software. It comes without any warranty, to
/// the extent permitted by applicable law. You can redistribute it
/// and/or modify it under the terms of the Do What The Fuck You Want
/// To Public License, Version 2, as published by Sam Hocevar. See
/// http://www.wtfpl.net/ for more details.

#import "NSManagedObjectContext+Helpers.h"
#import "NSArray+Func.h"

@implementation NSManagedObjectContext (Helpers)

- (NSArray *)fetchObjectsForEntityName:(NSString *)entityName
                       sortDescriptors:(NSArray *)descriptors
                                 limit:(NSUInteger)limit
                             predicate:(id)stringOrPredicate, ...
{
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:entityName
                                   inManagedObjectContext:self];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    if (descriptors)
    {
        descriptors = [descriptors map:^id(id item) {
            if ([item isKindOfClass:[NSArray class]])
            {
                NSAssert([item count] == 2 &&
                         [item[0] isKindOfClass:[NSString class]] &&
                         [item[1] isKindOfClass:[NSNumber class]],
                         @"Wrong sort descriptor array format");
                return [[NSSortDescriptor alloc]
                        initWithKey:item[0]
                        ascending:[item[1] boolValue]];
            }
            return item;
        }];
        [request setSortDescriptors:descriptors];
    }
    [request setFetchLimit:limit];
    
    if (stringOrPredicate)
    {
        NSPredicate *predicate;
        if ([stringOrPredicate isKindOfClass:[NSString class]])
        {
            va_list variadicArguments;
            va_start(variadicArguments, stringOrPredicate);
            predicate = [NSPredicate predicateWithFormat:stringOrPredicate
                                               arguments:variadicArguments];
            va_end(variadicArguments);
        }
        else
        {
            NSAssert2([stringOrPredicate isKindOfClass:[NSPredicate class]],
                      @"Second parameter passed to %s is of unexpected class %@",
                      sel_getName(_cmd), NSStringFromClass([stringOrPredicate class]));
            predicate = (NSPredicate *)stringOrPredicate;
        }
        [request setPredicate:predicate];
    }
    
    NSError *error = nil;
    NSArray *results = [self executeFetchRequest:request error:&error];
    if (error != nil)
    {
        [NSException raise:NSGenericException format:@"%@",[error description]];
    }
    
    return results;
}

- (NSFetchedResultsController *)fetchedControllerForEntityName:(NSString *)entityName
                                               sortDescriptors:(NSArray *)descriptors
                                                         limit:(NSUInteger)limit
                                                batchSize:(NSUInteger)batchSize
                                            sectionNameKeyPath:(NSString*)sectionNameKeyPath
                                                     cacheName:(NSString*)cacheName
                                     fetchedControllerDelegate:(id)delegate
                                                     predicate:(id)stringOrPredicate, ...
{
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:entityName
                                   inManagedObjectContext:self];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    if (descriptors)
    {
        descriptors = [descriptors map:^id(id item) {
            if ([item isKindOfClass:[NSArray class]])
            {
                NSAssert([item count] == 2 &&
                         [item[0] isKindOfClass:[NSString class]] &&
                         [item[1] isKindOfClass:[NSNumber class]],
                         @"Wrong sort descriptor array format");
                return [[NSSortDescriptor alloc]
                        initWithKey:item[0]
                        ascending:[item[1] boolValue]];
            }
            return item;
        }];
        [request setSortDescriptors:descriptors];
    }
    [request setFetchLimit:limit];
    [request setFetchBatchSize:batchSize];
    
    if (stringOrPredicate)
    {
        NSPredicate *predicate;
        if ([stringOrPredicate isKindOfClass:[NSString class]])
        {
            va_list variadicArguments;
            va_start(variadicArguments, stringOrPredicate);
            predicate = [NSPredicate predicateWithFormat:stringOrPredicate
                                               arguments:variadicArguments];
            va_end(variadicArguments);
        }
        else
        {
            NSAssert2([stringOrPredicate isKindOfClass:[NSPredicate class]],
                      @"Second parameter passed to %s is of unexpected class %@",
                      sel_getName(_cmd), NSStringFromClass([stringOrPredicate class]));
            predicate = (NSPredicate *)stringOrPredicate;
        }
        [request setPredicate:predicate];
    }
    
    [NSFetchedResultsController deleteCacheWithName:cacheName];
    NSFetchedResultsController *result = [[NSFetchedResultsController alloc]
                                          initWithFetchRequest:request
                                          managedObjectContext:self
                                          sectionNameKeyPath:sectionNameKeyPath
                                          cacheName:cacheName];
    result.delegate = delegate;
    
    return result;
}


@end
