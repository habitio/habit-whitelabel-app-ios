//
//  MZBaseWorkerDevice.swift
//  Muzzley-iOS
//
//  Created by Cristina Lopes on 22/12/15.
//  Copyright © 2015 Muzzley. All rights reserved.
//

class MZBaseWorkerDevice: NSObject
{
    static let key_photoUrl     = "photoUrl"
    static let key_photoUrlAlt  = "photoUrlAlt"
    static let key_label        = "label"
    static let key_channel      = "channel"
    static let key_component    = "component"


    var photoUrl: URL?  = URL(string: "")
    var photoUrlAlt: URL?   = URL(string: "")
    var label: String = ""
    var channelId: String = ""
    var componentIds: [String] = []
    var type: String = ""

    dynamic var tile: MZTile?
	
    var items:[MZBaseWorkerItem] = []
    
    var dictionaryRepresentation: NSDictionary = NSDictionary()
    
    override init()
    {
        super.init()
        self.rx.observe(MZTile.self, "tile", options: NSKeyValueObservingOptions.new)
		.subscribe(onNext: { (tile) in
			self.photoUrl = tile!.photoUrl!
			self.photoUrlAlt = tile!.photoUrlAlt!
			self.label = tile!.label
			self.channelId = tile!.channelId
			for component in tile!.components
			{
				self.componentIds.append(component.identifier)
			}

		}, onError: { (error) in
			
		}, onCompleted: { 
			
		}, onDisposed: {})
//            .subscribeNext { (tile) -> Void in
//                self.photoUrl = tile!.photoUrl!
//                self.photoUrlAlt = tile!.photoUrlAlt!
//                self.label = tile!.label
//                self.channelId = tile!.channelId
//                
//                for component in tile!.components
//                {
//                    self.componentIds.append(component.identifier)
//                }
//        }
    }
    
    
    convenience init(dictionary: NSDictionary)
    {
        self.init()
		if (dictionary.isKind(of: NSDictionary.self))
        {
            self.dictionaryRepresentation = dictionary
			
            if let photoUrlStr : String = dictionary[MZBaseWorkerDevice.key_photoUrl] as? String {
				if(!photoUrlStr.isEmpty)
				{
					let photoUrl : URL = URL(string: photoUrlStr)!
					self.photoUrl = photoUrl
				}
            }
            if let photoUrlAltStr : String = dictionary[MZBaseWorkerDevice.key_photoUrlAlt] as? String {
				if(!photoUrlAltStr.isEmpty)
				{
					let photoUrl : URL = URL(string: photoUrlAltStr)!
					self.photoUrlAlt = photoUrl
				}
            }
            if let channelId : String = dictionary[MZBaseWorkerDevice.key_channel] as? String {
                self.channelId = channelId
            }
            if let componentId : String = dictionary[MZBaseWorkerDevice.key_component] as? String {
                self.componentIds.append(componentId)
            }
        }
    }
}
