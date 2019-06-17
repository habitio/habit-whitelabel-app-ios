//
//  MZPopup.swift
//  Muzzley-iOS
//
//  Created by Carlotta Tatti on 07/01/16.
//  Copyright © 2016 Muzzley. All rights reserved.
//

import UIKit

@objc protocol PopupContentViewDelegate : NSObjectProtocol {
    func didTapOnPopupButtonAtIndex(_ sender: PopupContentView,btnIndex: Int)
}

@objc class PopupContentView: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var btnCollectionView: UICollectionView!

    var delegate: PopupContentViewDelegate!
    var identifier: Int = 0

    var hasImage: Bool = false {
        didSet {
            self.imageView.isHidden = !self.hasImage
        }
    }
    
    var message: String = "" {
        didSet {
            self.messageLabel.text = self.message
        }
    }
    
    var imageUrl: URL? = URL(string: "") {
        didSet {
            self.imageView.setImageWith(self.imageUrl!)
        }
    }
    
    var image: UIImage = UIImage() {
        didSet {
            self.imageView.image = self.image
        }
    }
    
    var topColor: UIColor = UIColor.white {
        didSet {
            self.containerView.backgroundColor = self.topColor
        }
    }
    
    var bottomColor: UIColor = UIColor.white {
        didSet {
            self.backgroundColor = self.bottomColor
        }
    }
    
    var textColor: UIColor = UIColor.white {
        didSet {
            self.messageLabel.textColor = self.textColor
        }
    }
    
    var btnStrings: NSArray = NSArray() {
        didSet {
            self.btnCollectionView.reloadData()
        }
    }
    
    internal var cornerRadius: CGFloat = 4.0 {
        didSet {
            self.containerView.layer.cornerRadius = self.cornerRadius
            self.setNeedsDisplay()
            self.setNeedsLayout()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        self.imageView.layer.cornerRadius = self.imageView.frame.size.width / 2
        self.imageView.contentMode = UIViewContentMode.scaleAspectFill
        self.imageView.clipsToBounds = true;
        
        self.layer.cornerRadius = 4
        self.layer.masksToBounds = true
        
        self.btnCollectionView.register(UINib(nibName: "PopupButton", bundle: nil), forCellWithReuseIdentifier: "PopupButton")
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.btnStrings.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PopupButton", for: indexPath) as! PopupButton
        
        let btnString = self.btnStrings[indexPath.item] as! String
        
        cell.btnLabel!.text = btnString
        cell.btnLabel!.font = UIFont.lightFontOfSize(17)
        cell.btnLabel!.textColor = UIColor.muzzleyBlueColor(withAlpha: 1.0)

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let size = CGSize(width: self.frame.size.width / CGFloat(self.btnStrings.count), height: self.frame.size.height)
        
        return size
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.delegate.didTapOnPopupButtonAtIndex(self, btnIndex: indexPath.item)
        self.dismissPresentingPopup()
    }
    
    static func loadFromNib() -> PopupContentView {
        let nibName = "\(self)".characters.split{$0 == "."}.map(String.init).last!
        let nib = UINib(nibName: nibName, bundle: nil)
        return nib.instantiate(withOwner: self, options: nil).first as! PopupContentView
    }
}
