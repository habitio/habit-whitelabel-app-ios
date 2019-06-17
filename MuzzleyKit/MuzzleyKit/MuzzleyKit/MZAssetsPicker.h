//
//  MZAssetsPicker.h
//  muzzley-sdk-ios
//
//  Created by Hugo Sousa on 19/02/13.
//  Copyright (c) 2013 Muzzley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MZWidget.h"
#import <AssetsLibrary/AssetsLibrary.h>
//#import <AFNetworking.h>
#import "MZPhotoAssetCell.h"

@class AFHTTPRequestOperationManager;

@interface MZAssetsPicker : MZWidget <
                                UITableViewDataSource,
                                UITableViewDelegate,
                                MZPhotoAssetCellSelectionDelegate>

@property (nonatomic, strong, readonly) AFHTTPRequestOperationManager *httpPhotoUploader;

/// UI Objects
@property (nonatomic, strong, readonly) IBOutlet UIButton *buttonShare;
@property (nonatomic, strong, readonly) IBOutlet UILabel *selectionBar;
@property (nonatomic, strong, readonly) IBOutlet UIView *progressBar;
@property (nonatomic, strong, readonly) IBOutlet UITableView *tableView;
@property (nonatomic, strong, readonly) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong, readonly) IBOutlet UIView *permissionInformationView;
@property (nonatomic, strong, readonly) IBOutlet UILabel *permissionInformationLabel;

/// IBACTIONS
- (IBAction)uploadFiles:(id)sender;

@end
