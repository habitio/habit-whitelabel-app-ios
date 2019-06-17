//
//  AppConstants.h
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 21/11/12.
//  Copyright (c) 2012 Muzzley. All rights reserved.
//

// Map View
// -----------------------------------------
extern float const MUZZLEY_MAP_ZOOM;

// URL Muzzley Command
// -----------------------------------------
extern NSString *const MUZZLEY_URL_COMMAND_ID;
extern NSString *const MUZZLEY_URL_COMMAND_NAVIGATE_ID;
extern NSString *const MUZZLEY_URL_COMMAND_EXECUTE_ID;

// URL Routing Pattern
// -----------------------------------------
extern NSString *const URL_NAVIGATION_ROUTE_PATTERN_ROOT;
extern NSString *const URL_NAVIGATION_ROUTE_PATTERN_TIMELINE;
extern NSString *const URL_NAVIGATION_ROUTE_PATTERN_TIMELINE_EVENT;
extern NSString *const URL_NAVIGATION_ROUTE_PATTERN_WORKERS;
extern NSString *const URL_NAVIGATION_ROUTE_PATTERN_WORKERS_CREATE;
//extern NSString *const URL_NAVIGATION_ROUTE_PATTERN_WORKERS_SELECT;
//extern NSString *const URL_NAVIGATION_ROUTE_PATTERN_WORKERS_EDIT;
//extern NSString *const URL_NAVIGATION_ROUTE_PATTERN_WORKERS_DELETE;
extern NSString *const URL_NAVIGATION_ROUTE_PATTERN_CHANNELS;
//extern NSString *const URL_NAVIGATION_ROUTE_PATTERN_CHANNELS_SELECT;
//extern NSString *const URL_NAVIGATION_ROUTE_PATTERN_CHANNELS_EDIT;
//extern NSString *const URL_NAVIGATION_ROUTE_PATTERN_CHANNELS_DELETE;
extern NSString *const URL_NAVIGATION_ROUTE_PATTERN_NOTIFICATIONS;
extern NSString *const URL_NAVIGATION_ROUTE_PATTERN_PROFILES;
//extern NSString *const URL_NAVIGATION_ROUTE_PATTERN_PROFILES_SELECT;
//extern NSString *const URL_NAVIGATION_ROUTE_PATTERN_PROFILES_CHANNELS;
//extern NSString *const URL_NAVIGATION_ROUTE_PATTERN_PROFILES_AUTH;
extern NSString *const URL_NAVIGATION_ROUTE_PATTERN_INTERFACES_SELECT;
extern NSString *const URL_NAVIGATION_ROUTE_PATTERN_WIDGET_SELECT;
extern NSString *const URL_NAVIGATION_ROUTE_PATTERN_USER_AUTH;
extern NSString *const URL_NAVIGATION_ROUTE_PATTERN_USER_PROFILE;
//extern NSString *const URL_NAVIGATION_ROUTE_PATTERN_USER_SETTINGS;

// XIB Identifiers
// -----------------------------------------
extern NSString *const SCREEN_ID_HINT_ADD_DEVICE;
extern NSString *const SCREEN_ID_ONBOARDING;
extern NSString *const SCREEN_ID_USER_AUTH;
extern NSString *const SCREEN_ID_USER_AUTH_SIGNIN;
extern NSString *const SCREEN_ID_USER_AUTH_RESET_PASSWORD;
extern NSString *const SCREEN_ID_USER_AUTH_SIGNUP;
extern NSString *const SCREEN_ID_PROFILE_MENU;
extern NSString *const SCREEN_ID_QRCODE_READER;
extern NSString *const SCREEN_ID_CHANNEL_PROFILES;
extern NSString *const SCREEN_ID_CHANNEL_OAUTH;
extern NSString *const SCREEN_ID_CHANNELS;
extern NSString *const SCREEN_ID_TIMELINE;
extern NSString *const SCREEN_ID_TIMELINE_EVENT;
extern NSString *const SCREEN_ID_WIDGET_AWAITING;
extern NSString *const SCREEN_ID_LOCAL_DEVICE_DISCOVERY;
extern NSString *const SCREEN_ID_MUZZLEY_INTERACTION_CONTAINER;
extern NSString *const SCREEN_ID_THING_INTERACTION;
extern NSString *const SCREEN_ID_CREATE_WORKER;
extern NSString *const SCREEN_ID_WORKER_RULE;

// Table View Cell Identifiers
// ------------------------------------------
extern NSString *const CELL_ID_SIGN_IN;
extern NSString *const CELL_ID_SIGN_UP;
extern NSString *const CELL_ID_IMG;
extern NSString *const CELL_ID_CHANNEL_POST;

// Collection View Cell Identifiers
// ------------------------------------------
extern NSString *const COLLECTION_ITEM_ID;
extern NSString *const COLLECTION_ITEM_ID_IMG_LABEL;
extern NSString *const COLLECTION_ITEM_ID_LABEL;

extern NSString *const COLLECTION_ITEM_ID_ONBOARDING;

extern NSString *const COLLECTION_ITEM_ID_TIMELINE_EVENT_HEADER;
extern NSString *const COLLECTION_ITEM_ID_TIMELINE_EVENT_TEXT_CONTENT;
extern NSString *const COLLECTION_ITEM_ID_TIMELINE_EVENT_PHOTO_CONTENT;
extern NSString *const COLLECTION_ITEM_ID_TIMELINE_EVENT_SUGGESTION_COUNT;
extern NSString *const COLLECTION_ITEM_ID_TIMELINE_EVENT_HORIZONTAL_ACTIONS;
extern NSString *const COLLECTION_ITEM_ID_TIMELINE_EVENT_VERTICAL_ACTIONS;
extern NSString *const COLLECTION_ITEM_ID_TIMELINE_CONTEXT_EVENT_ACTION;
extern NSString *const COLLECTION_ITEM_ID_TIMELINE_GENERIC_EVENT_ACTION;
extern NSString *const COLLECTION_ITEM_ID_TIMELINE_MANAGER_EVENT_ACTION;
extern NSString *const COLLECTION_ITEM_ID_TIMELINE_SPINNER;


// Apple app ID Configs
// ------------------------------------------
extern NSString *const APPLE_APP_ID;




extern NSString * MUZZLEY_PHILIPSHUE_PROFILEID;

// Muzzley API Base Url - AUTHENTICAÇÃO
extern NSString *const VERSION_AUTH_API_BASE_URL;
// Muzzley Site API Base Url - WEBVIEWS
extern NSString *const VERSION_WEB_BASE_URL;
// Muzzley Site API Worker Url
extern NSString *const VERSION_WORKER_EDITOR_ENDPOINT_URL;
// Channel REST API
extern NSString *const VERSION_REST_API_BASE_URL;
// Worker Editor version
extern NSString *const VERSION_WORKER_EDITOR;
// Core
extern NSString *const VERSION_CORE_URL;




// Google Client Token
// ------------------------------------------
//extern NSString *const GOOGLE_AUTH_CLIENT_ID;

// Google Url Scheme
// ------------------------------------------
extern NSString *const GOOGLE_URL_SCHEME;

// Facebook Url Scheme
// ------------------------------------------
extern NSString *const FACEBOOK_URL_SCHEME;


extern NSString *const ENDPOINT_VERSION;


// PARAMETERS KEYS
extern NSString *const KEY_USER;
extern NSString *const KEY_TILE;
extern NSString *const KEY_ACTION;
extern NSString *const KEY_INCLUDE;
extern NSString *const KEY_EXCLUDE;
extern NSString *const KEY_OFFSET;
extern NSString *const KEY_LIMIT;
extern NSString *const KEY_PLACE;
extern NSString *const KEY_CATEGORY;
extern NSString *const KEY_TYPE;
extern NSString *const KEY_CHANNELS;
extern NSString *const KEY_MUZZCAP;

extern NSString *const KEY_FORCE_LOGOUT;
extern NSString *const NONE_CAPABILITY;


//NOTIFICATION CENTER
extern NSString *const ClientDidConnect;
extern NSString *const MQTTDidSubscribe;
extern NSString *const AppManagerDidReceiveMuzzleyURLSchema;



@class UITableView;
@class UICollectionView;
@class NSObject;

typedef id (^ConfigureTableViewCell)(UITableView *tableView, NSObject *item, NSIndexPath *indexPath);
typedef id (^ConfigureCollectionViewCell)(UICollectionView *collectionView, NSObject *item, NSIndexPath *indexPath);


extern CGFloat const CORNER_RADIUS;

