//
//  AppConstants.m
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 01/04/14.
//  Copyright (c) 2014 Muzzley. All rights reserved.
//
#import "AppConstants.h"

// Map View
// -----------------------------------------
float const MUZZLEY_MAP_ZOOM = 13;

// URL Muzzley Command
// -----------------------------------------
NSString *const MUZZLEY_URL_COMMAND_ID = @"muzcommand";
NSString *const MUZZLEY_URL_COMMAND_NAVIGATE_ID = @"navigate";
NSString *const MUZZLEY_URL_COMMAND_EXECUTE_ID = @"execute";

// URL Routing Pattern
// -----------------------------------------
NSString *const URL_NAVIGATION_ROUTE_PATTERN_ROOT = @"navigate/";
NSString *const URL_NAVIGATION_ROUTE_PATTERN_TIMELINE = @"navigate/timeline";
NSString *const URL_NAVIGATION_ROUTE_PATTERN_TIMELINE_EVENT = @"navigate/events/:id";
NSString *const URL_NAVIGATION_ROUTE_PATTERN_WORKERS = @"navigate/workers";
NSString *const URL_NAVIGATION_ROUTE_PATTERN_WORKERS_CREATE = @"navigate/workers/create";
NSString *const URL_NAVIGATION_ROUTE_PATTERN_WORKERS_SELECT = @"navigate/workers/:id";
NSString *const URL_NAVIGATION_ROUTE_PATTERN_WORKERS_EDIT = @"navigate/workers/:id/edit";
NSString *const URL_NAVIGATION_ROUTE_PATTERN_WORKERS_DELETE = @"navigate/workers/:id/delete";
NSString *const URL_NAVIGATION_ROUTE_PATTERN_CHANNELS = @"navigate/channels";
NSString *const URL_NAVIGATION_ROUTE_PATTERN_CHANNELS_SELECT = @"navigate/channels/:id";
NSString *const URL_NAVIGATION_ROUTE_PATTERN_CHANNELS_EDIT = @"navigate/channels/:id/edit";
NSString *const URL_NAVIGATION_ROUTE_PATTERN_CHANNELS_DELETE = @"navigate/channels/:id/delete";
NSString *const URL_NAVIGATION_ROUTE_PATTERN_NOTIFICATIONS = @"navigate/notifications";
NSString *const URL_NAVIGATION_ROUTE_PATTERN_PROFILES = @"navigate/profiles";
NSString *const URL_NAVIGATION_ROUTE_PATTERN_PROFILES_SELECT = @"navigate/profiles/:id";
NSString *const URL_NAVIGATION_ROUTE_PATTERN_PROFILES_CHANNELS = @"navigate/profiles/:id/channels";
NSString *const URL_NAVIGATION_ROUTE_PATTERN_PROFILES_AUTH = @"navigate/profiles/:id/auth";
NSString *const URL_NAVIGATION_ROUTE_PATTERN_INTERFACES_SELECT = @"navigate/interfaces/:id";
NSString *const URL_NAVIGATION_ROUTE_PATTERN_WIDGET_SELECT = @"navigate/widgets";
NSString *const URL_NAVIGATION_ROUTE_PATTERN_USER_AUTH = @"navigate/auth";
NSString *const URL_NAVIGATION_ROUTE_PATTERN_USER_PROFILE = @"navigate/user";
NSString *const URL_NAVIGATION_ROUTE_PATTERN_USER_SETTINGS = @"navigate/user/settings";

// XIB Identifiers
// -----------------------------------------
NSString *const SCREEN_ID_HINT_ADD_DEVICE = @"AddDeviceHintViewController";
NSString *const SCREEN_ID_ONBOARDING = @"OnboardingViewController";
NSString *const SCREEN_ID_USER_AUTH = @"UserAuthViewController";
NSString *const SCREEN_ID_USER_AUTH_SIGNIN = @"UserAuthSignInViewController";
NSString *const SCREEN_ID_USER_AUTH_RESET_PASSWORD = @"UserAuthResetPasswordViewController";
NSString *const SCREEN_ID_USER_AUTH_SIGNUP = @"UserAuthSignUpViewController";
NSString *const SCREEN_ID_PROFILE_MENU = @"ProfileMenuViewController";
NSString *const SCREEN_ID_QRCODE_READER = @"QRCodeReaderViewController";
NSString *const SCREEN_ID_CHANNEL_OAUTH = @"OAuthViewController";
NSString *const SCREEN_ID_CHANNELS = @"ChannelsViewController";
NSString *const SCREEN_ID_TIMELINE = @"MZCardsTabViewController";
NSString *const SCREEN_ID_TIMELINE_EVENT = @"TimelineEventViewController";
NSString *const SCREEN_ID_MUZZLEY_INTERACTION_CONTAINER = @"MZMuzzleyInteractionViewController";
//deprecated?NSString *const SCREEN_ID_THING_INTERACTION = @"ThingInteractionViewController";
NSString *const SCREEN_ID_CREATE_WORKER = @"CreateWorkerViewController";
NSString *const SCREEN_ID_WORKER_RULE = @"WorkerRuleViewController";

// Table View Cell Identifiers
// ------------------------------------------
NSString *const CELL_ID_SIGN_IN = @"SignInTableViewCell";
NSString *const CELL_ID_SIGN_UP = @"SignUpTableViewCell";
NSString *const CELL_ID_IMG = @"MZTableViewCellImg";
NSString *const CELL_ID_SUBSCRIBED_CHANNEL = @"SubscribedChannelCell";
NSString *const CELL_ID_CHANNEL_POST = @"MZChannelEventCell";

// Collection View Cell Identifiers
// ------------------------------------------
NSString *const COLLECTION_ITEM_ID = @"MZSliderItem";
NSString *const COLLECTION_ITEM_ID_IMG_LABEL = @"MZCollectionItemImgLabel";
NSString *const COLLECTION_ITEM_ID_LABEL = @"MZCollectionItemLabel";

NSString *const COLLECTION_ITEM_ID_ONBOARDING = @"OnboardingCollectionCell";

NSString *const COLLECTION_ITEM_ID_TIMELINE_EVENT_HEADER = @"TimelineEventHeaderCell";
NSString *const COLLECTION_ITEM_ID_TIMELINE_EVENT_TEXT_CONTENT = @"TimelineEventTextContentCell";
NSString *const COLLECTION_ITEM_ID_TIMELINE_EVENT_PHOTO_CONTENT = @"TimelineEventPhotoContentCell";
NSString *const COLLECTION_ITEM_ID_TIMELINE_EVENT_SUGGESTION_COUNT = @"TimelineEventSuggestionCountCell";
NSString *const COLLECTION_ITEM_ID_TIMELINE_EVENT_HORIZONTAL_ACTIONS = @"TimelineEventHorizontalActionsCell";
NSString *const COLLECTION_ITEM_ID_TIMELINE_EVENT_VERTICAL_ACTIONS = @"TimelineEventVerticalActionsCell";
NSString *const COLLECTION_ITEM_ID_TIMELINE_CONTEXT_EVENT_ACTION = @"TimelineContextEventActionCell";
NSString *const COLLECTION_ITEM_ID_TIMELINE_GENERIC_EVENT_ACTION = @"TimelineGenericEventActionCell";
NSString *const COLLECTION_ITEM_ID_TIMELINE_MANAGER_EVENT_ACTION = @"TimelineManagerEventActionCell";

NSString *const COLLECTION_ITEM_ID_TIMELINE_SPINNER = @"TimelineSpinnerCell";


// MQTT Core URL
NSString * MUZZLEY_MQTT_CORE_URL = @"in.muzzley.com";
NSString * MUZZLEY_MQTT_TOPIC_PREFIX = @"/v3";



NSString * MUZZLEY_PHILIPSHUE_PROFILEID = @"";



// Muzzley API Base Url - AUTHENTICAÇÃO
NSString *const VERSION_AUTH_API_BASE_URL = @"";
// Muzzley Site API Base Url - WEBVIEWS
NSString *const VERSION_WEB_BASE_URL = @"";
// Muzzley Site API Worker Url
NSString *const VERSION_WORKER_EDITOR_ENDPOINT_URL = @"";
// Channel REST API
NSString *const VERSION_REST_API_BASE_URL = @"/v3/legacy";
// Core
NSString *const VERSION_CORE_URL = @"/v3";
// Worker Editor version
NSString *const VERSION_WORKER_EDITOR = @"2.0";


// Google Client Token
//NSString *const GOOGLE_AUTH_CLIENT_ID = @"871976415890-qvhmnc61hr4hu0ja0evq6h78s3ga134q.apps.googleusercontent.com";
NSString *const GOOGLE_URL_SCHEME = @"";
// Facebook Url Scheme
NSString *const FACEBOOK_URL_SCHEME = @"";
// Apple App Id
NSString *const APPLE_APP_ID = @"604133373";


// PARAMETERS KEYS
NSString *const KEY_USER     = @"userId";
NSString *const KEY_TILE     = @"tileId";
NSString *const KEY_ACTION   = @"action";
NSString *const KEY_INCLUDE  = @"include";
NSString *const KEY_EXCLUDE  = @"exclude";
NSString *const KEY_OFFSET   = @"offset";
NSString *const KEY_LIMIT    = @"limit";
NSString *const KEY_PLACE    = @"place";
NSString *const KEY_CATEGORY = @"category";
NSString *const KEY_TYPE     = @"type";
NSString *const KEY_CHANNELS = @"channels";
NSString *const KEY_MUZZCAP  = @"muz-capabilities";

NSString *const KEY_FORCE_LOGOUT = @"force_logout";

NSString *const NONE_CAPABILITY = @"none";

//NOTIFICATION CENTER
NSString *const ClientDidConnect = @"ClientDidConnect";
NSString *const MQTTDidSubscribe = @"MQTTDidSubscribe";
NSString *const MQTTDidConnect = @"MQTTDidConnect";

NSString *const AppManagerDidReceiveMuzzleyURLSchema = @"AppManagerDidReceiveMuzzleyURLSchema";

CGFloat const CORNER_RADIUS = 3;


