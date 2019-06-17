//
//  MZUIImageView.swift
//  Muzzley-iOS
//
//  Created by Carlotta Tatti on 11/11/15.
//  Copyright © 2015 Muzzley. All rights reserved.
//

import UIKit

class MZUIImageView: UIImageView {
    
}

extension UIImageView {
    func downloadedFrom(_ link:String, contentMode mode: UIViewContentMode) {
        guard
            let url = URL(string: link)
            else {return}
        contentMode = mode
        URLSession.shared.dataTask(with: url, completionHandler: { (data, _, error) -> Void in
            guard
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async { () -> Void in
                self.image = image
            }
        }).resume()
    }
}
