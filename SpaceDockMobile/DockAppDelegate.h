//
//  DockAppDelegate.h
//  SpaceDockMobile
//
//  Created by Rob Tsuk on 10/14/13.
//  Copyright (c) 2013 Rob Tsuk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DockAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
