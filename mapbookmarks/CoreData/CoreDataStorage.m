//
//  CoreDataStorage.m
//  mapbookmarks
//
//  Created by Коля on 04.07.15.
//  Copyright (c) 2015 Mykola Prokopiev. All rights reserved.
//

#import "CoreDataStorage.h"
#import "CoreDataManager.h"
#import "Bookmark.h"

@interface CoreDataStorage ()

@property (strong, nonatomic) NSManagedObjectContext    *managedObjectContext;
@property (strong, nonatomic) CoreDataManager           *coreDataManager;

@end

@implementation CoreDataStorage

#pragma mark - Accessors

- (NSManagedObjectContext*)managedObjectContext {
    
    if (!_managedObjectContext) {
        _managedObjectContext = [[CoreDataManager sharedManager] managedObjectContext];
    }
    return _managedObjectContext;
}

- (CoreDataManager *)coreDataManager {
    if (!_coreDataManager) {
        _coreDataManager = [CoreDataManager sharedManager];
    }
    return _coreDataManager;
}

+ (CoreDataStorage*)sharedStorage {
    static CoreDataStorage *storage = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        storage = [[CoreDataStorage alloc] init];
    });
    
    return storage;
}

#pragma mark Bookmark

- (void)createBookmarkNamed:(NSString *)name withLocation:(CLLocationCoordinate2D)location {
    
    CLLocation *bookmarkLocation = [[CLLocation alloc] initWithLatitude:location.latitude longitude:location.longitude];

    Bookmark *bookmark = (Bookmark *)[[CoreDataManager sharedManager] addNewManagedObjectForName:NSStringFromClass([Bookmark class])];
    bookmark.name = name;
    bookmark.location = bookmarkLocation;
    
    [self.coreDataManager saveContext];    
}

- (NSArray *)getAllBookmarks {
    
    NSArray *bookmarks = [self.coreDataManager getEntities:NSStringFromClass([Bookmark class])];
    return bookmarks;
}

@end
