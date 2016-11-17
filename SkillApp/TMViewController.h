//
//  TMViewController.h
//  SkillApp
//
//  Created by Тарас on 11.11.16.
//  Copyright © 2016 Тарас. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TMDownloadManager.h"
#import "TMExifInfo.h"

@interface TMViewController : UIViewController <UINavigationControllerDelegate,UIImagePickerControllerDelegate, UITableViewDelegate, UITableViewDataSource, TMDownloadManagerDelegate, TMExifInfoDelegate>

@end
