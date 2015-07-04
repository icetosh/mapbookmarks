//
//  CoreDataManager.h
//  mapbookmarks
//
//  Created by Коля on 04.07.15.
//  Copyright (c) 2015 Mykola Prokopiev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface CoreDataManager : NSObject

+(CoreDataManager*) sharedManager;

#pragma mark - CoreData

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

- (void)deleteManagedObject:(NSManagedObject*)object;
- (void)deleteCollection:(id<NSFastEnumeration>)collection;

- (NSManagedObject*)addNewManagedObjectForName:(NSString*)name;
- (NSArray*)getEntities:(NSString*)entityName byPredicate:(NSPredicate*)predicate;
- (NSArray*)getEntities:(NSString*)entityName;

@end
