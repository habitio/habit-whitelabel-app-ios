//
//  MZBaseWorkerItemViewModel.swift
//  Muzzley-iOS
//
//  Created by Cristina Lopes on 22/12/15.
//  Copyright © 2015 Muzzley. All rights reserved.
//

import RxSwift
//import RxCocoa

class MZBaseWorkerItemViewModel: NSObject {
    dynamic var stateDescription: NSAttributedString = NSAttributedString(string: "")
    
    var model:MZBaseWorkerItem?
    
    convenience init(model: MZBaseWorkerItem)
    {
        self.init()
        self.model = model
        self.rx.observe(NSAttributedString.self, "stateDescription", options: NSKeyValueObservingOptions.new)
            .subscribe(onNext: { (stateDescription) in
				self.model!.label = stateDescription!.string
			}, onError: { (error) in
				
			}, onCompleted: {
			}, onDisposed: {}
		)
			
			
			//.subscribeNext { (stateDescription) -> Void in
              //  self.model!.label = stateDescription!.string
		
    }
    
    
}



