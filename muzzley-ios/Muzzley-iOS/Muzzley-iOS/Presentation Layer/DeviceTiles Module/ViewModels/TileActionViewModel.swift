//
//  TriStateToggleViewModel.swift
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 19/11/2015.
//  Copyright © 2015 Muzzley. All rights reserved.
//

import Foundation
import RxSwift

@objc enum TileActionViewModelState: Int {
    case unknown = 0, on, off, offOn, onOff
}

@objc enum TileActionViewModelIcon: Int {
    case onOff = 0, home, lock
}

class TileActionViewModel : TileAttrViewModel {
    var state: TileActionViewModelState = TileActionViewModelState.unknown
    var onStateIconName: String!
    var offStateIconName: String!
    
    var icon : TileActionViewModelIcon = TileActionViewModelIcon.onOff {
        didSet {
            switch self.icon {
            case .onOff:
                onStateIconName = "IconToggleOnOff"
                offStateIconName = "IconToggleOnOff"
                break
            case .home:
                onStateIconName = "IconToggleClosed"
                offStateIconName = "IconToggleOpened"
                break
            case .lock:
                onStateIconName = "IconToggleUnlocked"
                offStateIconName = "IconToggleLocked"
                break
            }
        }
    }
    
    
    override init(model: MZBaseTileAttr)
    {
        super.init(model: model)

        let actionModel: MZTileAction = model as! MZTileAction
        switch actionModel.icon
        {
        case MZTileAction.Option_icon.on_off.rawValue :
            self.icon = TileActionViewModelIcon.onOff
            break
        case MZTileAction.Option_icon.lock.rawValue :
            self.icon = TileActionViewModelIcon.lock
            break
        case MZTileAction.Option_icon.home.rawValue :
            self.icon = TileActionViewModelIcon.home
            break
        default : break
        }
        
        self.rx.observe(Bool.self, "valueRaw", options: NSKeyValueObservingOptions.new)
			.subscribe(onNext: { (valueRaw) in
				if valueRaw != nil
				{
					if let boolValue : Bool = valueRaw! as? Bool
					{
						if boolValue
						{
							self.state = TileActionViewModelState.on
						}
						else
						{
							self.state = TileActionViewModelState.off
						}
					}
				}
			},
			onError: { (error) in
				//
			}, onCompleted: {
				//
			}, onDisposed: {}
		)
//            .subscribeNext { (valueRaw) -> Void in
//             //   print("value \(valueRaw)")
//				if valueRaw != nil
//				{
//					if let boolValue : Bool = valueRaw! as? Bool
//					{
//						if boolValue {
//							self.state = TileActionViewModelState.On
//						} else {
//							self.state = TileActionViewModelState.Off
//						}
//					}
//				}
//        }
    }
}
