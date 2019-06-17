//
//  MZCardsInteractor.swift
//  Muzzley-iOS
//
//  Created by Cristina Lopes on 27/11/15.
//  Copyright Â© 2015 Muzzley. All rights reserved.
//

class MZCardsInteractor: MZDeviceListInteractor
{    
    func getCards(_ completion: @escaping (_ result: AnyObject?, _ error : NSError?) -> Void)
    {
		var paramsDict = NSMutableDictionary()
		
		var ninClasses = "?class=nin/["
		
		var urlParams = [String]()
		if(MZDeviceInfoHelper.areLocationServicesEnabled())
		{
			urlParams.append("no-location-permission")
		}
		
		if(MZDeviceInfoHelper.areNotificationsEnabled() && MZLocalStorageHelper.loadPushNotificationsStatusFromNSUserDefaults())
		{
			urlParams.append("no-notifications-permission")
		}
		
		var isFirst = true
		if(urlParams.count > 0)
		{
			for index in 0 ... urlParams.count-1
			{
				ninClasses +=  "\"" + urlParams[index] + "\""
				if(index < urlParams.count-1 )
				{
					ninClasses += ","
				}
			}
		}
		
		ninClasses += "]/j"
		

		if(urlParams.count > 0)
		{
			paramsDict.addEntries(from: [MZCardsWebService.key_request_url_params: ninClasses])
		}
		
        let observable = MZCardsDataManager.sharedInstance.getObservableOfCardsForCurrentUser(paramsDict)
        
        observable.subscribe(
            onNext: { (results) -> Void in
                var cardsViewModels = [MZCardViewModel] ()
                
                for card : MZCard in results as! [MZCard]
                {
                    let cardVM : MZCardViewModel = MZCardViewModel(model: card)
                    
                    for stage : MZStage in card.stages
                    {
                        let stageVM : MZStageViewModel = MZStageViewModel(model: stage)
                        stageVM.text = MZTextViewModel ()
                        stageVM.text.content = stage.content
                        
                        for action : MZStageAction in stage.actions
                        {
                            let actionVM : MZActionViewModel = MZActionViewModel (model: action)
                            if action.args != nil {
                                //FIX ME do this on MZArgsViewModel
                                actionVM.args = MZArgsViewModel()
                                if let nStage: Int = action.args!.dictionaryRepresentation[MZArgs.key_nStage] as? Int {
                                    actionVM.args.nStage = nStage
                                }
                                if let url: String = action.args!.dictionaryRepresentation[MZArgs.key_url] as? String {
                                    actionVM.args.url = url
                                }
                                if let hashBang: String = action.args!.dictionaryRepresentation[MZArgs.key_hashBang] as? String {
                                    actionVM.args.hashBang = hashBang
                                }
                                if let workerSpec: String = action.args!.dictionaryRepresentation[MZArgs.key_workerSpec] as? String {
                                    actionVM.args.workerSpec = workerSpec
                                }
                                if let infoText: String = action.args!.dictionaryRepresentation[MZArgs.key_infoText] as? String {
                                    actionVM.args.infoText = infoText
                                }
//								if let topic: String = action.args!.dictionaryRepresentation[MZArgs.key_topic] as? String {
//									actionVM.args.topic = topic
//								}
//								if let payload: NSDictionary = action.args!.dictionaryRepresentation[MZArgs.key_payload] as? NSDictionary {
//									actionVM.args.payload = payload
//								}
                            }
                            stageVM.actions.append(actionVM)
                        }
                        
                        for field : MZStageField in stage.fields
                        {
                            let fieldVM : MZFieldViewModel = MZFieldViewModel (model: field)
                            //FIX ME do this on MZStageField and MZFieldViewModel
                            if let placeholders : NSArray = field.dictionaryRepresentation[MZStageField.key_placeholder] as? NSArray
                            {
								for case let placeholderDic as NSDictionary in placeholders
                                {
                                    switch fieldVM.type
                                    {
                                    case MZStageField.type.location.rawValue :
                                        let placeholder : MZLocationPlaceholderViewModel = MZLocationPlaceholderViewModel()
                                        //FIX ME do this on MZLocationPlaceholderViewModel
                                        if let latitude: Double = placeholderDic[MZStageField.key_latitude] as? Double {
                                            placeholder.latitude = latitude
                                        }
                                        if let longitude: Double = placeholderDic[MZStageField.key_longitude] as? Double {
                                            placeholder.longitude = longitude
                                        }
                                        fieldVM.placeholders.append(placeholder)
                                        break
                                    case MZStageField.type.time.rawValue :
                                        let placeholder : MZTimePlaceholderViewModel = MZTimePlaceholderViewModel()
                                        //FIX ME do this on MZTimePlaceholderViewModel
                                        if let time: String = placeholderDic[MZStageField.key_time] as? String {
                                            placeholder.setupTime(time)
                                        }
                                        if let weekDays: [Bool] = placeholderDic[MZStageField.key_weekDays] as? [Bool] {
                                            placeholder.weekDays = weekDays
                                        }
                                        fieldVM.placeholders.append(placeholder)
                                        break
                                    case MZStageField.type.text.rawValue :
                                        let placeholder : MZTextPlaceholderViewModel = MZTextPlaceholderViewModel()
                                        //FIX ME do this on MZTextPlaceholderViewModel
                                        if let text: String = placeholderDic[MZStageField.key_text] as? String {
                                            placeholder.string = text
                                        }
                                        fieldVM.placeholders.append(placeholder)
                                        break
                                    case MZStageField.type.devicechoice.rawValue :
                                        let placeholder : MZDeviceChoicePlaceholderViewModel = MZDeviceChoicePlaceholderViewModel()
                                        //FIX ME do this on MZDeviceChoicePlaceholderViewModel
                                        if let component: String = placeholderDic[MZStageField.key_component] as? String {
                                            placeholder.componentId = component
                                        }
                                        if let profile: String = placeholderDic[MZStageField.key_profileId] as? String {
                                            placeholder.profileId = profile
                                        }
                                        if let remote: String = placeholderDic[MZStageField.key_remoteId] as? String {
                                            placeholder.remoteId = remote
                                        }
                                        if let tileLabel: String = placeholderDic[MZStageField.key_tile] as? String {
                                            placeholder.deviceTitle = tileLabel
                                        }
                                        fieldVM.placeholders.append(placeholder)
                                        break
                                    case MZStageField.type.singlechoice.rawValue :
                                        let placeholder : MZChoicePlaceholderViewModel = MZChoicePlaceholderViewModel(dictionary: placeholderDic as! NSDictionary)
                                        placeholder.multiSelection = false
                                        fieldVM.placeholders.append(placeholder)
                                        break
                                    case MZStageField.type.multichoice.rawValue :
                                        let placeholder : MZChoicePlaceholderViewModel = MZChoicePlaceholderViewModel(dictionary: placeholderDic as! NSDictionary)
                                        placeholder.multiSelection = true
                                        fieldVM.placeholders.append(placeholder)
                                        break
                                    case MZStageField.type.adslist.rawValue :
                                        let placeholder : MZAdsPlaceholderViewModel = MZAdsPlaceholderViewModel(dictionary: placeholderDic as! NSDictionary)
                                        fieldVM.placeholders.append(placeholder)
                                        break
                                    default : break
                                    }
                                }
                            }
                            stageVM.fields.append(fieldVM)
                        }
                        
                        for rangeStyles : MZRangeStyle in stage.rangeStyles
                        {
                            //TODO improve this
                            let rangeStypeVM : MZRangeStyleViewModel = MZRangeStyleViewModel (ranges: rangeStyles.dictionaryRepresentation[MZRangeStyle.key_range] as! [Int])
                            if let bold: Bool = rangeStyles.dictionaryRepresentation[MZRangeStyle.key_bold] as? Bool {
                                rangeStypeVM.bold = bold
                            }
                            if let underline: Bool = rangeStyles.dictionaryRepresentation[MZRangeStyle.key_underline] as? Bool {
                                rangeStypeVM.underline = underline
                            }
                            if let italic: Bool = rangeStyles.dictionaryRepresentation[MZRangeStyle.key_italic] as? Bool {
                                rangeStypeVM.italic = italic
                            }
                            if let fontSizeScale: Float = rangeStyles.dictionaryRepresentation[MZRangeStyle.key_fontSize] as? Float {
                                rangeStypeVM.fontSizeScale = fontSizeScale
                            }
                            stageVM.text.rangeStyles.append(rangeStypeVM)
                        }
                        
                        for contentStyles : MZContentStyle in stage.contentStyles
                        {
                            let contentStypeVM : MZContentStyleViewModel = MZContentStyleViewModel ()
                            if let margin: [Float] = contentStyles.dictionaryRepresentation[MZContentStyle.key_margin] as? [Float] {
                                contentStypeVM.margin = margin
                            }
                            stageVM.text.contentStyles.append(contentStypeVM)
                        }
                        
                        cardVM.stages.append(stageVM)
                    }
                    
                    cardsViewModels.append(cardVM)
                }
                
                return completion(cardsViewModels as AnyObject, nil)
            },
            onError: { (error) -> Void in
                return completion(nil, NSError(domain:Bundle.main.bundleIdentifier!, code:0, userInfo:nil))
        })
    }
    
    func sendHideCard(_ card: MZCardViewModel, hideOption: String, completion: ((_ error : NSError?) -> Void)?)
    {
        let parameters : NSMutableDictionary = [MZCardsWebService.key_cardId: card.cardModel.identifier, MZCardsWebService.key_feedback: hideOption]
		
        MZCardsDataManager.sharedInstance.sendCardFeedback(parameters) { (error) -> Void in
            completion?(error)
        }
    }
    
    func deleteAutomationCards(completion: ((_ error : NSError?) -> Void)?)
    {
        MZCardsDataManager.sharedInstance.deleteAutomationCards() { (error) -> Void in
            completion?(error)
        }
    }
    
    
    func sendNotifyCard(_ card : MZCardViewModel, action : MZActionViewModel)
    {
        if action.notifyOnClick
        {
            let parameters : NSMutableDictionary = [MZCardsWebService.key_cardId : card.cardModel.identifier, KEY_ACTION : action.actionModel]
            MZCardsDataManager.sharedInstance.sendCardNotify(parameters)
        }
    }
    
    
    func sendActionCard(_ card : MZCardViewModel, action : MZActionViewModel, completion : ((_ error : NSError?) -> Void)?)
    {
        let parameters : NSMutableDictionary = [MZCardsWebService.key_cardId : card.cardModel.identifier, KEY_ACTION : action.actionModel]
        
        MZCardsDataManager.sharedInstance.sendCardFeedback(parameters) { (error) -> Void in
            completion?(error)
        }
    }
    
    
    func sendActionCard(_ card : MZCardViewModel, action : MZActionViewModel, stage : MZStageViewModel, completion : ((_ error : NSError?) -> Void)?)
    {
        var fieldsModel : [NSDictionary] = [NSDictionary]()
        for field : MZFieldViewModel in stage.fields
        {
            let dic : NSMutableDictionary = NSMutableDictionary(dictionary: field.fieldModel!.dictionaryRepresentation)
            
            if field.fieldModel!.value != nil && !field.fieldModel!.value!.isEmpty
            {
                let dicts = field.fieldModel!.value! as [NSDictionary]
                
                var filteredDict: [NSDictionary] = []
                for dict in dicts
                {
                    if field.type == MZStageField.type.singlechoice.rawValue || field.type == MZStageField.type.multichoice.rawValue
                    {
                        if let selected: Bool = dict[MZStageField.key_selected] as? Bool {
                            if selected {
                                filteredDict.append(dict)
                            }
                        }
                    } else {
                        filteredDict.append(dict)
                    }
                }
                
                dic.setObject(filteredDict, forKey: MZStageField.key_value as NSCopying)
                dic.removeObject(forKey: MZStageField.key_placeholder)
                fieldsModel.append(dic)
            }
        }
        
        let parameters : NSMutableDictionary = [MZCardsWebService.key_cardId : card.cardModel.identifier,
                                                KEY_ACTION : action.actionModel,
                                                MZCardsWebService.key_fields : fieldsModel]
        
        MZCardsDataManager.sharedInstance.sendCardFeedback(parameters) { (error) -> Void in
            completion?(error)
        }
    }
    
    
	override func getDevicesByArea(_ input:AnyObject?, completion: @escaping (_ result:AnyObject?, _ error:NSError?) -> Void)
    {
        var classes : [AnyObject]? = input as? [AnyObject]
        if classes == nil
        {
            classes = []
        }
        self.getNonGroupedDevicesFilterByClasses(classes!, completion: completion)
    }
    
    
    func getNonGroupedDevicesFilterByClasses(_ filterClasses: [AnyObject], completion: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void)
    {
        self.getAllDevices ({ (results, error) -> Void in
            if error == nil
            {
                if let arrayResults : [AnyObject] = results as? [AnyObject]
                {
                    let resultTiles : [MZArea] = arrayResults[0] as! [MZArea]
                    let resultChannels : [String : MZChannel] = arrayResults[1] as! [String : MZChannel]
                    var areaViewModels = [MZAreaViewModel] ()
                    
                    for area : MZArea in resultTiles
                    {
                        if let areaVM : MZAreaViewModel = self.addDeviceViewModelToArea(area, channels: resultChannels, filterClasses: filterClasses)
                        {
                            areaViewModels.append(areaVM)
                        }
                    }
                    completion(areaViewModels as AnyObject, nil)
                }
            } else {
                completion(nil, error)
            }
        })
    }
    
    
    override func getDeviceViewModel(_ tile:MZTile, channels : [String : MZChannel], areaVM: MZAreaViewModel, filterClasses: [AnyObject]) -> MZDeviceViewModel?
    {
        var deviceVM: MZDeviceViewModel? = nil
        
        if tile.updateWithChannel(channels)
        {
            for filter in filterClasses
            {
                if let componentClass = (filter as! NSDictionary)[MZStageField.key_componentClasses] as? String
                {
                    let filteredComponents = tile.components.filter() {$0.classes.contains(componentClass)}
                    for component in filteredComponents
                    {
                        if let propertyClasses = (filter as! NSDictionary)[MZStageField.key_propertyClasses] as? [String]
                        {
                            if MZBaseInteractor.isArrayContainsAllArray(component.propertiesClasses as [AnyObject], lookFor: propertyClasses) && !filterClasses.isEmpty
                            {
                                deviceVM = MZDeviceViewModel (model: tile as MZTile)
                                break
                            }
                        }
                    }
                    
                    if deviceVM != nil
                    {
                        break
                    }
                }
            }
            deviceVM?.parent = areaVM
        }
        return deviceVM
    }
    
    
    func getComponentsWithFilter(_ device: MZDeviceViewModel, filterClasses: [AnyObject]?) -> [MZComponentViewModel]
    {
        var componentsVM:[MZComponentViewModel] = [MZComponentViewModel]()
        var componentVM:MZComponentViewModel? = nil
        
		for filter in filterClasses!
        {
            if let componentClass = (filter as! NSDictionary)[MZStageField.key_componentClasses] as? String
            {
                let filteredComponents = device.model!.components.filter() {$0.classes.contains(componentClass)}
                for component in filteredComponents
                {
                    if let propertyClasses = (filter as! NSDictionary)[MZStageField.key_propertyClasses] as? [String]
                    {
                        if MZBaseInteractor.isArrayContainsAllArray(component.propertiesClasses as [AnyObject], lookFor: propertyClasses) && !filterClasses!.isEmpty
                        {
                            componentVM = MZComponentViewModel(model: component)
                        }
                    }
                    
                    if componentVM != nil
                    {
                        componentsVM.append(componentVM!)
                        componentVM = nil
                    }
                }
            }
            
        }
        
        return componentsVM
    }
    
    func convertDevicesChoicePlaceholderViewModel (_ devicesPlaceholdersVM: [MZDeviceChoicePlaceholderViewModel]) -> [MZDeviceViewModel]
    {
        var devicesVM: [MZDeviceViewModel] = [MZDeviceViewModel]()
        
        for devicePlaceholderVM: MZDeviceChoicePlaceholderViewModel in devicesPlaceholdersVM
        {
            if let deviceVM = devicePlaceholderVM.convertToDeviceViewModel()
            {
                devicesVM.append(deviceVM)
            }
        }
        
        return devicesVM
    }
    
    func getProductDetails(_ detailUrl: String, completion: @escaping (_ result: MZProduct?, _ error: NSError?) -> Void)
    {
        let latitude: NSNumber? = UserDefaults.standard.value(forKey: "lastLatitude") as? NSNumber
        let longitude: NSNumber? = UserDefaults.standard.value(forKey: "lastLongitude") as? NSNumber
        MZCardsDataManager.sharedInstance.getProductDetail(detailUrl, location: (latitude == nil ? 0.0 : (latitude?.doubleValue)!, longitude == nil ? 0.0 : (longitude?.doubleValue)!)) { (result, error) -> Void in
            completion(result, error)
        }
    }
    
    func setCardViewFeedback(_ cardId: String, storeId: String, completion: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) {
        MZCardsDataManager.sharedInstance.setCardViewFeedback(cardId, storeId: storeId) { (result, error) -> Void in
            completion(result, error)
        }
    }
    
    func setCardClickFeedback(_ cardId: String, storeId: String, completion: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) {
        MZCardsDataManager.sharedInstance.setCardClickFeedback(cardId, storeId: storeId) { (result, error) -> Void in
            completion(result, error)
        }
    }
    
    func pubMQTT(_ topic:String, payload: NSDictionary)
    {
        
        MZMQTTConnection.sharedInstance.publish(topic, jsonDict: payload) { (success, error) in
            if(success)
            {
//                dLog(message: "Publish successful")
            }
            else
            {
//                dLog(message: "Publish error")
            }
        }
    }
}
