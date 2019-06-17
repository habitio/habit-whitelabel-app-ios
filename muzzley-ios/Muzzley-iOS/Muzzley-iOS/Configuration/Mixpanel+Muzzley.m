//
//  Mixpanel+Muzzley.m
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 17/8/15.
//  Copyright (c) 2015 Muzzley. All rights reserved.
//

#import "Mixpanel+Muzzley.h"

#pragma mark - Mixpanel Tags
#pragma mark - Lifecycle

NSString *const MIXPANEL_EVENT_START_APP = @"Start App";
NSString *const MIXPANEL_EVENT_EXIT_APP = @"Exit App";
NSString *const MIXPANEL_EVENT_NAVIGATE_TO = @"Navigate To";

NSString *const MIXPANEL_EVENT_FORCE_UPDATE_SHOW = @"Update - Show";
NSString *const MIXPANEL_EVENT_FORCE_UPDATE_REDIRECT_STORE = @"Update - Redirect Store";


#pragma mark - Authentication

NSString *const MIXPANEL_EVENT_SIGN_IN_START = @"Sign In - Start";
NSString *const MIXPANEL_EVENT_SIGN_IN_FINISH = @"Sign In - Finish";

NSString *const MIXPANEL_EVENT_SIGN_UP_START = @"Sign Up - Start";
NSString *const MIXPANEL_EVENT_SIGN_UP_FINISH = @"Sign Up - Finish";

NSString *const MIXPANEL_EVENT_SIGN_OUT = @"Sign Out";

#pragma mark Forgot Password

NSString *const MIXPANEL_EVENT_FORGOT_PASSWORD_START = @"Forgot Password - Start";
NSString *const MIXPANEL_EVENT_FORGOT_PASSWORD_REQUEST_FINISH = @"Forgot Password - Request Finish";


#pragma mark - Devices

NSString *const MIXPANEL_EVENT_MANUAL_INTERACTION = @"Manual Interaction";

#pragma mark Add Device

NSString *const MIXPANEL_EVENT_ADD_DEVICE_START = @"Add Device - Start";
NSString *const MIXPANEL_EVENT_ADD_DEVICE_CANCEL = @"Add Device - Cancel";
NSString *const MIXPANEL_EVENT_ADD_DEVICE_SELECT_DEVICE = @"Add Device - Select Device";
NSString *const MIXPANEL_EVENT_ADD_DEVICE_SELECT_CHANNEL = @"Add Device - Select Channel";
NSString *const MIXPANEL_EVENT_ADD_DEVICE_FINISH = @"Add Device - Finish";

#pragma mark Edit Device

NSString *const MIXPANEL_EVENT_EDIT_DEVICE_START = @"Edit Device - Start";
NSString *const MIXPANEL_EVENT_EDIT_DEVICE_FINISH = @"Edit Device - Finish";
NSString *const MIXPANEL_EVENT_EDIT_DEVICE_DELETE_CANCEL = @"Edit Device - Delete Cancel";
NSString *const MIXPANEL_EVENT_EDIT_DEVICE_DELETE_FINISH = @"Edit Device - Delete Finish";

#pragma mark Groups

NSString *const MIXPANEL_EVENT_CREATE_GROUP_START = @"Create Group - Start";
NSString *const MIXPANEL_EVENT_CREATE_GROUP_CANCEL = @"Create Group - Cancel";
NSString *const MIXPANEL_EVENT_CREATE_GROUP_FINISH = @"Create Group - Finish";

NSString *const MIXPANEL_EVENT_EDIT_GROUP_START = @"Edit Group - Start";
NSString *const MIXPANEL_EVENT_EDIT_GROUP_CANCEL = @"Edit Group - Cancel";
NSString *const MIXPANEL_EVENT_EDIT_GROUP_FINISH = @"Edit Group - Finish";
NSString *const MIXPANEL_EVENT_EDIT_GROUP_UNGROUP_CANCEL = @"Edit Group - Ungroup - Cancel";
NSString *const MIXPANEL_EVENT_EDIT_GROUP_UNGROUP_FINISH = @"Edit Group - Ungroup - Finish";


#pragma mark - Routines

NSString *const MIXPANEL_EVENT_ENABLE_ROUTINE = @"Enable Routine";
NSString *const MIXPANEL_EVENT_DISABLE_ROUTINE = @"Disable Routine";

NSString *const MIXPANEL_EVENT_REMOVE_ROUTINE_START = @"Remove Routine - Start";
NSString *const MIXPANEL_EVENT_REMOVE_ROUTINE_CANCEL = @"Remove Routine - Cancel";
NSString *const MIXPANEL_EVENT_REMOVE_ROUTINE_FINISH = @"Remove Routine - Finish";

NSString *const MIXPANEL_EVENT_EXECUTE_ROUTINE = @"Execute Routine";


#pragma mark Add Routine

NSString *const MIXPANEL_EVENT_CREATE_ROUTINE_START = @"Create Routine - Start";
NSString *const MIXPANEL_EVENT_CREATE_ROUTINE_CANCEL = @"Create Routine - Cancel";
NSString *const MIXPANEL_EVENT_CREATE_ROUTINE_FINISH = @"Create Routine - Finish";

NSString *const MIXPANEL_EVENT_CREATE_ROUTINE_ADD_TRIGGER_START = @"Create Routine - Add Trigger Start";
NSString *const MIXPANEL_EVENT_CREATE_ROUTINE_ADD_TRIGGER_FINISH = @"Create Routine - Add Trigger Finish";
//NSString *const MIXPANEL_EVENT_CREATE_ROUTINE_EDIT_TRIGGER_START = @"Create Routine - Edit Trigger Start";
//NSString *const MIXPANEL_EVENT_CREATE_ROUTINE_EDIT_TRIGGER_FINISH = @"Create Routine - Edit Trigger Finish";
NSString *const MIXPANEL_EVENT_CREATE_ROUTINE_DELETE_TRIGGER_FINISH = @"Create Routine - Delete Trigger Finish";

NSString *const MIXPANEL_EVENT_CREATE_ROUTINE_ADD_ACTION_START = @"Create Routine - Add Action Start";
NSString *const MIXPANEL_EVENT_CREATE_ROUTINE_ADD_ACTION_FINISH = @"Create Routine - Add Action Finish";
//NSString *const MIXPANEL_EVENT_CREATE_ROUTINE_EDIT_ACTION_START = @"Create Routine - Edit Action Start";
//NSString *const MIXPANEL_EVENT_CREATE_ROUTINE_EDIT_ACTION_FINISH = @"Create Routine - Edit Action Finish";
NSString *const MIXPANEL_EVENT_CREATE_ROUTINE_DELETE_ACTION_FINISH = @"Create Routine - Delete Action Finish";
NSString *const MIXPANEL_EVENT_CREATE_ROUTINE_DELETE_RULE_ACTION_FINISH = @"Create Routine - Delete Rule Action Finish";

NSString *const MIXPANEL_EVENT_CREATE_ROUTINE_ADD_STATE_START = @"Create Routine - Add But Only If Start";
NSString *const MIXPANEL_EVENT_CREATE_ROUTINE_ADD_STATE_FINISH = @"Create Routine - Add But Only If Finish";
//NSString *const MIXPANEL_EVENT_CREATE_ROUTINE_EDIT_STATE_START = @"Create Routine - Edit But Only If Start";
//NSString *const MIXPANEL_EVENT_CREATE_ROUTINE_EDIT_STATE_FINISH = @"Create Routine - Edit But Only If Finish";
NSString *const MIXPANEL_EVENT_CREATE_ROUTINE_DELETE_STATE_FINISH = @"Create Routine - Delete But Only If Finish";

#pragma Edit Routine

NSString *const MIXPANEL_EVENT_EDIT_ROUTINE_START = @"Edit Routine - Start";
NSString *const MIXPANEL_EVENT_EDIT_ROUTINE_CANCEL = @"Edit Routine - Cancel";
NSString *const MIXPANEL_EVENT_EDIT_ROUTINE_FINISH = @"Edit Routine - Finish";

NSString *const MIXPANEL_EVENT_EDIT_ROUTINE_ADD_TRIGGER_START = @"Edit Routine - Add Trigger Start";
NSString *const MIXPANEL_EVENT_EDIT_ROUTINE_ADD_TRIGGER_FINISH = @"Edit Routine - Add Trigger Finish";
//NSString *const MIXPANEL_EVENT_EDIT_ROUTINE_EDIT_TRIGGER_START = @"Edit Routine - Edit Trigger Start";
//NSString *const MIXPANEL_EVENT_EDIT_ROUTINE_EDIT_TRIGGER_FINISH = @"Edit Routine - Edit Trigger Finish";
NSString *const MIXPANEL_EVENT_EDIT_ROUTINE_DELETE_TRIGGER_FINISH = @"Edit Routine - Delete Trigger Finish";

NSString *const MIXPANEL_EVENT_EDIT_ROUTINE_ADD_ACTION_START = @"Edit Routine - Add Action Start";
NSString *const MIXPANEL_EVENT_EDIT_ROUTINE_ADD_ACTION_FINISH = @"Edit Routine - Add Action Finish";
//NSString *const MIXPANEL_EVENT_EDIT_ROUTINE_EDIT_ACTION_START = @"Edit Routine - Edit Action Start";
//NSString *const MIXPANEL_EVENT_EDIT_ROUTINE_EDIT_ACTION_FINISH = @"Edit Routine - Edit Action Finish";
NSString *const MIXPANEL_EVENT_EDIT_ROUTINE_DELETE_ACTION_FINISH = @"Edit Routine - Delete Action Finish";
NSString *const MIXPANEL_EVENT_EDIT_ROUTINE_DELETE_RULE_ACTION_FINISH = @"Edit Routine - Delete Rule Action Finish";

NSString *const MIXPANEL_EVENT_EDIT_ROUTINE_ADD_STATE_START = @"Edit Routine - Add But Only If Start";
NSString *const MIXPANEL_EVENT_EDIT_ROUTINE_ADD_STATE_FINISH = @"Edit Routine - Add But Only If Finish";
//NSString *const MIXPANEL_EVENT_EDIT_ROUTINE_EDIT_STATE_START = @"Edit Routine - Edit But Only If Start";
//NSString *const MIXPANEL_EVENT_EDIT_ROUTINE_EDIT_STATE_FINISH = @"Edit Routine - Edit But Only If Finish";
NSString *const MIXPANEL_EVENT_EDIT_ROUTINE_DELETE_STATE_FINISH = @"Edit Routine - Delete But Only If Finish";


#pragma mark - Shortcuts

NSString *const MIXPANEL_EVENT_EXECUTE_SHORTCUT = @"Execute Shortcut";

#pragma mark Add Shortcut

NSString *const MIXPANEL_EVENT_CREATE_SHORTCUT_START = @"Create Shortcut - Start";
NSString *const MIXPANEL_EVENT_CREATE_SHORTCUT_CANCEL = @"Create Shortcut - Cancel";
NSString *const MIXPANEL_EVENT_CREATE_SHORTCUT_FINISH = @"Create Shortcut - Finish";

NSString *const MIXPANEL_EVENT_CREATE_SHORTCUT_ADD_ACTION_START = @"Create Shortcut - Add Action Start";
NSString *const MIXPANEL_EVENT_CREATE_SHORTCUT_ADD_ACTION_FINISH = @"Create Shortcut - Add Action Finish";
//NSString *const MIXPANEL_EVENT_CREATE_SHORTCUT_EDIT_ACTION_START = @"Create Shortcut - Edit Action Start";
//NSString *const MIXPANEL_EVENT_CREATE_SHORTCUT_EDIT_ACTION_FINISH = @"Create Shortcut - Edit Action Finish";
NSString *const MIXPANEL_EVENT_CREATE_SHORTCUT_DELETE_ACTION_FINISH = @"Create Shortcut - Delete Action Finish";
NSString *const MIXPANEL_EVENT_CREATE_SHORTCUT_DELETE_RULE_ACTION_FINISH = @"Create Shortcut - Delete Rule Action Finish";

#pragma mark Edit Shortcuts

NSString *const MIXPANEL_EVENT_EDIT_SHORTCUT_START = @"Edit Shortcut - Start";
NSString *const MIXPANEL_EVENT_EDIT_SHORTCUT_CANCEL = @"Edit Shortcut - Cancel";
NSString *const MIXPANEL_EVENT_EDIT_SHORTCUT_FINISH = @"Edit Shortcut - Finish";

NSString *const MIXPANEL_EVENT_EDIT_SHORTCUT_ADD_ACTION_START = @"Edit Shortcut - Add Action Start";
NSString *const MIXPANEL_EVENT_EDIT_SHORTCUT_ADD_ACTION_FINISH = @"Edit Shortcut - Add Action Finish";
//NSString *const MIXPANEL_EVENT_EDIT_SHORTCUT_EDIT_ACTION_START = @"Edit Shortcut - Edit Action Start";
//NSString *const MIXPANEL_EVENT_EDIT_SHORTCUT_EDIT_ACTION_FINISH = @"Edit Shortcut - Edit Action Finish";
NSString *const MIXPANEL_EVENT_EDIT_SHORTCUT_DELETE_ACTION_FINISH = @"Edit Shortcut - Delete Action Finish";
NSString *const MIXPANEL_EVENT_EDIT_SHORTCUT_DELETE_RULE_ACTION_FINISH = @"Edit Shortcut - Delete Rule Action Finish";

#pragma mark Remove Shortcuts

NSString *const MIXPANEL_EVENT_REMOVE_SHORTCUT_START = @"Remove Shortcut - Start";
NSString *const MIXPANEL_EVENT_REMOVE_SHORTCUT_CANCEL = @"Remove Shortcut - Cancel";
NSString *const MIXPANEL_EVENT_REMOVE_SHORTCUT_FINISH = @"Remove Shortcut - Finish";


#pragma mark - Suggestions

NSString *const MIXPANEL_EVENT_SUGGESTION_VIEW = @"Suggestion - View";
NSString *const MIXPANEL_EVENT_SUGGESTION_USER_ENGAGE = @"Suggestion - User Engage";
NSString *const MIXPANEL_EVENT_SUGGESTION_FINISH = @"Suggestion - Finish";
NSString *const MIXPANEL_EVENT_SUGGESTION_HIDE = @"Suggestion - Hide";


#pragma mark - User Profile
#pragma mark Feedback

NSString *const MIXPANEL_EVENT_FEEDBACK_START = @"Feedback - Start";
NSString *const MIXPANEL_EVENT_FEEDBACK_FINISH = @"Feedback - Finish";

#pragma mark About

NSString *const MIXPANEL_EVENT_ABOUT_VIEW = @"About Muzzley - View";


#pragma mark - Mixpanel Properties

NSString *const MIXPANEL_PROPERTY_APPLICATION = @"Application";
NSString *const MIXPANEL_PROPERTY_USER_NAME = @"Name";
NSString *const MIXPANEL_PROPERTY_USER_ID = @"User ID";
NSString *const MIXPANEL_PROPERTY_USER_EMAIL = @"Email";
NSString *const MIXPANEL_PROPERTY_STATUS = @"Status";
NSString *const MIXPANEL_PROPERTY_DETAIL = @"Detail";
NSString *const MIXPANEL_PROPERTY_PROFILE_ID = @"Profile ID";
//NSString *const MIXPANEL_PROPERTY_PROFILE_NAME = @"Profile Name";
NSString *const MIXPANEL_PROPERTY_DEVICE_NAME = @"Device Name";
NSString *const MIXPANEL_PROPERTY_CHANNEL_ID = @"Channel ID";
NSString *const MIXPANEL_PROPERTY_CHANNEL_NAME = @"Channel Name";
NSString *const MIXPANEL_PROPERTY_COMPONENT_NAME = @"Component Name";
//NSString *const MIXPANEL_PROPERTY_TRIGGER = @"Trigger";
//NSString *const MIXPANEL_PROPERTY_ACTION = @"Action";
//NSString *const MIXPANEL_PROPERTY_STATE = @"State";
NSString *const MIXPANEL_PROPERTY_ROUTINE_ID = @"Routine ID";
NSString *const MIXPANEL_PROPERTY_SOURCE = @"Source";
NSString *const MIXPANEL_PROPERTY_WHERE = @"Where";
NSString *const MIXPANEL_PROPERTY_GROUP_ID = @"Group ID";
NSString *const MIXPANEL_PROPERTY_INTERACTION_SOURCE = @"Interaction Source";
NSString *const MIXPANEL_PROPERTY_INTERACTION_VIEW = @"Interaction View";
NSString *const MIXPANEL_PROPERTY_GROUP_COUNT = @"Group Count";
NSString *const MIXPANEL_PROPERTY_INTERACTION_PROPERTY = @"Interaction Property";
NSString *const MIXPANEL_PROPERTY_PLATFORM = @"Platform";
NSString *const MIXPANEL_PROPERTY_SCREEN = @"Screen";
NSString *const MIXPANEL_PROPERTY_TYPE = @"Type";
NSString *const MIXPANEL_PROPERTY_SHORTCUT_ID = @"Shortcut ID";
//NSString *const MIXPANEL_PROPERTY_SHORTCUT_AVAILABLE_ON = @"Available On";
NSString *const MIXPANEL_PROPERTY_SHORTCUT_WHERE = @"Where";
NSString *const MIXPANEL_PROPERTY_SHORTCUT_SOURCE = @"Source";
NSString *const MIXPANEL_PROPERTY_SUGGESTION_ID = @"Suggestion ID";
NSString *const MIXPANEL_PROPERTY_CLASS = @"Class";
NSString *const MIXPANEL_PROPERTY_ACTION_TYPE = @"Action Type";
NSString *const MIXPANEL_PROPERTY_STAGE_INDEX = @"Stage Index";
NSString *const MIXPANEL_PROPERTY_VALUE = @"Value";
NSString *const MIXPANEL_PROPERTY_QUESTION_ID = @"Question ID";
NSString *const MIXPANEL_PROPERTY_OPTION_ID = @"Option ID";


NSString *const MIXPANEL_VALUE_ERROR = @"Error";
NSString *const MIXPANEL_VALUE_SUCCESS = @"Success";
NSString *const MIXPANEL_VALUE_EMAIL = @"Email";
NSString *const MIXPANEL_VALUE_FACEBOOK = @"Facebook";
NSString *const MIXPANEL_VALUE_GOOGLE = @"Google";
NSString *const MIXPANEL_VALUE_TILE = @"Tile";
NSString *const MIXPANEL_VALUE_ADVANCE_INTERFACE = @"Advance interface";
NSString *const MIXPANEL_VALUE_GROUP = @"Group";
NSString *const MIXPANEL_VALUE_INDIVIDUAL = @"Individual";
NSString *const MIXPANEL_VALUE_MANUAL = @"Manual";
NSString *const MIXPANEL_VALUE_SUGGESTION = @"Suggestion";
NSString *const MIXPANEL_VALUE_CONTEXTUAL = @"Contextual";
NSString *const MIXPANEL_VALUE_APP = @"App";


@implementation Mixpanel (Muzzley)

@end
