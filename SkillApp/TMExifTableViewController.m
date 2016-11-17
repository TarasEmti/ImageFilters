//
//  TMExifTableViewController.m
//  SkillApp
//
//  Created by Тарас on 16.11.16.
//  Copyright © 2016 Тарас. All rights reserved.
//

#import "TMExifTableViewController.h"

@interface TMExifTableViewController ()

@property (strong, nonatomic) NSArray *keysExif;
@property (strong, nonatomic) NSDictionary* exif;

@end

@implementation TMExifTableViewController

- (id)initWithExifDict:(NSDictionary*)exifDict {
    self = [super init];
    
    self.exif = exifDict;
    NSArray* keysArray = [exifDict allKeys];
    self.keysExif = [keysArray sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [UIView new];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [self.keysExif count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
    
    NSString *option = [NSString stringWithFormat:@"%@", [_keysExif objectAtIndex:indexPath.row]];
    NSString *detail = [NSString stringWithFormat:@"%@", [_exif valueForKey:[_keysExif objectAtIndex:indexPath.row]]];
    NSString *detailClean = [detail stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    
    cell.textLabel.text = option;
    cell.detailTextLabel.text = [detailClean stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

@end
