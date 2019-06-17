//
//  MZAdsPlaceholderViewModel.swift
//  Muzzley-iOS
//
//  Created by Cristina Lopes on 16/03/16.
//  Copyright © 2016 Muzzley. All rights reserved.
//

class MZAdsPlaceholderViewModel: NSObject
{
   // static let key_id           = "id"
    static let key_label        = "label"
    static let key_image        = "image"
    static let key_priceRange   = "priceRange"
    static let key_detailUrl    = "detailUrl"
    static let key_highlighted  = "highlighted"

  //  var identifier : String     = ""
    var label : String          = ""
    var image : NSURL?          = nil
    var priceRange : String     = ""
    var detailUrl : String      = ""
    var highlighted : Bool      = false

    init(dictionary : NSDictionary)
    {
      /*  if let identifier: String = dictionary[MZStageField.key_id] as? String {
            self.identifier = identifier
        }*/
        if let label: String = dictionary[MZStageField.key_label] as? String {
            self.label = label
        }
        if let imageUrl: String = dictionary[MZStageField.key_image] as? String {
            self.image = NSURL(string: imageUrl)
        }
        if let priceRange: String = dictionary[MZStageField.key_priceRange] as? String {
            self.priceRange = priceRange
        }
        if let detailUrl: String = dictionary[MZStageField.key_detailUrl] as? String {
            self.detailUrl = detailUrl
        }
        if let highlighted: Bool = dictionary[MZStageField.key_highlighted] as? Bool {
            self.highlighted = highlighted
        }
    }
}
