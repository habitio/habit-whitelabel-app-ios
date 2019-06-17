//
//  MZWidget.m
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 01/07/13.
//  Copyright (c) 2013 Muzzley. All rights reserved.
//

#import "MZWidget.h"

@interface MZWidget ()

@end

@implementation MZWidget

- (id)initWithParameters:(NSDictionary*)parameters
{
    [NSException raise:@"Invoked abstract method" format:@"MZWidget subclasses should override this abstract init method"];
    
    return nil;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if ([self.delegate respondsToSelector:@selector(widgetCloseButton:)]) {
        UIView *button = [self.delegate widgetCloseButton:self];
        [self.view addSubview:button];
    }
}

/*
- (void)handleProtocolData:(NSDictionary *)protocolData responseCallback:(MZResponseBlock)response
{
    //[NSException raise:@"Invoked abstract method" format:@"MZWidget subclasses should override the handleProtocolData:responseCallback: abstract method"];
    NSLog(@"MZWidget subclasses should override the handleProtocolData:responseCallback: abstract method");
}*/

@end
