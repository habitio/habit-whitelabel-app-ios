//
//  ChannelsViewController.m
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 16/5/14.
//  Copyright (c) 2014 Muzzley. All rights reserved.
//

#import "ChannelsViewController.h"
#import "MZChannelsTableViewCell.h"

#define POPUP_ERROR 1000
#define POPUP_PASS 2000

static NSString *cellIdentifier = @"MZChannelsTableViewCell";

@interface ChannelsViewController ()
<UITableViewDelegate,
UITableViewDataSource,
MZInfoViewDelegate>
//,
//PopupContentViewDelegate>
{
    MZLoadingView * _loadingView;
//    KLCPopup * _popupView;
}

@property (nonatomic, weak) IBOutlet UITableView *tableView;

@property (nonatomic, weak) IBOutlet UIButton *selectChannelsButton;

@property (nonatomic, strong) NSMutableArray *selectedChannels;


- (IBAction)selectChannelsButtonTouchUpInside:(id)sender;

@end

@implementation ChannelsViewController

- (void)dealloc
{
    self.datasourceArray = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    _loadingView = [MZLoadingView new];
	[self.selectChannelsButton setTitle:NSLocalizedString(@"mobile_add", @"") forState: UIControlStateNormal];
    self.selectedChannels = [NSMutableArray new];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self setSelectChannelsButtonInteraction:NO];
}

- (void)willMoveToParentViewController:(UIViewController *)parent
{
    [super willMoveToParentViewController:parent];
    if (parent == nil) [MZAnalyticsInteractor deviceAddCancelEvent:[self.delegate selectedProfileIdentifier]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MZChannelsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell)
	{
        [tableView
         registerNib:[UINib nibWithNibName:@"MZChannelsTableViewCell" bundle:[NSBundle mainBundle]]
         forCellReuseIdentifier:cellIdentifier];
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    }
    
    // Reset the cell
    NSDictionary *channel = self.datasourceArray[indexPath.row];
    cell.channelImageView.image = nil;
    [cell.channelImageView cancelImageDownloadTask];
    [cell.channelImageView setImageWithURL:[NSURL URLWithString:channel[@"photoUrl"]]];
        
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(MZChannelsTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Edit Cell
    NSDictionary *channel = self.datasourceArray[indexPath.row];
    cell.channelLabel.text = channel[@"content"];
    
    // Can´t interact with the cell
    if ([channel[@"subscribed"] boolValue])
	{
        cell.userInteractionEnabled = NO;
        cell.contentView.alpha = 0.25;
        cell.selected = YES;
    }
    else
	{
        // Can interact with the cell
        // Selectable
        cell.userInteractionEnabled = YES;
        cell.contentView.alpha = 1;
        
        // Already selected
        for (NSDictionary *selectedChannel in self.selectedChannels)
		{
            if([channel[@"id"] isEqualToString:selectedChannel[@"id"]])
			{
                cell.selected = YES;
                break;
            }
        }
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.datasourceArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 75;
}

- (void)updateView
{
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0]
                  withRowAnimation:UITableViewRowAnimationFade];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *channel = self.datasourceArray[indexPath.row];
    [self.selectedChannels addObject:channel];
    
    [self setSelectChannelsButtonInteraction:YES];
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *channel = self.datasourceArray[indexPath.row];
    [self.selectedChannels removeObject:channel];
    
    if ([self.selectedChannels count] == 0) {
        [self setSelectChannelsButtonInteraction:NO];
    }
}

- (void)setSelectChannelsButtonInteraction:(BOOL)enabled
{
    self.selectChannelsButton.userInteractionEnabled = enabled;
    if (enabled)
	{
        self.selectChannelsButton.alpha = 1.0;
    }
    else
	{
        self.selectChannelsButton.alpha = 0.3;
    }
}
	
#pragma mark - IB Actions
- (void)selectChannelsButtonTouchUpInside:(id)sender
{
    [_loadingView updateLoadingStatus:YES container:self.view];
    
    if ([self.delegate respondsToSelector:@selector(channelVC:didSelectChannels:)])
	{
        [self.delegate channelVC:self didSelectChannels:self.selectedChannels];
    }
}

- (void) showPasswordRequest:(int)passType forChannelId:(NSString*)channeldId
{
    NSString * alertMessage = @"";
    if (passType == CURRENT_PASS)
    {
        alertMessage = NSLocalizedString(@"mobile_password_current_request", comment: @"");
    } else if (passType == NEW_PASS) {
        alertMessage = NSLocalizedString(@"mobile_password_new_request", comment: @"");
    }
    
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@""
                                          message:alertMessage
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField)
     {
         textField.secureTextEntry = YES;
     }];
    
    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"mobile_cancel", comment: @"")
                                   style:UIAlertActionStyleCancel
                                   handler:^(UIAlertAction *action)
                                   {
                                   }];
    
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:NSLocalizedString(@"mobile_ok", comment: @"")
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action)
                               {
                                   UITextField *password = alertController.textFields.firstObject;
                                   if (self.delegate && [self.delegate respondsToSelector:@selector(didPassSetup:forChannelId:andPassType:)])
                                   {
                                       [self.delegate didPassSetup:password.text forChannelId:channeldId andPassType:passType];
                                   }
                               }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:okAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}


- (void) showError:(NSError*)error
{
    [self hideLoading];
    [self setSelectChannelsButtonInteraction:YES];

    //TODO
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@""
                                          message:error.localizedDescription
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:NSLocalizedString(@"mobile_ok", comment: @"")
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action)
                               {
                               }];
    
    [alertController addAction:okAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void) hideLoading
{
    [_loadingView updateLoadingStatus:NO container:self.view];
}


@end
