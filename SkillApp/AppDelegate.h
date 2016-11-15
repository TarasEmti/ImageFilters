//
//  AppDelegate.h
//  SkillApp
//
//  Created by Тарас on 09.11.16.
//  Copyright © 2016 Тарас. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;

@end

