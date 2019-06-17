//
//  TileAttrViewModel.swift
//  Muzzley-iOS
//
//  Created by Cristina Lopes on 28/12/15.
//  Copyright © 2015 Muzzley. All rights reserved.
//

import RxSwift

class TileAttrViewModel: NSObject
{
    dynamic var value: String = "--"
    dynamic var valueRaw: Any?
	var valueInDefaultUnit : Double? = nil
	var suffix : String = ""
	
    var model : MZBaseTileAttr?

    override init ()
    {
        valueRaw = "--" as Any
    }
    
    init(model : MZBaseTileAttr)
    {
        super.init()

        self.model = model
	
        self.rx.observe(Any.self, "valueRaw", options: NSKeyValueObservingOptions.new)
			.subscribe(onNext: { (valueRaw) in
                
//                print(valueRaw)
//                if valueRaw is Bool
//                {
//                    if let bool : Bool = valueRaw as? Bool
//                    {
//                        if bool
//                        {
//                            self.value = "true"
//                        }
//                        else
//                        {
//                            self.value = "false"
//                        }
//                    }
//                }
                
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
			}, onCompleted: {},
			   onDisposed: {}
		)
    }
}
