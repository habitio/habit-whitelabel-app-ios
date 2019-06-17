//
//  MZDeviceInteractorHelper.swift
//  Muzzley-iOS
//
//  Created by Cristina Lopes on 24.01.17.
//  Copyright © 2017 Muzzley. All rights reserved.
//

import UIKit
import RxSwift

class MZDeviceInteractorHelper: NSObject
{
    
    static func setPropertyViewModelValue(_ propertyViewModels:[MZPropertyViewModel], property: String, value:Any?) -> Bool
    {
        let filteredPropertyVM = propertyViewModels.filter() {
            return $0.model!.identifier == property
        }
        
        if !filteredPropertyVM.isEmpty
        {
            let propertyVM: MZPropertyViewModel = filteredPropertyVM[0]
                        
            propertyVM.valueRaw = value
            return true
        }
        
        return false
    }

    
    
    static func setAttrViewModelValue(_ attrViewModels:[TileAttrViewModel], component: String, property: String, value:Any?) -> Bool
    {
        let filteredAttrVM = attrViewModels.filter() {
            return $0.model!.componentId == component && $0.model!.propertyId == property
        }
        
        if !filteredAttrVM.isEmpty
        {
            let attrVM: TileAttrViewModel = filteredAttrVM[0]
            
            
            var processedValue = value
            
            if let attrM: MZTileInformation = attrVM.model! as? MZTileInformation
            {
                
                if value != nil
                {
                    
                    switch attrM.type
                    {
                        
                    case MZTileInformation.type_text:
                        if value is String
                        {
                            processedValue = value as! String
                        }
                        else if value is Bool
                        {
                            processedValue = (value as! Bool) == true ? "true" : "false"
                        }
                        break
                    case MZTileInformation.type_unit:
                        
                        if(!attrM.muzzleyUnit.isEmpty)
                        {
                            attrVM.valueInDefaultUnit = value as? Double
                            if !attrM.targetMetric.isEmpty && !attrM.targetImperial.isEmpty
                            {
                                if(attrM.targetMetric == attrM.targetImperial && attrM.targetMetric == attrM.muzzleyUnit) // No conversion is required
                                {
                                    processedValue = MZSessionDataManager.sharedInstance.session.unitsSpec.applyUnitDecimalPlaces(attrM.muzzleyUnit, value: attrVM.valueInDefaultUnit! as! Double) as AnyObject
                                    attrVM.suffix = MZSessionDataManager.sharedInstance.session.unitsSpec.getUnitSuffix(attrM.muzzleyUnit)
                                    
                                }
                                else
                                {
                                    if let doubleValue = value as? Double
                                    {
                                        var convertedValue = doubleValue

                                        switch  MZSessionDataManager.sharedInstance.session.userProfile.preferences.units
                                        {
                                        case "metric":
                                            if(attrM.muzzleyUnit != attrM.targetMetric)
                                            {
                                                convertedValue = MZSessionDataManager.sharedInstance.session.unitsSpec.convertUnits(attrM.muzzleyUnit, targetUnitKey: attrM.targetMetric, value: convertedValue)
                                            }
                                            
                                            processedValue = MZSessionDataManager.sharedInstance.session.unitsSpec.applyUnitDecimalPlaces(attrM.targetMetric, value: convertedValue as! Double) as AnyObject
                                            attrVM.suffix = MZSessionDataManager.sharedInstance.session.unitsSpec.getUnitSuffix(attrM.targetMetric)
                                            break
                                        case "imperial":
                                            if(attrM.muzzleyUnit != attrM.targetImperial)
                                            {
                                                convertedValue = MZSessionDataManager.sharedInstance.session.unitsSpec.convertUnits(attrM.muzzleyUnit, targetUnitKey: attrM.targetImperial, value: convertedValue)
                                            }
                                            processedValue = MZSessionDataManager.sharedInstance.session.unitsSpec.applyUnitDecimalPlaces(attrM.targetImperial, value: convertedValue as! Double) as AnyObject
                                            attrVM.suffix = MZSessionDataManager.sharedInstance.session.unitsSpec.getUnitSuffix(attrM.targetImperial)
                                            break
                                            
                                        default:
                                            break
                                        }
                                    }
                                }
                            }
                            else
                            {
                                let val = MZSessionDataManager.sharedInstance.session.unitsSpec.applyUnitDecimalPlaces(attrM.muzzleyUnit, value: attrVM.valueInDefaultUnit!)
                                if(val != value as? Double)
                                {
                                    processedValue = val as! Any
                                    attrVM.suffix = MZSessionDataManager.sharedInstance.session.unitsSpec.getUnitSuffix(attrM.muzzleyUnit)
                                }
                            }
                        }
                        else
                        {
                            var val = value as? Double
                            val = Double(String(format: "%.1f", val!))
                            if val!.truncatingRemainder(dividingBy: 1) == 0
                            {
                                processedValue = Double(String(format: "%.0f", val!))! as AnyObject
                            }
                            else
                            {
                                processedValue = Double(String(val!))! as AnyObject
                            }
                            attrVM.suffix = attrM.unit
                        }
                        
                        break
                        
                        
                        
                    case MZTileInformation.type_expression:
                        
                        if let valueNmb = value as? Double
                        {
                            
                            var val = MathExpressionsHelper.calculate(attrM.mathExpression, value: valueNmb)
                            
                            val = Double(String(format: "%.1f", val))!
                            if val.truncatingRemainder(dividingBy: 1) == 0
                            {
                                processedValue = Double(String(format: "%.0f", val))! as AnyObject
                            }
                            else
                            {
                                processedValue = Double(String(val))! as AnyObject
                            }
                        }
                        
                        attrVM.suffix = attrM.unit
                        break
                        
                        
                    case MZTileInformation.type_icon:
                        if let _ = value as? NSDictionary
                        {
                            var color: UIColor?
                            if attrM.format == MZTileInformation.color_hsv
                            {
                                var x = 0.0
                                if let h = (value as AnyObject).object(forKey: "h") as? Double
                                {
                                    x = h/360.0
                                }
                                
                                var y = 0.0
                                if let s = (value as AnyObject).object(forKey:"s") as? Double
                                {
                                    y = s/100.0
                                }
                                
                                
                                if y <= 0.05 / 100.0 {
                                    color = UIColor(hex: "#FEFBD0")
                                } else {
                                    color = UIColor(hue: CGFloat(x), saturation: CGFloat(y), brightness: 1.0, alpha: 1.0)
                                }
                            } else if attrM.format == MZTileInformation.color_rgb
                            {
                                var x = 255.0
                                if let r = (value as AnyObject).object(forKey:"r") as? Double
                                {
                                    x = r/255.0
                                }
                                
                                var y = 255.0
                                if let g = (value as AnyObject).object(forKey:"g") as? Double
                                {
                                    y = g/255.0
                                }
                                
                                var z = 255.0
                                if let b = (value as AnyObject).object(forKey: "b") as? Double
                                {
                                    z = b/255.0
                                }
                                
                                if x > 240.0 / 255.0 && y > 240.0 / 255.0 && z > 240.0 / 255.0 {
                                    color = UIColor(hex: "#FEFBD0")
                                } else {
                                    color = UIColor(red: CGFloat(x), green: CGFloat(y), blue: CGFloat(z), alpha: 1.0)
                                }
                            }
                            processedValue = color
                        }
                        break
                    default: break
                    }
                }
            } else if let attrM: MZTileAction = attrVM.model! as? MZTileAction
            {
                if value != nil
                {
                    switch attrM.type
                    {
                    case MZTileAction.type_triState:
                        var key = ""
                        for i in 0..<attrM.mappings!.values.count
                        {
                            if Array(attrM.mappings!.values)[i] === value as! AnyObject {
                                key = Array(attrM.mappings!.keys)[i]
                                break
                            }
                        }
                        processedValue = (key == "on") as AnyObject
                        break
                    default: break
                    }
                }
            }
            
            //print("setAttrViewModelValue value:\(value!) processedValue:\(processedValue!)")
            
            attrVM.valueRaw = processedValue
            return true
        }
        
        return false
    }
    
    static func getComponentIDAndPropertyVMByPropertyClass(_ tileVM: MZTileViewModel, propertyClass: String) -> [String:AnyObject]?
    {
        let filteredPropertiesVM = tileVM.tileProperties.filter() { $0.model!.classes.contains(propertyClass)}

        if let propertyVM = filteredPropertiesVM.first
        {
            let propertyId = propertyVM.model?.identifier
            let filteredComponents = (tileVM.model as! MZTile).components.filter() {
                let filteredProperties = $0.properties.filter() { $0.identifier == propertyId }
                return !filteredProperties.isEmpty
            }
            
            if let component = filteredComponents.first
            {
                return ["component" : component.identifier as AnyObject, "propertyVM" : propertyVM]
            }
        }
        return nil
    }
    
    
   /* static func getObservableOfPropertyClassValue(tileVM: MZTileViewModel, propertyClass: String, coreClient: MZBaseClient) -> Observable<(AnyObject)>
    {
        
        return Observable.create({ (observer) -> Disposable in
            
            if let componentAndProperty = getComponentIDAndPropertyVMByPropertyClass(tileVM, propertyClass: propertyClass)
            {
                let propertyVM = componentAndProperty["propertyVM"] as? MZPropertyViewModel
                let component = componentAndProperty["component"] as? String
               /* let filteredPropertiesVM = tileVM.tileProperties.filter() { $0.model!.classes.contains(propertyClass)}
                
                //TODO get dinamically componentId
                
                if let propertyVM = filteredPropertiesVM.first
                {*/
                    if propertyVM!.value.isEmpty
                    {
                        let payload: [String:AnyObject] = ["io":"r",
                            "channel":(tileVM.model as! MZTile).channel!.remoteId,
                            "profile":(tileVM.model as! MZTile).profileId,
                            "property": propertyVM!.model!.identifier,
                            "component": component!]
                        
                        coreClient.publishWithNamespace(MZMessageNamespaceIOT, payload:payload, completion:{(response, error) -> Void in
                            
                            if let value = MZCoreClientHelper.getDictionaryValue(response)
                            {
                                MZDeviceInteractorHelper.setPropertyViewModelValue(tileVM.tileProperties, property: propertyVM!.model!.identifier, value: value)
                                
                                observer.onNext(propertyVM!)
                                observer.onCompleted()
                            } else {
                                observer.onError(NSError( domain: "", code: 0, userInfo: nil))
                            }
                        })
                    } else {
                        observer.onNext(propertyVM!)
                        observer.onCompleted()
                    }
                /*}*/
            }
            
            return Disposables.create {}
        })
    }*/
    
   /* static func getObservableOfPropertyIdValue(tileVM: MZTileViewModel, propertyId: String, componentId: String, coreClient: MZBaseClient) -> Observable<(AnyObject)>
    {
        return Observable.create({ (observer) -> Disposable in
            
            let payload: [String:AnyObject] = ["io":"r",
                "channel":(tileVM.model as! MZTile).channel!.remoteId,
                "profile":(tileVM.model as! MZTile).profileId,
                "property": propertyId,
                "component": componentId]
            
            coreClient.publishWithNamespace(MZMessageNamespaceIOT, payload:payload, completion:{(response, error) -> Void in
                
                dLog("response \(response)")
                if let value = MZCoreClientHelper.getStringValue(response)
                {
                    MZDeviceInteractorHelper.setPropertyViewModelValue(tileVM.tileProperties, property: propertyId, value: value)
                    
                    observer.onNext(value)
                    observer.onCompleted()
                } else {
                    observer.onError(NSError( domain: "", code: 0, userInfo: nil))
                }
            })
*/
	
	
	static func getObservableOfPropertyValueViaMQTT(_ channelId: String, componentId: String, propertyId: String, data: NSDictionary?) -> Observable<(AnyObject)>
	    {	
	        return Observable.create({ (observer) -> Disposable in
	
				MZMQTTMessageHelper.getPropertyValueViaMQTT(channelId: channelId, componentId: componentId, propertyId: propertyId, data: data, completion: { (response, error) in
					if(error != nil)
					{
//						dLog(message: "response \(response)")
						if response != nil //let value = MZCoreClientHelper.getStringValue(response)
						{
							observer.onNext(response!)
							observer.onCompleted()
						}
						else
						{
							observer.onError(NSError( domain: "", code: 0, userInfo: nil))
						}
					}
				})
				
				return Disposables.create {}
	        })
	    }

}
