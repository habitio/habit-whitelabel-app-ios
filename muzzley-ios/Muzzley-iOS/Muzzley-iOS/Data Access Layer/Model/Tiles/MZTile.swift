//
//  MZTile.swift
//  Muzzley-iOS
//
//  Created by Cristina Lopes on 23/11/15.
//  Copyright Â© 2015 Muzzley. All rights reserved.
//

import RxSwift

class MZTile: MZAreaChild
{
    static let key_profileId    = "profile"
    static let key_channelId    = "channel"
    static let key_overlayUrl     = "overlayUrl"
    static let key_photoUrl     = "photoUrl"
    static let key_photoUrlAlt  = "photoUrlAlt"
    static let key_isGroupable  = "isGroupable"
    static let key_useInterface = "useInterface"
    static let key_informations = "information"
    static let key_actions      = "actions"
    static let key_groupIds     = "groups"
    static let key_components   = "components"
    
    var profileId: String                   = ""
    var channelId : String                  = ""
    var remoteId : String                   = ""
    var overlayUrl : String                 = ""
    var photoUrl : URL?
    var photoUrlAlt : URL?
    var isGroupable : Bool                  = false
    var useInterface : Bool                 = false
    var groupIds : [String]                 = [String]()
    var componentClasses : [String]         = [String] ()
    var components : [MZComponent]          = [MZComponent]()
    var informations : [MZTileInformation]  = [MZTileInformation]()
    var actions : [MZTileAction]            = [MZTileAction]()
    
    dynamic var channel : MZChannel?
    
    override init(dictionary: NSDictionary)
    {
        super.init(dictionary: dictionary)
        
        self.rx.observe(MZChannel.self, "channel", options: NSKeyValueObservingOptions.new)
			.subscribe(onNext: { (channel) in
				self.remoteId = channel!.remoteId
			}, onError: { (error) in
			}, onCompleted: {
			}, onDisposed: {}
		)
		
//            .subscribeNext { (channel) -> Void in
//                self.remoteId = channel!.remoteId
//        }
		
		if (dictionary.isKind(of: NSDictionary.self))
        {
            self.dictionaryRepresentation = dictionary
            
            if let identifier : String = dictionary[MZTile.key_id] as? String {
                self.identifier = identifier
            }
            if let label : String = dictionary[MZTile.key_label] as? String {
                self.label = label
            }
            if let profileId : String = dictionary[MZTile.key_profileId] as? String {
                self.profileId = profileId
            }
            if let channelId : String = dictionary[MZTile.key_channelId] as? String {
                self.channelId = channelId
            }
            
            if let overlayUrl : String = dictionary[MZTile.key_overlayUrl] as? String {
                self.overlayUrl = overlayUrl
            }
            
            if let photoUrlStr : String = dictionary[MZTile.key_photoUrl] as? String {
                let photoUrl : URL = URL(string: photoUrlStr)!
                self.photoUrl = photoUrl
            }
            if let photoUrlAltStr : String = dictionary[MZTile.key_photoUrlAlt] as? String {
                let photoUrlAlt : URL = URL(string: photoUrlAltStr)!
                self.photoUrlAlt = photoUrlAlt
            }
            if let isGroupable: Bool = dictionary[MZTile.key_isGroupable] as? Bool {
                self.isGroupable = isGroupable
            }
            if let useInterface: Bool = dictionary[MZTile.key_useInterface] as? Bool {
                self.useInterface = useInterface
            }
            if let groupIds: [String] = dictionary[MZTile.key_groupIds] as? [String] {
                self.groupIds = groupIds
            }
            if let informations: NSArray = dictionary[MZTile.key_informations] as? NSArray {
                for element in informations as NSArray {
                    if let informationDict = element as? NSDictionary {
                        if let information : MZTileInformation = MZTileInformation (dictionary: informationDict) {
                            self.informations.append(information)
                        }
                    }
                }
            }
            if let actions: NSArray = dictionary[MZTile.key_actions] as? NSArray {
                for element in actions as NSArray {
                    if let actionDict = element as? NSDictionary {
                        if let action : MZTileAction = MZTileAction (dictionary: actionDict) {
                            self.actions.append(action)
                        }
                    }
                }
            }
            if let components: NSArray = dictionary[MZTile.key_components] as? NSArray {
                for element in components as NSArray {
                    if let dict = element as? NSDictionary {
                        if let component : MZComponent = MZComponent (dictionary: dict) {
                            self.components.append(component)
                        }
                    }
                }
            }
            
            var actionValidated: [MZTileAction] = []
            for action in self.actions
            {
                let filteredComponents = self.components.filter {$0.type == action.componentType}
                //TODO can we garanty that it returns only one?
                if !filteredComponents.isEmpty
                {
                    let firstResult = filteredComponents[0]
                    action.componentId = firstResult.identifier
                    actionValidated.append(action)
                }
            }
            self.actions = actionValidated
            
            
            var informationValidated: [MZTileInformation] = []
            for information in self.informations
            {
                let filteredComponents = self.components.filter {$0.type == information.componentType}
                //TODO can we garanty that it returns only one?
                if !filteredComponents.isEmpty
                {
                    let firstResult = filteredComponents[0]
                    information.componentId = firstResult.identifier
                    informationValidated.append(information)
                }
            }
            self.informations = informationValidated
        }
    }
    
    
    func updateWithChannel(_ channels: [String:MZChannel]) -> Bool
    {
        if let channel: MZChannel = channels[self.channelId] as MZChannel?
        {
            
            self.channel = channel
            
            var tempComponents = [MZComponent]()
            self.componentClasses = [String]()
            for component: MZComponent in self.components
            {
                let filteredChannelComponents = channel.components.filter() {$0.identifier == component.identifier}
                if let channelComponent = filteredChannelComponents.first
                {
                    self.componentClasses += channelComponent.classes
                    tempComponents.append(channelComponent)
                }
            }
            
            self.components = tempComponents
                
            if let interface: MZControlInterface = channel.interface as MZControlInterface?
            {
                self.interfaceUUID = interface.uuid
                self.interfaceETAG = interface.eTag
                self.native = interface.native
            }
            
            for information in self.informations
            {
                let filteredProperties = channel.properties.filter() {$0.identifier == information.propertyId}
                if !filteredProperties.isEmpty && information.label.isEmpty
                {
                    information.label = filteredProperties[0].label
					
					if(information.type == "text-unit")
					{
						information.updateWithChannelPropertyInfo(filteredProperties[0].unitsOptions)
					}
				}
            }
            
            for channelProperty in channel.properties
            {
                for channelComponent in channelProperty.components
                {
					
                    let filteredComponents = self.components.filter() {$0.type == channelComponent}
                    if let tileComponent = filteredComponents.first
                    {
                        tileComponent.propertiesClasses += channelProperty.classes
                        tileComponent.properties.append(channelProperty)
                    }
                }
            }
            
            return true
        } else {
            return false
        }
    }
}
