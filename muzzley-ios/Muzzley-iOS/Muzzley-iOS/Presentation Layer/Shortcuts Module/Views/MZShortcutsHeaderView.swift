//
//  MZShortcutsHeaderView.swift
//  Muzzley-iOS
//
//  Created by Jorge Mendes on 08/01/16.
//  Copyright © 2016 Muzzley. All rights reserved.
//

import UIKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


@objc protocol MZShortcutsHeaderViewDelegate {
    func shouldAddShortcut(_ interactor: MZShortcutsInteractor)
    func didPressShowMore(_ interactor: MZShortcutsInteractor)
}

class MZShortcutsHeaderView: UIView, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, MZShortcutsDelegate, MZChangeWorkerDelegate
{
    static let height: CGFloat = 164.0
    
    fileprivate var collectionView: UICollectionView!
    fileprivate var moreButton: UIButton!
    fileprivate var shortcutsInteractor: MZShortcutsInteractor!
    
    internal var delegate: MZShortcutsHeaderViewDelegate?
    internal var shortcuts: [MZShortcutViewModel]? {
        didSet {
            if self.collectionView != nil {
                self.collectionView.reloadData()
            }
        }
    }
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        self.shortcutsInteractor = MZShortcutsInteractor()
        self.commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.commonInit()
    }
//    
//    convenience  init(frame: CGRect) {
//        self.init(frame: frame)
//        self.shortcutsInteractor = MZShortcutsInteractor(dataManager: MZShortcutsDataManager.sharedInstance)
//    }
//    
    override func draw(_ rect: CGRect)
    {
        super.draw(rect)
        
        if self.shortcuts != nil
        {
            self.collectionView.reloadData()
        }
        
        var bFrame: CGRect = self.moreButton.frame
        
//        bFrame.origin.x = UIScreen.main.bounds.size.width - 8.0 - self.moreButton.frame.size.width
//        bFrame.origin.y = rect.size.height - 12.0 - self.moreButton.frame.size.height
        
        bFrame.origin.x = UIScreen.main.bounds.size.width - 8.0 - self.moreButton.frame.size.width
        bFrame.origin.y = 12.0
        
        self.moreButton.frame = bFrame
        
        self.addSubview(self.moreButton)
        self.bringSubview(toFront: self.moreButton)
        
        self.collectionView.frame = CGRect(x: 8.0, y: 6 + self.moreButton.frame.size.height, width: UIScreen.main.bounds.size.width - 16.0, height: rect.size.height)
        
        //        self.collectionView.frame = CGRect(x: 8.0, y: 0.0, width: UIScreen.main.bounds.size.width - 16.0, height: rect.size.height)
        self.addSubview(self.collectionView)
    }
    
    
    // MARK: - UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: MZShortcutsCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "MZShortcutsCollectionViewCell", for: indexPath) as! MZShortcutsCollectionViewCell
        
        if self.shortcuts != nil && self.shortcuts?.count > indexPath.row {
            cell.setViewModel(self.shortcuts![indexPath.row], forIndexPath: indexPath)
        }
        
        return cell
    }
    
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 12.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (UIScreen.main.bounds.size.width - 52.0) / 4.0, height: collectionView.bounds.size.height)
    }
    
    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if self.shortcuts != nil && self.shortcuts?.count > indexPath.row {
            if self.shortcuts![indexPath.row].isValid && !self.shortcuts![indexPath.row].isRunning {
                self.shortcuts![indexPath.row].isRunning = true
                (collectionView.cellForItem(at: indexPath) as! MZShortcutsCollectionViewCell).startrunningAnimation()
                var counter: Int = self.shortcuts![indexPath.row].shortcutModel!.executeParams.count
                MZAnalyticsInteractor.shortcutExecuteEvent(self.shortcuts![indexPath.row].shortcutModel!.identifier, fromWhere: MIXPANEL_VALUE_APP, source: self.shortcuts![indexPath.row].origin)
                self.shortcutsInteractor.executeShortcut(self.shortcuts![indexPath.row], completion: { (result, error) -> Void in
                    counter -= 1
                    if counter == 0 {
                        (collectionView.cellForItem(at: indexPath) as! MZShortcutsCollectionViewCell).stopRunningAnimation()
                        self.shortcuts![indexPath.row].isRunning = false
                    }
                })
            }
        } else {
            self.delegate?.shouldAddShortcut(self.shortcutsInteractor)
        }
        collectionView.deselectItem(at: indexPath, animated: true)
    }
    
    
    // MARK: - MZShortcutsDelegate
    
    func updatedShortcuts(_ shortcuts: [MZShortcutViewModel]) {
        self.shortcuts = shortcuts
        self.collectionView.reloadData()
    }
    
    
    // MARK: - MZChangeWorkerDelegate
    
    func didChangeWorker() {
        self.shortcutsInteractor.getShortcuts { (result, error) -> Void in
            self.shortcuts = result as? [MZShortcutViewModel]
            self.collectionView.reloadData()
        }
    }

    
    // MARK: - Private stuff
    
    fileprivate func commonInit() {
        self.backgroundColor = UIColor.clear
        if self.collectionView == nil {
            self.collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout())
            self.collectionView.dataSource = self
            self.collectionView.delegate = self
            self.collectionView.allowsSelection = true
            self.collectionView.allowsMultipleSelection = true
            self.collectionView.bounces = false
            self.collectionView.isScrollEnabled = false
            self.collectionView.backgroundColor = UIColor.clear
            self.collectionView.register(UINib(nibName: "MZShortcutsCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "MZShortcutsCollectionViewCell")
        }
        
        if self.moreButton == nil {
            self.moreButton = UIButton()
            self.moreButton.setAttributedTitle(NSAttributedString(string: NSLocalizedString("mobile_show_more", comment: ""), attributes: [NSFontAttributeName: UIFont.regularFontOfSize(14), NSForegroundColorAttributeName: UIColor.muzzleyBlueColor(withAlpha: 1.0)]), for: UIControlState())
            self.moreButton.sizeToFit()
            self.moreButton.addTarget(self, action: #selector(MZShortcutsHeaderView.showMoreAction(_:)), for: .touchUpInside)
        }
    }
    
    @IBAction func showMoreAction(_ sender: AnyObject) {
        self.delegate?.didPressShowMore(self.shortcutsInteractor)
    }

}
