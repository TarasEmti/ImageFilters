//
//  TMExifTableViewController.h
//  SkillApp
//
//  Created by Тарас on 16.11.16.
//  Copyright © 2016 Тарас. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TMExifTableViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate>

- (id)initWithExifDict:(NSDictionary*)exifDict;

@end
