//
//  MZDiscoveryRecipeInteractor.m
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 14/7/14.
//  Copyright (c) 2014 Muzzley. All rights reserved.
//

#import "MZDiscoveryRecipeInteractor.h"
#import "MZLocalDiscoveryService.h"
#import "MZUDPClient.h"
#import "SSNetworkInfo+Additions.h"


@class MZDiscoveryProcess;
@class MZDiscoveryProcessStep;
@class MZDiscoveryProcessAction;
@class MZCustomAuthenticationWebService;

@interface MZDiscoveryRecipeInteractor ()

@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) MZDiscoveryProcess *discoveryProcess;
@property (nonatomic, strong) MZCustomAuthenticationWebService *customAuthenticationWS;

// Create a new private queue
@property (nonatomic, strong) dispatch_queue_t myBackgroundQueue;

@end

@implementation MZDiscoveryRecipeInteractor

- (void)dealloc
{
	_url = nil;
	_customAuthenticationWS = nil;
	_discoveryProcess = nil;
}

- (instancetype)initWithURL:(NSURL *)url
{
	self = [super init];
	if (self) {
		_url = url;
		//self.dataSource = [NSMutableArray new];
		_customAuthenticationWS = [MZCustomAuthenticationWebService new];
		_myBackgroundQueue = dispatch_queue_create("com.muzzley.mzuserchanneladdinteractor.task", NULL);
	}
	return self;
}

#pragma mark - MZDiscoveryRecipeInteractorInput
- (void)requestDiscoveryProcessInfo
{
	__typeof__(self) __weak welf = self;
	dispatch_async(self.myBackgroundQueue, ^{
		
		
		[welf.customAuthenticationWS
		 getDiscoveryProcessInitiation:self.url
		 completion:^(MZDiscoveryProcess *discoveryProcess, NSError *error) {
			 
			 if (error) {
				 [welf.output authenticationFailedWithError:error];
				 return;
			 }
			 
			 welf.discoveryProcess = discoveryProcess;
			 [welf.output foundDiscoveryProcessInfo:discoveryProcess];
		 }];
	});
}

- (void)startCustomAuthentication
{
	// Fetch next discovery process step
	NSString *nextStepUrlString = self.discoveryProcess.nextStepUrl;
	if (![nextStepUrlString isKindOfClass:[NSString class]]) {
		nextStepUrlString = @"";
	}
	NSURL *nextStepUrl = [NSURL URLWithString:nextStepUrlString];
	[self _getNextDiscoveryProcessStepWithURL:nextStepUrl];
}

#pragma mark - Private Methods
- (void)_getNextDiscoveryProcessStepWithURL:(NSURL *)nextStepUrl
{
	__typeof__(self) __weak welf = self;
	[self.customAuthenticationWS getNextDiscoveryProcessStepWithURL:nextStepUrl completion:^(MZDiscoveryProcessStep *discoveryProcessStep, NSError *error) {
		if (error) {
			[welf.output authenticationFailedWithError:error];
			return;
		}
		[welf _processDiscoveryProcessStep:discoveryProcessStep];
	}];
}

- (void)_processDiscoveryProcessStep:(MZDiscoveryProcessStep *)discoveryProcessStep
{
	[self.output foundDiscoveryProcessStepInfo:discoveryProcessStep];
	
	__typeof__(self) __weak welf = self;
	// Start Processing all child discoveryProcessActions.
	__block MZDiscoveryProcessStep *currentDiscoveryProcessStep = discoveryProcessStep;
	__block NSMutableArray *processStepActionsResult = [NSMutableArray new];
	// Perform Actions
	__block NSUInteger actionsDone = 0;
	
	DLog(@"actions........ ------ ------ %@",currentDiscoveryProcessStep.actions);
	for (MZDiscoveryProcessAction *action in currentDiscoveryProcessStep.actions) {
		[self _performAction:action callback:^(NSArray *actionResult) {
			// Increase actions done counter.
			actionsDone++;
			// Add the Response to the Post Results
			[processStepActionsResult addObjectsFromArray:actionResult];
			// Check if it's the last action.
			if (actionsDone == currentDiscoveryProcessStep.actions.count) {
				//Finish Processing Discovery Process Step
				[welf sendToServerWithURL:[NSURL URLWithString:currentDiscoveryProcessStep.resultUrl] processStepResult:processStepActionsResult];
			}
		}];
	}
}

- (void) sendToServerWithURL:(NSURL *)resultUrl processStepResult:(NSArray *)processStepActionsResult
{
	__typeof__(self) __weak welf = self;
	[self.customAuthenticationWS
	 postDiscoveryProcessStepResultWithURL:resultUrl
	 array:processStepActionsResult
	 completion:^(MZDiscoveryProcessStep *discoveryProcessStep, NSDictionary * data, NSError *error) {
		 if (error)
         {
			 [welf.output authenticationFailedWithError:error];
			 return;
		 }
		 else
		 {   // Execute next discovery process step
			 if (discoveryProcessStep) {
				 [welf _processDiscoveryProcessStep:discoveryProcessStep];
			 } else { // The discovery process ended with success
				 if (data)
					 [welf.output authenticationDidEndedWithSuccessAndData:data];
				 else
					 [welf.output authenticationDidEndedWithSuccess];
			 }
		 }
	 }];
}

- (NSArray *) createActionResultsArrayWithArray:(NSArray *)array actionId:(NSString *)actionId
{
	NSMutableArray *mutableResponses = [NSMutableArray new];
	for (NSString *response in array)
    {
		[mutableResponses addObject:
		 @{
		   @"id": actionId,
		   @"result":response
		   }];
	}
	return [NSArray arrayWithArray:mutableResponses];
}

#pragma mark - Actions Performing
- (void)_performAction:(MZDiscoveryProcessAction *)action callback:(void (^)(NSArray *actionResult))callback
{
	__typeof__(self) __weak weakSelf = self;
	
	if ([action.type isEqualToString:@"upnp-discovery"]) {
		[weakSelf _performUPNPDiscoveryAction:action callback:^(NSArray *response) {
			if (callback && weakSelf) callback(response);
		}];
	}
	else if ([action.type isEqualToString:@"udp"]){
		[weakSelf _performUdpAction:action callback:^(NSArray *response, MZDiscoveryProcessAction *action) {
			if (callback && weakSelf) callback(response);
		}];
	}
	else if ([action.type isEqualToString:@"network-info"]){
		[weakSelf _performNetworkInfoAction:action callback:^(NSArray *response, MZDiscoveryProcessAction *action) {
			if (callback && weakSelf) callback(response);
		}];
	}
	else if ([action.type isEqualToString:@"http"]){
		[weakSelf _performHTTPDiscoveryAction:action callback:^(NSArray *response) {
			if (callback && weakSelf) callback(response);
		}];
	}
	else if ([action.type isEqualToString:@"webview"])
	{
		if (callback && weakSelf) callback([NSArray new]);
	}
	else if([action.type isEqualToString:@"activation-code"])
	{
		[weakSelf.output requestActivationAction: action callback: ^(NSArray * response) {
			if(callback && weakSelf) callback(response);
		}];
	}
	else
	{
		if (callback && weakSelf) callback([NSArray new]);
	}
}


// UPNP Action
- (void)_performUPNPDiscoveryAction:(MZDiscoveryProcessAction *)action callback:(void (^)(NSArray * actionResult))callback
{
	NSString *st = action.params[@"st"];
	if (!st) st = @"";
	
	NSTimeInterval timeout;
	NSUInteger mx = 3;
	NSNumber *mxNumber = action.params[@"mx"];
	if (mxNumber) mx = [mxNumber integerValue];
	timeout = mx;
	
	NSString *actionId = action.identifier;
	__typeof__(self) __weak welf = self;
	
	MZLocalDiscoveryService *localDiscoveryService = [[MZLocalDiscoveryService alloc] initWithST:st mx:[NSString stringWithFormat:@"%lu", (unsigned long)mx]];
	[localDiscoveryService startLocalDeviceSearchWithTimeout:timeout
													callback:^(NSArray *localDeviceResponses, NSError *error)
	 {
		 if (error) {
			 [welf.output authenticationFailedWithError:error];
			 return;
		 }
		 NSArray *actionResponseArray = [welf createActionResultsArrayWithArray:localDeviceResponses actionId:actionId];
		 if (callback && welf) callback(actionResponseArray);
	 }];
}

// UDP Action
- (void)_performUdpAction:(MZDiscoveryProcessAction *)action callback:(void (^)(NSArray * actionResult, MZDiscoveryProcessAction * action))callback
{
	NSString *actionId = action.identifier;
	
	id data;
	NSString *host;
	NSUInteger port = 0;
	NSTimeInterval ttlInMilliseconds = 0.0;
	BOOL expectResponse = YES;
	
	data = action.params[@"data"];
	host = action.params[@"host"];
	
	NSNumber *portNumber = action.params[@"port"];
	//    if (![portNumber isKindOfClass:[NSNumber class]]) {
	//        port = 0;
	//    }
	port = portNumber.unsignedIntegerValue;
	
	NSNumber *ttlNumber = action.params[@"ttl"];
	if ([ttlNumber isKindOfClass:[NSNumber class]]) {
		ttlInMilliseconds = ttlNumber.doubleValue;
	}
	expectResponse = [action.params[@"expectResponse"] boolValue];
	
	// Validate values
	if (!data) { data = @""; };
	if (!host) { host = @""; };
	
	__typeof__(self) __weak welf = self;
	
	MZUDPClient *udp = [MZUDPClient new];
	udp.onCompletion = ^(NSArray *responses, NSError *error) {
		
		if (error || responses.count == 0) {
			[welf.output authenticationFailedWithError:error];
			return;
		}
		NSArray *actionResponseArray = [welf createActionResultsArrayWithArray:responses actionId:actionId];
		if (callback && welf) callback(actionResponseArray, action);
	};
	[udp sendData:data toHost:host port:port withTimeout:ttlInMilliseconds expectResponse:expectResponse];
}

// Network Info Action
- (void)_performNetworkInfoAction:(MZDiscoveryProcessAction *)action callback:(void (^)(NSArray * actionResults, MZDiscoveryProcessAction * action))callback
{
	NSMutableDictionary *actionResponse = [NSMutableDictionary new];
	
	if ([action.params isKindOfClass:[NSDictionary class]]) {
		
		NSString *broadcastAddress;
		NSString *ipAddress;
		NSString *netmaskAddress;
		NSString *bitmaskAddress;
		
		NSString *interface = action.params[@"interface"];
		if ([interface isKindOfClass:[NSString class]]) {
			if ([interface isEqualToString:@"wifi"]) {
				if ([action.params[@"broadcast"] boolValue]) {
					broadcastAddress = [SSNetworkInfo wiFiBroadcastAddress];
				}
				if ([action.params[@"ip"] boolValue]) {
					ipAddress = [SSNetworkInfo wiFiIPAddress];
				}
				if ([action.params[@"prefixLength"] boolValue]) {
					netmaskAddress = [SSNetworkInfo wiFiNetmaskAddress];
                    bitmaskAddress = [SSNetworkInfo bitmaskFromNetmaskAddress:netmaskAddress];
				}
			}
			else if ([interface isEqualToString:@"cell"]) {
				if ([action.params[@"broadcast"] boolValue]) {
					broadcastAddress = [SSNetworkInfo cellBroadcastAddress];
				}
				if ([action.params[@"ip"] boolValue]) {
					ipAddress = [SSNetworkInfo cellIPAddress];
				}
				if ([action.params[@"prefixLength"] boolValue]) {
					netmaskAddress = [SSNetworkInfo cellNetmaskAddress];
                    bitmaskAddress = [SSNetworkInfo bitmaskFromNetmaskAddress:netmaskAddress];
				}
			}
		}
        
		// Validate values
		if (!broadcastAddress) { broadcastAddress = @""; };
		if (!ipAddress) { ipAddress = @""; };
		if (!bitmaskAddress) { bitmaskAddress = @""; };
		
		actionResponse[@"broadcast"] = broadcastAddress;
		actionResponse[@"ip"] = ipAddress;
		actionResponse[@"prefixLength"] = bitmaskAddress;
		
		NSError *error;
		NSData *jsonData = [NSJSONSerialization dataWithJSONObject:[actionResponse copy]
														   options:NSJSONReadingMutableLeaves error:&error];
		
		NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
		
		NSArray *actionResponseArray = [self createActionResultsArrayWithArray:@[jsonString] actionId:action.identifier];
		if (callback) callback(actionResponseArray, action);
	}
}

// Http Action
- (void)_performHTTPDiscoveryAction:(MZDiscoveryProcessAction *)action callback:(void (^)(NSArray * actionResults))callback
{
	__typeof__(self) __weak welf = self;
	
	NSDictionary *actionParameters = action.params;
	NSString *method = actionParameters[@"method"];
	NSString *urlString = actionParameters[@"url"];
	NSArray *headers = actionParameters[@"headers"];
	NSDictionary *body = actionParameters[@"body"];
	NSString *actionId = action.identifier;
	
	DLog(@"A:%@, Method:%@ ",actionId, method);
	
	[self.customAuthenticationWS requestWithMethodWithMethod:method url:[NSURL URLWithString:urlString] headers:headers parameters:body
										  completion:^(id response, NSError *error) {
											  if (error) {
												  [welf.output authenticationFailedWithError:error];
												  return;
											  }
											  NSArray *actionResponseArray = [welf createActionResultsArrayWithArray:@[response] actionId:actionId];
											  if (callback && welf) callback(actionResponseArray);
										  }];
}

@end
