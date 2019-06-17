//
//  NoInternetTableViewDataSource.m
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 16/7/15.
//  Copyright (c) 2015 Muzzley. All rights reserved.
//

#import "NoInternetTableViewDataSource.h"

@implementation NoInternetTableViewDataSource

#pragma mark - UITableViewDataSouce
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PlaceholderTableViewCell *cell = (PlaceholderTableViewCell *)[self _cellForIndexPath:indexPath tableView:tableView];
    
    [self _configureCell:cell forRowAtIndexPath:indexPath];
    return cell;
}

#pragma mark - Public Methods
- (CGSize)tableViewCellSizeForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.tableView isKindOfClass:[UITableView class]]) {
        return self.tableView.bounds.size;
    }
    return CGSizeZero;
}

#pragma mark - Helper Methods
- (UITableViewCell *)_cellForIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView
{
    if (!indexPath) { return nil; }
    
    return [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([PlaceholderTableViewCell class]) forIndexPath:indexPath];
}

- (void)_configureCell:(UITableViewCell *)aCell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!indexPath) { return; }

    PlaceholderTableViewCell *cell = (PlaceholderTableViewCell *)aCell;
    [cell setIconImageNamed:@"IconNoWifi"];
    [cell setIconTintColor:[UIColor colorWithWhite:0 alpha:0.5]];
    [cell setTitleString:NSLocalizedString(@"mobile_no_internet_title", @"")];
    [cell setDescriptionString:NSLocalizedString(@"mobile_no_internet_text", @"")];
}
@end
