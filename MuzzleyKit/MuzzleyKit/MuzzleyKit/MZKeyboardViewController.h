//
//  MZKeyboardViewController.h
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 13/12/12.
//  Copyright (c) 2012 Muzzley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MZWidget.h"

@interface MZKeyboardViewController : MZWidget <UITextViewDelegate>

/// UI Objects
@property (nonatomic, strong, readonly) IBOutlet UIButton *buttonSend;
@property (strong, nonatomic, readonly) IBOutlet UITextView *textView;

@property (strong, nonatomic) IBOutlet UILabel *maxNumCharsLabel;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *placeholderLabel;

/// IBACTIONS
- (IBAction)sendMessage:(id)sender;

@end