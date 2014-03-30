/// Copyright © 2013 NeedMoreDesu desu@horishniy.org.ua
//
/// This program is free software. It comes without any warranty, to
/// the extent permitted by applicable law. You can redistribute it
/// and/or modify it under the terms of the Do What The Fuck You Want
/// To Public License, Version 2, as published by Sam Hocevar. See
/// http://www.wtfpl.net/ for more details.

#import <CoreData/CoreData.h>

@interface NSManagedObjectContext (Helpers)

//descriptor and predicate can be nil, limit can be 0 (no limit)
- (NSArray *)fetchObjectsForEntityName:(NSString *)entityName
                       sortDescriptors:(NSArray *)descriptors
                                 limit:(NSUInteger)limit
                             predicate:(id)stringOrPredicate, ...;

//sectionNameKeyPath can be nil too
- (NSFetchedResultsController *)fetchedControllerForEntityName:(NSString *)entityName
                                               sortDescriptors:(NSArray *)descriptors
                                                         limit:(NSUInteger)limit
                                                     batchSize:(NSUInteger)batchSize
                                            sectionNameKeyPath:(NSString*)sectionNameKeyPath
                                                     cacheName:(NSString*)cacheName
                                     fetchedControllerDelegate:(id)delegate
                                                     predicate:(id)stringOrPredicate, ...;

@end
