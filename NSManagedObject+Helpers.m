/// Copyright © 2013 NeedMoreDesu desu@horishniy.org.ua
//
/// This program is free software. It comes without any warranty, to
/// the extent permitted by applicable law. You can redistribute it
/// and/or modify it under the terms of the Do What The Fuck You Want
/// To Public License, Version 2, as published by Sam Hocevar. See
/// http://www.wtfpl.net/ for more details.

#import "NSManagedObject+Helpers.h"
#import "NSManagedObjectContext+Helpers.h"
#import <objc/runtime.h>

@implementation NSManagedObject (Helpers)

+ (NSEntityDescription*)setupEntity:(id)entityNameOrClass
                        withContext:(NSManagedObjectContext*)context;
{
    if(class_isMetaClass(object_getClass(entityNameOrClass)))
        // if class
        return [NSEntityDescription
                entityForName:NSStringFromClass(entityNameOrClass)
                inManagedObjectContext:context];
    else if([entityNameOrClass isKindOfClass:[NSString class]])
        return [NSEntityDescription
                entityForName:entityNameOrClass
                inManagedObjectContext:context];
    else
        return
        [NSEntityDescription
         entityForName:NSStringFromClass([self class])
         inManagedObjectContext:context];
}

+ (id)temporaryObjectWithContext:(NSManagedObjectContext *)context
                          entity:(id)entityNameOrClass
{
    NSEntityDescription *entity = [self
                                   setupEntity:entityNameOrClass
                                   withContext:context];
    
    return [[[self class] alloc]
            initWithEntity:entity
            insertIntoManagedObjectContext:nil];
}

- (id)temporaryObjectWithContext:(NSManagedObjectContext *)context
                          entity:(id)entityNameOrClass
{
    NSEntityDescription *entity = [[self class]
                                   setupEntity:entityNameOrClass
                                   withContext:context];
    
    NSManagedObject *obj = [[[self class] alloc]
                            initWithEntity:entity
                            insertIntoManagedObjectContext:nil];
    
    [obj setValuesForKeysWithDictionary:
     [self dictionaryWithValuesForKeys:
      [entity attributesByName].allKeys]];
    
    return obj;
}

- (id)insertToContext:(NSManagedObjectContext*)context
{
    [context insertObject:self];
    return self;
}

+ (id)newObjectWithContext:(NSManagedObjectContext *)context
                    entity:(id)entityNameOrClass
{
    return [[self
             temporaryObjectWithContext:context
             entity:entityNameOrClass]
            insertToContext:context];
}

- (id)newObjectWithContext:(NSManagedObjectContext *)context
                    entity:(id)entityNameOrClass
{
    return [[self
             temporaryObjectWithContext:context
             entity:entityNameOrClass]
            insertToContext:context];
}

@end
