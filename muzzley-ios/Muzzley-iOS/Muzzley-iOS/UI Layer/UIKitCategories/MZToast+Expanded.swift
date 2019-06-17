//
//  MZToast+Expanded.swift
//  Muzzley-iOS
//
//  Created by Jorge Mendes on 06/01/16.
//  Copyright © 2016 Muzzley. All rights reserved.
//

import UIKit

extension MZToast {
    
    class func showNoInternetConnectionToastOnScrollview(_ scrollview: UIScrollView) -> MZToast
    {
        let toast: MZToast = MZToast(withState: .warning)
        toast.toastColor = UIColor.muzzleyBlueColor(withAlpha: 0.8)
        toast.message = NSLocalizedString("mobile_no_internet_text", comment: "")
        toast.showAboveScrollView(scrollview)
        
        return toast
    }
    
    
    class func showPullToRefreshToastOnScrollview(_ scrollview: UIScrollView) -> MZToast
    {
        let toast: MZToast = MZToast(withState: .warning)
        toast.toastColor = UIColor.muzzleyBlueColor(withAlpha: 1.0)
        toast.message = NSLocalizedString("mobile_card_new", comment: "")
        toast.messageFont = UIFont.regularFontOfSize(16)
        toast.messageAlign = .center
        toast.hasImage = false
        toast.hasTimer = false
        toast.height = 50
        toast.showAboveScrollView(scrollview)
        
        return toast
    }


}
