//
//  MZCardViewModel.swift
//  Muzzley-iOS
//
//  Created by Carlotta Tatti on 24/11/15.
//  Copyright © 2015 Muzzley. All rights reserved.
//

class MZCardViewModel: NSObject {
    @objc enum CardState: Int {
        case none = 0, loading, error, success
    }
    
    var identifier: String = ""
    var state: CardState = CardState.none
    
    var title : String?
    var timestamp : String?
    var type: String = ""
    
    var stages: Array<MZStageViewModel> = Array()
    var feedback: Array<String>         = Array()

    var unfoldedStagesIndex: Int        = 0
    
    var defaultColorMainBackground = UIColor.muzzleyWhiteColor(withAlpha: 1.0)
    
    var colorMainBackground : UIColor?
    var colorMainTitle : UIColor?
    var colorMainText : UIColor?
    var colorActionBarBackground : UIColor?
    var colorActionBarText : UIColor?
    var colorBtnHideOptions : UIColor = UIColor.muzzleyGrayColor(withAlpha: 1.0)
    
    var viewed : Bool = false
    
    var cardModel : MZCard
    
    init(model : MZCard)
    {
        self.identifier = model.identifier
        self.cardModel = model
        self.feedback = model.feedback
        self.title = model.title
        self.type = model.type
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss.SSSZ"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC") as! TimeZone
        
        let iso8601Date = dateFormatter.date(from: model.updatedTS)
		
        
        if iso8601Date != nil
        {
            dateFormatter.timeZone = TimeZone.current
            dateFormatter.dateStyle = .long
            let dateString = dateFormatter.string(from: iso8601Date!)

            var timestampString = String(format: "%1$@, %2$@", dateString, TimeFormatHelper.formatTime(MZSessionDataManager.sharedInstance.session.userProfile.preferences.hourFormat, date: iso8601Date!))

            self.timestamp = timestampString
        }
        
        self.unfoldedStagesIndex = 0
        
        self.colorMainBackground = model.colorMainBackground
        self.colorMainTitle = model.colorMainTitle
        self.colorMainText = model.colorMainText
        self.colorActionBarBackground = model.colorActionBarBackground
        self.colorActionBarText = model.colorActionBarText
        if self.colorMainBackground != defaultColorMainBackground
        {
            self.colorBtnHideOptions = self.colorMainText!
        }
    }

}
