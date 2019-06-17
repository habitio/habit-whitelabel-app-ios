//
//  MZViewController.h
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 30/04/14.
//  Copyright (c) 2014 Muzzley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MZInfoPlaceholderView.h"



@protocol MZBaseViewControllerRefreshDelegate <NSObject>

@optional

- (void) refreshTriggered;

@end


@interface BaseViewController : UIViewController

@property (nonatomic, weak) id<MZBaseViewControllerRefreshDelegate> refreshDelegate;



@property (nonatomic, strong) MZInfoPlaceholderView *placeholder; //FIX review the need for a double property for MZDeviceSelectionTableViewController (strong and weak differences) <- it's because device tiles override's this
@property (nonatomic, weak) IBOutlet MZInfoPlaceholderView *infoPlaceholderView;
@property (nonatomic) bool isFirstTime;


- (void)setInfoPlaceholderVisible:(BOOL)visible;
- (void)setEmptyResultsInfoPlaceholderWithPlaceholderImageName:(NSString *)placeholderImageName title:(NSString *)title message:(NSString *)message;
- (void)setEmptyResultsInfoPlaceholderWithPlaceholderImageName:(NSString *)placeholderImageName title:(NSString *)title message:(NSString *)message buttonTitle:(NSString *)title andButtonAction:(SEL)action;
- (void)setErrorInfoPlaceholderWithPlaceholderImageName:(NSString *)placeholderImageName;
- (void)setNoInternetInfoPlaceholder;
- (void)setLoadingResultsInfoPlaceholderWithPlaceholderImageName:(NSString *)placeholderImageName title:(NSString *)title message:(NSString *)message;
- (void)setGenericErrorInfoPlaceholderWithPlaceholderImageName:(NSString *)placeholderImageName andDecription:(NSString *)description;

- (void)reloadData;
- (void)refreshData;

@end
