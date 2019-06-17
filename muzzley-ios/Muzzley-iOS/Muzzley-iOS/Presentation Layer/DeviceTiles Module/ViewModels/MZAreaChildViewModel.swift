//
//  MZAreaChildViewModel.swift
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 18/11/2015.
//  Copyright © 2015 Muzzley. All rights reserved.
//

import RxSwift

@objc enum TileState: Int {
    case loading = 0, error, loaded
}

class MZAreaChildViewModel : NSObject
{
    dynamic var title: String = ""
    var tileActionViewModel: TileActionViewModel?
    var parentViewModel: AnyObject?
    var identifier: String = ""
    var interfaceUUID: String? = nil
    var interfaceETAG: String? = nil
    var channelID: String? = ""
    var bridgeOptions: [String : Any]? = nil
    var isSelected: Bool = false
    var indexPath:NSIndexPath?
    var nativeComponents: [MZTileNativeComponentViewModel]?
    
    var model : MZAreaChild?
    
    var refreshViewModel: TileRefreshViewModel = TileRefreshViewModel()
    var problemViewModel: TileProblemViewModel = TileProblemViewModel()
    
    var state: TileState = TileState.loading {
        didSet {
            if (state == TileState.loading) {
                self.refreshViewModel.animating = true;
            } else if (state == TileState.error) {
                self.refreshViewModel.animating = false;
            } else if (state == TileState.loaded) {
                self.refreshViewModel.animating = false;
            }
        }
    }
    
    override init () {
        super.init()
    }
    
    fileprivate var myContext = 0

    init(model : MZAreaChild)
    {
        super.init()
        self.model = model
        self.identifier = model.identifier
        self.title = model.label
        self.interfaceETAG = model.interfaceETAG
        self.interfaceUUID = model.interfaceUUID
        
        self.nativeComponents = []
        for (_, nativeComponent) in model.native.enumerated() {
            self.nativeComponents?.append(MZTileNativeComponentViewModel(withModel: nativeComponent))
        }
        
        self.rx.observe(String.self, "title", options: NSKeyValueObservingOptions.new)
			.subscribe(onNext: { (title) in
				self.model!.label = title!
			}, onError: { (error) in
				
			}, onCompleted: { 
				
			}, onDisposed: {}
		)
			//.subscribeNext { (title) -> Void in
            //    self.model!.label = title!
    }
}
