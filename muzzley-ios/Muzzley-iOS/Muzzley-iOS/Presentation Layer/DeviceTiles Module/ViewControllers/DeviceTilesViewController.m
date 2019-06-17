//
//  UserDevicesViewController.m
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 02/05/14.
//  Copyright (c) 2014 Muzzley. All rights reserved.
//

#import "DeviceTilesViewController.h"

#import "DeviceTilesWireframe.h"
#import "MZRootWireframe.h"
#import "MZCollectionView.h"
#import "OngoingOperationView.h"
#import "MZRefreshControl.h"
#import "AppManager.h"
#import "MZTriStateToggle.h"

@class MZDeviceTilesInteractor;

@interface DeviceTilesViewController () <UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate, DeviceTileCellDelegate, MZDeviceTilesInteractorDelegate, MZDeviceTilesRefreshProtocol, DeviceTilesDataSourceDelegate, UITextFieldDelegate, MZOnboardingViewControllerDelegate, MZCreateGroupViewControllerDelegate, MZBlankStateDelegate>

@property (nonatomic, readwrite) DeviceTilesWireframe *wireframe;
@property (nonatomic) DeviceTilesDataSource *deviceTilesDataSource;
@property (nonatomic) UIView *overlayView;

@property (weak, nonatomic) IBOutlet MZBlankStateView *uiBlankState;

@property (nonatomic, weak) IBOutlet UIButton *addDeviceButton;
//@property (nonatomic, weak) IBOutlet MZColorButton *createGroupButton;

@property (nonatomic, weak) IBOutlet MZCollectionView *collectionView;

@property (nonatomic, strong) NSArray * devices;
@property (nonatomic) MZRefreshControl *refreshControl;
@property (nonatomic) UIAlertView *alertView;
@property (nonatomic) bool canRefresh;

@property (nonatomic) bool addedTile;
@property (nonatomic) bool addedGroup;
@property (nonatomic) bool isFirstTime;


@end

@implementation DeviceTilesViewController

- (void)dealloc
{
    [self.alertView dismissWithClickedButtonIndex:-1 animated:YES];
    self.alertView = nil;
}

- (instancetype)initWithWireframe:(DeviceTilesWireframe *)wireframe
                       interactor:(MZDeviceTilesInteractor *)interactor
{
    self = [super initWithNibName:NSStringFromClass([self class]) bundle:[NSBundle mainBundle]];
    if (self) {
        self.wireframe = wireframe;
        self.interactor = interactor;
        self.interactor.delegate = self;
		self.isDevicesViewVisible = false;
		self.addedGroup = false;
		self.addedTile = false;
		self.hasGroupableDevices = false;
        self.isFirstTime = true;
    }
    return self;
}

- (void)blankStateButtonPressed
{
    [self addDevice];
}

- (void)blankStateRefreshTriggered
{
    [self reloadData];
}

- (void)setupBlankState
{
    [self uiBlankState].delegate = self;
    [self.uiBlankState setupWithBlankStateImage:[[UIImage imageNamed:@"BlankStateDevices"] imageWithRenderingMode:UIImageRenderingModeAutomatic] blankStateTitle: NSLocalizedString(@"mobile_device_blankstate_empty_title", @"")  blankStateText: NSLocalizedString(@"mobile_device_blankstate_empty_text", @"")  blankStatebuttonTitle: NSLocalizedString(@"mobile_device_add", @"") loadingStateTitle: NSLocalizedString(@"mobile_device_blankstate_empty_title", @"") loadingStateText:  NSLocalizedString(@"mobile_device_blankstate_loading_text", @"")];
    
    [self.uiBlankState setStateWithState: StateEnumBlank];
    
}

#pragma mark - View Lifecycle Methods
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupBlankState];
    
    self.deviceTilesDataSource = [[DeviceTilesDataSource alloc] initWithCollectionView:self.collectionView];
    self.deviceTilesDataSource.delegate = self;
	self.hasGroupableDevices = self.deviceTilesDataSource.canCreateGroups;
	
	
    
    [self _setupInterface];
}

- (void) refreshTriggered
{
	[self reloadData];
}


- (void) scrollToTop
{
    if(self.collectionView != nil && [self.collectionView numberOfSections] > 0 && [self.collectionView numberOfItemsInSection:0] > 0)
    {
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
}

- (void)tilesTabVisibleStatusUpdate:(BOOL) isVisible
{
	self.isDevicesViewVisible = isVisible;
	
	if(self.isDevicesViewVisible)
	{
		[self.collectionView reloadData];
	}
	if(self.isDevicesViewVisible && !self.addedGroup && !self.addedTile)
	{
		[self performSelector:@selector(showOnboarding) withObject:nil afterDelay:0.3];
	}
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    self.canRefresh = NO;
	
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

#pragma mark - Public Methods
- (void)reloadData
{
    if (!self.view) { return; }
	
	Reachability *internetReachable = [Reachability reachabilityForInternetConnection];
	if([internetReachable currentReachabilityStatus] == NotReachable)
	{
   
         [self.uiBlankState setStateWithState: StateEnumNoInternet];

		return;
	}
	
	self.canRefresh = NO;
	
    __typeof__(self) __weak weakSelf = self;
    [self.alertView dismissWithClickedButtonIndex:-1 animated:NO];
    
    for (UIViewController * vc in [self childViewControllers])
	{
        if ([vc isKindOfClass:MZGroupTilesViewController.class])
		{
            [((MZGroupTilesViewController *)vc) showLoadingView];
            break;
        }
    }
    
    if (self.isFirstTime || self.devices.count  == 0)
    {
         [self.uiBlankState setStateWithState: StateEnumLoading];

    } else {
        [self.uiBlankState hide];
    }
    
    [self.refreshControl beginRefreshing];
        
    [self.interactor getDevicesByAreasAndGroups:^(NSArray* results, NSError* error)
    {
        if (self.isFirstTime)
		{
            self.isFirstTime = NO;
        }
		
		
        if (error) {
            if ([error.domain isEqualToString:NSURLErrorDomain] &&
                (error.code == NSURLErrorNotConnectedToInternet ||
                 error.code == NSURLErrorCannotFindHost))
			{
                [self.uiBlankState setStateWithState: StateEnumNoInternet];
			}
			else
				{
                    [self.uiBlankState setStateWithState: StateEnumError];
                }
            for (UIViewController * vc in [self childViewControllers]) {
                if ([vc isKindOfClass:MZGroupTilesViewController.class]) {
                    [((MZGroupTilesViewController *)vc) hideLoadingView];
                    [UIView animateWithDuration:0.3 animations:^{
                        CGRect newFrame = vc.view.frame;
                        newFrame.origin.y = [UIScreen mainScreen].bounds.size.height;
                        vc.view.frame = newFrame;
                    } completion:^(BOOL finished) {
                        [((MZGroupTilesViewController *)vc) closeAction:self];
                        
                        for (UIView * view in self.view.superview.superview.superview.superview.subviews) {
                            if ([view isKindOfClass:UICollectionView.class]) {
                                ((UICollectionView *)view).scrollEnabled = YES;
                            }
                        }
                    }];
                    break;
                }
            }
        }
		else
		{
            _devices = results;
            
            if (results.count > 0) {
                //[self _showTutorialIfNeeded];
                [self.uiBlankState hide];
            } else {
                [self.uiBlankState setStateWithState: StateEnumBlank];
            }

            [weakSelf.deviceTilesDataSource setData:results];
			
			self.hasGroupableDevices = weakSelf.deviceTilesDataSource.canCreateGroups;
			[weakSelf _reloadData];
			
            [weakSelf _updateChildViewControllers];
        }
    }];
}


#pragma mark - Private Methods
- (void) _updateChildViewControllers
{
    for (UIViewController * vc in [self childViewControllers]) {
        if ([vc isKindOfClass:MZGroupTilesViewController.class]) {
            MZGroupTilesViewController * groupVC = (MZGroupTilesViewController *)vc;
            MZTileGroupViewModel * oldTile = groupVC.groupMV;
            bool updated = NO;
            
            for (MZTileAreaViewModel * area in self.deviceTilesDataSource.deviceAreaViewModelList) {
                for (NSObject * tile in area.tilesViewModel) {
					
                    if ([tile isKindOfClass:MZTileGroupViewModel.class]) {
							if ([((MZTileGroupViewModel *)tile).identifier isEqualToString:oldTile.identifier]) {
                            GroupInteractionTileViewModel * groupControlVM = [GroupInteractionTileViewModel new];
                            groupControlVM.interfaceUUID = ((MZTileGroupViewModel *)tile).interfaceUUID;
                            groupControlVM.interfaceETAG = ((MZTileGroupViewModel *)tile).interfaceETAG;
                            groupControlVM.channelID = ((MZTileGroupViewModel *)tile).channelID;
                            groupControlVM.bridgeOptions = ((MZTileGroupViewModel *)tile).bridgeOptions;
                            groupControlVM.nativeComponents = ((MZTileGroupViewModel *)tile).nativeComponents;
                            groupControlVM.isDetail = NO;
                            
                            NSMutableArray * tiles = [[NSMutableArray alloc] initWithArray:@[groupControlVM]];
                            [tiles addObjectsFromArray:((MZTileGroupViewModel *)tile).tilesViewModel];
                            MZTileAreaViewModel * areaVM = [MZTileAreaViewModel new];
                            areaVM.title = ((MZTileGroupViewModel *)tile).title;
                            areaVM.tilesViewModel = tiles.copy;
                            //TODO fixme
                            groupVC.areas = @[areaVM];
                            groupVC.groupMV = (MZTileGroupViewModel *)tile;
                            
                            groupVC.groupTitle.text = areaVM.title;
                            [groupVC.deviceTilesDataSource setData:groupVC.areas];
                            [groupVC.collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
                            updated = YES;
                            [((MZGroupTilesViewController *)vc) hideLoadingView];
                            break;
                        }
                    }
                }
				
                if (updated) break;
            }
            
            if (!updated)
			{
                for (UIViewController * vc in [self childViewControllers]) {
                    if ([vc isKindOfClass:MZGroupTilesViewController.class]) {
                        [((MZGroupTilesViewController *)vc) hideLoadingView];
                        [self.wireframe.parentWireframe popToRootViewControllerAnimated:YES];
                        [UIView animateWithDuration:0.3 animations:^{
                            CGRect newFrame = vc.view.frame;
                            newFrame.origin.y = [UIScreen mainScreen].bounds.size.height;
                            vc.view.frame = newFrame;
                        } completion:^(BOOL finished) {
                            [((MZGroupTilesViewController *)vc) closeAction:self];
                            
                            for (UIView * view in self.view.superview.superview.superview.superview.subviews) {
                                if ([view isKindOfClass:UICollectionView.class]) {
                                    ((UICollectionView *)view).scrollEnabled = YES;
                                }
                            }
                        }];
                        break;
                    }
                }
            }
        }
    }
}


- (void)_setupInterface {
//	self.createGroupButton.hidden = YES;
	//MZNotifications.register(self, selector:@selector(reloadTiles), notificationKey:MZNotificationKeys.Tiles.Reload);
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTiles) name:@"Reload" object:nil]; // Can't use the struct here to get the key from MZNotificationKeys because objective-c doesn't support it... If the key changes, change it here too.
	
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceAddedNotification) name:@"DeviceAddedNotification" object:nil];
	
    self.canRefresh = NO;
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.dataSource = self.deviceTilesDataSource;
    self.collectionView.delegate = self;
    self.collectionView.allowsSelection = YES;
    self.collectionView.alwaysBounceVertical = YES;
    
    self.refreshControl = [[MZRefreshControl alloc] initWithCollectionView:self.collectionView];
    [self.refreshControl addTarget:self action:@selector(reloadData) forControlEvents:UIControlEventValueChanged];
	
	[self _reloadData];
}

#pragma mark Helper Methods
- (void)_reloadData
{
	[self.refreshControl endRefreshing];

	[self.collectionView reloadData];

	[self.collectionView performBatchUpdates:^{
		
	} completion:^(BOOL finished) {
		if(finished)
		{
			if(self.isDevicesViewVisible)
				[self performSelector:@selector(showOnboarding) withObject:nil afterDelay:0.3];
		}
	}];
}


- (void)_presentAlertInterfaceWithTitle:(NSString *)title message:(NSString *)message {
    [self.alertView dismissWithClickedButtonIndex:-1 animated:NO];
    self.alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:NSLocalizedString(@"mobile_ok", @"") otherButtonTitles:nil, nil];
    [self.alertView show];
}

- (void)_presentNoNetworkAlertInterface {
    [self.alertView dismissWithClickedButtonIndex:-1 animated:NO];
    self.alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"mobile_no_internet_title", @"") message:NSLocalizedString(@"mobile_no_internet_text", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"mobile_ok", @"") otherButtonTitles:nil, nil];
    [self.alertView show];
}

#pragma mark UIControlEvents
- (IBAction)_addDevice:(id)sender {
    [self addDevice];
}


- (void)addDevice
{
    if ([self.delegate respondsToSelector:@selector(deviceTilesViewControllerDidSelectAddDevice:)])
    {
        [self.delegate deviceTilesViewControllerDidSelectAddDevice:self];
    }
}

- (IBAction)_addGroupTile:(id)sender {
    MZCreateGroupViewController * createGroupVC = [[MZCreateGroupViewController alloc] initWithWireframe:self.wireframe andInteractor:self.interactor];
	createGroupVC.delegate = self;
    [self.wireframe.parentWireframe pushViewController:createGroupVC animated:YES];
}


#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)collectionViewLayout;
    CGFloat sectionInsetsHSpacing = flowLayout.sectionInset.left + flowLayout.sectionInset.right;
    CGFloat minimumInteritemSpacing = flowLayout.minimumInteritemSpacing;
    CGFloat twoItemWidth = collectionView.bounds.size.width - sectionInsetsHSpacing - minimumInteritemSpacing;
    CGFloat oneItemWidth = twoItemWidth * 0.5;
    return CGSizeMake(oneItemWidth, oneItemWidth);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return CGSizeMake(collectionView.bounds.size.width, 60);
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    MZTileAreaViewModel * dev = [self.deviceTilesDataSource.deviceAreaViewModelList objectAtIndex:indexPath.section];
    NSObject * tile = [dev.tilesViewModel objectAtIndex:indexPath.row];
        
    if ([tile isKindOfClass:MZTileViewModel.class])
	{
        MZDeviceInteractionViewController * deviceInteractionVM = [[MZDeviceInteractionViewController alloc] initWithWireframe:self.wireframe andInteractor: self.interactor];
        deviceInteractionVM.tile = (MZTileViewModel *)tile;
        [self.wireframe.parentWireframe pushViewControllerToEnd:deviceInteractionVM animated:YES];
    }
	else if ([tile isKindOfClass:MZTileGroupViewModel.class])
	{
        GroupInteractionTileViewModel * groupControlVM = [GroupInteractionTileViewModel new];
        groupControlVM.interfaceUUID = ((MZTileViewModel *)tile).interfaceUUID;
        groupControlVM.interfaceETAG = ((MZTileViewModel *)tile).interfaceETAG;
        groupControlVM.channelID = ((MZTileViewModel *)tile).channelID;
        groupControlVM.bridgeOptions = ((MZTileViewModel *)tile).bridgeOptions;
        groupControlVM.nativeComponents = ((MZTileViewModel *)tile).nativeComponents;
        
        NSMutableArray * tiles = [[NSMutableArray alloc] initWithArray:@[groupControlVM]];
        [tiles addObjectsFromArray:((MZTileGroupViewModel *)tile).tilesViewModel];
        MZTileAreaViewModel * areaVM = [MZTileAreaViewModel new];
        areaVM.title = ((MZTileGroupViewModel *)tile).title;
        areaVM.tilesViewModel = tiles.copy;
        //TODO fixme
        MZGroupTilesViewController * groupVC = [[MZGroupTilesViewController alloc] initWithWireframe:self.wireframe andInteractor:self.interactor];
        groupVC.areas = @[areaVM];
        groupVC.delegate = self.delegate;
        groupVC.groupMV = (MZTileGroupViewModel *)tile;
        [self addChildViewController:groupVC];
        [self.view addSubview:groupVC.view];
        [self.view bringSubviewToFront:groupVC.view];
        
        CGRect newFrame = self.view.frame;
        newFrame.origin.y = [UIScreen mainScreen].bounds.size.height;
        groupVC.view.frame = newFrame;
        [UIView animateWithDuration:0.3 animations:^{
            CGRect newFrame = self.view.frame;
            newFrame.size.width -= 8.0;
            newFrame.size.height -= 8.0;
            newFrame.origin.x += 4.0;
            newFrame.origin.y += 4.0;
            groupVC.view.frame = newFrame;
        }];
    }
}



#pragma DeviceTilesDataSourceDelegate

- (void)deviceTilesDataSource:(MZTriStateToggle *)toggle dataSource:(DeviceTilesDataSource *)dataSource didSelectSwitchTileState:(MZAreaChildViewModel *)viewModel
{
    [self.interactor sendStatusToDevice:viewModel completion:nil];
}


#pragma MZDeviceTilesInteractorDelegate

-(void) deviceViewModelsDidUpdate:(NSArray<MZTileAreaViewModel *> *)devices
{
    _devices = devices;

    [self.deviceTilesDataSource setData:devices];
    if(self.isDevicesViewVisible)
	{
		[self _reloadData];
		[self _updateChildViewControllers];
	}
}

#pragma mark - MZDeviceTilesRefreshProtocol

- (void)refreshDeviceTiles {
    self.canRefresh = YES;
}

- (void)reloadTiles {
	[self reloadData];
}

- (void)refreshNowDeviceTiles {
    if (![self.refreshControl isRefreshing]) {
        [self reloadData];
    }
}

- (void)hideGroup {
    for (UIViewController * vc in [self childViewControllers]) {
        if ([vc isKindOfClass:MZGroupTilesViewController.class]) {
            [((MZGroupTilesViewController *)vc) hideLoadingView];
            [((MZGroupTilesViewController *)vc) closeAction:self];
            
            for (UIView * view in self.view.superview.superview.superview.superview.subviews) {
                if ([view isKindOfClass:UICollectionView.class]) {
                    ((UICollectionView *)view).scrollEnabled = YES;
                }
            }
            break;
        }
    }
}

- (void)deviceAddedNotification
{
	[self refreshNowDeviceTiles];
	self.addedTile = true;
}

- (void)showOnboarding {

	if(self.viewLoaded)
	{
		if(self.deviceTilesDataSource.deviceAreaViewModelList.count == 0)
			return;
		
		// A new tile was added
		if(self.addedTile)
		{
			// UNCOMMNENT THIS ONCE THE GROUPS FEATURE IS ADDED
			
//			if(![[MZOnboardingsInteractor sharedInstance] hasOnboardingBeenShown: [[MZOnboardingsInteractor sharedInstance] key_tileAddedCreateGroup]] && self.deviceTilesDataSource.canCreateGroups)
//			{
//				self.addedTile = false;
//				self.definesPresentationContext = true;
//				
//				NSIndexPath * indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
//				UICollectionViewCell *firstCell = [self.collectionView cellForItemAtIndexPath:indexPath];
//				
//				MZTileAddedCreateGroupOnboardingViewController * onboarding = [[MZTileAddedCreateGroupOnboardingViewController alloc] initWithModalPresentationStyle: UIModalPresentationOverCurrentContext highlightViews: [NSArray arrayWithObjects:firstCell, self.createGroupButton, nil]];
//				
//				[self presentViewController:onboarding animated:NO completion:nil];
//				[onboarding show];
//				
//				[[MZOnboardingsInteractor sharedInstance] updateOnboardingStatus:[[MZOnboardingsInteractor sharedInstance] key_tileAddedCreateGroup] shownStatus: YES];
//				[[MZOnboardingsInteractor sharedInstance] updateOnboardingStatus:[[MZOnboardingsInteractor sharedInstance] key_tileAdded] shownStatus: YES];
//				[[MZOnboardingsInteractor sharedInstance] updateOnboardingStatus:[[MZOnboardingsInteractor sharedInstance] key_createGroup] shownStatus: YES];
//				
//				return;
//			}
			
			if(![[MZOnboardingsInteractor sharedInstance] hasOnboardingBeenShown: [[MZOnboardingsInteractor sharedInstance] key_tileAdded]])
			{
				
				self.definesPresentationContext = true;
				
				NSIndexPath * indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
				UICollectionViewCell *firstCell = [self.collectionView cellForItemAtIndexPath:indexPath];
				if(firstCell != nil)
				{
					MZTileAddedOnboardingViewController * onboarding =  [[MZTileAddedOnboardingViewController alloc] initWithModalPresentationStyle: UIModalPresentationOverCurrentContext highlightViews: [NSArray arrayWithObjects:firstCell, nil]];
				
					[self presentViewController:onboarding animated:NO completion:nil];
					[onboarding show];
					
					[[MZOnboardingsInteractor sharedInstance] updateOnboardingStatus:[[MZOnboardingsInteractor sharedInstance] key_tileAdded] shownStatus: YES];
					self.addedTile = false;
				}
				else
				{
					// table isn't loaded yet
					self.addedTile = true;
				}
				return;
			}
			else
			{
				self.addedTile = false;
			}
			
//			if(![[MZOnboardingsInteractor sharedInstance] hasOnboardingBeenShown: [[MZOnboardingsInteractor sharedInstance] key_createGroup]] && self.deviceTilesDataSource.canCreateGroups)
//			{
//				self.addedTile = false;
//				self.definesPresentationContext = true;
//				MZCreateGroupOnboardingViewController * onboarding = [[MZCreateGroupOnboardingViewController alloc] initWithModalPresentationStyle: UIModalPresentationOverCurrentContext highlightViews: [NSArray arrayWithObjects:self.createGroupButton, nil]];
//				[self presentViewController:onboarding animated:NO completion:nil];
//				[onboarding show];
//				[[MZOnboardingsInteractor sharedInstance] updateOnboardingStatus:[[MZOnboardingsInteractor sharedInstance] key_createGroup] shownStatus: YES];
//				return;
//			}
//			return;
		}
		
		// A group was created
//		if(self.addedGroup)
//		{
//			if(![[MZOnboardingsInteractor sharedInstance] hasOnboardingBeenShown: [[MZOnboardingsInteractor sharedInstance] key_groupCreated]])
//			{
//				
//				if(self.deviceTilesDataSource.firstGroupViewIndexPath)
//				{
//					self.addedGroup = false;
//
//					self.definesPresentationContext = true;
//					
//					[self.collectionView scrollToItemAtIndexPath:self.deviceTilesDataSource.firstGroupViewIndexPath atScrollPosition:UICollectionViewScrollPositionTop animated:NO];
//					
//					UICollectionViewCell *firstCell = [self.collectionView cellForItemAtIndexPath:self.deviceTilesDataSource.firstGroupViewIndexPath];
//					
//					MZGroupCreatedOnboardingViewController * onboarding = [[MZGroupCreatedOnboardingViewController alloc] initWithModalPresentationStyle: UIModalPresentationOverCurrentContext highlightViews: [NSArray arrayWithObjects:firstCell, nil]];
//					
//					
//					[self presentViewController:onboarding animated:NO completion:nil];
//					
//					[onboarding show];
//					
//					[[MZOnboardingsInteractor sharedInstance] updateOnboardingStatus:[[MZOnboardingsInteractor sharedInstance] key_groupCreated] shownStatus: YES];
//				}
//				return;
//			}
//			else
//			{
//				self.addedGroup = false;
//			}
//		}
    }
}


- (void) createGroupSuccess
{
	// Trigger refresh
	[self refreshNowDeviceTiles];
	self.addedGroup = true;
}

- (void) createGroupCancel
{
	self.addedGroup = false;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

@end
