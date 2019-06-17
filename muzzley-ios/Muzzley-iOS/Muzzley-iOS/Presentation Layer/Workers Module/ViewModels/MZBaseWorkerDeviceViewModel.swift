//
//  MZBaseWorkerDeviceViewModel.swift
//  Muzzley-iOS
//
//  Created by Cristina Lopes on 22/12/15.
//  Copyright © 2015 Muzzley. All rights reserved.
//

class MZBaseWorkerDeviceViewModel: NSObject {
    
    dynamic var imageUrl: URL?
    dynamic var imageUrlAlt: URL?
    dynamic var title: String?
    dynamic var componentIds: [String]?
    internal var type = ""

    var items: [MZBaseWorkerItemViewModel] = []
    
    var model: MZBaseWorkerDevice?
    
    convenience init(model: MZBaseWorkerDevice) {
        self.init()
        self.model = model
		self.imageUrl = model.photoUrl
        self.imageUrlAlt = model.photoUrlAlt
        self.title = model.label
        self.type = model.type
        self.componentIds = model.componentIds
		
		
        for item in model.items as [MZBaseWorkerItem]
        {
            let itemVM: MZBaseWorkerItemViewModel = MZBaseWorkerItemViewModel(model: item)
            itemVM.stateDescription = NSAttributedString(string: item.label)
            items.append(itemVM)
        }
        
        self.rx.observe(URL.self, "imageUrl", options: NSKeyValueObservingOptions.new)
            .subscribe(onNext: { (imageUrl) in
               self.model!.photoUrl = imageUrl!
            }, onError: { (error) in
                //
            }, onCompleted: { 
                //
            }, onDisposed: {}
        )
        
        self.rx.observe(URL.self, "imageUrlAlt", options: NSKeyValueObservingOptions.new)
            .subscribe(onNext: { (imageUrlAlt) in
                self.model!.photoUrlAlt = imageUrlAlt!
            }, onError: { (error) in
                //
            }, onCompleted: { 
                //
            }, onDisposed: {}
        )

        self.rx.observe(String.self, "title", options: NSKeyValueObservingOptions.new)
            .subscribe(onNext: { (title) in
                self.model!.label = title!
            }, onError: { (error) in
                //
            }, onCompleted: { 
                //
            }, onDisposed: {}
        )

        
        self.rx.observe(MZTile.self, "model.tile", options: NSKeyValueObservingOptions.new)
            .subscribe(onNext: { (tile) in
                self.imageUrl = tile!.photoUrl!
                self.imageUrlAlt = tile!.photoUrlAlt!
                self.title = tile!.label
            }, onError: { (error) in
                //
            }, onCompleted: { 
                //
            }, onDisposed: {}
        )
    }
}
