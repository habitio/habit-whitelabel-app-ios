//
//  MZUIImageExtensions.swift
//  Muzzley-iOS
//
//  Created by Ana Figueira on 28/11/2018.
//  Copyright © 2018 Muzzley. All rights reserved.
//

extension UIImage {
    static var appIcon: UIImage? {
        guard let iconsDictionary = Bundle.main.infoDictionary?["CFBundleIcons"] as? [String:Any],
            let primaryIconsDictionary = iconsDictionary["CFBundlePrimaryIcon"] as? [String:Any],
            let iconFiles = primaryIconsDictionary["CFBundleIconFiles"] as? [String],
            let lastIcon = iconFiles.last else { return nil }
        return UIImage(named: lastIcon)
    }
}
