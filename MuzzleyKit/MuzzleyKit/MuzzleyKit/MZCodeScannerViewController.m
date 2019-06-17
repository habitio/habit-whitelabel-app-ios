//
//  MZWidgetViewController.m
//  MuzzleyKit
//
//  Created by Hugo Sousa on 27/11/13.
//  Copyright (c) 2013 Muzzley. All rights reserved.
//

#import "MZCodeScannerViewController.h"

#import <AVFoundation/AVFoundation.h>
#import <QuartzCore/QuartzCore.h>

#import "MZSettings.h"
#import "MZUserClient.h"
#import "MZMessage.h"
#import "MZWidget.h"


#define DEGREES_TO_RADIANS(x) (M_PI * x / 180.0)

NSString *const kMZCodeScannerOptionThreshold =     @"threshold";
NSString *const kMZCodeScannerOptionOrientation =   @"orientation";
NSString *const kMZCodeScannerOptionLabel =         @"label";
NSString *const kMZCodeScannerOptionFormats =       @"formats";

NSString *const kMZCodeScannerFormatMuzzley =       @"muzzley";
NSString *const kMZCodeScannerFormatEAN8 =          @"ean8";
NSString *const kMZCodeScannerFormatEAN13 =         @"ean13";
NSString *const kMZCodeScannerFormatCODE39 =        @"code39";
NSString *const kMZCodeScannerFormatCODE93 =        @"code93";
NSString *const kMZCodeScannerFormatCODE128 =       @"code128";
NSString *const kMZCodeScannerFormatQRCODE =        @"qrcode";
NSString *const kMZCodeScannerFormatPDF417 =        @"pdf417";

NSString *const kIOS5Version = @"5";
NSString *const kIOS6Version = @"6";

NSString *const kMZCodeScannerDefaultLabelMessage = @"Scan a muzzley QR Code";
NSString *const kMZCodeScannerDefaultLabelError = @"Invalid muzzley QR Code";

CGFloat const kMZCodeScannerResetLabelTimerDuration = 2.5;

@interface MZCodeScannerViewController () <AVCaptureMetadataOutputObjectsDelegate>

@property (nonatomic, strong) UIAlertView *alertView;

@property (nonatomic, assign) UIInterfaceOrientation interfaceOrientation;
@property (nonatomic, assign) UIInterfaceOrientationMask interfaceOrientationMask;

// iOS >= 7.0 version of code scanner
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *videoPreviewLayer;
@property (nonatomic, assign) AVCaptureConnection *connection;

@property (nonatomic, strong) NSTimer *samplingTimer;
@property (nonatomic, strong) NSTimer *resetLabelTimer;

@property (nonatomic, assign) NSUInteger threshold;
@property (nonatomic, copy) NSString *labelStringValue;
@property (nonatomic, strong) NSMutableArray *formats;

@property (nonatomic, getter = isMuzzleyFormatPrecedent) BOOL muzzleyFormatPrecedent;

@property (nonatomic, copy) NSString *mode;

@property (nonatomic, copy) NSString *codeScanned;
@property (nonatomic) BOOL legacyMode;

@end



@implementation MZCodeScannerViewController 

#pragma mark - Dealloc
- (void)dealloc
{
    [self.alertView dismissWithClickedButtonIndex:-1 animated:NO];
    self.alertView = nil;
    
    [self.samplingTimer invalidate];
    self.samplingTimer = nil;
    
    [self.resetLabelTimer invalidate];
    self.resetLabelTimer = nil;
}

#pragma mark - Initializers
-(id)initWithParameters:(NSDictionary*)parameters
{
    UIStoryboard *muzzleyKitStoryboard = [UIStoryboard storyboardWithName:@"MuzzleyKitStoryboard_iPhone" bundle:[NSBundle mainBundle]];
    MZCodeScannerViewController *codeScannerViewController = [muzzleyKitStoryboard instantiateViewControllerWithIdentifier:@"MZCodeScannerViewController"];
    self = codeScannerViewController;
    
    if (self) {
        self.parameters = parameters;
        
        // Default parameters
        
        // orientation
        self.interfaceOrientation = UIInterfaceOrientationPortrait;
        self.interfaceOrientationMask = UIInterfaceOrientationMaskPortrait;
        self.threshold = 1000; // value in milliseconds
        self.mode = @"continuous";
        
        if (self.parameters[kMZCodeScannerOptionOrientation]) {
            
            NSString *orientationString = self.parameters[kMZCodeScannerOptionOrientation];
            if ([orientationString isEqualToString:@"landscape"]) {
                
                self.interfaceOrientationMask = UIInterfaceOrientationMaskLandscape;
                self.interfaceOrientation = UIInterfaceOrientationLandscapeRight;
                
            } else if ([orientationString isEqualToString:@"portrait"]) {
                
                self.interfaceOrientationMask = UIInterfaceOrientationMaskPortrait;
                self.interfaceOrientation = UIInterfaceOrientationPortrait;
            }
        }
        
        if (self.parameters[kMZCodeScannerOptionThreshold] &&
            [self.parameters[kMZCodeScannerOptionThreshold] isKindOfClass:[NSNumber class]]) {
            
            NSUInteger threshold= [self.parameters[kMZCodeScannerOptionThreshold] unsignedIntegerValue];
            NSUInteger minimumThreshold = 0.1 * 1000; //miliseconds
            self.threshold = MAX(threshold, minimumThreshold);
        }
        

        if (self.parameters[kMZCodeScannerOptionLabel] &&
            [self.parameters[kMZCodeScannerOptionLabel] isKindOfClass:[NSString class]]) {
            self.labelStringValue = self.parameters[kMZCodeScannerOptionLabel];
        }
        
        self.muzzleyFormatPrecedent = NO;
        self.legacyMode = NO;
        
        if (self.parameters[kMZCodeScannerOptionFormats] &&
            [self.parameters[kMZCodeScannerOptionFormats] isKindOfClass:[NSArray class]]) {
            
            self.formats = [NSMutableArray new];
            
            NSArray *formats = self.parameters[kMZCodeScannerOptionFormats];
            for (NSString *format in formats) {
                if ([format isEqualToString:kMZCodeScannerFormatMuzzley]) {
                    self.muzzleyFormatPrecedent = YES;
                    [self.formats addObject:kMZCodeScannerFormatMuzzley];
                }
                else if ([format isEqualToString:kMZCodeScannerFormatQRCODE]) {
                    [self.formats addObject:kMZCodeScannerFormatQRCODE];
                }
                else if ([format isEqualToString:kMZCodeScannerFormatPDF417]) {
                    [self.formats addObject:kMZCodeScannerFormatPDF417];
                }
                else if ([format isEqualToString:kMZCodeScannerFormatEAN8]) {
                    [self.formats addObject:kMZCodeScannerFormatEAN8];
                }
                else if ([format isEqualToString:kMZCodeScannerFormatEAN13]) {
                    [self.formats addObject:kMZCodeScannerFormatEAN13];
                }
                else if ([format isEqualToString:kMZCodeScannerFormatCODE39]) {
                    [self.formats addObject:kMZCodeScannerFormatCODE39];
                }
                else if ([format isEqualToString:kMZCodeScannerFormatCODE93]) {
                    [self.formats addObject:kMZCodeScannerFormatCODE93];
                }
                else if ([format isEqualToString:kMZCodeScannerFormatCODE128]) {
                    [self.formats addObject:kMZCodeScannerFormatCODE128];
                }
            }
            
        } else {
            self.formats = [NSMutableArray new];
            self.legacyMode = YES;
            self.muzzleyFormatPrecedent = YES;
            [self.formats addObject:kMZCodeScannerFormatMuzzley];
            
        }
    }
    return self;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.statusLabel.layer.cornerRadius = 6;
    [self configureCodeScannerView];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    self.videoPreviewLayer.frame = self.codeScannerView.layer.bounds;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.codeScannerView.alpha = 1;
    
    if (self.labelStringValue) {
        self.statusLabel.text = self.labelStringValue;
        self.statusLabel.alpha = 1;
    } else {
         self.statusLabel.alpha = 0;
    }
    
    [self startCameraCapture];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self resetSamplingTimer];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    // Disable the Timer.
    [self.samplingTimer invalidate];
    self.samplingTimer = nil;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}
#pragma mark View Rotation
- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    UIInterfaceOrientation toInterfaceOrientation = [UIApplication sharedApplication].statusBarOrientation;
    if (self.interfaceOrientationMask == UIInterfaceOrientationMaskLandscape) {
        if (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
            toInterfaceOrientation == UIInterfaceOrientationLandscapeRight) {
            [self rotateVideoPreviewLayerOrientation:toInterfaceOrientation];
        }
    } else if(self.interfaceOrientationMask == UIInterfaceOrientationMaskPortrait) {
        if (toInterfaceOrientation == UIInterfaceOrientationPortrait) {
            [self rotateVideoPreviewLayerOrientation:toInterfaceOrientation];
        }
    }
    return self.interfaceOrientationMask;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    if (self.interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
        self.interfaceOrientation = UIInterfaceOrientationPortrait;
    }
    return self.interfaceOrientation;
}

- (void)rotateVideoPreviewLayerOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    switch (toInterfaceOrientation) {
        case UIInterfaceOrientationPortrait:
            self.videoPreviewLayer.connection.videoOrientation = AVCaptureVideoOrientationPortrait;
            break;
            
        case UIInterfaceOrientationPortraitUpsideDown:
            self.videoPreviewLayer.connection.videoOrientation = AVCaptureVideoOrientationPortraitUpsideDown;
            break;
            
        case UIInterfaceOrientationLandscapeLeft:
            self.videoPreviewLayer.connection.videoOrientation = AVCaptureVideoOrientationLandscapeLeft;
            break;
            
        case UIInterfaceOrientationLandscapeRight:
            self.videoPreviewLayer.connection.videoOrientation = AVCaptureVideoOrientationLandscapeRight;
            break;
            
        default:
            break;
    }
    self.videoPreviewLayer.frame = self.view.layer.bounds;
}

#pragma mark - Code Scanner View Configuration
- (void)configureCodeScannerView
{
    [self configureAppleCodeScannerView:self.codeScannerView];
}

#pragma mark Apple Code Scanner Configuration
- (void)configureAppleCodeScannerView:(UIView *)codeScannerView
{
    AVCaptureSession *captureSession = [AVCaptureSession new];
    AVCaptureDevice *videoCaptureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError *lockConfigError = nil;
    
    [captureSession beginConfiguration];
    
    if ([videoCaptureDevice lockForConfiguration:&lockConfigError]) {
        
        if ([videoCaptureDevice isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {
            videoCaptureDevice.focusMode = AVCaptureFocusModeContinuousAutoFocus;
        }
        
        if ([videoCaptureDevice isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]) {
            videoCaptureDevice.exposureMode = AVCaptureExposureModeContinuousAutoExposure;
        }
        
        if ([videoCaptureDevice isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance ]) {
            videoCaptureDevice.whiteBalanceMode = AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance;
        }
        [videoCaptureDevice unlockForConfiguration];
    }
    
    NSError *deviceInputError = nil;
    
    AVCaptureDeviceInput *videoInput = [AVCaptureDeviceInput deviceInputWithDevice:videoCaptureDevice
                                                                             error:&deviceInputError];
    if (videoInput) {
        [captureSession addInput:videoInput];
    } else {
        NSLog(@"Error: %@", deviceInputError);
    }
    
    /*
     * -addOuput: must be called before setMetadataObjectTypes. In retrospect, it makes sense: the output object must know it is linked to a video session to know which metadata it may provide.
     */
    
    AVCaptureMetadataOutput *metaDataOutput = [AVCaptureMetadataOutput new];
    [captureSession addOutput:metaDataOutput];
    [metaDataOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    NSMutableArray *metadataObjectsArray = [NSMutableArray new];
    
    for (NSString *format in self.formats) {
        
        if ([format isEqualToString:kMZCodeScannerFormatMuzzley]) {
            [metadataObjectsArray addObject:AVMetadataObjectTypeQRCode];
        }
        else if ([format isEqualToString:kMZCodeScannerFormatQRCODE]) {
            if (!self.isMuzzleyFormatPrecedent) {
                [metadataObjectsArray addObject:AVMetadataObjectTypeQRCode];
            }
        }
        else if ([format isEqualToString:kMZCodeScannerFormatPDF417]) {
            [metadataObjectsArray addObject:AVMetadataObjectTypePDF417Code];
        }
        else if ([format isEqualToString:kMZCodeScannerFormatEAN8]) {
            [metadataObjectsArray addObject:AVMetadataObjectTypeEAN8Code];
        }
        else if ([format isEqualToString:kMZCodeScannerFormatEAN13]) {
            [metadataObjectsArray addObject:AVMetadataObjectTypeEAN13Code];
        }
        else if ([format isEqualToString:kMZCodeScannerFormatCODE39]) {
            [metadataObjectsArray addObject:AVMetadataObjectTypeCode39Code];
        }
        else if ([format isEqualToString:kMZCodeScannerFormatCODE93]) {
            [metadataObjectsArray addObject:AVMetadataObjectTypeCode93Code];
        }
        else if ([format isEqualToString:kMZCodeScannerFormatCODE128]) {
            [metadataObjectsArray addObject:AVMetadataObjectTypeCode128Code];
        }
    }

    [metaDataOutput setMetadataObjectTypes:metadataObjectsArray];
    
    [captureSession commitConfiguration];
    
    self.videoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:captureSession];
    self.videoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    self.videoPreviewLayer.backgroundColor = [UIColor clearColor].CGColor;
    [self.codeScannerView.layer addSublayer:self.videoPreviewLayer];
}

- (void) startCameraCapture
{
    [self.videoPreviewLayer.session startRunning];
}

- (void) stopCameraCapture
{
    [self.videoPreviewLayer.session stopRunning];
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputMetadataObjects:(NSArray *)metadataObjects
       fromConnection:(AVCaptureConnection *)connection
{
    //NSLog(@"captureOutput");
    self.connection = connection;
    
    for (AVMetadataObject *metaDataObject in metadataObjects) {
        AVMetadataMachineReadableCodeObject *readableObject = (AVMetadataMachineReadableCodeObject *)metaDataObject;
        
        if ([readableObject.type isEqualToString:AVMetadataObjectTypeQRCode] ||
            [readableObject.type isEqualToString:AVMetadataObjectTypePDF417Code] ||
            [readableObject.type isEqualToString:AVMetadataObjectTypeEAN8Code] ||
            [readableObject.type isEqualToString:AVMetadataObjectTypeEAN13Code] ||
            [readableObject.type isEqualToString:AVMetadataObjectTypeCode39Code] ||
            [readableObject.type isEqualToString:AVMetadataObjectTypeCode93Code] ||
            [readableObject.type isEqualToString:AVMetadataObjectTypeCode128Code] ) {
            
            NSString *metadata = readableObject.stringValue;
            [self handleAppleScanReaderMetadataInput:metadata type:metaDataObject.type];
            
            break;
        }
    }
}

#pragma mark - Handle Input
- (void)handleAppleScanReaderMetadataInput:(NSString *)metadata type:(NSString *)type
{
    if ([type isEqualToString:AVMetadataObjectTypeQRCode] && self.muzzleyFormatPrecedent) {
        [self handleMuzzleyMetadataInput:metadata];
    } else {
        
        NSString *format;
        
        if ([type isEqualToString:AVMetadataObjectTypeQRCode])              format = @"qrcode";
        else if ([type isEqualToString:AVMetadataObjectTypePDF417Code])     format = @"pdf417";
        else if ([type isEqualToString:AVMetadataObjectTypeEAN8Code])       format = @"ean8";
        else if ([type isEqualToString:AVMetadataObjectTypeEAN13Code])      format = @"ean13";
        else if ([type isEqualToString:AVMetadataObjectTypeCode39Code])     format = @"code39";
        else if ([type isEqualToString:AVMetadataObjectTypeCode93Code])     format = @"code93";
        else if ([type isEqualToString:AVMetadataObjectTypeCode128Code])    format = @"code128";
            
        [self handleGenericMetadataInput:metadata format:format];
    }
}

- (void)handleGenericMetadataInput:(NSString *)metadata format:(NSString *)format
{
    if (!metadata) {
        [self setLabelMessage:@"Unknown code"];
        return;
    }
    
    self.codeScanned = metadata;
    
    [self setMetadataCaptureEnabled:NO];
    [self resetSamplingTimer];
    
    [self animateCaptureWithID:[self.codeScanned copy]];
    [self sendDecoding:self.codeScanned format:format];
    
}

- (void)handleMuzzleyMetadataInput:(NSString *)metadata
{

    /* Handle Muzzley Format */
    NSString *urlString = metadata;
    
    if (!urlString) {
        [self setLabelMessage:kMZCodeScannerDefaultLabelError];
        [self scheduleResetLabelTimer];
        return;
    }
    
    if ( !([urlString hasPrefix:@"http://"] || [urlString hasPrefix:@"https://"]) ) {
        urlString = [NSString stringWithFormat:@"http://%@", urlString];
    }
    
    NSURL *url = [[NSURL alloc] initWithString: urlString];
    if (url == nil) {
        [self setLabelMessage:kMZCodeScannerDefaultLabelError];
        [self scheduleResetLabelTimer];
        return;
    }
    
    MZSettings *mzSharedSettings = [MZSettings sharedSettings];
    NSString *host = [url host];
    
    NSMutableString *searchedString = [NSMutableString stringWithString: host];
    NSError* error = nil;
    
    NSRegularExpression* regex =
    [NSRegularExpression regularExpressionWithPattern:@"(\\.muzzley\\.com$|^muzzley\\.com$)"
                                              options:0 error:&error];
    
    NSArray* matches = [regex matchesInString:searchedString options:0 range:NSMakeRange(0, [searchedString length])];
    /*for ( NSTextCheckingResult* match in matches )
     {
     NSString* matchText = [searchedString substringWithRange:[match range]];
     NSLog(@"match: %@", matchText);
     }*/
    
    if (matches.count == 0) {
        [self setLabelMessage:kMZCodeScannerDefaultLabelError];
        [self scheduleResetLabelTimer];
        return;
    }
    
    // Parse path components
    NSArray *pathComponents = [url pathComponents];
    NSUInteger count = pathComponents.count;
    
    if (count < 2) {
        [self setLabelMessage:kMZCodeScannerDefaultLabelError];
        [self scheduleResetLabelTimer];
        return;
    }
    
    // Check if the activityID path component is preceded by 'play' path component.
    if ([[pathComponents objectAtIndex:count-2] isEqualToString:
         mzSharedSettings.muzzleyActivityURIPrefixPath]) {
        
        self.codeScanned = [pathComponents objectAtIndex:count - 1];
        
        [self setMetadataCaptureEnabled:NO];
        [self resetSamplingTimer];
        
        if (self.codeScanned == nil) {
            [self setLabelMessage:kMZCodeScannerDefaultLabelError];
            [self scheduleResetLabelTimer];
            return;
        }

        [self animateCaptureWithID:self.codeScanned];
        [self sendDecoding:self.codeScanned format:@"muzzley"];
    }
    else {
        [self setLabelMessage:kMZCodeScannerDefaultLabelError];
        [self scheduleResetLabelTimer];
    }
}

- (void)handleSamplingTimer:(NSTimer*)timer
{
    [self setMetadataCaptureEnabled:YES];
}

#pragma mark - Send Muzzley Message
- (void)sendDecoding:(NSString *)decodeString format:(NSString *)format {
    
    if (decodeString == nil || ![decodeString isKindOfClass:[NSString class]]) {
        return;
    }
    //NSLog(@"%@",decodeString);
    NSString *widget = @"codeScanner";
    
    id value;
    if (self.legacyMode) {
        value = decodeString;
    } else {
        value = @{
                  @"result" : decodeString,
                  @"format" : format ? format : @"Unknown format"
                };
    }
    
    NSString *event = @"decode";
    
    /// private signaling mzmessage for communication with activity
    NSMutableDictionary *data = [NSMutableDictionary dictionaryWithDictionary:
                         @{
                           @"w": widget,
                           @"v": value,
                           @"e": event
                          }];
    
    [self.muzzleyChannel sendMessageWithAction:MZMessageActionSignal data:data completion:nil];
}

#pragma mark - Quit Activity flow
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        //NSLog(@"Cancel");
    } else {
        
        [self.samplingTimer invalidate];
        self.samplingTimer = nil;
        
        if ([self.delegate respondsToSelector:@selector(widgetNeedsToDismiss:)])
            [self.delegate widgetNeedsToDismiss:self];
    }
}

#pragma mark - Help Methods
- (void)setMetadataCaptureEnabled:(BOOL)enabled
{
    self.connection.enabled = enabled;
}

- (void)animateCaptureWithID:(NSString *)codeId
{
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut
        animations:^{
            self.statusLabel.alpha = 0.4;
            self.scanFrame.transform = CGAffineTransformMakeScale(1.15, 1.15);
        }
        completion:^(BOOL finished) {
                         
            [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut
                animations:^{
                    self.statusLabel.text = [NSString stringWithFormat:@"ID: %@", codeId];
                    self.statusLabel.alpha = 1;
                    self.scanFrame.transform = CGAffineTransformMakeScale(1, 1);
                    [self scheduleResetLabelTimer];
                }
                completion:^(BOOL finished) {}];
        }];
}

- (void)setLabelMessage:(NSString *)string
{
    if (!string) {
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut
            animations:^{
                self.statusLabel.alpha = 0;
            }
            completion:nil];
        return;
    }
    
    if ([string isEqualToString:self.statusLabel.text]) {
        return;
    }
    
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut
        animations:^{
            self.statusLabel.alpha = 0.4;
        }
        completion:^(BOOL finished) {
                         
            [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut
                animations:^{
                    self.statusLabel.text = string;
                    self.statusLabel.alpha = 1;
                                              
                }
                completion:nil];
            }];
}

- (float)toSecs:(NSUInteger)milliseconds {
    return milliseconds/1000;
}

- (void)resetSamplingTimer {
    
    [self.samplingTimer invalidate];
    self.samplingTimer = nil;
    
    float seconds = [self toSecs:self.threshold];
    self.samplingTimer =
    [NSTimer scheduledTimerWithTimeInterval:seconds target:self
                                   selector:@selector(handleSamplingTimer:)
                                   userInfo:nil repeats:YES];
}

- (void)scheduleResetLabelTimer
{
    [self.resetLabelTimer invalidate];
    self.resetLabelTimer = nil;
    
    self.resetLabelTimer =
        [NSTimer scheduledTimerWithTimeInterval:kMZCodeScannerResetLabelTimerDuration
                                         target:self
                                       selector:@selector(handleResetLabelTimer:)
                                       userInfo:nil repeats:NO];
}

- (void)handleResetLabelTimer:sender
{
    [self setLabelMessage:self.labelStringValue];
}
@end
