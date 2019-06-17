//
//  MZPropertyViewModel.swift
//  Muzzley-iOS
//
//  Created by Cristina Lopes on 24.01.17.
//  Copyright © 2017 Muzzley. All rights reserved.
//

import UIKit


//TODO should this be merged with TileAttrViewModel?
class MZPropertyViewModel: NSObject
{
    dynamic var value: String = ""
    dynamic var valueRaw: Any?
    var valueInDefaultUnit : Double? = nil
    
    var model : MZProperty?
    
    override init ()
    {
        valueRaw = "--" as Any
    }
    
    init(model : MZProperty)
    {
        super.init()
        
        self.model = model
        
        self.rx.observe(Any.self, "valueRaw", options: NSKeyValueObservingOptions.new)
			.subscribe(onNext: { (valueRaw) in
            
				if let string: String = valueRaw as? String
				{
					self.value = string
				}
				else if let double: Double = valueRaw as? Double
				{
					// Not using locale format for now. To be used when language is implemented only because of language like arabic/chinese/etc which translate numbers
					if double.truncatingRemainder(dividingBy: 1) == 0
					{
						self.value =  String(format: "%.0f", double)
						//self.value =  NumberFormatHelper.formatNumberAccordingToLocale(Double(String(format: "%.0f", double))!)
					}
					else
					{
						self.value = String(double)
						//self.value = NumberFormatHelper.formatNumberAccordingToLocale(Double(String(double))!)
					}
				
				}
				else if let int: Int = valueRaw as? Int
				{
				self.value = String(int)
				}

			}, onError: { (error) in
			}, onCompleted: {
			},
			   onDisposed: {
			}
		)
    }

}
