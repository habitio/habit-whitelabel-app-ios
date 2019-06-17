//
//  MZThemeManager.swift
//  Muzzley-iOS
//
//  Created by Ana Figueira on 27/12/2016.
//  Copyright © 2016 Muzzley. All rights reserved.
//


import Foundation
import Hex

@objc class MZThemeManager : NSObject
{
	
    private let key_mobile = "mobile"
    private let key_ios = "ios"
    private let key_plugins = "plugins"
    private let key_endpoints = "endpoints"
    private let key_colors = "colors"
    private let key_notifications_azure = "notifications_azure"
    private let key_urls = "urls"
    private let key_copyright = "copyright"
    private let key_features = "features"
    private let key_neura = "neura"
    private let key_mixpanel = "mixpanel"
    private let key_shared_interface = "shared_interface"
    private let key_localization_copy = "localization_copy"
    private let key_language_en = "en"

    
    
    let endpoints : Endpoints
    let colors : Colors
    let copyright : Copyright
    let urls : Urls
    let appInfo : AppInfo
    let azureNotifications : AzureNotifications
    let features : Features
    let neura : Neura?
    let mixpanel : MixpanelInfo?
    let sharedInterface : NSDictionary
    let localization_copy : NSDictionary
	
	class var sharedInstance : MZThemeManager
	{
		struct Singleton
		{
			static let instance = MZThemeManager()
		}
		return Singleton.instance
	}
	
    override init()
	{
		var themePlistPath : String? = ""
		var themeDictionary = NSDictionary()

        let targetName = Bundle.main.infoDictionary?["CFBundleName"] as! String
       
        themePlistPath = Bundle.main.path(forResource: targetName, ofType: "json")
		dLog(themePlistPath!)
		do
		{
			let jsonData = try Data(contentsOf: URL(fileURLWithPath: themePlistPath!), options: NSData.ReadingOptions.mappedIfSafe)
			
			if let jsonResult: NSDictionary = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary
			{
				themeDictionary = jsonResult
			}
		}
		catch _ as NSError
		{
			NSLog("Error occurred loading theme.")
		}
		
        let mobileDict = themeDictionary[self.key_mobile] as! NSDictionary
        let iosDict = mobileDict[self.key_ios] as! NSDictionary
        let pluginsDict = iosDict[self.key_plugins] as! NSDictionary
        self.appInfo =  AppInfo(iosDict as! NSDictionary)
        self.endpoints =  Endpoints(themeDictionary[self.key_endpoints] as! NSDictionary)
        self.colors =  Colors(iosDict[self.key_colors] as! NSDictionary)
        self.copyright =  Copyright(iosDict[self.key_copyright] as! NSDictionary)
        self.urls =  Urls(iosDict[self.key_urls] as! NSDictionary)
        self.azureNotifications =  AzureNotifications(pluginsDict[self.key_notifications_azure] as! NSDictionary)
        self.features =  Features(iosDict[self.key_features] as! NSDictionary)
        self.sharedInterface = iosDict[self.key_shared_interface] as! NSDictionary
        self.neura = pluginsDict[self.key_neura] != nil ? Neura(pluginsDict[self.key_neura] as! NSDictionary) : nil
        self.mixpanel = pluginsDict[self.key_mixpanel] != nil ? MixpanelInfo(pluginsDict[self.key_mixpanel] as! NSDictionary) : nil
        self.localization_copy = iosDict[self.key_localization_copy] as! NSDictionary
        
     
	}
    
    @objc func getLocalizedCopyInCurrentLanguage(key: String) -> String
    {
        let language = MZDeviceInfoHelper.getDeviceLanguage()
        guard let languageDict : NSDictionary = self.localization_copy.object(forKey: language) as? NSDictionary else {
            guard let defaultDict : NSDictionary = self.localization_copy.object(forKey: key_language_en) as! NSDictionary else {
                return ""
            }
            if defaultDict.object(forKey: key) != nil
            {
                return defaultDict.object(forKey: key) as! String
            }
            return ""
        }
        if languageDict.object(forKey: key) != nil
        {
            return languageDict.object(forKey: key) as! String
        }
        return ""
    }
    
    @objc class Copyright : NSObject
    {
        private let key_companyName = "company_name"
        private let key_startDate = "start_date"
        
        let companyName : String
        let startDate : String
        
        init(_ dictionary: NSDictionary) {
            self.companyName = dictionary[key_companyName] as! String
            self.startDate = dictionary[key_startDate] as! String
        }
    }
    
    @objc class Colors : NSObject
    {
        private let key_primaryColor = "primary_color"
        private let key_primaryColorText = "primary_color_text"
        private let key_secondaryColor = "secondary_color"
        private let key_secondaryColorText = "secondary_color_text"
        private let key_complementaryColor = "complementary_color"
        private let key_complementaryColorText = "complementary_color_text"
        
        let primaryColor : UIColor
        let primaryColorText : UIColor
        let secondaryColor : UIColor
        let secondaryColorText : UIColor
        let complementaryColor : UIColor
        let complementaryColorText : UIColor
        
        init(_ dictionary: NSDictionary)
        {
            self.primaryColor = UIColor(hex: dictionary[key_primaryColor] as! String)
            self.primaryColorText = UIColor(hex: dictionary[key_primaryColorText] as! String)
            self.secondaryColor = UIColor(hex: dictionary[key_secondaryColor] as! String)
            self.secondaryColorText = UIColor(hex: dictionary[key_secondaryColorText] as! String)
            self.complementaryColor = UIColor(hex: dictionary[key_complementaryColor] as! String)
            self.complementaryColorText = UIColor(hex: dictionary[key_complementaryColorText] as! String)
        }
        
    }
    
    @objc class Endpoints : NSObject
    {
        private let key_endpoints = "endpoints"
        private let key_authBaseUrl = "auth_base_url"
        private let key_workerEditorUrl = "worker_editor_url"
        private let key_webBaseUrl = "web_base_url"
        
        let authBase : String
        let workerEditorUrl : String
        let webBaseUrl : String
        
        init(_ dictionary: NSDictionary)
        {
            self.authBase = dictionary[key_authBaseUrl] as! String
            self.workerEditorUrl = dictionary[key_workerEditorUrl] as! String
            self.webBaseUrl = dictionary[key_webBaseUrl] as! String
        }
    }
    
    
    @objc class AzureNotifications : NSObject
    {
        private let key_endpoint = "endpoint"
        private let key_hubname = "hubname"
        
        let endpoint : String
        let hubname : String
        
        init(_ dictionary: NSDictionary)
        {
            self.endpoint = dictionary[key_endpoint] as! String
            self.hubname = dictionary[key_hubname] as! String
        }
    }
    
    @objc class Neura : NSObject
    {
        private let key_app_uid = "app_uid"
        private let key_app_secret = "app_secret"

        let appUID : String
        let appSecret : String
        
        init?(_ dictionary: NSDictionary)
        {
            guard let app_uid = dictionary[key_app_uid] as? String else {
                return nil
            }
            guard let app_secret = dictionary[key_app_secret] as? String else {
                return nil
            }
            
            if app_uid.isEmpty || app_secret.isEmpty
            {
                return nil
            }
            
            self.appUID = app_uid
            self.appSecret = app_secret
        }
        
    }
    
    
    @objc class MixpanelInfo : NSObject
    {
        private let key_application_name = "application_name"
        private let key_project_token = "project_token"
        
        let applicationName : String?
        let projectToken : String?
        
        init?(_ dictionary: NSDictionary)
        {
            guard let application_name = dictionary[key_application_name] as? String else {
                return nil
            }
            guard let project_token = dictionary[key_project_token] as? String else {
                return nil
            }
            
            if application_name.isEmpty || project_token.isEmpty
            {
                return nil
            }
            
            self.applicationName = application_name
            self.projectToken = project_token
        }
    }

    
    
    @objc class Features : NSObject
    {
        private let key_cards = "cards"

        let cards : Bool
        
        init(_ dictionary: NSDictionary)
        {
            self.cards = dictionary[key_cards] as! Bool
        }
    }
    
    @objc class Urls : NSObject
    {
        
        private let key_faq = "faq"
        private let key_termsServices = "terms_services"
        private let key_privacyPolicy = "privacy_policy"
        private let key_website = "website"
        private let key_facebook = "facebook"
        private let key_twitter = "twitter"
        private let key_blog = "blog"
        
        var faq : URL? = nil
        var termsServices : URL? = nil
        var privacyPolicy : URL? = nil
        var website : URL? = nil
        var facebook : URL? = nil
        var twitter : URL? = nil
        var blog : URL? = nil
        
        init(_ dictionary: NSDictionary)
        {
        
            if dictionary[key_faq] != nil
            {
                self.faq =  URL(string: dictionary[key_faq] as! String)
            }
            if dictionary[key_termsServices] != nil
            {
                self.termsServices =  URL(string: dictionary[key_termsServices] as! String)
            }
            if dictionary[key_privacyPolicy] != nil
            {
                self.privacyPolicy =  URL(string: dictionary[key_privacyPolicy] as! String)
            }
            if dictionary[key_website] != nil
            {
                self.website =  URL(string: dictionary[key_website] as! String)
            }
            if dictionary[key_facebook] != nil
            {
                self.facebook =  URL(string: dictionary[key_facebook] as! String)
            }
            if dictionary[key_twitter] != nil
            {
                self.twitter =  URL(string: dictionary[key_twitter] as! String)
            }
            
            if dictionary[key_blog] != nil
            {
                self.blog =  URL(string: dictionary[key_blog] as! String)
            }
            
        }
    }
    
    
    @objc class AppInfo : NSObject
    {
        private let key_appId = "app_id"
        private let key_applicationName = "application_name"
        private let key_mixpanel = "mixpanel"
        private let key_mixpanelApplicationName = "application_name"
        private let key_mixpanelProjectToken = "project_token"
        private let key_appScheme = "app_scheme"
        private let key_namespace = "namespace"
        private let key_bundleId = "bundle_id"
        private let key_googleMapsAPIKey = "google_maps_api_key"
        
        let appId : String
        let applicationName : String
        let appScheme : String
        let namespace : String
        let bundleId : String
        let googleMapsAPIKey : String
        
        init(_ dictionary: NSDictionary)
        {
            self.appId = dictionary[key_appId] as! String
            self.applicationName = dictionary[key_applicationName] as! String
            self.appScheme = dictionary[key_appScheme] as! String
            self.namespace = dictionary[key_namespace] as! String
            self.bundleId = dictionary[key_bundleId] as! String
            self.googleMapsAPIKey = dictionary[key_googleMapsAPIKey] as! String
            
        }
    }
}
