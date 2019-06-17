//
//  MZUIColorExtensions.swift
//  Muzzley-iOS
//
//  Created by Ana Figueira on 08/10/2018.
//  Copyright © 2018 Muzzley. All rights reserved.
//

extension UIColor {
    static var random: UIColor {
        return UIColor(red: .random(in: 0...1),
                       green: .random(in: 0...1),
                       blue: .random(in: 0...1),
                       alpha: 1.0)
    }
}

