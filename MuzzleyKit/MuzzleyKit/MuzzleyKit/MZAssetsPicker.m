//
//  MZAssetsPicker.m
//  muzzley-sdk-ios
//
//  Created by Hugo Sousa on 19/02/13.
//  Copyright (c) 2013 Muzzley. All rights reserved.
//

#import "MZAssetsPicker.h"

#import <QuartzCore/QuartzCore.h>

#import "AFHTTPRequestOperationManager.h"
#import "AFHTTPRequestOperation.h"

#import "MZUserClient.h"
#import "MZPhotoAssetCell.h"
#import "ImageHelpers.h"
#import "MZError.h"
@interface MZAssetsPicker ()

#define RANDOM_KEY_ALPHANUMERIC_SIZE 4

/// Internal state
typedef enum : NSUInteger {
    I_STATE_DEFAULT = 0,
    I_STATE_PREPARING_FOR_UPLOAD = 1,
    I_STATE_UPLOADING = 2,
    I_STATE_CANCEL = 3
    
} IState;

@property (nonatomic, assign) IState state;

@property (nonatomic, strong, readwrite) AFHTTPRequestOperationManager *httpPhotoUploader;

@property (nonatomic, strong) ALAssetsLibrary *assetsLibrary;
@property (nonatomic, strong) NSMutableArray *assetGroups;
@property (nonatomic, strong) NSMutableDictionary *selectedThumbnailsDictionary;

@property (nonatomic, strong) NSOperationQueue *worker;
@property (nonatomic, strong) NSMutableArray *executingOperations;

@property (nonatomic, strong, readwrite) IBOutlet UIButton *buttonShare;
@property (nonatomic, strong, readwrite) IBOutlet UILabel *selectionBar;
@property (nonatomic, strong, readwrite) IBOutlet UIView *progressBar;
@property (nonatomic, strong, readwrite) IBOutlet UITableView *tableView;
@property (nonatomic, strong, readwrite) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong, readwrite) IBOutlet UIView *permissionInformationView;
@property (nonatomic, strong, readwrite) IBOutlet UILabel *permissionInformationLabel;


@property (nonatomic, assign) NSUInteger selectedMediaItemsTotalCount;
@property (nonatomic, copy) NSString* contextKey;

@property (nonatomic, strong) UIAlertView *alertView;

- (void)_doCancelAssetsSharing;

@end

@implementation MZAssetsPicker

@synthesize buttonShare;
@synthesize selectionBar;
@synthesize progressBar;
@synthesize tableView;
@synthesize activityIndicator;
@synthesize permissionInformationView;
@synthesize permissionInformationLabel;

- (void)dealloc
{
    [self.alertView dismissWithClickedButtonIndex:-1 animated:NO];
    self.alertView = nil;
    
    [[NSNotificationCenter defaultCenter]
        removeObserver:self
        name:UIApplicationDidBecomeActiveNotification
        object:nil];
    
    /// If is Uploading
    if (self.executingOperations.count != 0) { 
        /// cancels and sends message cancel sharing
        [self cancelAllUploadOperations];
        
    } else { /// Ignore dealloc is called at the begining when the Asset Picker is created
        if (self.state != I_STATE_DEFAULT) {
            /// cancels without sending message cancel sharing
            
            [self setInternalState:I_STATE_CANCEL];
            [self cancelAllUploadOperations];
        }
    }
}

#pragma mark Initializers
-(id)initWithParameters:(NSDictionary*)parameters
{
    UIStoryboard *muzzleyKitStoryboard = [UIStoryboard storyboardWithName:@"MuzzleyKitStoryboard_iPhone" bundle:[NSBundle mainBundle]];
    MZAssetsPicker *assetsPicker = [muzzleyKitStoryboard instantiateViewControllerWithIdentifier:@"MZAssetsPicker"];
    self = assetsPicker;
    
    if (self) {
        self.parameters = parameters;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.httpPhotoUploader = [AFHTTPRequestOperationManager manager];
    
    self.worker = [NSOperationQueue new];
    self.worker.name = @"worker";
    
    if (!self.assetsLibrary)
        self.assetsLibrary = [ALAssetsLibrary new];
    
    
    if (!self.assetGroups)
        self.assetGroups = [NSMutableArray new];
    else
        [self.assetGroups removeAllObjects];
    
    if (!self.selectedThumbnailsDictionary) 
        self.selectedThumbnailsDictionary = [NSMutableDictionary new];
    else 
        [self.selectedThumbnailsDictionary removeAllObjects];
    
    self.executingOperations = [NSMutableArray new];

    [[NSNotificationCenter defaultCenter]
        removeObserver:self
                  name:UIApplicationDidBecomeActiveNotification
                object:nil];
    
    [[NSNotificationCenter defaultCenter]
        addObserver:self
           selector:@selector(applicationDidBecomeActiveNotificationHandler)
               name:UIApplicationDidBecomeActiveNotification
             object:nil];
    
    [self setUIStateShareButton];
    [self setInternalState:I_STATE_DEFAULT];

    [self performALAssetsLibraryGroupsEnumeration];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.activityIndicator stopAnimating];
    self.tableView.alpha = 0;
    //self.progressBar.frame = CGRectMake(self.progressBar.frame.origin.x, self.progressBar.frame.origin.y, 0, 2);
}

#pragma mark - View Rotation
-(BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

#pragma mark - ALAssets Library Groups Enumeration
- (void) performALAssetsLibraryGroupsEnumeration
{
    /// Self weak reference
    MZAssetsPicker * __weak _self = self;
    
    ALAssetsLibraryGroupsEnumerationResultsBlock listGroupBlock =
    ^(ALAssetsGroup *group,BOOL *stop) {
        
        if (!_self) return;
        
        if (group) {
            /// If a group doesn´t have any assets, it´s discarded
            if (group.numberOfAssets != 0) {
                
                /// Create a dictionary to save a representation of each ALAssetsGroups
                NSMutableDictionary *assetGroupsDictionary = [[NSMutableDictionary alloc] init];
                /// Store group object
                [assetGroupsDictionary setObject:group forKey:@"assetGroup"];
                /// Create and store an array where all assets will be stored
                NSMutableArray *assets = [[NSMutableArray alloc] init];
                [assetGroupsDictionary setObject:assets forKey:@"assets"];
                
                /// Save each group representation on groupsLibrary
                [_self.assetGroups addObject: assetGroupsDictionary];
                
                /// Define a filter by asset's type
                ALAssetsFilter *allAssetsFilter = [ALAssetsFilter allAssets];
                [group setAssetsFilter:allAssetsFilter];
                
                /// Enumerate and store each asset in the array ´assets´ of
                [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                    if (result) {
                        [assets addObject:result];
                    }
                }];
            }
        } else {
            
            if ([_self.selectedThumbnailsDictionary count] == 0) {
                _self.selectionBar.text = @"Select media items";
            }
            
            [_self.tableView performSelectorOnMainThread:@selector(reloadData)
                                             withObject:nil waitUntilDone:NO];
            
            _self.tableView.alpha = 1;
        }
    };
    
    ALAssetsLibraryAccessFailureBlock failureBlock = ^(NSError *error) {
        
        NSString *errorMessage = nil;
        
        switch (error.code) {
            case ALAssetsLibraryAccessUserDeniedError:
                errorMessage = @"The user has declined access to it";
                _self.permissionInformationLabel.text = @"Access denied to the photo library. Please grant the permission via the Settings app. Then close the app and try again.";
                
                break;
            case ALAssetsLibraryAccessGloballyDeniedError:
                errorMessage = @"The user has declined location service";
                _self.permissionInformationLabel.text = @"Access denied to the photo library. Please grant the permission via the Settings app. Then close the app and try again.";
                
                break;
            default:
                errorMessage = @"Reason unknown.";
                _self.permissionInformationLabel.text = @"A problem occured. Please close the app and try again. Please close the app and try again";
                break;
        }
        
        _self.selectionBar.text = @"";
        _self.permissionInformationView.hidden = NO;
        _self.tableView.alpha = 0;
        NSLog(@"errorMessage:%@", errorMessage);
    };
    
    self.permissionInformationView.hidden = YES;
    [self.assetGroups removeAllObjects];
    
    NSUInteger groupTypes = ALAssetsGroupAlbum | ALAssetsGroupEvent |
    ALAssetsGroupFaces | ALAssetsGroupSavedPhotos;
    
    // ALAssetsGroupAll
    // ALAssetsGroupLibrary
    [self.assetsLibrary enumerateGroupsWithTypes:groupTypes
                                      usingBlock:listGroupBlock
                                    failureBlock:failureBlock];
    
}


#pragma mark -
#pragma mark Table view data source

/// Definition of the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.assetGroups count];
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSMutableDictionary *groupDictionary = [self.assetGroups objectAtIndex: section];
    ALAssetsGroup *groupForSection = [groupDictionary objectForKey:@"assetGroup"];
     
    return [groupForSection valueForProperty:ALAssetsGroupPropertyName];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 104;
}
/// Definition of the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSMutableDictionary *groupDictionary = [self.assetGroups objectAtIndex: section];
    ALAssetsGroup *groupForSection = [groupDictionary objectForKey:@"assetGroup"];
    
    /// Return the number of rows in the section.
    /// There are three photos per row.
    /// Return groupForSection.numberOfAssets
    return ceil((float)groupForSection.numberOfAssets / 3);
}

/// Definition of the appearance of table view cells.
-(UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"MZPhotoAssetCell";
    
    MZPhotoAssetCell *cell = [aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
   
    if (cell == nil) {
        cell = [[MZPhotoAssetCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
    }
    
    cell.numberOfThumbnails = 3;
    cell.selectionDelegate = self;
    cell.rowNumber = indexPath.row;
    cell.sectionNumber = indexPath.section;
    
    [cell resetThumbnails];
    
    NSMutableDictionary *groupDictionary = [self.assetGroups objectAtIndex: cell.sectionNumber];
    NSMutableArray *assets = [groupDictionary objectForKey:@"assets"];
    
    NSUInteger firstPhotoInCell = cell.rowNumber * cell.numberOfThumbnails;
    NSUInteger lastPhotoInCell  = firstPhotoInCell + cell.numberOfThumbnails;
    
    if (assets.count <= firstPhotoInCell) {
        NSLog(@"We are out of range, asking to start with photo %lu but we only have %lu", (unsigned long)firstPhotoInCell, (unsigned long)assets.count);
        
        return nil;
    }
    
        NSUInteger currentPhotoIndex = 0;
        NSUInteger lastPhotoIndex = MIN(lastPhotoInCell, assets.count);
        
        for ( ; firstPhotoInCell + currentPhotoIndex < lastPhotoIndex ; currentPhotoIndex++) {
            
            ALAsset *asset = [assets objectAtIndex:firstPhotoInCell + currentPhotoIndex];
            UIImage *thumbnail = [UIImage imageWithCGImage:[asset thumbnail]];
            
            NSString *mediaType = [asset valueForProperty:@"ALAssetPropertyType"];
            //NSString *orientation = [asset valueForProperty:@"ALAssetPropertyOrientation"];
       
            /// Update UI in main thread
            
                NSIndexPath *indexPathThumbnail;
                id success;
                
                if (self.tableView.alpha == 0) {
                    
                    [UIView animateWithDuration:0.3 animations:^{
                        self.tableView.alpha = 1;
                    }];
                    
                }
                
                switch (currentPhotoIndex) {
                    
                case 0:
                        cell.thumb1.image = thumbnail;
                                           
                        /// Create an index path representing section - row - itemInRow
                        indexPathThumbnail = [[[NSIndexPath indexPathWithIndex:cell.sectionNumber] indexPathByAddingIndex:cell.rowNumber] indexPathByAddingIndex:currentPhotoIndex];
                        success = [self.selectedThumbnailsDictionary objectForKey:indexPathThumbnail];
                    
                        if (success) [cell.thumb1 setSelected:YES animated:NO];
                        
                        if (mediaType == ALAssetTypeVideo) {
                            cell.thumb1.type = MZThumbnailViewTypeVideo;
                        } else {
                            cell.thumb1.type = MZThumbnailViewTypeImage;
                        }
                    
                        cell.thumb1.hidden = NO;
                        cell.thumb1.userInteractionEnabled = YES;
                        
                    break;
                    
                case 1:
                    
                        cell.thumb2.image = thumbnail;
                        
                        cell.thumb2.layer.borderWidth = 1;
                        cell.thumb2.layer.borderColor = [[UIColor colorWithWhite:1 alpha:1] CGColor];
                    
                        /// Create an index path representing section - row - itemInRow
                        indexPathThumbnail = [[[NSIndexPath indexPathWithIndex:cell.sectionNumber] indexPathByAddingIndex:cell.rowNumber] indexPathByAddingIndex:currentPhotoIndex];
                        success = [self.selectedThumbnailsDictionary objectForKey:indexPathThumbnail];
                    
                        if (success) [cell.thumb2 setSelected:YES animated:NO];
                    
                        if (mediaType == ALAssetTypePhoto) {
                            cell.thumb2.type = MZThumbnailViewTypeImage;
                        } else {
                            cell.thumb2.type = MZThumbnailViewTypeVideo;
                        }
                        
                        cell.thumb2.hidden = NO;
                        cell.thumb2.userInteractionEnabled = YES;
                       
                    break;
                    
                case 2:
                        cell.thumb3.image = thumbnail;
                        
                        cell.thumb3.layer.borderWidth = 1;
                        cell.thumb3.layer.borderColor = [[UIColor colorWithWhite:1 alpha:1] CGColor];
                    
                        /// Create an index path representing section - row - itemInRow
                        indexPathThumbnail = [[[NSIndexPath indexPathWithIndex:cell.sectionNumber] indexPathByAddingIndex:cell.rowNumber] indexPathByAddingIndex:currentPhotoIndex];
                        success = [self.selectedThumbnailsDictionary objectForKey:indexPathThumbnail];
                    
                        if (success) [cell.thumb3 setSelected:YES animated:NO];
                    
                        if (mediaType == ALAssetTypePhoto) {
                            cell.thumb3.type = MZThumbnailViewTypeImage;
                        } else {
                            cell.thumb3.type = MZThumbnailViewTypeVideo;
                        }
                        
                        cell.thumb3.hidden = NO;
                        cell.thumb3.userInteractionEnabled = YES;
                        
                    break;
                    
                default:
                    break;
                }
    
        }

    return cell;
}

#pragma mark -
#pragma mark Table view delegate


#pragma mark -
#pragma mark MZPhotoAssetCell Delegate

- (void)photoAssetCell:(MZPhotoAssetCell *)cell selectedPhotoAtIndex:(NSUInteger)index didChangedState:(MZThumbnailViewState)thumbnailState
{
    NSMutableDictionary *groupDictionary = [self.assetGroups objectAtIndex: cell.sectionNumber];
    NSMutableArray *assets = [groupDictionary objectForKey:@"assets"];
    ALAsset *asset = [assets objectAtIndex:cell.rowNumber * cell.numberOfThumbnails + index];
    
    /// Create an index path representing section - row - itemInRow
    NSIndexPath *indexPathThumbnail = [[[NSIndexPath indexPathWithIndex:cell.sectionNumber] indexPathByAddingIndex:cell.rowNumber] indexPathByAddingIndex:index];
    
    if (thumbnailState == MZThumbnailViewStateDeselected) {
        
        /// Remove the corresponding thumbnail dictionary given an indexPath as a key
        [self.selectedThumbnailsDictionary removeObjectForKey:indexPathThumbnail];
        
        //NSLog(@"Deselected %d",cell.rowNumber * cell.numberOfThumbnails + index);
        
    } else if (thumbnailState == MZThumbnailViewStateSelected) {
        
        NSNumber *selected = [NSNumber numberWithBool:YES];
        
        /// Save the corresponding asset and the thumbnail selection state in a dictionary representing the selected thumbnail
        NSDictionary *selectedThumbnailDictionary =
            [NSDictionary dictionaryWithObjectsAndKeys: asset,      @"asset",
                                                        selected,   @"selected", nil];
        
        /// Save each selectedThumbnailDictionary with his indexPath as a key
        [self.selectedThumbnailsDictionary setObject:selectedThumbnailDictionary forKey:indexPathThumbnail];
    }
    
    /// Update UI - change selectionBar text with the number of selected items
    NSUInteger numItems = [self.selectedThumbnailsDictionary count];
    NSString *string;
    
    if (numItems == 0 ) {
        string = @"Select media items";
    } else if (numItems == 1) {
        string = [NSString stringWithFormat:@"Ready to share %lu item", (unsigned long)numItems];
    } else {
        string = [NSString stringWithFormat:@"Ready to share %lu items", (unsigned long)numItems];
    }
    
    self.selectionBar.text = string;
    
    [self setUIStateShareButton];
    //NSLog(@"selectedThumbnailsDictionary %@",self.selectedThumbnailsDictionary);
}

//////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////

- (IBAction)uploadFiles:(UIButton*)sender
{

    if (self.state == I_STATE_UPLOADING) {
        /// If is already uploading files to server
        /// Cancel all upload operations that are executing now
        [self _doCancelAssetsSharing];
        return;
    }
    
    if (self.state == I_STATE_PREPARING_FOR_UPLOAD) {
        /// CANCEL
         NSLog(@"[CANCEL ] ...");
        [self _doCancelAssetsSharing];
        return;
    }
    
    /// Upload action
    NSLog(@"[PREPARING UPLOAD] ...");
    [self setInternalState:I_STATE_PREPARING_FOR_UPLOAD];
    
    /// Generate a random key
    self.contextKey = [self generateRandomKey:RANDOM_KEY_ALPHANUMERIC_SIZE];
    
    /// Check total number of assets selected
    self.selectedMediaItemsTotalCount = self.selectedThumbnailsDictionary.count;
   
    /// Calculate the total size of selected assets to share
    __block long long assetsTotalByteSize = 0;
    
    /// Self weak reference
    MZAssetsPicker * __weak _self = self;

    [self.worker addOperationWithBlock:^{
        
        assetsTotalByteSize = [_self calculateAssetsTotalByteSize:[_self.selectedThumbnailsDictionary copy]];
        
        /// Get hold of main queue (main thread)
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            
            NSDictionary *data = @{
                             @"a" : @"sharingInvitation",
                             @"d" : @{
                                     @"context"    : _self.contextKey,
                                     @"filesCount" : [NSNumber numberWithUnsignedInteger:_self.selectedMediaItemsTotalCount],
                                     @"totalSize"  : [NSNumber numberWithLongLong:assetsTotalByteSize]
                                     }
                             };
            
            [_self.muzzleyChannel sendMessageWithAction:MZMessageActionSignal data:data
                                             completion:^(MZResponseMessage *response, MZError *error)
            {
                if (error) {
                    [_self setInternalState:I_STATE_DEFAULT];
                    return;
                }
                
                if(_self.state == I_STATE_PREPARING_FOR_UPLOAD){
                    
                    NSLog(@"[UPLOADING] Begin Upload");
                    [_self setInternalState:I_STATE_UPLOADING];
                    [_self uploadLastItem];
                }
            }];
        }];
    }];
}

- (void)uploadLastItem {
    
    NSLog(@"    Selected asset items:%lu", (unsigned long)self.selectedThumbnailsDictionary.count);
    
    /// Capture the weak reference to avoid the reference cycle
    __typeof__(self) __weak weakSelf = self;
    
    /// If there is no asset to upload
    if (self.selectedThumbnailsDictionary.count == 0) {
        
        NSDictionary *data = @{
                               @"a" : @"sharingEnd",
                               @"d" : @{
                                        @"context" : self.contextKey
                                       }
                               };
        
        [self.muzzleyChannel sendMessageWithAction:MZMessageActionSignal data:data completion:^(MZResponseMessage *response, MZError *error) {
            if (error) {
                NSLog(@"Failed to perform request messageRequestAssetsSharingEnd.");
                return;
            }
            
            NSLog(@"    Assets Sharing End");
            UIColor *color = [UIColor colorWithRed:66/255.0 green:66/255.0 blue:66/255.0 alpha:1];
            [weakSelf.buttonShare setTitle:@"Share" forState:UIControlStateNormal];
            [weakSelf.buttonShare setTitleColor:color forState:UIControlStateNormal];
            weakSelf.buttonShare.enabled = NO;
            
            weakSelf.selectionBar.text = @"Media sharing was successful";
            weakSelf.selectionBar.textColor = [UIColor colorWithRed:153/255.0 green:204/255.0 blue:51/255.0 alpha:1];
            [weakSelf.activityIndicator stopAnimating];
            weakSelf.progressBar.frame = CGRectMake( weakSelf.progressBar.frame.origin.x,
                                                 weakSelf.progressBar.frame.origin.y,
                                                 0, 2);
            
            
            [weakSelf performALAssetsLibraryGroupsEnumeration];
            
            [UIView animateWithDuration:0.3 animations:^{
                weakSelf.tableView.alpha = 1;
            }completion:^(BOOL finished) {
                weakSelf.tableView.userInteractionEnabled = YES;
            }];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC*3), dispatch_get_main_queue(), ^{
                [weakSelf setInternalState:I_STATE_DEFAULT];
            });
        }];
    }
    else {
        
        weakSelf.selectionBar.text =
         [NSString stringWithFormat:@"%lu of %lu items shared", (unsigned long)(weakSelf.selectedMediaItemsTotalCount - weakSelf.selectedThumbnailsDictionary.count) ,
                                  (unsigned long)weakSelf.selectedMediaItemsTotalCount];
        
        weakSelf.progressBar.frame = CGRectMake( weakSelf.progressBar.frame.origin.x,
                                              weakSelf.progressBar.frame.origin.y,
                                              0, 2);
        
        NSIndexPath *indexPath = [[weakSelf.selectedThumbnailsDictionary allKeys] lastObject];
        
        NSDictionary *itemDictionary = [weakSelf.selectedThumbnailsDictionary objectForKey:indexPath];
        
        ALAsset *asset = [itemDictionary objectForKey:@"asset"];
        
       
        NSString *contentType = @"";
        NSString *filename = @"";
        
        ALAssetRepresentation *assetRepresentation = [asset defaultRepresentation];
        NSString *extension = assetRepresentation.url.pathExtension;
        
        CFStringRef UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)extension, NULL);
        CFStringRef MIMEType = UTTypeCopyPreferredTagWithClass (UTI, kUTTagClassMIMEType);
        CFRelease(UTI);
        contentType = (__bridge NSString *)MIMEType;
            
        if(assetRepresentation.filename){
            filename = assetRepresentation.filename;
        }
            
        NSDictionary *data = @{
                               @"fileName"    : filename,
                               @"contentType" : contentType,
                               @"context"     : weakSelf.contextKey
                               };
        
        [self.muzzleyChannel sendMessageWithAction:MZMessageActionShareFile data:data completion:^(MZResponseMessage *response, MZError *error) {
            if (error) {
                
                /// item asset Failure
                
                NSIndexPath *indexPath = [[weakSelf.selectedThumbnailsDictionary allKeys] lastObject];
                [weakSelf.selectedThumbnailsDictionary removeObjectForKey:indexPath];
                [weakSelf uploadLastItem];
                return;
            }
            
            /// Get URL path
            NSString *urlString = response.data[@"url"];
            NSURL *url = [NSURL URLWithString: urlString];
            
            /// Get asset myme type
            ALAssetRepresentation *assetRepresentation = [asset defaultRepresentation];
            NSString *mimeType;
            
            NSString *extension = assetRepresentation.url.pathExtension;
            CFStringRef UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)extension, NULL);
            CFStringRef MIMEType = UTTypeCopyPreferredTagWithClass (UTI, kUTTagClassMIMEType);
            CFRelease(UTI);
            
            mimeType = [NSString stringWithString:(__bridge NSString *)(MIMEType)];
            
            /// Get Asset NSData
            NSString *mediaType = [asset valueForProperty:@"ALAssetPropertyType"];
            NSData *assetData;
            NSString *assetFilename;
            
            if (mediaType == ALAssetTypeVideo) {
                /// Get Video Data
                Byte *buffer = (Byte*)malloc(assetRepresentation.size);
                NSUInteger buffered = [assetRepresentation getBytes:buffer fromOffset:0.0 length:assetRepresentation.size error:nil];
                assetData = [NSData dataWithBytesNoCopy:buffer length:buffered freeWhenDone:YES];
                
            } else {
                /// Get Photo Data
                UIImage *fullResolutionImage =
                [UIImage imageWithCGImage:assetRepresentation.fullResolutionImage
                                    scale:1.0
                              orientation:(UIImageOrientation)assetRepresentation.orientation];
                
                NSNumber *width = [weakSelf.parameters objectForKey:@"width"];
                NSNumber *height = [weakSelf.parameters objectForKey:@"height"];
                
                CGSize size;
                if (width && height)
                    size = CGSizeMake(width.floatValue, height.floatValue);
                else size = fullResolutionImage.size;
                
                UIImage *scaledImage = [fullResolutionImage scaleToSize:size];
                assetData = UIImageJPEGRepresentation(scaledImage,1);
            }
            assetFilename = assetRepresentation.filename;
            
            // New httpClient per photo
            // Create a url request and append the asset data
            
            AFHTTPRequestOperation *operation = [weakSelf.httpPhotoUploader POST:[url absoluteString] parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                
                [formData appendPartWithFileData:assetData
                                            name:assetFilename
                                        fileName:assetFilename
                                        mimeType:mimeType];
                
            } success:^(AFHTTPRequestOperation *operation, id responseObject) {
                
                [weakSelf.executingOperations removeObject: operation];
                
                [weakSelf.selectedThumbnailsDictionary removeObjectForKey:indexPath];
                [weakSelf uploadLastItem];
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                
                NSLog(@"Operation error: %@",  error.localizedDescription);
                
                [weakSelf.executingOperations removeObject: operation];
                [operation pause];
                [operation cancel];
                operation = nil;
                
                [weakSelf.selectedThumbnailsDictionary removeObjectForKey:indexPath];
                [weakSelf uploadLastItem];
            }];
            
            /// Schedule an operation to perform the url request
            [operation setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
                
                float progress = totalBytesWritten * 100 / totalBytesExpectedToWrite;
                [UIView animateWithDuration:0.15 animations:^{
                    
                    weakSelf.progressBar.frame =
                    CGRectMake( weakSelf.progressBar.frame.origin.x,
                               weakSelf.progressBar.frame.origin.y,
                               ( weakSelf.view.bounds.size.width *progress ) / 100,
                               2);
                }];
            }];
            
            [weakSelf.executingOperations addObject: operation];
        }];
    }
}

#pragma mark - Helpers
-(long long)calculateAssetsTotalByteSize:(NSDictionary*)assetsDictionary
{
    __block long long assetsTotalByteSize = 0;
    
    /// Check if a photo size is requested
    NSNumber *width = [self.parameters objectForKey:@"width"];
    NSNumber *height = [self.parameters objectForKey:@"height"];
        
    [assetsDictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            
        ALAsset *asset = (ALAsset *)[obj objectForKey:@"asset"];
            
        ALAssetRepresentation *assetRepresentation = asset.defaultRepresentation;
        NSString *mediaType = [asset valueForProperty:@"ALAssetPropertyType"];
            
        if (mediaType == ALAssetTypeVideo) {    /// Get Video Data
            assetsTotalByteSize += assetRepresentation.size;
                
        } else if (mediaType == ALAssetTypePhoto) {    /// Get Photo Data
            UIImage *fullResolutionImage =
            [UIImage imageWithCGImage:assetRepresentation.fullResolutionImage
                                scale:1.0
                          orientation:(UIImageOrientation)assetRepresentation.orientation];
            
            CGSize size;
            if (width && height) size = CGSizeMake(width.floatValue, height.floatValue);
            else size = fullResolutionImage.size;
                
            UIImage *scaledImage = [fullResolutionImage scaleToSize:size];
            NSData *imgData = UIImageJPEGRepresentation(scaledImage,1.0);
            assetsTotalByteSize += imgData.length;
        }
            
    }];
    return assetsTotalByteSize;
}

- (void)handleProtocolData:(NSDictionary *)protocolData responseCallback:(MZResponseBlock)response
{
    /// ***********************************************************
    /// *** ACTION: SIGNAL MESSAGE                              ***
    /// ***********************************************************
    NSString *signalAction = [protocolData objectForKey:@"a"];
    NSObject *dataObject =   [protocolData objectForKey:@"d"];
    NSArray *signalData;
    
    if ([dataObject isKindOfClass: [NSDictionary class]]) signalData = [NSArray arrayWithObject: dataObject];
    else if ([dataObject isKindOfClass: [NSArray class]]) signalData = (NSArray*)dataObject;
    else return;
    
    /// *** SIGNAL ACTION: CHANGE WIDGET **********************
    if ([signalAction isEqualToString:@"sharingCancel"]) {
        /// if cancel assets sharing
        [self cancelAssetsSharing];
        
        if(response) response(nil,nil,YES);
    }
}

- (void)cancelAssetsSharing
{
    [self cancelAllUploadOperations];
    [self setInternalState:I_STATE_DEFAULT];
}
- (void)_doCancelAssetsSharing
{
    
    /// If is already uploading files to server
    /// Cancel all upload operations that are executing now
    [self cancelAssetsSharing];
   
    /// Capture the weak reference to avoid the reference cycle
    //MZAssetsPicker * __weak _self = self;
    NSDictionary *data = @{
                           @"a" : @"sharingCancel",
                           @"d" : @{
                                   @"context" : self.contextKey
                                   }
                           };
    
    [self.muzzleyChannel sendMessageWithAction:MZMessageActionSignal data:data completion:^(MZResponseMessage *response, MZError *error) {
        
        if (error) {
            NSLog(@"Failed to perform request messageRequestAssetsSharingCancel.");
            //_self.buttonShare.enabled = YES;
            return ;
        }
        
        //[_self cancelAllUploadOperations];
        //[_self setInternalState:I_STATE_DEFAULT];
    }];

}

- (NSString *)generateRandomKey:(NSUInteger)numberOfChars
{
    NSString *randomKey = @"";
    NSInteger i;
    NSString *allletters = @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuwxyz0123456789";
    for (i=0; i<numberOfChars; i++) {
        randomKey = [randomKey stringByAppendingString:[allletters substringWithRange:[allletters rangeOfComposedCharacterSequenceAtIndex:random()%[allletters length]]]];
    }
    return randomKey;
}

- (void)setUIStateShareButton
{
    /// If there isn´t any thumbnails selected
    /// Disable the sharing button
    if (self.selectedThumbnailsDictionary.count == 0) {
        self.buttonShare.enabled = NO;
    } else {
        /// Enable the sharing button
        self.buttonShare.enabled = YES;
    }
}

- (void) setInternalState:(IState)aState
{
    self.state = aState;
    
    if (_state == I_STATE_DEFAULT) {
        
        UIColor *color = [UIColor colorWithRed:66/255.0 green:66/255.0 blue:66/255.0 alpha:1];
        [self.buttonShare setTitle:@"Share" forState:UIControlStateNormal];
        [self.buttonShare setTitleColor:color forState:UIControlStateNormal];
        self.buttonShare.enabled = NO;
        [self.activityIndicator stopAnimating];
        
        [UIView animateWithDuration:0.3 animations:^{
            self.tableView.alpha = 1;
        } completion:^(BOOL finished) {
            self.tableView.userInteractionEnabled = YES;
        }];
        
        self.selectionBar.text = @"Select media items";
        self.selectionBar.textColor = [UIColor colorWithRed:66/255.0 green:66/255.0 blue:66/255.0 alpha:1];
        
        self.progressBar.hidden = YES;
        self.progressBar.frame =
        CGRectMake( self.progressBar.frame.origin.x,
                   self.progressBar.frame.origin.y,
                   0, 2);
        
        self.selectedMediaItemsTotalCount = 0;
        [self.selectedThumbnailsDictionary removeAllObjects];
        
        [self performALAssetsLibraryGroupsEnumeration];
        
    } else
    if (I_STATE_PREPARING_FOR_UPLOAD)
    {
        self.selectionBar.text = @"Preparing items upload...";
        self.selectionBar.textColor = [UIColor colorWithRed:66/255.0 green:66/255.0 blue:66/255.0 alpha:1];
        
        UIColor *color = [UIColor colorWithRed:220/255.0 green:66/255.0 blue:66/255.0 alpha:1];
        [self.buttonShare setTitle:@"Cancel" forState:UIControlStateNormal];
        [self.buttonShare setTitleColor:color forState:UIControlStateNormal];
        
        self.tableView.userInteractionEnabled = NO;
        [UIView animateWithDuration:0.3 animations:^{
            self.tableView.alpha = 0.70;
        }];
        
        self.progressBar.hidden = NO;
        [self.activityIndicator startAnimating];
        
    } else
    if (I_STATE_UPLOADING)
    {
        UIColor *color = [UIColor colorWithRed:220/255.0 green:66/255.0 blue:66/255.0 alpha:1];
        [self.buttonShare setTitle:@"Cancel" forState:UIControlStateNormal];
        [self.buttonShare setTitleColor:color forState:UIControlStateNormal];
        
        self.tableView.userInteractionEnabled = NO;
        [UIView animateWithDuration:0.3 animations:^{
            self.tableView.alpha = 0.70;
        }];
        
        self.progressBar.hidden = NO;
        [self.activityIndicator startAnimating];
    }
    
}
#pragma mark - Quit Activity flow
- (IBAction)exitAssetsPicker:(id)sender
{
    self.alertView =
    [[UIAlertView alloc ]initWithTitle:@"Return to menu"
                               message:@"Are you sure?"
                              delegate:self
                     cancelButtonTitle:@"Cancel"
                     otherButtonTitles:@"OK", nil];
    
    [self.alertView show];
}


-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        NSLog(@"Cancel");
    } else {
        
        if ([self.delegate respondsToSelector:@selector(widgetNeedsToDismiss:)]) {
            [self.delegate widgetNeedsToDismiss:self];
        }
    }
}

#pragma mark - Application Did Become Active Notification

- (void)applicationDidBecomeActiveNotificationHandler
{
    NSLog(@"applicationDidBecomeActiveNotificationHandler");
    [self performALAssetsLibraryGroupsEnumeration];
}

#pragma mark - Upload Operations life cycle
/// *** Upload Operations life cycle *** ///
- (void)cancelAllUploadOperations
{
    NSLog(@"[Cancel] AllUploadOperations");
    [self.executingOperations enumerateObjectsWithOptions:NSEnumerationReverse
            usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                
                AFHTTPRequestOperation *operation = obj;
                [operation pause];
                [operation cancel];
                [self.executingOperations removeObject:operation];
                NSLog(@"    [Remove] Operation - Executing Operations:%lu", (unsigned long)self.executingOperations.count);
                operation = nil;
            }];
}

- (void)pauseAllUploadOperations
{
    [self.executingOperations enumerateObjectsWithOptions:NSEnumerationReverse
                                               usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                                                   
                                                   AFHTTPRequestOperation *operation = obj;
                                                   [operation pause];
    }];
}

- (void)resumeAllUploadOperations
{
    
    [self.executingOperations enumerateObjectsWithOptions:NSEnumerationReverse
                                               usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                                                   
                                                   AFHTTPRequestOperation *operation = obj;
                                                   [operation resume];
                                               }];
}

@end
