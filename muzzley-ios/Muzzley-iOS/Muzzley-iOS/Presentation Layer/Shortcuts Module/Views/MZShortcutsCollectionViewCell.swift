//
//  MZShortcutsCollectionViewCell.swift
//  Muzzley-iOS
//
//  Created by Jorge Mendes on 08/01/16.
//  Copyright © 2016 Muzzley. All rights reserved.
//

import UIKit

class MZShortcutsCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var roundCircle: UIView!
    @IBOutlet weak var circleIcon: UIImageView!
    @IBOutlet weak var watchIcon: UIImageView!
    @IBOutlet weak var shortcutName: UILabel!
    @IBOutlet weak var circleIconHeightContraint: NSLayoutConstraint!
    @IBOutlet weak var circleIconVerticalConstraint: NSLayoutConstraint!
    
    fileprivate var runningLayer: UIImageView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.roundCircle.layer.cornerRadius = self.roundCircle.bounds.size.height / 2.0
        self.roundCircle.layer.borderWidth = 2.0
        self.roundCircle.layer.borderColor = UIColor.muzzleyGray4Color(withAlpha: 1.0).cgColor
        self.roundCircle.layer.shadowColor = UIColor.muzzleyGray2Color(withAlpha: 1.0).cgColor
        self.roundCircle.layer.shadowRadius = 0.0
        self.roundCircle.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        self.roundCircle.layer.shadowOpacity = 0.4
        self.roundCircle.backgroundColor = UIColor.muzzleyWhiteColor(withAlpha: 1.0)
        
        self.circleIcon.image = UIImage(named: "iconPlus")
        self.watchIcon.isHidden = true
        self.shortcutName.text = NSLocalizedString("mobile_shortcut_new", comment: "")
        self.shortcutName.font = UIFont.regularFontOfSize(12)
        self.shortcutName.textColor = UIColor.muzzleyBlackColor(withAlpha: 1.0)
        
        self.stopRunningAnimation()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.circleIconHeightContraint.constant = 28.0
        self.circleIconVerticalConstraint.constant = 0.0
        
        self.roundCircle.backgroundColor = UIColor.muzzleyWhiteColor(withAlpha: 1.0)
        self.roundCircle.layer.borderColor = UIColor.muzzleyGray4Color(withAlpha: 1.0).cgColor
        self.roundCircle.layer.borderWidth = 2.0
        self.roundCircle.layer.shadowRadius = 0.0
        self.circleIcon.image = UIImage(named: "iconPlus")
        self.watchIcon.isHidden = true
        self.shortcutName.text = NSLocalizedString("mobile_shortcut_new", comment: "")
        self.shortcutName.textColor = UIColor.muzzleyBlackColor(withAlpha: 1.0)
        self.stopRunningAnimation()
    }
    
    internal func setViewModel(_ model: MZShortcutViewModel, forIndexPath indexPath: IndexPath) {
        self.circleIconHeightContraint.constant = model.isValid ? 28.0 : 22.0
        self.circleIconVerticalConstraint.constant = model.isValid ? 0.0 : -2.0
        
        self.roundCircle.layer.borderWidth = model.isValid ? 0.0 : 2.0
        self.roundCircle.layer.borderColor = model.isValid ? UIColor.clear.cgColor : UIColor.muzzleyDarkBlueColor(withAlpha: 1.0).cgColor
        self.roundCircle.layer.shadowRadius = 4.0 / UIScreen.main.scale
        self.roundCircle.backgroundColor = model.isValid ? model.color : UIColor.muzzleyWhiteColor(withAlpha: 1.0)

        self.watchIcon.isHidden = model.isValid ? !model.shortcutModel!.showInWatch : true
        self.shortcutName.text = model.label
        self.shortcutName.textColor = model.isValid ? UIColor.muzzleyBlackColor(withAlpha: 1.0) : UIColor.muzzleyRedColor(withAlpha: 1.0)
        self.circleIcon.image = UIImage(named: model.isValid ? "iconArrow" : "invalidShortcut")
		
    }
    
    internal func startrunningAnimation() {
        self.stopRunningAnimation()
        
        var frame: CGRect = self.roundCircle.frame
        frame.origin.x = -2.0
        frame.origin.y = -2.0
        frame.size.width += 4.0
        frame.size.height += 4.0
        self.runningLayer = UIImageView()
        self.runningLayer?.frame = frame
        self.runningLayer?.image = UIImage(named: "spinner")
        
        let rotation: CABasicAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotation.toValue = 2.0 * CGFloat(M_PI)
        rotation.duration = 1.0
        rotation.isCumulative = true
        rotation.repeatCount = HUGE
        self.runningLayer?.layer.add(rotation, forKey: "rotationAnimation")
        self.roundCircle.addSubview(self.runningLayer!)
    }
    
    internal func stopRunningAnimation() {
        self.runningLayer?.layer.removeAllAnimations()
        self.runningLayer?.removeFromSuperview()
    }
    
    fileprivate func getColorForPath(_ indexPath: IndexPath) -> UIColor {
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0: return UIColor.muzzleyDarkBlueColor(withAlpha: 1.0)
            case 1: return UIColor.muzzleyShortOrangeColor(withAlpha: 1.0)
            case 2: return UIColor.muzzleyLightBlueColor(withAlpha: 1.0)
            case 3: return UIColor.muzzleyLightGreenColor(withAlpha: 1.0)
            case 4: return UIColor.muzzleyDarkPinkColor(withAlpha: 1.0)
            case 5: return UIColor.muzzleyShortGreyColor(withAlpha: 1.0)
                
            default: return UIColor.muzzleyWhiteColor(withAlpha: 1.0)
            }
        case 1: return UIColor.muzzleyRedColor(withAlpha: 1.0)
            
        default: return UIColor.muzzleyWhiteColor(withAlpha: 1.0)
        }
    }

}
