//
//  MZCardDevicesPicker.swift
//  Muzzley-iOS
//
//  Created by Carlotta Tatti on 20/11/15.
//  Copyright © 2015 Muzzley. All rights reserved.
//

import UIKit
import TagListView

@objc protocol MZCardDevicesPickerDelegate: NSObjectProtocol {
    func addDeviceTapped(_ fieldVM: MZFieldViewModel, card: MZCardViewModel)
    func removeDeviceTapped(_ indexPath:IndexPath?)
}

class MZCardDevicesPicker: UIViewController, TagListViewDelegate
{
    @IBOutlet weak var tagListView: TagListView?
    
    var delegate: MZCardDevicesPickerDelegate?
    
    fileprivate var usedDeviceIdentifiers: [String] = []
    var value : NSObject?
    var card: MZCardViewModel?
    var field: MZFieldViewModel?
    
    func tagPressed(_ title: String, tagView: TagView, sender: TagListView)
    {
        if (title != ("+ " + NSLocalizedString("mobile_device_add", comment: "")))
        {
            if var devicesPlaceholder = self.value! as? [MZDeviceChoicePlaceholderViewModel]
            {
                for devicePH in devicesPlaceholder
                {
                    if devicePH.deviceId == self.usedDeviceIdentifiers[tagView.tag]
                    {
                        let objIndexToRemove = devicesPlaceholder.index(of: devicePH)
                        devicesPlaceholder.remove(at: objIndexToRemove!)
                    }
                }
                self.tagListView!.removeTagView(tagView)
                self.value! = devicesPlaceholder as NSObject
                self.field!.setValue(self.value!)
            }
        }
        else
        {
            self.delegate?.addDeviceTapped(self.field!, card:self.card!)
        }
    }
    
    func setViewModel(_ cardViewModel: MZCardViewModel, fieldViewModel: MZFieldViewModel)
    {
        self.card = cardViewModel
        self.field = fieldViewModel
    }
    
    
    override func viewDidLoad() {
        let theValue = self.field?.getValue()
        if let devicesChoicePH : [MZDeviceChoicePlaceholderViewModel] = theValue as? [MZDeviceChoicePlaceholderViewModel] {
            self.value = devicesChoicePH as NSObject
        } else {
            self.value = field!.placeholders as? [MZDeviceChoicePlaceholderViewModel] as! NSObject
        }
        self.field?.setValue(self.value!)
        
        self.setTags()
    }
    
    func setTags()
    {
        self.tagListView!.removeAllTags()
        self.usedDeviceIdentifiers = []
        
        if (self.value != nil) {
            var i = 0
            
            for devicePH in self.value! as! [MZDeviceChoicePlaceholderViewModel]
            {
                if (!self.usedDeviceIdentifiers.contains(devicePH.deviceId))
                {
                    let tagView = self.tagListView!.addTag(devicePH.deviceTitle + " x ")
//                    tagView.textFont = font
                    tagView.cornerRadius = tagView.frame.size.height / 2
                    tagView.tagBackgroundColor = UIColor.muzzleyBlueColor(withAlpha: 1.0)
                    
                    tagView.tag = i
                    
                    self.usedDeviceIdentifiers.append(devicePH.deviceId)
                    
                    i += 1
                }
            }
        }
        
        let tagView = self.tagListView!.addTag("+ " + NSLocalizedString("mobile_device_add", comment: ""))
//        tagView.textFont = font
        tagView.cornerRadius = tagView.frame.size.height / 2
        tagView.tagBackgroundColor = UIColor.muzzleyWhiteColor(withAlpha: 1.0)
        tagView.borderColor = UIColor.muzzleyBlueColor(withAlpha: 1.0)
        tagView.layer.borderWidth = 1
        tagView.textColor = UIColor.muzzleyBlueColor(withAlpha: 1.0)
        
        let font = UIFont.lightFontOfSize(14)

        self.tagListView?.delegate = self
        self.tagListView?.textFont = font
        
        
        var cellFrame = self.view.frame
        cellFrame.size.height = self.tagListView!.intrinsicContentSize.height + self.tagListView!.frame.origin.y + 8
        self.view.frame = cellFrame

    }
}
