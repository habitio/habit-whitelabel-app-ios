//
//  MZImageViewController.m
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 13/05/13.
//  Copyright (c) 2013 Muzzley. All rights reserved.
//

#import "MZImageViewController.h"

@interface MZImageViewController ()

@property (nonatomic, assign) UIInterfaceOrientation interfaceOrientation;
@property (nonatomic, assign) UIInterfaceOrientationMask interfaceOrientationMask;
@property (nonatomic, assign) UIViewContentMode imageViewContentMode;

@property (nonatomic, strong) NSURL *imageURL;

@property (nonatomic, strong) UIAlertView *alertView;
@end

@implementation MZImageViewController


-(void)dealloc
{
    [self.alertView dismissWithClickedButtonIndex:-1 animated:NO];
    self.alertView = nil;
}

#pragma mark Initializers
- (id)initWithParameters:(NSDictionary*)parameters
{
    UIStoryboard *muzzleyKitStoryboard = [UIStoryboard storyboardWithName:@"MuzzleyKitStoryboard_iPhone" bundle:[NSBundle mainBundle]];
    MZImageViewController *imageViewController = [muzzleyKitStoryboard instantiateViewControllerWithIdentifier:@"MZImageViewController"];
    self = imageViewController;
    
    if (self) {
        // Custom initialization
        self.parameters = parameters;
        
        // Default parameters
        
        // orientation
        self.interfaceOrientation = UIInterfaceOrientationPortrait;
        self.interfaceOrientationMask = UIInterfaceOrientationMaskPortrait;
        
        if ([self.parameters objectForKey:@"orientation"]) {
            
            NSString *orientationString = [self.parameters objectForKey:@"orientation"];
            
            if ([orientationString isEqualToString:@"landscape"]) {
                
                self.interfaceOrientationMask = UIInterfaceOrientationMaskLandscape;
                self.interfaceOrientation = UIInterfaceOrientationLandscapeRight;
                
            } else if ([orientationString isEqualToString:@"portrait"]) {
                
                self.interfaceOrientationMask = UIInterfaceOrientationMaskPortrait;
                self.interfaceOrientation = UIInterfaceOrientationPortrait;
            }
        }
        
        /// mode
        self.imageViewContentMode = UIViewContentModeScaleAspectFill;
        
        if ([self.parameters objectForKey:@"mode"]) {
            
            NSString *modeString = [self.parameters objectForKey:@"mode"];
            
            if ([modeString isEqualToString:@"scaleFill"]) {
                self.imageViewContentMode = UIViewContentModeScaleToFill;
            } else if ([modeString isEqualToString:@"aspectFit"]) {
                self.imageViewContentMode = UIViewContentModeScaleAspectFit;
            } else if ([modeString isEqualToString:@"aspectFill"]) {
                self.imageViewContentMode = UIViewContentModeScaleAspectFill;
            } else if ([modeString isEqualToString:@"center"]) {
                self.imageViewContentMode = UIViewContentModeCenter;
            } else if ([modeString isEqualToString:@"top"]) {
                self.imageViewContentMode = UIViewContentModeTop;
            }  else if ([modeString isEqualToString:@"topLeft"]) {
                self.imageViewContentMode = UIViewContentModeTopLeft;
            } else if ([modeString isEqualToString:@"topRight"]) {
                self.imageViewContentMode = UIViewContentModeTopRight;
            } else if ([modeString isEqualToString:@"bottom"]) {
                self.imageViewContentMode = UIViewContentModeBottom;
            } else if ([modeString isEqualToString:@"bottomLeft"]) {
                self.imageViewContentMode = UIViewContentModeBottomLeft;
            } else if ([modeString isEqualToString:@"bottomRight"]) {
                self.imageViewContentMode = UIViewContentModeBottomRight;
            } else if ([modeString isEqualToString:@"left"]) {
                self.imageViewContentMode = UIViewContentModeLeft;
            } else if ([modeString isEqualToString:@"right"]) {
                self.imageViewContentMode = UIViewContentModeRight;
            }
        }
        
        /// image source
        if ([self.parameters objectForKey:@"src"]) {
            
            NSString *stringURL = [self.parameters objectForKey:@"src"];
            
            self.imageURL = [NSURL URLWithString: stringURL];
        }
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    self.imageView.alpha = 0;
    
    [self.activityIndicator tintToColor:[UIColor lightGrayColor]];
    [self.activityIndicator startRotating];
    /// *** Parameters
    /// image source
    
    //[self.imageView setImageWithURL: _imageURL];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:_imageURL];
    [request setHTTPShouldHandleCookies:NO];
    [request addValue:@"image/*" forHTTPHeaderField:@"Accept"];
    UIImageView *__weak weakImageView = self.imageView;
    MZActivityIndicatorView *__weak weakActivityIndicator = self.activityIndicator;

    
    [self.imageView setImageWithURLRequest:request
                          placeholderImage:nil
                                   success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                       
                                       weakImageView.image = image;
                                       
                                       [UIView animateWithDuration:0.1 animations:^{
                                           weakImageView.alpha = 1;
                                       }];
                                       
                                       [weakActivityIndicator stopRotating];
                                       
                                   } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                        [weakActivityIndicator stopRotating];
                                   }];
    /// mode
    self.imageView.contentMode = _imageViewContentMode;
    
    /// color
    if ([self.parameters objectForKey:@"bgColor"]) {
        
        NSDictionary *colorDictionary = [self.parameters objectForKey:@"bgColor"];
        NSUInteger red;
        NSUInteger green;
        NSUInteger blue;
        
        if ([colorDictionary objectForKey:@"r"]) {
            
            red = [[colorDictionary objectForKey:@"r"] unsignedIntegerValue];
            red = MAX(0, MIN(255, red));
        } else red = 0;
        
        if ([colorDictionary objectForKey:@"g"]) {
            green = [[colorDictionary objectForKey:@"g"] unsignedIntegerValue];
            green = MAX(0, MIN(255, green));
        } else green = 0;
        
        if ([colorDictionary objectForKey:@"b"]) {
            blue = [[colorDictionary objectForKey:@"b"] unsignedIntegerValue];
            blue = MAX(0, MIN(255, blue));
        } else blue = 0;
        
        self.view.backgroundColor = [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:1.0];
        
        self.backgroundView.alpha = 0;
        
    } else {
        self.backgroundView.alpha = 1;
    }
}

#pragma mark View Rotation
-(BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return _interfaceOrientationMask;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        
        if (_interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
            _interfaceOrientation = UIInterfaceOrientationPortrait;
        }
        return _interfaceOrientation;
    }
    return _interfaceOrientation;
}

#pragma mark Private methods
#pragma mark - Alert View Delegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {

    } else {
        
        if ([self.delegate respondsToSelector:@selector(widgetNeedsToDismiss:)]) 
            [self.delegate widgetNeedsToDismiss:self];
        
    }
}

@end
