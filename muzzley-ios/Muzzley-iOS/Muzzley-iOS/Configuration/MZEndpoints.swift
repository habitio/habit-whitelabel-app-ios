//
//  MZEndpoints.swift
//  Muzzley-iOS
//
//  Created by Ana Figueira on 24/03/2017.
//  Copyright © 2017 Muzzley. All rights reserved.
//

import UIKit

var SiteHost : String =  MZThemeManager.sharedInstance.endpoints.webBaseUrl
var APIHost : String = ""
var MQTTHost : String = ""
var OAuthHost : String = MZThemeManager.sharedInstance.endpoints.authBase

@objc class MZEndpoints: NSObject
{
	
	static let APIVersion = "/v3" // Include legacy on the request that requires it
	static let WebviewAPIVersion = "v3"
	
	static let APIHostWithVersion = APIHost + APIVersion
	
	fileprivate override init(){}
	
	class func oAuthHost() -> String { return OAuthHost }
	
	class func apiHost() -> String { return APIHost }

	class func mqttHost() -> String { return MQTTHost }
	
	class func mqttCoreVersion() -> String { return "/v3" }

    /// OAuth
	///

	class func SignIn(clientId: String, username: String, password: String) -> String
    {
		let escapedUsername : String = username.addingPercentEncoding(withAllowedCharacters: .alphanumerics)!
		let escapedPassword : String = password.addingPercentEncoding(withAllowedCharacters: .alphanumerics)!

		return OAuthHost + "/v3/auth/authorize?client_id=" + clientId + "&response_type=password&scope=application,user&username=" + escapedUsername + "&password=" + escapedPassword
	}
    
	class func SignUp() -> String { return OAuthHost + "/v3/legacy/account" }
	class func ResetPassword() -> String { return OAuthHost + "/v3/legacy/sendreset" }
	
	class func RefreshToken(clientId: String, refreshToken: String) -> String { return OAuthHost + "/v3/auth/exchange?client_id=" + clientId + "&refresh_token=" + refreshToken + "&grant_type=password"}
	
	
	/// Vodafone OAuth
	///
	class func VodafoneOAuthBaseUrl() -> String { return "" }
	class func VodafoneOAuthAccessToken(code: String) -> String { return "" }
	class func VodafoneOAuthUserInformation(accessToken: String) -> String { return "" }

	/// Channels
	///
	/// https://bitbucket.org/muzzley/muzzley-api/wiki/tiles
	/// https://bitbucket.org/muzzley/muzzley-wiki/wiki/workers-device-capabilities
	///
	
	class func Channels(_ userId: String) -> String { return APIHostWithVersion + "/legacy/users/" + userId + "/channels" }  //+ "/channels?include=channelProperties" }
	
	class func ChannelsWithContext(_ userId: String) -> String { return APIHostWithVersion + "/legacy/users/" + userId + "/channels?include=channelProperties,context" }
	
	class func ChannelsTriggerable(_ userId: String) -> String { return APIHostWithVersion + "/legacy/users/" + userId + "/channels?include=channelProperties,context&type=triggerable" }
	
	class func ChannelsActionable(_ userId: String) -> String { return APIHostWithVersion + "/legacy/users/" + userId + "/channels?include=channelProperties,context&type=actionable" }
	
	class func ChannelsStateful(_ userId: String) -> String { return APIHostWithVersion + "/legacy/users/" + userId + "/channels?include=channelProperties,context&type=stateful" }

	class func ChannelsByProfile(_ userId: String, profileId: String) -> String { return APIHostWithVersion + "/legacy/users/" + userId + "/channels/filter?filterType=profile&filterValue=" + profileId }
	
	class func ChannelsByTemplateId(_ userId: String, _ channelTemplateId: String) -> String { return APIHostWithVersion + "/users/" + userId + "/channels?channel.channeltemplate_id=" + channelTemplateId }
	
	/// Profiles
	///
	/// Include the following headers in getProfiles:
	/// muz-capabilities, discovery-webview=1, discovery-recipe=2
	///
	class func Profiles() -> String { return APIHostWithVersion + "/legacy/profiles" }
		
	class func ProfileAuthorization(_ profileId : String) -> String { return APIHostWithVersion + "/legacy/profiles/" + profileId + "/authorization" }
	
	class func ProfileChannels(_ profileId : String) -> String { return APIHostWithVersion + "/legacy/profiles/" + profileId + "/channels" }
    
    /// Channel Templates
    ///
    ///
    class func ChannelTemplates(_ userId: String) -> String { return APIHostWithVersion + "/users/" + userId + "/channel-templates" }
    
    class func ChannelTemplatesById(_ userId: String, channelTemplateId: String) -> String { return APIHostWithVersion + "/users/" + userId + "/channel-templates?template.id=" + channelTemplateId }
    
    class func ChannelTemplatesByType(_ userId: String, type: String) -> String { return APIHostWithVersion + "/users/" + userId + "/channel-templates?template.type=" + type + "&order_by=+order_index&order_index=gt/-999999/n" }
    
    /// Recipes
    ///
    ///
    class func RecipeMetadata(_ recipeId: String) -> String { return APIHostWithVersion + "/recipes/" + recipeId + "/meta" }
    
    class func RecipeExecute(_ url: String) -> String { return APIHost + url +  "/execute" }

    
	/// Tiles
	///
	/// https://bitbucket.org/muzzley/muzzley-api/wiki/tiles
	/// https://bitbucket.org/muzzley/muzzley-api/wiki/component-based-tiles
	/// https://bitbucket.org/muzzley/muzzley-wiki/wiki/workers-device-capabilities
	///
	class func Tiles(_ userId: String) -> String { return APIHostWithVersion + "/legacy/users/" + userId + "/tiles" }

	class func Tile(_ userId: String, tileId: String) -> String { return APIHostWithVersion + "/legacy/users/" + userId + "/tiles/" + tileId }

	
	class func TilesWithSpecs(_ userId: String) -> String { return APIHostWithVersion + "/legacy/users/" + userId + "/tiles?include=specs" }
	
	class func TilesWithSpecsContexts(_ userId: String) -> String { return APIHostWithVersion + "/legacy/users/" + userId + "/tiles?include=specs,context" }
	
	class func TilesTriggerable(_ userId: String) -> String { return APIHostWithVersion + "/legacy/users/" + userId + "/tiles?include=specs,context&type=triggerable" }
	
	class func TilesActionables(_ userId: String) -> String { return APIHostWithVersion + "/legacy/users/" + userId + "/tiles?include=specs,context&type=actionable" }
	
	class func TilesStateful(_ userId: String) -> String { return APIHostWithVersion + "/legacy/users/" + userId + "/tiles?include=specs,context&type=stateful" }

	
	/// Tile Groups
	///
	/// https://bitbucket.org/muzzley/muzzley-api/wiki/tile-groups
	///
	class func TileGroup(_ userId: String, groupId: String) -> String { return APIHostWithVersion + "/legacy/users/" + userId + "/tile-groups/" + groupId } // Single group
	
	class func TileGroups(_ userId: String) -> String { return APIHostWithVersion + "/legacy/users/" + userId + "/tile-groups" }
	
	class func TileGroupsIncludeUnsorted(_ userId: String) -> String { return APIHostWithVersion + "/legacy/users/" + userId + "/tile-groups?include=unsorted" }
	
	class func TileGroupsIncludeUnsortedContext(_ userId: String) -> String { return APIHostWithVersion + "/legacy/users/" + userId + "/tile-groups?include=unsorted,context" }
	
	class func TilesInGroup(_ userId: String, groupId: String) -> String {  return APIHostWithVersion + "/legacy/users/" + userId + "/tile-groups/" + groupId + "/tiles" } // All the tiles in a group
	
	class func TileInGroup(_ userId: String, groupId: String, tileId: String) -> String {  return APIHostWithVersion + "/legacy/users/" + userId + "/tile-groups/" + groupId + "/tiles/" + tileId } // A single tile in a group

	
	/// Workers
	///
	/// https://bitbucket.org/muzzley/muzzley-api/wiki/worker-resource
	///
	class func Workers(_ userId: String) -> String { return APIHostWithVersion + "/legacy/users/" + userId + "/workers" }
	
	class func WorkersAndUsecases(_ userId: String) -> String { return APIHostWithVersion + "/legacy/users/" + userId + "/workers" }
	
	class func Worker(_ userId: String, workerId : String) -> String { return APIHostWithVersion + "/legacy/users/" + userId + "/workers/" + workerId }
	
	class func WorkerSpec(_ channelId: String) -> String { return APIHostWithVersion + "/legacy/channels/" + channelId + "/workerspec" }
	
	class func WorkerExecute(_ userId: String, workerId : String) -> String { return APIHostWithVersion + "/legacy/users/" + userId + "/workers/" + workerId + "/play" }
    // Not being used yet but it necessary because of more complex workers that mobile can't execute
	
	
	/// Shortcuts
	///
	/// https://bitbucket.org/muzzley/muzzley-api/wiki/shortcuts
	///
	class func Shortcuts(_ userId: String) -> String { return APIHostWithVersion + "/legacy/users/" + userId + "/shortcuts" }

	class func ShortcutsSuggestions(_ userId: String) -> String { return APIHostWithVersion + "/legacy/users/" + userId + "/shortcuts-suggestions" }

	class func Shortcut(_ userId: String, shortcutId: String) -> String { return APIHostWithVersion + "/legacy/users/" + userId + "/shortcuts/" + shortcutId}
	
	class func ShortcutPlay(_ userId: String, shortcutId: String) -> String { return APIHostWithVersion + "/legacy/users/" + userId + "/shortcuts/" + shortcutId + "/play"}


	class func ShortcutsReorder(_ userId: String) -> String { return APIHostWithVersion + "/legacy/users/" + userId + "/shortcuts/reorder" }

	
	
	///Feedback
	///
	/// https://bitbucket.org/muzzley/muzzley-api/wiki/user-feedback
	///
	class func Feedback(_ userId: String) -> String { return APIHostWithVersion + "/legacy/users/" + userId + "/survey-responses" }
	
	/// AppVersion
	///
	/// https://bitbucket.org/muzzley/muzzley-api/wiki/mobile-clients-support
	///
	class func AppVersion(_ version: String) -> String { return OAuthHost + "/v3/legacy/clients/ios/versions/" + version }

	
	/// Users
	///
	/// https://bitbucket.org/muzzley/muzzley-api/wiki/user-preferences
	/// https://bitbucket.org/muzzley/muzzley-api/wiki/Notifications
	///
	class func User(_ userId: String) -> String { return APIHostWithVersion + "/legacy/users/" + userId }
	class func UserTags(_ userId: String) -> String { return APIHostWithVersion + "/legacy/users/" + userId + "/tags" }

	
	/// Places
	///
	/// https://bitbucket.org/muzzley/muzzley-api/wiki/user-preferences
	///
	class func Places(_ userId: String) -> String { return APIHostWithVersion + "/legacy/users/" + userId + "/places" }
	class func Place(_ userId: String, placeId: String) -> String { return APIHostWithVersion + "/legacy/users/" + userId + "/places/" + placeId }

	
	/// Services
	///
	/// https://bitbucket.org/muzzley/muzzley-api/wiki/Services 
	/// https://bitbucket.org/muzzley/muzzley-api/wiki/add-bundle
	///
	class func Services() -> String { return APIHostWithVersion + "/legacy/services?include=tutorial" }
	class func ServiceAuthorization(_ serviceId: String) -> String { return APIHostWithVersion + "/legacy/services/" + serviceId + "/authorization" }
	class func ServiceSubscribe(_ serviceId: String) -> String { return APIHostWithVersion + "/legacy/services/" + serviceId + "/authorization?op=subscribe" }
	class func ServiceSubscriptions(_ userId: String) -> String { return APIHostWithVersion + "/legacy/users/" + userId + "/services" }
	
	
	/// Cards
	///
	/// https://bitbucket.org/muzzley/muzzley-wiki/wiki/muzzley-postman/Cards
	/// https://bitbucket.org/muzzley/muzzley-api/wiki/Cards
	///
	class func Cards(_ userId: String) -> String { return APIHostWithVersion + "/users/" + userId + "/cards" }
    class func CardsType(_ userId: String, _ type: String) -> String
    { return APIHostWithVersion + "/users/" + userId + "/cards?type=" + type }

	class func CardFeedback(_ userId: String, cardId: String) -> String { return APIHostWithVersion + "/users/" + userId + "/cards/" + cardId + "/feedback"}
	class func CardAdsView(_ userId: String, cardId: String, adId: String) -> String { return APIHostWithVersion + "/users/" + userId + "/cards/" + cardId + "/ads/" + adId + "/view"}
	class func CardAdsClick(_ userId: String, cardId: String, adId: String) -> String { return APIHostWithVersion + "/users/" + userId + "/cards/" + cardId + "/ads/" + adId + "/click"}

	
	/// Widgets Archives
	class func WidgetArchive(uuid: String) -> String { return SiteHost + "/widgets/" + uuid + "/archive" }

	/// Json units
	///
	///
	class func UnitsTableEN() -> String { return "https://cdn.muzzley.com/units/units_table.json" }
	class func UnitsTablePT() -> String { return "https://cdn.muzzley.com/units/units_table_pt.json" }
	
	/// Currency Jsons
	class func CurrenciesTable() -> String { return "https://cdn.muzzley.com/units/currency_table.json" }

    // Neura inbox
    class func NeuraInbox() -> String { return APIHostWithVersion + "/utils/neura/inbox" }
    
}

