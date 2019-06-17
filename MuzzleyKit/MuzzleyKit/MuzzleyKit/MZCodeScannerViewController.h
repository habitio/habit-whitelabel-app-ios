//
//  MZWidgetViewController.h
//  MuzzleyKit
//
//  Created by Hugo Sousa on 27/11/13.
//  Copyright (c) 2013 Muzzley. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MZWidget.h"

@interface MZCodeScannerViewController : MZWidget

@property (nonatomic, weak) IBOutlet UIView *codeScannerView;
@property (nonatomic, weak) IBOutlet UILabel *statusLabel;
@property (nonatomic, weak) IBOutlet UIView *scanFrame;

@end
