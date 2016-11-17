//
//  TMViewController.m
//  SkillApp
//
//  Created by Тарас on 11.11.16.
//  Copyright © 2016 Тарас. All rights reserved.
//

#import "TMViewController.h"
#import "TMHistoryCell.h"
#import "TMFilterFactory.h"
#import "TMExifTableViewController.h"

#import <CoreImage/CoreImage.h>

@interface TMViewController ()

- (IBAction)filterAction:(UIButton*)filterButton;
- (IBAction)exifRequest:(UIButton *)sender;

@property (weak, nonatomic) IBOutlet UIImageView *currentImage;
@property (weak, nonatomic) IBOutlet UITableView *historyTableView;
@property (weak, nonatomic) IBOutlet UIProgressView *downloadProgressBar;

@property (weak, nonatomic) UIButton *loadImageButton;
@property (strong, nonatomic) NSArray *imagesGroup;
@property (strong, nonatomic) UIView *loadingView;

@property (strong, nonatomic) TMExifInfo *dataCollector;
@property (strong, nonatomic) NSURL *assertURL;

@property (assign) int cellsFitInHeight;

@end

@implementation TMViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    //Number of cells you can see in TableView without scrolling
    _cellsFitInHeight = 3;
    
    _dataCollector = [[TMExifInfo alloc] init];
    _dataCollector.delegate = self;
    
    _historyTableView.tableFooterView = [UIView new];
    _historyTableView.delegate = self;
    _historyTableView.dataSource = self;
    
    _loadingView = [[UIView alloc] initWithFrame:_currentImage.frame];
    [_loadingView setHidden:YES];
    [[self view] addSubview:_loadingView];
    [[self view] addSubview:_downloadProgressBar];
    
    if (_currentImage.image == nil) {
        
        UIButton* loadImageButton = [UIButton buttonWithType:UIButtonTypeSystem];
        
        loadImageButton.frame = _currentImage.frame;
        loadImageButton.layer.borderWidth = 1;
        loadImageButton.layer.borderColor = [UIColor blackColor].CGColor;
        
        [loadImageButton setTitle:@"Выбрать изображение" forState:UIControlStateNormal];
        loadImageButton.titleLabel.adjustsFontSizeToFitWidth = YES;
        [loadImageButton addTarget:self action:@selector(selectCurrentImage) forControlEvents:UIControlEventTouchUpInside];
        _loadImageButton = loadImageButton;
        [self.view addSubview:loadImageButton];
    }
    
    UITapGestureRecognizer* tapCurrentRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectCurrentImage)];
    [_currentImage addGestureRecognizer:tapCurrentRecognizer];
    
    UITapGestureRecognizer* tapHistoryRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(historyCellSelected:)];
    [_historyTableView addGestureRecognizer:tapHistoryRecognizer];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Actions

- (void)selectCurrentImage {
    
    UIAlertController* imageOptions = [UIAlertController alertControllerWithTitle:@"Выберите источник" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction* gallery = [UIAlertAction actionWithTitle:@"Выбрать фото" style:UIAlertActionStyleDefault handler:^(UIAlertAction* _Nonnull action) {
        [self handleGallery];
    }];
    
    UIAlertAction* camera = [UIAlertAction actionWithTitle:@"Сделать фото" style:UIAlertActionStyleDefault handler:^(UIAlertAction* _Nonnull action) {
        [self handleCamera];
    }];
    
    UIAlertAction* loadImage = [UIAlertAction actionWithTitle:@"Загрузить из сети" style:UIAlertActionStyleDefault handler:^(UIAlertAction* _Nonnull action) {
        [self handleDownload];
    }];
    
    UIAlertAction* cancel= [UIAlertAction actionWithTitle:@"Отмена" style:UIAlertActionStyleCancel handler:^(UIAlertAction* _Nonnull action) {
        
    }];
    
    [imageOptions addAction:gallery];
    [imageOptions addAction:camera];
    [imageOptions addAction:loadImage];
    [imageOptions addAction:cancel];
    [self presentViewController:imageOptions animated:YES completion:nil];
}

- (IBAction)filterAction:(UIButton*)filterButton {
    
    if (_currentImage.image == nil) {
        
        UIAlertController* noImageError = [UIAlertController alertControllerWithTitle:@"Ошибка"
                                                                               message:@"Нет изображения для фильтра"
                                                                        preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* okButton = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
        
        [noImageError addAction:okButton];
        [self presentViewController:noImageError animated:YES completion:nil];
        
        return;
    }
    
    //Preparation for applying filter
    
    UIImage *originalImg = _currentImage.image;
    UIImage *resultImg;
    
    switch (filterButton.tag) {
        case 1: {
            
            resultImg = [TMFilterFactory rotateImage:originalImg byDegrees:90];
            break;
        }
            
        case 2: {
            
            resultImg = [TMFilterFactory applyMonochromeFilterOnImage:originalImg];
            break;
        }
            
        case 3: {
            
            resultImg = [TMFilterFactory mirrorImage:originalImg];
            break;
        }
            
        case 4: {
            
            resultImg = [TMFilterFactory invertColors:originalImg];
            break;
        }
            
        case 5: {
            
            resultImg = [TMFilterFactory mirrorLeftHalf:originalImg];
            break;
        }
            
        default:
            break;
    }
    
    if (resultImg) [self addCellWithImage:resultImg];
    
}

- (IBAction)exifRequest:(UIButton *)sender {
    
    if (_currentImage.image) {
        
        //TMExifTableViewController* exifView = [[TMExifTableViewController alloc] initWithExifDict:[TMExifInfo getExifDataFromURL:_assertURL]];
        //TMExifTableViewController* exifView = [[TMExifTableViewController alloc] initWithExifDict:exifData];
        
        //[self showViewController:exifView sender:self];
        [_dataCollector collectEXIFdata:_assertURL];
    }
}

- (void)historyCellSelected:(UITapGestureRecognizer*)sender {
    
    CGPoint tapLocation = [sender locationInView:_historyTableView];
    NSIndexPath* cellIndex = [_historyTableView indexPathForRowAtPoint:tapLocation];
    
    if (cellIndex) {
        
        TMHistoryCell* touchedCell = [_historyTableView cellForRowAtIndexPath:cellIndex];
        [touchedCell setHighlighted:YES];
        [self tableView:_historyTableView didSelectRowAtIndexPath:cellIndex];
    }
}

- (void)doneSavingImage:(UIImage*)image withError:(NSError*)error andContextInfo:(void*)contextInfo {
    
    UILabel* okWidndow = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2 - 50, self.view.frame.size.height/2 - 50, 100, 100)];
    
    okWidndow.layer.cornerRadius = 10;
    okWidndow.layer.masksToBounds = YES;
    
    okWidndow.text = @"✔️";
    okWidndow.textAlignment = NSTextAlignmentCenter;
    //okWidndow.opaque = NO;
    
    okWidndow.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1];
    [[self view] addSubview:okWidndow];
    
    [UIView animateWithDuration:2
                          delay:1
                        options:UIViewAnimationOptionTransitionCrossDissolve
                     animations:^{
                         okWidndow.alpha = 0.0;
                     }
                     completion:^(BOOL finished){
                         [okWidndow setHidden:finished];
                     }];
    
    NSLog(@"Where is the Grey View?");
}

- (void)handleDownload {
    
    UIAlertController* URLLinkCollector = [UIAlertController alertControllerWithTitle:@"Загрузить" message:@"Введите URL картинки" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* startDownload = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        UITextField *urlEnter = URLLinkCollector.textFields[0];
        NSString *urlText = [NSString stringWithString:urlEnter.text];
        
        if ([urlText hasSuffix:@"png"] || [urlText hasSuffix:@"jpg"] || [urlText hasSuffix:@"jpeg"]) {
            [_loadImageButton setHidden:YES];
            
            TMDownloadManager* downloadImage = [[TMDownloadManager alloc] init];
            downloadImage.delegate = self;
            [downloadImage downloadImageFromURL:urlText];
            
            [_downloadProgressBar setProgress:0.0];
            [_downloadProgressBar setHidden:NO];
            
    
            [_loadingView setBackgroundColor:[UIColor colorWithRed:0.0
                                                             green:0.0
                                                              blue:0.0
                                                             alpha:0.9]];
            [_loadingView setHidden:NO];
            
            [self dismissViewControllerAnimated:YES completion:nil];
            
        } else {
            
            [self handleError];
        }
    }];
    
    UIAlertAction* cancel = [UIAlertAction actionWithTitle:@"Отмена" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [self resignFirstResponder];
    }];
    
    [URLLinkCollector addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"URL";
        [textField setReturnKeyType:UIReturnKeyGo];
    }];
    
    [URLLinkCollector addAction:startDownload];
    [URLLinkCollector addAction:cancel];
    
    [self presentViewController:URLLinkCollector animated:YES completion:nil];
}

- (void)chageCurrentImage:(UIImage*)image andSourceURL:(NSURL*)url {
    
    _currentImage.image = image;
    _assertURL = url;
}

#pragma mark - TMExifInfoDelegate

- (void)dataCollected:(NSDictionary *)exifData {
    
    TMExifTableViewController* exifView = [[TMExifTableViewController alloc] initWithExifDict:exifData];
    
    [self showViewController:exifView sender:self];
}

#pragma mark - UIImagePickerController

- (void)handleGallery {
    
    UIImagePickerController* picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    //Uncomment if you need editing
    //picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)handleCamera {
    
    #if TARGET_IPHONE_SIMULATOR
    
    UIAlertController* noCameraError = [UIAlertController alertControllerWithTitle:@"Ошибка"
                                                                   message:@"Камера не поддерживается на симуляторе"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* okButton = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [noCameraError addAction:okButton];
    [self presentViewController:noCameraError animated:YES completion:nil];
    
    #elif TARGET_OS_IPHONE
    
    UIImagePickerController* picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    //Uncomment if you need editing
    //picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    [self presentViewController:picker animated:YES completion:nil];
    
    #endif
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
    UIImage *chosenImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    NSURL* url = [info objectForKey:UIImagePickerControllerReferenceURL];
    //NSURL *url = [info objectForKey:UIImagePickerControllerMediaURL];
    
    [self chageCurrentImage:chosenImage andSourceURL:url];
    
    if (_loadImageButton.hidden == NO) {
        [_loadImageButton setHidden:YES];
    }
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [_imagesGroup count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    TMHistoryCell *cell = [tableView dequeueReusableCellWithIdentifier:@"imageTransformed" forIndexPath:indexPath];
    cell.imageFiltered.image = [_imagesGroup objectAtIndex:indexPath.row];
    
    return cell;
}

- (void)addCellWithImage:(UIImage*)image {
    
    int insertIndex = 0;
    int insertSection = 0;
    
    NSMutableArray* newPicturesArray = [[NSMutableArray alloc] initWithArray:_imagesGroup];
    [newPicturesArray insertObject:image atIndex:insertIndex];
    NSArray* newArray = [NSArray arrayWithArray:newPicturesArray];
    _imagesGroup = newArray;
    
    [_historyTableView beginUpdates];
    
    NSIndexPath *insertRow = [NSIndexPath indexPathForRow:insertIndex inSection:insertSection];
    NSArray *indexArray = [NSArray arrayWithObject:insertRow];
    [_historyTableView insertRowsAtIndexPaths:indexArray
                             withRowAnimation:UITableViewRowAnimationTop];
    
    [_historyTableView endUpdates];
}

#pragma mark - UITableViewDelegate

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UIAlertController* imageOptions = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction* use = [UIAlertAction actionWithTitle:@"Использовать" style:UIAlertActionStyleDefault handler:^(UIAlertAction* _Nonnull action) {
        
        TMHistoryCell *selectedCell = [_historyTableView cellForRowAtIndexPath:indexPath];
        _currentImage.image = selectedCell.imageFiltered.image;
        [selectedCell setHighlighted:NO];
    }];
    
    UIAlertAction* save = [UIAlertAction actionWithTitle:@"Сохранить" style:UIAlertActionStyleDefault handler:^(UIAlertAction* _Nonnull action) {
        
        TMHistoryCell *selectedCell = [_historyTableView cellForRowAtIndexPath:indexPath];
        [selectedCell setHighlighted:NO];
        
        UIImageWriteToSavedPhotosAlbum(selectedCell.imageFiltered.image, self, @selector(doneSavingImage:withError:andContextInfo:), nil);
    }];
    
    UIAlertAction* delete = [UIAlertAction actionWithTitle:@"Удалить" style:UIAlertActionStyleDestructive handler:^(UIAlertAction* _Nonnull action) {
        
        NSMutableArray* newPicturesArray = [[NSMutableArray alloc] initWithArray:_imagesGroup];
        [newPicturesArray removeObjectAtIndex:indexPath.row];
        NSArray* newArray = [NSArray arrayWithArray:newPicturesArray];
        _imagesGroup = newArray;
        
        [_historyTableView beginUpdates];
        
        [_historyTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                                 withRowAnimation:UITableViewRowAnimationFade];
        
        [_historyTableView endUpdates];
    }];
    
    UIAlertAction* cancel= [UIAlertAction actionWithTitle:@"Отмена" style:UIAlertActionStyleCancel handler:^(UIAlertAction* _Nonnull action) {
        
        TMHistoryCell *selectedCell = [_historyTableView cellForRowAtIndexPath:indexPath];
        [selectedCell setHighlighted:NO];
    }];
    
    [imageOptions addAction:use];
    [imageOptions addAction:save];
    [imageOptions addAction:delete];
    [imageOptions addAction:cancel];
    
    [self presentViewController:imageOptions animated:YES completion:nil];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat cellSize = [[self view] frame].size.height / (_cellsFitInHeight * 2);
    return cellSize;
}

#pragma mark - TMDownloadManagerDelegate

- (void)progressChanged:(float)progress {
    
    [_downloadProgressBar setProgress:progress];
}

- (void)imageDidLoad:(UIImage *)image fromURL:(NSURL *)url {
    
    [_downloadProgressBar setHidden:YES];
    [_loadingView setHidden:YES];
    
    if (_loadImageButton.hidden == NO) {
        [_loadImageButton setHidden:YES];
    }
    [self chageCurrentImage:image andSourceURL:url];
}

- (void)handleError {
    
    [_downloadProgressBar setHidden:YES];
    [_loadingView setHidden:YES];
    
    if (_currentImage.image == nil) {
        [_loadImageButton setHidden:NO];
    }
    
    UIAlertController* wrongUrl = [UIAlertController alertControllerWithTitle:@"Error" message:@"Invalid URL" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
    [wrongUrl addAction:ok];
    [self presentViewController:wrongUrl animated:YES completion:nil];
}

@end
