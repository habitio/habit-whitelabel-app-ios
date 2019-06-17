//
//  TileIconViewModel.swift
//  Muzzley-iOS
//
//  Created by Hugo Sousa on 26/11/2015.
//  Copyright © 2015 Muzzley. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

class TileIconViewModel: TileAttrViewModel {
    var color: UIColor? = nil
    var char: String = ""
    
    override init(model: MZBaseTileAttr)
    {
        super.init(model: model)
        let infoModel = model as! MZTileInformation
        
        self.char = infoModel.char
        
        self.rx.observe(Any.self, "valueRaw", options: NSKeyValueObservingOptions.new)
			.subscribe(onNext: { (valueRaw) in
				if let color = valueRaw as? UIColor
				{
					self.color = color
				}
			}, onError: { (error) in
			}, onCompleted: {
			}, onDisposed: {}
		)
//            .subscribeNext { (valueRaw) -> Void in
//            //    print("value \(valueRaw)")
//                if let color = valueRaw as? UIColor {
//                    self.color = color
//                }	
    }
}
