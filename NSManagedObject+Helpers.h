/// Copyright © 2013 NeedMoreDesu desu@horishniy.org.ua
//
/// This program is free software. It comes without any warranty, to
/// the extent permitted by applicable law. You can redistribute it
/// and/or modify it under the terms of the Do What The Fuck You Want
/// To Public License, Version 2, as published by Sam Hocevar. See
/// http://www.wtfpl.net/ for more details.

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface NSManagedObject (Helpers)

// if entityNameOrClass is nil, will try to use current class name as entity name

+ (id)temporaryObjectWithContext:(NSManagedObjectContext *)context
                          entity:(id)entityNameOrClass;
- (id)temporaryObjectWithContext:(NSManagedObjectContext *)context
                          entity:(id)entityNameOrClass;

- (id)insertToContext:(NSManagedObjectContext*)context;

+ (id)newObjectWithContext:(NSManagedObjectContext *)context
                    entity:(id)entityNameOrClass;
- (id)newObjectWithContext:(NSManagedObjectContext *)context
                    entity:(id)entityNameOrClass;

@end
