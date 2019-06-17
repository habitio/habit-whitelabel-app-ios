//
//  MZCameraInteractor.swift
//  Muzzley-iOS
//
//  Created by Cristina Lopes on 26.12.16.
//  Copyright © 2016 Muzzley. All rights reserved.
//

import UIKit
import RxSwift


class MZCameraInteractor: MZDeviceInteractor
{
    fileprivate let MZCameraInteractorErrorDomain = "MZCameraInteractorErrorDomain"
    let disposeBag = DisposeBag()

    
    func getCameraAudioPath(_ tileVM: MZTileViewModel, completion: @escaping (_ result: String,_ error: NSError?) -> Void)
    {
        self.getPathPropertyValue(tileVM: tileVM, urlClass: Constants.Class.AudioStream, completion: completion)
    }

    func getCameraVideoPath(_ tileVM: MZTileViewModel, completion: @escaping (_ result: String,_ error: NSError?) -> Void)
    {
        self.getPathPropertyValue(tileVM: tileVM, urlClass: Constants.Class.VideoStream, completion: completion)
    }
    
    func getPathPropertyValue(tileVM: MZTileViewModel, urlClass: String, completion: @escaping (_ result: String,_ error: NSError?) -> Void)
    {

        if let componentAndProperty = MZDeviceInteractorHelper.getComponentIDAndPropertyVMByPropertyClass(tileVM, propertyClass: urlClass)
        {
            let propertyVM = componentAndProperty["propertyVM"] as? MZPropertyViewModel
            let component = componentAndProperty["component"] as? String
        
            
			MZMQTTMessageHelper.getPropertyValueViaMQTT(channelId: (tileVM.model as! MZTile).channel!.identifier, componentId: component!, propertyId: propertyVM!.model!.identifier, data: nil, completion: { (response, error) in
				
				if var resultPath = response as? String
                {
//                    dLog(message: " path=" + resultPath)
                    let regex = try! NSRegularExpression(pattern: "\\$\\{.+\\}", options: .caseInsensitive)
					
                    let matches = regex.matches(in: resultPath, options: [], range:NSMakeRange(0, resultPath.characters.count))
                    
                    if matches.count > 0
                    {
                        //TODO change to rx to only complete at the end
                        var tasks : [Observable<AnyObject>] = []
                        var properties : [String] = []
                        for match in matches
                        {
                            let range = match.range
                            let property = (resultPath as NSString).substring(with: NSMakeRange(range.location+2,range.length-3))
                            //cast to NSString is required to match range format.
							
                            tasks.append(MZDeviceInteractorHelper.getObservableOfPropertyValueViaMQTT((tileVM.model as! MZTile).channel!.identifier, componentId: component!, propertyId: propertyVM!.model!.identifier, data: nil))
							
                            properties.append(property)
                        }
						
						Observable<Any>.zip(tasks) {return $0}
							.subscribe(onNext: { (results)  in
								if((results as! NSArray).count > 0)
								{
									for (index, element) in (results as! NSArray).enumerated()
									{
										resultPath = resultPath.replacingOccurrences(of:"${\(properties[index])}", with: element as! String, options: NSString.CompareOptions.literal, range: nil)
									}
							
//									dLog(message: "video final path=" + resultPath)
							
									completion(resultPath, error)
								}
								else
								{
									completion("", error)
								}
							}, onError: { (error) in
								completion("", NSError(domain: "", code: 0, userInfo: nil))
							}, onCompleted: {
							}, onDisposed: {}
							)
							.addDisposableTo(self.disposeBag)
                    }
					else
					{
                        dLog("final path=" + resultPath)

                        completion(resultPath, error)
                    }
                }
				else
				{
                    completion("", error)
                }
            })
            
        }
        
    }
    
    
    func microphone_on(_ tileVM: MZTileViewModel)
    {
       
    }
    
    
    func microphone_off()
    {
    }
    
    
    

    
}
