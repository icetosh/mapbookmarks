//
//  CoreDataManager.m
//  mapbookmarks
//
//  Created by Коля on 04.07.15.
//  Copyright (c) 2015 Mykola Prokopiev. All rights reserved.
//

#import "CoreDataManager.h"
#import <UIKit/UIKit.h>

@implementation CoreDataManager

+(CoreDataManager*) sharedManager {
    static CoreDataManager *manager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[CoreDataManager alloc] init];
    });
    
    return manager;
}

#pragma mark - Lifecycle

- (id)init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleContextDidSaveNotification:) name:NSManagedObjectContextDidSaveNotification object:nil];
    }
    
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Show error

-(void) showError:(NSError*)error {
    
    if (error == nil)
        return;
    
    NSMutableString *errStr = [NSMutableString stringWithString: NSLocalizedString(@"Error", nil)];
    
    if (error.code)
        [errStr appendFormat:@": %ld", (long)error.code];
    
    // If the user info dictionary doesn’t contain a value for NSLocalizedDescriptionKey
    // error.localizedDescription is constructed from domain and code by default
    [errStr appendFormat:@"\n%@", error.localizedDescription];
    
    if (error.localizedFailureReason)
        [errStr appendFormat:@"\n%@", error.localizedFailureReason];
    
    if (error.localizedRecoverySuggestion)
        [errStr appendFormat:@"\n%@", error.localizedRecoverySuggestion];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Core Data" message:errStr delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
    
    [alert show];
    
}

#pragma mark - Core Data stack

@synthesize managedObjectContext        = _managedObjectContext;
@synthesize managedObjectModel          = _managedObjectModel;
@synthesize persistentStoreCoordinator  = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "euginity.CoreDataDevelopment" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"MapBookmarks" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"CoreDataDevelopment.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - Deletion

- (void)deleteManagedObject:(NSManagedObject*)object {
    [self.managedObjectContext deleteObject:object];
    [self saveContext];
}

- (void)deleteCollection:(id<NSFastEnumeration>)collection {
    for (NSManagedObject *managedObject in collection) {
        [self.managedObjectContext deleteObject:managedObject];
    }
    [self saveContext];
}

#pragma mark - Creation

- (NSManagedObject*)addNewManagedObjectForName:(NSString*)name {
    return [NSEntityDescription insertNewObjectForEntityForName:name inManagedObjectContext:self.managedObjectContext];
}

#pragma mark - Actions

- (NSArray*)executeRequest:(NSFetchRequest*)fetchRequest {
    NSArray *managedObjects = nil;
    
    NSError *error = nil;
    managedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if (error) {
        [self showError:error];
        managedObjects = nil;
    }
    return managedObjects;
}

- (NSArray*)getEntities:(NSString*)entityName byPredicate:(NSPredicate*)predicate {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:entityName];
    
    if (predicate)
        [fetchRequest setPredicate:predicate];
    
    NSArray *items = [self executeRequest:fetchRequest];
    
    if (items.count)
        return items;
    
    return nil;
}

- (NSArray*)getEntities:(NSString*)entityName {
    return [self getEntities:entityName byPredicate:nil];
}

#pragma mark - NSNotification handler

- (void)handleContextDidSaveNotification:(NSNotification*)notification {
    NSManagedObjectContext *incomingContext = notification.object;
    
    if (!_managedObjectContext || _managedObjectContext == incomingContext) return;
    
    [_managedObjectContext mergeChangesFromContextDidSaveNotification:notification];
}

@end
