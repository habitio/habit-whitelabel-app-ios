//
//  MZWidget.h
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 01/07/13.
//  Copyright (c) 2013 Muzzley. All rights reserved.
//

#import <UIKit/UIKit.h>

//#import "MZMuzzleyChannel.h"

//@protocol MZBaseClient;
@class MZWidget;

@protocol MZWidgetDelegate < NSObject >
@optional
- (void)widgetNeedsToDismiss:(MZWidget *)widget;
- (UIView *)widgetCloseButton:(MZWidget *)widget;
@end

@interface MZWidget : UIViewController

@property (nonatomic, strong) NSDictionary *parameters;
@property (nonatomic, weak) id <MZWidgetDelegate>delegate;

//@property (nonatomic, weak) MZMuzzleyChannel *muzzleyChannel;
//@property (nonatomic, weak) id<MZBaseClient> muzzleyClient;

/// Abstract initializer method
/// MZWidget subclasses should override this init method
- (id)initWithParameters:(NSDictionary *)parameters;

@end
